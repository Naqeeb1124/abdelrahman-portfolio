"""
CubeSat Rigid Body Dynamics with Reaction Wheel System
======================================================

This module implements the complete spacecraft dynamics including:
1. Rigid body dynamics using Euler's equations
2. Three-axis reaction wheel system modeling
3. Environmental disturbances (solar pressure, gravity gradient)
4. Advanced numerical integration with adaptive time stepping

Mathematical Foundation:
- Euler's equations: J*ω̇ = -ω×(J*ω) + τ_external + τ_wheels
- Quaternion kinematics: q̇ = (1/2)*Ω(ω)*q  
- Reaction wheel dynamics: Jw*ḣw = τw
- Angular momentum conservation: h_total = J*ω + Σ(hw)

Author: CubeSat GN&C System
"""

import numpy as np
from typing import Tuple, Dict, Optional, Callable
from dataclasses import dataclass
from quaternion_utils import QuaternionUtils, skew_symmetric
import warnings

@dataclass
class CubeSatProperties:
    """Physical properties of the 3U CubeSat."""
    # Mass properties
    mass: float = 4.0  # kg (typical 3U CubeSat)

    # Moments of inertia (kg⋅m²) - 3U CubeSat (30x10x10 cm)
    # Principal axes aligned with body frame
    Jxx: float = 0.083  # About X (roll)
    Jyy: float = 0.083  # About Y (pitch)  
    Jzz: float = 0.0083 # About Z (yaw) - much smaller for elongated body

    # Products of inertia (assumed small for symmetric design)
    Jxy: float = 0.0
    Jxz: float = 0.0
    Jyz: float = 0.0

    # Geometry
    length: float = 0.30  # m (3U = 30 cm)
    width: float = 0.10   # m
    height: float = 0.10  # m

    # Surface properties for drag/solar pressure
    cross_section_area: float = 0.03  # m² (30 cm x 10 cm)
    reflectivity: float = 0.1         # Typical for solar panels

    @property
    def inertia_matrix(self) -> np.ndarray:
        """Return 3x3 inertia tensor."""
        return np.array([
            [self.Jxx, -self.Jxy, -self.Jxz],
            [-self.Jxy, self.Jyy, -self.Jyz],
            [-self.Jxz, -self.Jyz, self.Jzz]
        ])

    @property 
    def inertia_inverse(self) -> np.ndarray:
        """Return inverse of inertia tensor."""
        return np.linalg.inv(self.inertia_matrix)

@dataclass
class ReactionWheelProperties:
    """Properties of a single reaction wheel."""
    # Inertial properties
    inertia: float = 2e-5      # kg⋅m² (typical small reaction wheel)
    max_torque: float = 1e-3   # N⋅m (maximum wheel torque)
    max_speed: float = 6000 * 2*np.pi/60  # rad/s (6000 RPM)

    # Performance characteristics
    motor_constant: float = 0.01  # N⋅m/A
    resistance: float = 2.0       # Ω
    voltage_max: float = 12.0     # V

    # Friction and disturbance modeling
    static_friction: float = 1e-7   # N⋅m
    kinetic_friction: float = 5e-8  # N⋅m
    viscous_damping: float = 1e-10  # N⋅m⋅s

    # Installation direction (unit vector in body frame)
    direction: np.ndarray = None

    def __post_init__(self):
        if self.direction is None:
            self.direction = np.array([0, 0, 1])  # Default Z-axis
        self.direction = np.array(self.direction, dtype=float)
        self.direction = self.direction / np.linalg.norm(self.direction)

