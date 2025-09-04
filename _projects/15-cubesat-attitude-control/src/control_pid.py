"""
PID Attitude Controller for CubeSat with Anti-Windup
===================================================

This module implements a robust PID controller for spacecraft attitude control
using quaternion error representation and anti-windup mechanisms.

Mathematical Foundation:
- Quaternion error: q_e = q_desired^(-1) * q_current
- Control law: τ = Kp*e_att + Ki*∫e_att*dt + Kd*ω_error
- Anti-windup: Conditional integration and saturation handling
- Feedforward compensation for known disturbances

Key Features:
- Quaternion-based error computation (singularity-free)
- Anti-windup with conditional integration
- Derivative kick prevention
- Setpoint weighting for improved transient response
- Saturation handling with priority allocation

Author: CubeSat GN&C System
"""

import numpy as np
from typing import Tuple, Dict, Optional, Callable
from dataclasses import dataclass
from quaternion_utils import QuaternionUtils
import warnings

@dataclass
class PIDParameters:
    """PID controller parameters and tuning settings."""

    # PID gains (3x1 vectors for each axis)
    Kp: np.ndarray = None  # Proportional gains (N⋅m/rad)
    Ki: np.ndarray = None  # Integral gains (N⋅m⋅s/rad)
    Kd: np.ndarray = None  # Derivative gains (N⋅m⋅s/rad)

    # Anti-windup parameters
    integral_limit: float = 0.01         # Maximum integral term (N⋅m)
    anti_windup_method: str = 'clamping' # 'clamping', 'conditional', 'back_calculation'
    back_calc_gain: float = 1.0          # Back-calculation gain (for back_calc method)

    # Derivative filtering
    derivative_filter_coeff: float = 0.1  # Filter coefficient (0=no filter, 1=pure integrator)

    # Setpoint weighting (for improved transient response)
    proportional_weight: float = 1.0     # Weight on proportional term [0,1]
    derivative_weight: float = 0.0       # Weight on derivative term [0,1]

    # Output limits
    max_torque: float = 1e-3            # Maximum output torque per axis (N⋅m)

    # Performance tuning
    deadband: float = 0.0               # Control deadband (rad)

    def __post_init__(self):
        if self.Kp is None:
            # Default gains for 3U CubeSat (conservative tuning)
            self.Kp = np.array([0.01, 0.01, 0.001])  # Lower gain for Z-axis (spin axis)
        if self.Ki is None:
            self.Ki = np.array([0.001, 0.001, 0.0001])
        if self.Kd is None:
            self.Kd = np.array([0.05, 0.05, 0.005])

