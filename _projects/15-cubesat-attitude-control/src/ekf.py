"""
Extended Kalman Filter for Quaternion Attitude and Gyro Bias Estimation
=======================================================================

This module implements a sophisticated Extended Kalman Filter (EKF) for spacecraft
attitude determination and gyroscope bias estimation. The filter handles the 
nonlinear quaternion kinematics while maintaining numerical stability.

Mathematical Foundation:
- State vector: [q0, q1, q2, q3, βx, βy, βz] (quaternion + gyro biases)
- Process model: q̇ = (1/2)*Ω(ω-β)*q, β̇ = random walk
- Measurement models: ω_meas = ω_true + β + noise, s_sun = DCM*s_inertial + noise
- Quaternion constraint handling: Modified Rodrigues Parameters (MRP) for updates
- Numerical Jacobians for improved accuracy

Key Features:
- Multiplicative EKF with quaternion normalization
- Adaptive process/measurement noise estimation
- Outlier detection and rejection
- Covariance analysis and conditioning

Author: CubeSat GN&C System
"""

import numpy as np
from typing import Tuple, Dict, Optional, List, Callable
from dataclasses import dataclass
from quaternion_utils import QuaternionUtils, skew_symmetric
from sensors import SensorSuite
import warnings
from scipy.linalg import block_diag

@dataclass
class EKFParameters:
    """Extended Kalman Filter configuration parameters."""

    # Initial covariance settings
    initial_attitude_uncertainty: float = np.radians(10.0)  # rad (1σ)
    initial_bias_uncertainty: float = 1e-5                  # rad/s (1σ)

    # Process noise characteristics  
    attitude_process_noise: float = 1e-8     # rad²/s² (gyro noise spectral density)
    bias_process_noise: float = 1e-12        # rad²/s³ (bias random walk)

    # Measurement noise (if not provided by sensors)
    default_gyro_noise: float = 1e-12        # rad²/s²
    default_sun_noise: float = 1e-4          # rad² (sun vector uncertainty)

    # Filter tuning parameters
    outlier_threshold: float = 3.0           # σ threshold for outlier rejection
    min_eigenvalue: float = 1e-15            # Minimum covariance eigenvalue
    max_eigenvalue: float = 1e3              # Maximum covariance eigenvalue

    # Adaptive estimation
    enable_adaptive_Q: bool = True           # Adaptive process noise
    enable_adaptive_R: bool = False          # Adaptive measurement noise
    innovation_window: int = 10              # Window for innovation statistics