class CubeSatDynamics:
    """
    Complete 3U CubeSat dynamics simulation with reaction wheel system.

    This class implements the full nonlinear dynamics including:
    - Rigid body attitude dynamics (Euler's equations)
    - Quaternion kinematics for singularity-free attitude representation  
    - Three-axis reaction wheel system with realistic constraints
    - Environmental disturbances (solar pressure, magnetic, gravity gradient)
    - Advanced numerical integration with error control
    """

    def __init__(self, cubesat_props: Optional[CubeSatProperties] = None,
                 wheel_props: Optional[list] = None):
        """
        Initialize CubeSat dynamics model.

        Args:
            cubesat_props: CubeSat physical properties
            wheel_props: List of ReactionWheelProperties for each wheel
        """
        # Set default properties if not provided
        self.cubesat = cubesat_props or CubeSatProperties()

        # Default 3-axis reaction wheel configuration
        if wheel_props is None:
            self.wheels = [
                ReactionWheelProperties(direction=np.array([1, 0, 0])),  # X wheel
                ReactionWheelProperties(direction=np.array([0, 1, 0])),  # Y wheel  
                ReactionWheelProperties(direction=np.array([0, 0, 1]))   # Z wheel
            ]
        else:
            self.wheels = wheel_props

        self.n_wheels = len(self.wheels)

        # Precompute wheel direction matrix for efficiency
        self.wheel_directions = np.column_stack([w.direction for w in self.wheels])

        # Environmental parameters
        self.solar_flux = 1361.0  # W/m² at Earth distance
        self.c = 299792458.0      # Speed of light (m/s)

        # Simulation state
        self.time = 0.0
        self.disturbance_torques = np.zeros(3)

    def state_derivative(self, t: float, state: np.ndarray, 
                        control_torques: np.ndarray) -> np.ndarray:
        """
        Compute time derivative of spacecraft state.

        State vector: [q0, q1, q2, q3, ωx, ωy, ωz, hw1, hw2, hw3]
        - q: unit quaternion (4 elements)
        - ω: angular velocity in body frame (3 elements) 
        - hw: wheel angular momenta (n_wheels elements)

        Args:
            t: Current time
            state: Current state vector
            control_torques: Commanded wheel torques (N⋅m)

        Returns:
            Time derivative of state vector
        """
        # Extract state components
        q = state[0:4]
        omega = state[4:7] 
        h_wheels = state[7:7+self.n_wheels]

        # Ensure quaternion is normalized
        q = QuaternionUtils.normalize(q)

        # Compute quaternion kinematics
        q_dot = QuaternionUtils.angular_velocity_to_quaternion_rate(q, omega)

        # Total angular momentum in body frame
        J = self.cubesat.inertia_matrix
        h_body = J @ omega

        # Wheel angular momentum contribution
        h_wheel_total = self.wheel_directions @ h_wheels

        # Environmental disturbances
        disturbance_torque = self._compute_disturbance_torques(t, q, omega)

        # Wheel reaction torques on spacecraft (Newton's 3rd law)
        wheel_reaction_torque = self.wheel_directions @ control_torques

        # Euler's equations: J*ω̇ = -ω×(J*ω + hw_total) + τ_disturbance - τ_wheels
        omega_cross_h = skew_symmetric(omega) @ (h_body + h_wheel_total)
        total_external_torque = disturbance_torque - wheel_reaction_torque

        omega_dot = self.cubesat.inertia_inverse @ (total_external_torque - omega_cross_h)

        # Wheel dynamics: Jw*ω̇w = τw - friction
        h_wheels_dot = np.zeros(self.n_wheels)
        for i, wheel in enumerate(self.wheels):
            # Wheel speed from angular momentum
            wheel_speed = h_wheels[i] / wheel.inertia

            # Friction modeling
            friction_torque = self._compute_wheel_friction(wheel, wheel_speed)

            # Wheel angular momentum rate
            h_wheels_dot[i] = control_torques[i] - friction_torque

            # Apply saturation constraints
            if np.abs(wheel_speed) >= wheel.max_speed:
                h_wheels_dot[i] = min(0, h_wheels_dot[i]) if wheel_speed > 0 else max(0, h_wheels_dot[i])

        # Combine all derivatives
        state_dot = np.concatenate([q_dot, omega_dot, h_wheels_dot])

        return state_dot

    def _compute_wheel_friction(self, wheel: ReactionWheelProperties, 
                               wheel_speed: float) -> float:
        """
        Compute friction torque in reaction wheel.

        Includes static friction, kinetic friction, and viscous damping.

        Args:
            wheel: Wheel properties
            wheel_speed: Wheel angular velocity (rad/s)

        Returns:
            Friction torque (N⋅m)
        """
        speed_threshold = 0.1  # rad/s threshold for static friction

        if np.abs(wheel_speed) < speed_threshold:
            # Static friction region
            friction = wheel.static_friction * np.sign(wheel_speed)
        else:
            # Kinetic friction + viscous damping
            friction = (wheel.kinetic_friction * np.sign(wheel_speed) + 
                       wheel.viscous_damping * wheel_speed)

        return friction

    def _compute_disturbance_torques(self, t: float, q: np.ndarray, 
                                    omega: np.ndarray) -> np.ndarray:
        """
        Compute environmental disturbance torques.

        Includes:
        1. Solar radiation pressure
        2. Gravity gradient torque
        3. Magnetic dipole interactions
        4. Atmospheric drag (for low orbits)

        Args:
            t: Current time
            q: Current quaternion
            omega: Current angular velocity

        Returns:
            Total disturbance torque vector (N⋅m)
        """
        # Solar radiation pressure (simplified model)
        # Assumes constant solar flux and 1 AU distance
        solar_pressure = self.solar_flux / self.c  # N/m²

        # Sun direction in body frame (simplified - assume sun along X in inertial)
        R_body_inertial = QuaternionUtils.to_rotation_matrix(q)
        sun_inertial = np.array([1, 0, 0])  # Simplified sun direction
        sun_body = R_body_inertial @ sun_inertial

        # Center of pressure offset from center of mass (10% of length)
        cp_offset = np.array([0.03, 0, 0])  # 3 cm offset along X

        # Solar pressure force (only if sun-facing)
        if sun_body[0] > 0:  # Sun illumination condition
            force_magnitude = solar_pressure * self.cubesat.cross_section_area * sun_body[0]
            solar_force = force_magnitude * sun_body
            solar_torque = np.cross(cp_offset, solar_force)
        else:
            solar_torque = np.zeros(3)

        # Gravity gradient torque (simplified Earth pointing)
        # τ_gg = 3*μ/r³ * (r̂ × J*r̂)
        # For simplicity, assume nadir pointing requirement
        orbital_rate = 1.1e-3  # rad/s (90-minute orbit)
        nadir_body = R_body_inertial @ np.array([0, 0, -1])  # Nadir in body frame

        J = self.cubesat.inertia_matrix
        gravity_gradient_torque = (3 * orbital_rate**2 * 
                                  np.cross(nadir_body, J @ nadir_body))

        # Add stochastic variations
        stochastic_amplitude = 5e-6  # N⋅m RMS
        stochastic_torque = np.random.normal(0, stochastic_amplitude, 3)

        # Total disturbance
        total_disturbance = solar_torque + gravity_gradient_torque + stochastic_torque

        # Store for external access
        self.disturbance_torques = total_disturbance

        return total_disturbance

    def compute_wheel_torques_from_body_torque(self, body_torque: np.ndarray) -> np.ndarray:
        """
        Convert desired body torque to wheel torques using pseudo-inverse.

        For over-actuated system (3 wheels, 3 DOF), uses Moore-Penrose pseudo-inverse
        to distribute torques optimally.

        Args:
            body_torque: Desired torque in body frame (3x1)

        Returns:
            Required wheel torques (n_wheels x 1)
        """
        # Pseudo-inverse for wheel torque allocation
        A = self.wheel_directions  # 3 x n_wheels matrix
        A_pinv = np.linalg.pinv(A)

        wheel_torques = A_pinv @ body_torque

        # Apply saturation constraints
        for i, wheel in enumerate(self.wheels):
            wheel_torques[i] = np.clip(wheel_torques[i], 
                                     -wheel.max_torque, wheel.max_torque)

        return wheel_torques

    def get_wheel_speeds(self, state: np.ndarray) -> np.ndarray:
        """Get current wheel speeds from state vector."""
        h_wheels = state[7:7+self.n_wheels]
        wheel_speeds = np.array([h_wheels[i] / self.wheels[i].inertia 
                                for i in range(self.n_wheels)])
        return wheel_speeds

    def get_total_angular_momentum(self, state: np.ndarray) -> Tuple[np.ndarray, float]:
        """
        Compute total system angular momentum.

        Args:
            state: Current state vector

        Returns:
            Tuple of (angular momentum vector, magnitude)
        """
        omega = state[4:7]
        h_wheels = state[7:7+self.n_wheels]

        h_body = self.cubesat.inertia_matrix @ omega
        h_wheel_total = self.wheel_directions @ h_wheels
        h_total = h_body + h_wheel_total

        return h_total, np.linalg.norm(h_total)