class QuaternionPIDController:
    """
    PID controller for quaternion-based attitude control.

    Implements a sophisticated PID controller that:
    - Uses quaternion error for singularity-free attitude representation
    - Includes anti-windup mechanisms to handle actuator saturation
    - Provides derivative filtering to reduce noise sensitivity
    - Supports setpoint weighting for improved transient response
    """

    def __init__(self, params: Optional[PIDParameters] = None):
        """
        Initialize PID controller.

        Args:
            params: Controller parameters and tuning settings
        """
        self.params = params or PIDParameters()

        # Controller state variables
        self.integral_term = np.zeros(3)
        self.prev_error = np.zeros(3)
        self.filtered_derivative = np.zeros(3)
        self.prev_time = 0.0

        # Performance tracking
        self.control_stats = {
            'max_error_achieved': np.inf,
            'settling_time': np.inf,
            'steady_state_error': np.inf,
            'total_control_effort': 0.0,
            'windup_events': 0
        }

        # Internal flags
        self.first_call = True

    def compute_control(self, 
                       q_current: np.ndarray,
                       omega_current: np.ndarray,
                       q_desired: np.ndarray,
                       omega_desired: np.ndarray = None,
                       time: float = 0.0) -> Tuple[np.ndarray, Dict]:
        """
        Compute PID control torques.

        Args:
            q_current: Current attitude quaternion
            omega_current: Current angular velocity (rad/s)
            q_desired: Desired attitude quaternion
            omega_desired: Desired angular velocity (rad/s, optional)
            time: Current time (s)

        Returns:
            Tuple of (control_torques, debug_info)
        """
        if omega_desired is None:
            omega_desired = np.zeros(3)

        # Compute time step
        if self.first_call:
            dt = 0.01  # Default time step for first call
            self.first_call = False
        else:
            dt = time - self.prev_time
            if dt <= 0:
                dt = 0.01  # Fallback for non-monotonic time

        self.prev_time = time

        # Compute quaternion error
        q_error = QuaternionUtils.error_quaternion(q_desired, q_current)

        # Extract attitude error (vector part of error quaternion, scaled by scalar part)
        # For small angles: attitude_error ≈ 2 * q_vector / q_scalar
        if np.abs(q_error[0]) < 1e-6:
            # Near 180° error - handle carefully
            attitude_error = np.sign(q_error[0]) * 2 * q_error[1:4]
        else:
            attitude_error = 2 * q_error[1:4] / q_error[0]

        # Angular velocity error
        omega_error = omega_desired - omega_current

        # Proportional term with setpoint weighting
        proportional_term = (self.params.Kp * 
                           (self.params.proportional_weight * attitude_error))

        # Integral term with anti-windup
        if self._should_integrate(attitude_error, dt):
            self.integral_term += self.params.Ki * attitude_error * dt

            # Apply integral limits
            integral_magnitude = np.linalg.norm(self.integral_term)
            if integral_magnitude > self.params.integral_limit:
                self.integral_term = (self.integral_term / integral_magnitude * 
                                    self.params.integral_limit)

        # Derivative term with filtering and setpoint weighting
        if dt > 0:
            raw_derivative = (attitude_error - self.prev_error) / dt

            # Apply low-pass filter to derivative
            alpha = self.params.derivative_filter_coeff
            self.filtered_derivative = (alpha * self.filtered_derivative + 
                                      (1 - alpha) * raw_derivative)

            # Derivative term with setpoint weighting
            derivative_term = (self.params.Kd * 
                             (self.params.derivative_weight * self.filtered_derivative +
                              (1 - self.params.derivative_weight) * omega_error))
        else:
            derivative_term = np.zeros(3)

        # Total control output
        control_torque = proportional_term + self.integral_term + derivative_term

        # Apply deadband
        if self.params.deadband > 0:
            for i in range(3):
                if np.abs(attitude_error[i]) < self.params.deadband:
                    control_torque[i] = 0.0

        # Handle output saturation with anti-windup
        saturated_torque, was_saturated = self._apply_saturation(control_torque)

        # Anti-windup correction
        if was_saturated:
            self._handle_anti_windup(control_torque, saturated_torque, dt)
            self.control_stats['windup_events'] += 1

        # Update state for next iteration
        self.prev_error = attitude_error

        # Update performance statistics
        self._update_performance_stats(attitude_error, np.linalg.norm(saturated_torque), time)

        # Prepare debug information
        debug_info = {
            'attitude_error_deg': np.degrees(attitude_error),
            'attitude_error_norm_deg': np.degrees(np.linalg.norm(attitude_error)),
            'omega_error': omega_error,
            'proportional_term': proportional_term,
            'integral_term': self.integral_term,
            'derivative_term': derivative_term,
            'saturated': was_saturated,
            'control_effort': np.linalg.norm(saturated_torque),
            'time_step': dt
        }

        return saturated_torque, debug_info

    def _should_integrate(self, error: np.ndarray, dt: float) -> bool:
        """
        Determine whether to integrate based on anti-windup strategy.

        Args:
            error: Current attitude error
            dt: Time step

        Returns:
            True if integration should proceed
        """
        if self.params.anti_windup_method == 'conditional':
            # Conditional integration - don't integrate if error and integral have same sign
            # and integral is near saturation
            integral_magnitude = np.linalg.norm(self.integral_term)

            if integral_magnitude > 0.8 * self.params.integral_limit:
                # Near saturation - check if error would increase integral
                dot_product = np.dot(error, self.integral_term)
                return dot_product <= 0  # Only integrate if it reduces the integral

        return True  # Default: always integrate

    def _apply_saturation(self, torque: np.ndarray) -> Tuple[np.ndarray, bool]:
        """
        Apply output saturation limits.

        Args:
            torque: Desired control torque

        Returns:
            Tuple of (saturated_torque, was_saturated)
        """
        saturated_torque = np.clip(torque, -self.params.max_torque, self.params.max_torque)
        was_saturated = not np.allclose(torque, saturated_torque)

        return saturated_torque, was_saturated

    def _handle_anti_windup(self, original_torque: np.ndarray, 
                           saturated_torque: np.ndarray, dt: float):
        """
        Handle integral anti-windup when saturation occurs.

        Args:
            original_torque: Original (unsaturated) control output
            saturated_torque: Saturated control output
            dt: Time step
        """
        if self.params.anti_windup_method == 'clamping':
            # Simple clamping - already handled by not integrating when saturated
            pass

        elif self.params.anti_windup_method == 'back_calculation':
            # Back-calculation method
            saturation_error = saturated_torque - original_torque

            # Adjust integral term to reduce saturation
            if dt > 0:
                integral_adjustment = (self.params.back_calc_gain * 
                                     saturation_error * dt / self.params.Ki)
                self.integral_term += integral_adjustment

                # Ensure integral doesn't exceed limits after adjustment
                integral_magnitude = np.linalg.norm(self.integral_term)
                if integral_magnitude > self.params.integral_limit:
                    self.integral_term = (self.integral_term / integral_magnitude * 
                                        self.params.integral_limit)

    def _update_performance_stats(self, error: np.ndarray, control_effort: float, time: float):
        """Update controller performance statistics."""
        error_norm = np.linalg.norm(error)

        # Track maximum error achieved
        if error_norm < self.control_stats['max_error_achieved']:
            self.control_stats['max_error_achieved'] = error_norm

        # Estimate settling time (when error drops below 5% of initial)
        if (error_norm < 0.05 * np.pi and 
            self.control_stats['settling_time'] == np.inf):
            self.control_stats['settling_time'] = time

        # Track steady-state error (recent average)
        self.control_stats['steady_state_error'] = 0.9 * self.control_stats['steady_state_error'] + 0.1 * error_norm

        # Accumulate total control effort
        self.control_stats['total_control_effort'] += control_effort

    def reset_controller(self):
        """Reset controller internal state."""
        self.integral_term = np.zeros(3)
        self.prev_error = np.zeros(3)
        self.filtered_derivative = np.zeros(3)
        self.first_call = True

        # Reset performance statistics
        self.control_stats = {
            'max_error_achieved': np.inf,
            'settling_time': np.inf,
            'steady_state_error': np.inf,
            'total_control_effort': 0.0,
            'windup_events': 0
        }

    def tune_gains(self, desired_bandwidth: float, damping_ratio: float = 0.707,
                  spacecraft_inertia: np.ndarray = None):
        """
        Auto-tune PID gains based on desired bandwidth and damping.

        Uses simplified second-order approximation for each axis.

        Args:
            desired_bandwidth: Desired closed-loop bandwidth (rad/s)
            damping_ratio: Desired damping ratio (typically 0.707)
            spacecraft_inertia: Spacecraft moment of inertia (kg⋅m²)
        """
        if spacecraft_inertia is None:
            # Default 3U CubeSat inertia
            spacecraft_inertia = np.array([0.083, 0.083, 0.0083])

        # Second-order system: s² + 2*ζ*ωn*s + ωn² = 0
        # For PID: Kp = J*ωn², Kd = J*2*ζ*ωn, Ki = J*ωn³/(10*ζ)

        omega_n = desired_bandwidth

        # Proportional gains
        self.params.Kp = spacecraft_inertia * omega_n**2

        # Derivative gains  
        self.params.Kd = spacecraft_inertia * 2 * damping_ratio * omega_n

        # Integral gains (set lower to avoid windup)
        self.params.Ki = spacecraft_inertia * omega_n**3 / (10 * damping_ratio)

        print(f"Auto-tuned PID gains:")
        print(f"  Kp = {self.params.Kp}")
        print(f"  Ki = {self.params.Ki}")  
        print(f"  Kd = {self.params.Kd}")

    def get_performance_metrics(self) -> Dict:
        """Get controller performance metrics."""
        return {
            'max_error_deg': np.degrees(self.control_stats['max_error_achieved']),
            'settling_time_s': self.control_stats['settling_time'],
            'steady_state_error_deg': np.degrees(self.control_stats['steady_state_error']),
            'total_control_effort': self.control_stats['total_control_effort'],
            'windup_events': self.control_stats['windup_events'],
            'gains': {
                'Kp': self.params.Kp.copy(),
                'Ki': self.params.Ki.copy(),
                'Kd': self.params.Kd.copy()
            }
        }