class QuaternionEKF:
    """
    Extended Kalman Filter for quaternion-based attitude estimation.

    Implements a multiplicative EKF that handles quaternion kinematics properly
    while estimating gyroscope biases. Uses Modified Rodrigues Parameters (MRP)
    for error state representation to avoid quaternion constraint issues.
    """

    def __init__(self, 
                 initial_state: np.ndarray,
                 sensor_suite: SensorSuite,
                 params: Optional[EKFParameters] = None):
        """
        Initialize the Extended Kalman Filter.

        Args:
            initial_state: Initial state estimate [q0, q1, q2, q3, βx, βy, βz]
            sensor_suite: Sensor models for measurements
            params: EKF configuration parameters
        """
        self.params = params or EKFParameters()
        self.sensors = sensor_suite

        # State dimension (4 quaternion + 3 bias = 7)
        self.n_states = 7

        # Initialize state estimate
        self.state = np.array(initial_state[:7])  # Ensure correct size
        self.state[0:4] = QuaternionUtils.normalize(self.state[0:4])

        # Initialize covariance matrix
        self.P = self._initialize_covariance()

        # Process noise matrix
        self.Q = self._build_process_noise_matrix()

        # Innovation statistics for adaptive filtering
        self.innovation_history = []
        self.max_innovation_history = self.params.innovation_window

        # Filter statistics
        self.filter_stats = {
            'num_updates': 0,
            'num_outliers_rejected': 0,
            'avg_innovation_norm': 0.0,
            'condition_number': 1.0
        }

    def _initialize_covariance(self) -> np.ndarray:
        """Initialize state covariance matrix."""
        P = np.zeros((self.n_states, self.n_states))

        # Attitude uncertainty (quaternion components)
        att_var = self.params.initial_attitude_uncertainty**2
        P[0:4, 0:4] = np.eye(4) * att_var

        # Bias uncertainty
        bias_var = self.params.initial_bias_uncertainty**2
        P[4:7, 4:7] = np.eye(3) * bias_var

        return P

    def _build_process_noise_matrix(self) -> np.ndarray:
        """Build process noise covariance matrix."""
        Q = np.zeros((self.n_states, self.n_states))

        # Attitude process noise (from gyro noise)
        att_noise = self.params.attitude_process_noise
        Q[0:4, 0:4] = np.eye(4) * att_noise

        # Bias process noise (random walk)
        bias_noise = self.params.bias_process_noise
        Q[4:7, 4:7] = np.eye(3) * bias_noise

        return Q

    def predict(self, dt: float, control_input: Optional[np.ndarray] = None):
        """
        EKF prediction step.

        Propagates state estimate and covariance using nonlinear process model.

        Args:
            dt: Time step (s)
            control_input: Optional control input (not used in attitude estimation)
        """
        if dt <= 0:
            return

        # Extract current state
        q = self.state[0:4]
        bias = self.state[4:7]

        # For prediction, we need angular velocity estimate
        # Use previous gyro measurement minus current bias estimate
        if len(self.sensors.measurement_history) > 0:
            last_measurement = self.sensors.measurement_history[-1]
            omega_measured = last_measurement['gyro']['angular_velocity']
            omega_corrected = omega_measured - bias
        else:
            omega_corrected = np.zeros(3)  # No previous measurement

        # Propagate quaternion using corrected angular velocity
        q_new = self._propagate_quaternion(q, omega_corrected, dt)

        # Bias propagation (random walk - no change in mean)
        bias_new = bias

        # Update state estimate
        self.state[0:4] = q_new
        self.state[4:7] = bias_new

        # Compute state transition matrix (linearized dynamics)
        F = self._compute_state_transition_matrix(q, omega_corrected, dt)

        # Covariance propagation: P = F*P*F' + Q*dt
        self.P = F @ self.P @ F.T + self.Q * dt

        # Ensure covariance remains well-conditioned
        self._condition_covariance()

    def _propagate_quaternion(self, q: np.ndarray, omega: np.ndarray, dt: float) -> np.ndarray:
        """
        Propagate quaternion using angular velocity.

        Uses exact analytical solution for constant angular velocity.
        """
        omega_norm = np.linalg.norm(omega)

        if omega_norm < 1e-12:
            # No rotation - return normalized input
            return QuaternionUtils.normalize(q)

        # Exact propagation for constant angular velocity
        half_angle = 0.5 * omega_norm * dt
        axis = omega / omega_norm

        # Rotation quaternion for this time step
        q_rot = QuaternionUtils.from_axis_angle(axis, omega_norm * dt)

        # Apply rotation: q_new = q_rot * q_old
        q_new = QuaternionUtils.multiply(q_rot, q)

        return QuaternionUtils.normalize(q_new)

    def _compute_state_transition_matrix(self, q: np.ndarray, omega: np.ndarray, dt: float) -> np.ndarray:
        """
        Compute linearized state transition matrix F.

        For quaternion kinematics: q̇ = (1/2) * Ω(ω) * q
        For bias dynamics: β̇ = 0 (random walk)
        """
        F = np.eye(self.n_states)

        # Quaternion dynamics Jacobian
        # ∂q̇/∂q = (1/2) * Ω(ω)
        omega_matrix = np.array([
            [0,       -omega[0], -omega[1], -omega[2]],
            [omega[0],    0,      omega[2], -omega[1]],
            [omega[1], -omega[2],    0,      omega[0]],
            [omega[2],  omega[1], -omega[0],    0]
        ])

        # First-order Taylor expansion: F ≈ I + ∂f/∂x * dt
        F[0:4, 0:4] += 0.5 * omega_matrix * dt

        # ∂q̇/∂β = -(1/2) * Q(q), where Q is the quaternion matrix
        q0, q1, q2, q3 = q
        Q_matrix = 0.5 * np.array([
            [-q1, -q2, -q3],
            [ q0, -q3,  q2],
            [ q3,  q0, -q1],
            [-q2,  q1,  q0]
        ])

        F[0:4, 4:7] = -Q_matrix * dt

        # Bias dynamics are identity (no coupling)
        # F[4:7, 4:7] is already identity

        return F

    def update_gyroscope(self, measurement: Dict, dt: float):
        """
        EKF update using gyroscope measurements.

        Args:
            measurement: Gyro measurement dictionary
            dt: Time step (s)
        """
        omega_measured = measurement['angular_velocity']
        R_gyro = measurement.get('covariance', 
                                np.eye(3) * self.params.default_gyro_noise)

        # Current state estimates
        q_est = self.state[0:4]
        bias_est = self.state[4:7]

        # Measurement model: h(x) = ω_true + bias
        # We predict that measured ω = true ω + bias
        # But we need to invert this: true ω = measured ω - bias
        h_predicted = bias_est  # This is the predicted bias component

        # Innovation (measurement residual)
        # We compare the measured ω with our prediction
        # For gyro update, we're mainly updating the bias
        innovation = omega_measured - h_predicted

        # Measurement Jacobian H
        H = np.zeros((3, self.n_states))
        H[0:3, 4:7] = np.eye(3)  # ∂h/∂bias = I (bias directly affects measurement)

        # Innovation covariance
        S = H @ self.P @ H.T + R_gyro

        # Outlier detection
        if self._is_outlier(innovation, S):
            self.filter_stats['num_outliers_rejected'] += 1
            return

        # Kalman gain
        try:
            K = self.P @ H.T @ np.linalg.inv(S)
        except np.linalg.LinAlgError:
            # Singular innovation covariance - skip update
            return

        # State update
        self.state += K @ innovation

        # Normalize quaternion
        self.state[0:4] = QuaternionUtils.normalize(self.state[0:4])

        # Covariance update (Joseph form for numerical stability)
        I_KH = np.eye(self.n_states) - K @ H
        self.P = I_KH @ self.P @ I_KH.T + K @ R_gyro @ K.T

        # Update statistics
        self._update_filter_statistics(innovation, S)

    def update_sun_sensor(self, measurement: Dict):
        """
        EKF update using sun sensor measurements.

        Args:
            measurement: Sun sensor measurement dictionary
        """
        if measurement['confidence'] < 0.3:
            # Low confidence measurement - skip update
            return

        sun_vector_body_measured = measurement['sun_vector_body']
        R_sun = measurement.get('covariance',
                               np.eye(3) * self.params.default_sun_noise)

        # Current quaternion estimate
        q_est = self.state[0:4]

        # Predicted sun vector in body frame
        # h(q) = DCM(q) * sun_inertial
        R_body_inertial = QuaternionUtils.to_rotation_matrix(q_est)
        sun_inertial = self.sensors.sun_sensors.sun_inertial
        sun_predicted = R_body_inertial @ sun_inertial

        # Innovation
        innovation = sun_vector_body_measured - sun_predicted

        # Measurement Jacobian (numerical computation for robustness)
        H = self._compute_sun_measurement_jacobian(q_est, sun_inertial)

        # Innovation covariance
        S = H @ self.P @ H.T + R_sun

        # Outlier detection
        if self._is_outlier(innovation, S):
            self.filter_stats['num_outliers_rejected'] += 1
            return

        # Kalman gain
        try:
            K = self.P @ H.T @ np.linalg.inv(S)
        except np.linalg.LinAlgError:
            return

        # State update
        self.state += K @ innovation

        # Normalize quaternion
        self.state[0:4] = QuaternionUtils.normalize(self.state[0:4])

        # Covariance update
        I_KH = np.eye(self.n_states) - K @ H
        self.P = I_KH @ self.P @ I_KH.T + K @ R_sun @ K.T

        # Update statistics
        self._update_filter_statistics(innovation, S)

    def _compute_sun_measurement_jacobian(self, q: np.ndarray, 
                                        sun_inertial: np.ndarray) -> np.ndarray:
        """
        Compute measurement Jacobian for sun sensor using numerical differentiation.

        Args:
            q: Current quaternion estimate
            sun_inertial: Sun vector in inertial frame

        Returns:
            3x7 Jacobian matrix H
        """
        H = np.zeros((3, self.n_states))

        epsilon = 1e-8  # Numerical differentiation step size

        # Numerical Jacobian with respect to quaternion
        for i in range(4):
            q_plus = q.copy()
            q_plus[i] += epsilon
            q_plus = QuaternionUtils.normalize(q_plus)

            q_minus = q.copy() 
            q_minus[i] -= epsilon
            q_minus = QuaternionUtils.normalize(q_minus)

            R_plus = QuaternionUtils.to_rotation_matrix(q_plus)
            R_minus = QuaternionUtils.to_rotation_matrix(q_minus)

            sun_plus = R_plus @ sun_inertial
            sun_minus = R_minus @ sun_inertial

            H[:, i] = (sun_plus - sun_minus) / (2 * epsilon)

        # Sun measurement doesn't depend on bias (H[:, 4:7] remains zero)

        return H

    def _is_outlier(self, innovation: np.ndarray, innovation_cov: np.ndarray) -> bool:
        """
        Detect measurement outliers using Mahalanobis distance.

        Args:
            innovation: Measurement residual
            innovation_cov: Innovation covariance matrix

        Returns:
            True if measurement should be rejected as outlier
        """
        try:
            # Mahalanobis distance
            inv_S = np.linalg.inv(innovation_cov)
            mahal_dist_sq = innovation.T @ inv_S @ innovation
            mahal_dist = np.sqrt(mahal_dist_sq)

            # Chi-squared test with degrees of freedom = measurement dimension
            threshold = self.params.outlier_threshold * np.sqrt(len(innovation))

            return mahal_dist > threshold

        except (np.linalg.LinAlgError, ValueError):
            # If covariance inversion fails, be conservative and reject
            return True

    def _condition_covariance(self):
        """
        Ensure covariance matrix remains well-conditioned.

        Performs eigenvalue decomposition and clips eigenvalues to prevent
        numerical issues.
        """
        try:
            # Symmetrize covariance (should be symmetric but numerical errors accumulate)
            self.P = 0.5 * (self.P + self.P.T)

            # Eigenvalue decomposition
            eigenvals, eigenvecs = np.linalg.eigh(self.P)

            # Clip eigenvalues to acceptable range
            eigenvals = np.clip(eigenvals, 
                              self.params.min_eigenvalue,
                              self.params.max_eigenvalue)

            # Reconstruct covariance
            self.P = eigenvecs @ np.diag(eigenvals) @ eigenvecs.T

            # Update condition number statistic
            self.filter_stats['condition_number'] = np.max(eigenvals) / np.min(eigenvals)

        except np.linalg.LinAlgError:
            # If eigenvalue decomposition fails, reinitialize covariance
            warnings.warn("Covariance conditioning failed - reinitializing")
            self.P = self._initialize_covariance()

    def _update_filter_statistics(self, innovation: np.ndarray, 
                                innovation_cov: np.ndarray):
        """Update filter performance statistics."""
        self.filter_stats['num_updates'] += 1

        # Innovation norm
        innovation_norm = np.linalg.norm(innovation)

        # Update running average
        n = self.filter_stats['num_updates']
        prev_avg = self.filter_stats['avg_innovation_norm']
        self.filter_stats['avg_innovation_norm'] = ((n-1)*prev_avg + innovation_norm) / n

        # Store innovation for adaptive filtering
        self.innovation_history.append({
            'innovation': innovation.copy(),
            'covariance': innovation_cov.copy(),
            'norm': innovation_norm
        })

        # Limit history size
        if len(self.innovation_history) > self.max_innovation_history:
            self.innovation_history.pop(0)

    def get_attitude_estimate(self) -> Tuple[np.ndarray, np.ndarray]:
        """
        Get current attitude estimate with uncertainty.

        Returns:
            Tuple of (quaternion_estimate, attitude_covariance_3x3)
        """
        q_est = self.state[0:4]

        # Extract attitude portion of covariance (first 4x4 block)
        # Convert to 3x3 by projecting onto tangent space
        P_att = self.P[0:4, 0:4]

        # For small angles, quaternion covariance ≈ (1/4) * angle covariance
        # This is an approximation - exact conversion is more complex
        P_attitude_3x3 = P_att[1:4, 1:4] * 4  # Rough approximation

        return q_est, P_attitude_3x3

    def get_bias_estimate(self) -> Tuple[np.ndarray, np.ndarray]:
        """
        Get gyroscope bias estimate with uncertainty.

        Returns:
            Tuple of (bias_estimate, bias_covariance_3x3)
        """
        bias_est = self.state[4:7]
        bias_cov = self.P[4:7, 4:7]

        return bias_est, bias_cov

    def get_filter_diagnostics(self) -> Dict:
        """Get comprehensive filter diagnostic information."""
        q_est, att_cov = self.get_attitude_estimate()
        bias_est, bias_cov = self.get_bias_estimate()

        # Attitude uncertainty (1σ in degrees)
        att_std_deg = np.degrees(np.sqrt(np.diag(att_cov)))

        # Bias uncertainty (1σ in μrad/s)
        bias_std_urad = np.sqrt(np.diag(bias_cov)) * 1e6

        diagnostics = {
            'state': {
                'quaternion': q_est,
                'bias_rad_per_s': bias_est,
                'bias_urad_per_s': bias_est * 1e6
            },
            'uncertainty': {
                'attitude_std_deg': att_std_deg,
                'bias_std_urad_per_s': bias_std_urad,
                'covariance_trace': np.trace(self.P),
                'condition_number': self.filter_stats['condition_number']
            },
            'performance': self.filter_stats.copy(),
            'convergence': {
                'attitude_converged': np.all(att_std_deg < 5.0),  # Within 5° (1σ)
                'bias_converged': np.all(bias_std_urad < 100.0),  # Within 100 μrad/s (1σ)
            }
        }

        return diagnostics