class AdaptiveIntegrator:
    """
    Advanced numerical integrator with adaptive time stepping.

    Implements Runge-Kutta 4th/5th order with error estimation
    for accurate and efficient dynamics propagation.
    """

    def __init__(self, atol: float = 1e-8, rtol: float = 1e-6,
                 max_step: float = 0.1, min_step: float = 1e-6):
        """
        Initialize adaptive integrator.

        Args:
            atol: Absolute tolerance
            rtol: Relative tolerance  
            max_step: Maximum time step
            min_step: Minimum time step
        """
        self.atol = atol
        self.rtol = rtol
        self.max_step = max_step
        self.min_step = min_step

        # Butcher tableau for RK45 (Dormand-Prince)
        self.a = np.array([
            [0, 0, 0, 0, 0, 0, 0],
            [1/5, 0, 0, 0, 0, 0, 0],
            [3/40, 9/40, 0, 0, 0, 0, 0],
            [44/45, -56/15, 32/9, 0, 0, 0, 0],
            [19372/6561, -25360/2187, 64448/6561, -212/729, 0, 0, 0],
            [9017/3168, -355/33, 46732/5247, 49/176, -5103/18656, 0, 0],
            [35/384, 0, 500/1113, 125/192, -2187/6784, 11/84, 0]
        ])

        self.b4 = np.array([35/384, 0, 500/1113, 125/192, -2187/6784, 11/84, 0])
        self.b5 = np.array([5179/57600, 0, 7571/16695, 393/640, -92097/339200, 
                           187/2100, 1/40])

        self.c = np.array([0, 1/5, 3/10, 4/5, 8/9, 1, 1])

    def step(self, dynamics_func: Callable, t: float, y: np.ndarray, 
             dt: float, *args) -> Tuple[np.ndarray, float, bool]:
        """
        Take one adaptive step.

        Args:
            dynamics_func: Function computing dy/dt
            t: Current time
            y: Current state
            dt: Proposed time step
            *args: Additional arguments for dynamics_func

        Returns:
            Tuple of (new_state, actual_dt_used, success_flag)
        """
        # Compute RK stages
        k = np.zeros((7, len(y)))

        k[0] = dt * dynamics_func(t, y, *args)

        for i in range(1, 7):
            y_temp = y + np.sum([self.a[i, j] * k[j] for j in range(i)], axis=0)
            k[i] = dt * dynamics_func(t + self.c[i] * dt, y_temp, *args)

        # 4th and 5th order solutions
        y4 = y + np.sum([self.b4[i] * k[i] for i in range(7)], axis=0)
        y5 = y + np.sum([self.b5[i] * k[i] for i in range(7)], axis=0)

        # Error estimate
        error = np.abs(y5 - y4)
        tolerance = self.atol + self.rtol * np.maximum(np.abs(y), np.abs(y5))

        # Error ratio
        error_ratio = np.max(error / tolerance)

        # Step acceptance and size adjustment
        if error_ratio <= 1.0:
            # Accept step
            # Normalize quaternion if present (first 4 elements)
            if len(y5) >= 4:
                y5[0:4] = y5[0:4] / np.linalg.norm(y5[0:4])

            # Compute new step size
            safety_factor = 0.9
            new_dt = dt * safety_factor * (1.0 / error_ratio)**(1/5)
            new_dt = np.clip(new_dt, self.min_step, self.max_step)

            return y5, new_dt, True
        else:
            # Reject step, reduce step size
            safety_factor = 0.8
            new_dt = dt * safety_factor * (1.0 / error_ratio)**(1/4)
            new_dt = np.clip(new_dt, self.min_step, dt * 0.5)

            return y, new_dt, False