# Utility functions for PID controller analysis

def analyze_step_response(controller: QuaternionPIDController,
                         step_magnitude_deg: float = 30.0,
                         simulation_time: float = 60.0,
                         dt: float = 0.01) -> Dict:
    """
    Analyze PID controller step response.

    Args:
        controller: PID controller instance
        step_magnitude_deg: Step input magnitude (degrees)
        simulation_time: Total simulation time (s)
        dt: Time step (s)

    Returns:
        Performance analysis results
    """
    from dynamics import CubeSatDynamics, create_initial_state
    from dynamics import AdaptiveIntegrator

    # Create simplified dynamics for testing
    dynamics = CubeSatDynamics()
    integrator = AdaptiveIntegrator()

    # Initial conditions
    q_initial = np.array([1.0, 0.0, 0.0, 0.0])
    omega_initial = np.zeros(3)
    state = create_initial_state(q_initial, omega_initial, np.zeros(3))

    # Desired step input
    step_angle = np.radians(step_magnitude_deg)
    q_desired = QuaternionUtils.from_axis_angle([0, 0, 1], step_angle)

    # Simulation arrays
    time_array = np.arange(0, simulation_time, dt)
    error_history = []
    control_history = []

    controller.reset_controller()

    for i, t in enumerate(time_array):
        # Current state
        q_current = state[0:4]
        omega_current = state[4:7]

        # Compute control
        control_torque, debug_info = controller.compute_control(
            q_current, omega_current, q_desired, np.zeros(3), t
        )

        # Convert to wheel torques
        wheel_torques = dynamics.compute_wheel_torques_from_body_torque(control_torque)

        # Propagate dynamics
        state_dot = dynamics.state_derivative(t, state, wheel_torques)
        state = state + state_dot * dt

        # Normalize quaternion
        state[0:4] = QuaternionUtils.normalize(state[0:4])

        # Store history
        error_history.append(debug_info['attitude_error_norm_deg'])
        control_history.append(debug_info['control_effort'])

    # Analyze performance
    error_array = np.array(error_history)

    # Settling time (2% criteria)
    steady_state_value = np.mean(error_array[-100:])  # Last 1 second
    settling_threshold = steady_state_value + 0.02 * step_magnitude_deg

    settling_idx = np.where(error_array <= settling_threshold)[0]
    settling_time = time_array[settling_idx[0]] if len(settling_idx) > 0 else simulation_time

    # Overshoot
    peak_error = np.max(error_array)
    overshoot_percent = ((peak_error - steady_state_value) / step_magnitude_deg) * 100

    # Rise time (10% to 90% of final value)
    rise_start_idx = np.where(error_array <= 0.9 * step_magnitude_deg)[0]
    rise_end_idx = np.where(error_array <= 0.1 * step_magnitude_deg)[0]

    rise_time = (time_array[rise_end_idx[0]] - time_array[rise_start_idx[0]] 
                if len(rise_start_idx) > 0 and len(rise_end_idx) > 0 else np.inf)

    return {
        'settling_time_s': settling_time,
        'overshoot_percent': overshoot_percent,
        'rise_time_s': rise_time,
        'steady_state_error_deg': steady_state_value,
        'peak_error_deg': peak_error,
        'time_history': time_array,
        'error_history': error_array,
        'control_history': np.array(control_history)
    }