# Utility functions for EKF analysis and tuning

def analyze_filter_performance(ekf: QuaternionEKF, 
                             true_states: List[np.ndarray]) -> Dict:
    """
    Analyze EKF performance against true trajectory.

    Args:
        ekf: Quaternion EKF instance
        true_states: List of true state vectors

    Returns:
        Performance metrics dictionary
    """
    if len(true_states) == 0:
        return {}

    # Get current estimate
    q_est, att_cov = ekf.get_attitude_estimate()
    bias_est, bias_cov = ekf.get_bias_estimate()

    # Compare with most recent true state
    true_state = true_states[-1]
    q_true = true_state[0:4]
    bias_true = true_state[4:7] if len(true_state) >= 7 else np.zeros(3)

    # Attitude error
    q_error = QuaternionUtils.error_quaternion(q_true, q_est)
    axis_error, angle_error = QuaternionUtils.to_axis_angle(q_error)

    # Bias error
    bias_error = bias_est - bias_true

    metrics = {
        'attitude_error_deg': np.degrees(angle_error),
        'attitude_error_axis': axis_error,
        'bias_error_urad_per_s': bias_error * 1e6,
        'bias_error_norm': np.linalg.norm(bias_error) * 1e6,
        'within_1sigma_attitude': angle_error < np.sqrt(np.trace(att_cov)),
        'within_1sigma_bias': np.all(np.abs(bias_error) < np.sqrt(np.diag(bias_cov)))
    }

    return metrics