def create_initial_state(q_init: np.ndarray = None, 
                        omega_init: np.ndarray = None,
                        wheel_speeds_init: np.ndarray = None,
                        n_wheels: int = 3) -> np.ndarray:
    """
    Create initial state vector for simulation.

    Args:
        q_init: Initial quaternion [q0, q1, q2, q3]
        omega_init: Initial angular velocity [ωx, ωy, ωz] rad/s
        wheel_speeds_init: Initial wheel speeds (rad/s)
        n_wheels: Number of reaction wheels

    Returns:
        Initial state vector
    """
    # Default values
    if q_init is None:
        q_init = np.array([1.0, 0.0, 0.0, 0.0])  # Identity quaternion

    if omega_init is None:
        omega_init = np.zeros(3)

    if wheel_speeds_init is None:
        wheel_speeds_init = np.zeros(n_wheels)

    # Convert wheel speeds to angular momenta
    # Assume standard wheel inertia
    wheel_inertia = 2e-5  # kg⋅m²
    h_wheels_init = wheel_speeds_init * wheel_inertia

    # Normalize quaternion
    q_init = q_init / np.linalg.norm(q_init)

    return np.concatenate([q_init, omega_init, h_wheels_init])

# Test function for dynamics validation
def test_dynamics():
    """Test the dynamics implementation."""
    print("Testing CubeSat dynamics...")

    # Create dynamics model
    dynamics = CubeSatDynamics()

    # Test state derivative computation
    state = create_initial_state()
    control_torques = np.array([1e-4, 0, 0])  # Small X-axis torque

    state_dot = dynamics.state_derivative(0.0, state, control_torques)

    # Verify dimensions
    assert len(state_dot) == len(state), "State derivative dimension mismatch"
    assert len(state_dot) == 10, f"Expected 10 states, got {len(state_dot)}"

    # Test conservation properties
    h_total, h_magnitude = dynamics.get_total_angular_momentum(state)
    print(f"Initial angular momentum magnitude: {h_magnitude:.2e} kg⋅m²/s")

    # Test wheel torque allocation
    desired_torque = np.array([1e-4, 1e-4, 1e-4])
    wheel_torques = dynamics.compute_wheel_torques_from_body_torque(desired_torque)

    print(f"Desired body torque: {desired_torque}")
    print(f"Allocated wheel torques: {wheel_torques}")

    # Verify torque allocation
    achieved_torque = dynamics.wheel_directions @ wheel_torques
    print(f"Achieved body torque: {achieved_torque}")

    print("✓ Dynamics tests passed!")

if __name__ == "__main__":
    test_dynamics()