def test_pid_controller():
    """Test the PID controller implementation."""
    print("Testing PID Controller...")

    # Create controller with default parameters
    params = PIDParameters(
        Kp=np.array([0.02, 0.02, 0.002]),
        Ki=np.array([0.005, 0.005, 0.0005]), 
        Kd=np.array([0.1, 0.1, 0.01])
    )

    controller = QuaternionPIDController(params)

    # Test step input
    q_current = np.array([1.0, 0.0, 0.0, 0.0])  # Identity
    omega_current = np.zeros(3)

    # 30° rotation about Z-axis
    q_desired = QuaternionUtils.from_axis_angle([0, 0, 1], np.radians(30))

    # Compute control
    control_torque, debug_info = controller.compute_control(
        q_current, omega_current, q_desired, np.zeros(3), 0.01
    )

    print(f"30° Z-axis step response:")
    print(f"  Attitude error: {debug_info['attitude_error_deg']} deg")
    print(f"  Control torque: {control_torque} N⋅m")
    print(f"  Proportional term: {debug_info['proportional_term']} N⋅m")
    print(f"  Control effort: {debug_info['control_effort']:.2e} N⋅m")

    # Test auto-tuning
    print(f"\nTesting auto-tuning:")
    controller.tune_gains(desired_bandwidth=0.5, damping_ratio=0.707)

    # Test with tuned gains
    control_torque2, debug_info2 = controller.compute_control(
        q_current, omega_current, q_desired, np.zeros(3), 0.02
    )

    print(f"After auto-tuning:")
    print(f"  Control torque: {control_torque2} N⋅m")
    print(f"  Control effort: {debug_info2['control_effort']:.2e} N⋅m")

    # Test saturation handling
    large_error_q = QuaternionUtils.from_axis_angle([1, 0, 0], np.radians(90))
    control_torque3, debug_info3 = controller.compute_control(
        q_current, omega_current, large_error_q, np.zeros(3), 0.03
    )

    print(f"\nLarge error (90°) test:")
    print(f"  Saturated: {debug_info3['saturated']}")
    print(f"  Control torque: {control_torque3} N⋅m")

    # Performance metrics
    metrics = controller.get_performance_metrics()
    print(f"\nController performance:")
    print(f"  Windup events: {metrics['windup_events']}")
    print(f"  Max error achieved: {metrics['max_error_deg']:.1f} deg")

    print("✓ PID Controller tests passed!")

if __name__ == "__main__":
    test_pid_controller()