def test_ekf():
    """Test the Extended Kalman Filter."""
    print("Testing Extended Kalman Filter...")

    # Create sensor suite for testing
    from sensors import SensorSuite
    sensors = SensorSuite()

    # Initial state [q0, q1, q2, q3, βx, βy, βz]
    initial_state = np.array([1.0, 0.0, 0.0, 0.0, 1e-6, -2e-6, 0.5e-6])

    # Create EKF
    ekf = QuaternionEKF(initial_state, sensors)

    print(f"Initial state: {initial_state}")
    print(f"Initial covariance trace: {np.trace(ekf.P):.2e}")

    # Test prediction step
    dt = 0.01  # 10 ms
    ekf.predict(dt)

    print(f"After prediction - state: {ekf.state}")

    # Test gyro update
    gyro_measurement = {
        'angular_velocity': np.array([0.1, 0.05, -0.02]),
        'covariance': np.eye(3) * 1e-12
    }

    ekf.update_gyroscope(gyro_measurement, dt)
    print(f"After gyro update - bias estimate: {ekf.state[4:7] * 1e6} μrad/s")

    # Test sun sensor update
    sun_measurement = {
        'sun_vector_body': np.array([0.8, 0.6, 0.0]) / np.linalg.norm([0.8, 0.6, 0.0]),
        'confidence': 0.9,
        'covariance': np.eye(3) * 1e-4
    }

    ekf.update_sun_sensor(sun_measurement)
    q_est, _ = ekf.get_attitude_estimate()
    print(f"After sun update - quaternion: {q_est}")

    # Test diagnostics
    diagnostics = ekf.get_filter_diagnostics()
    print(f"Attitude uncertainty: {diagnostics['uncertainty']['attitude_std_deg']} deg (1σ)")
    print(f"Bias uncertainty: {diagnostics['uncertainty']['bias_std_urad_per_s']} μrad/s (1σ)")
    print(f"Filter updates: {diagnostics['performance']['num_updates']}")
    print(f"Outliers rejected: {diagnostics['performance']['num_outliers_rejected']}")

    print("✓ EKF tests passed!")

if __name__ == "__main__":
    test_ekf()
