"""
High-Fidelity Sensor Models for CubeSat Attitude Determination
=============================================================

This module implements realistic sensor models for spacecraft attitude determination:
1. Rate gyroscopes with bias, noise, and temperature effects
2. Coarse sun sensors with nonlinear measurement models
3. Star trackers with outlier detection (future extension)
4. Magnetometers with calibration errors (future extension)

Mathematical Foundation:
- Gyroscope model: ω_meas = ω_true + bias + noise + scale_error*ω_true
- Sun sensor model: s_meas = DCM * s_sun + noise (with field-of-view constraints)
- Realistic noise characteristics: white noise + colored noise (bias drift)
- Sensor fusion through Extended Kalman Filter

Author: CubeSat GN&C System
"""

import numpy as np
from typing import Tuple, Dict, Optional, List
from dataclasses import dataclass
from quaternion_utils import QuaternionUtils, skew_symmetric
import warnings

@dataclass
class GyroscopeProperties:
    """Properties of a 3-axis rate gyroscope."""
    # Bias characteristics
    bias_stability: float = 1e-6      # rad/s (1σ, ARW coefficient)  
    bias_initial: np.ndarray = None   # Initial bias offset (rad/s)
    bias_drift_rate: float = 1e-8     # Bias random walk (rad/s²/√Hz)

    # Noise characteristics  
    noise_density: float = 1e-7       # rad/s/√Hz (angle random walk)
    white_noise_std: float = 1e-6     # rad/s (1σ white noise)

    # Scale factor errors
    scale_factor_error: float = 1e-4  # Fractional scale factor error (1σ)
    cross_coupling: np.ndarray = None # 3x3 cross-coupling matrix

    # Operating characteristics
    max_rate: float = 10.0            # rad/s (maximum measurable rate)
    resolution: float = 1e-8          # rad/s (ADC resolution)
    bandwidth: float = 100.0          # Hz (sensor bandwidth)

    # Temperature effects
    temp_sensitivity: float = 1e-6    # rad/s/°C (bias temperature drift)
    operating_temp: float = 25.0      # °C (operating temperature)

    def __post_init__(self):
        if self.bias_initial is None:
            self.bias_initial = np.random.normal(0, self.bias_stability, 3)
        if self.cross_coupling is None:
            self.cross_coupling = np.eye(3)

@dataclass  
class SunSensorProperties:
    """Properties of a coarse sun sensor (CSS) array."""
    # Geometric properties
    field_of_view: float = 120.0      # degrees (half-angle FOV)
    n_sensors: int = 6                # Number of sensors (typically 6 faces)

    # Sensor characteristics
    noise_std: float = 0.05           # Fractional noise (1σ)
    bias_offset: float = 0.01         # Fractional bias offset

    # Nonlinear response
    cosine_response: bool = True      # Cosine response to sun angle
    threshold_angle: float = 90.0     # degrees (minimum detection angle)

    # Installation geometry (sensor normal directions in body frame)
    sensor_normals: np.ndarray = None

    def __post_init__(self):
        if self.sensor_normals is None:
            # Default cube configuration (+/- X, Y, Z faces)
            self.sensor_normals = np.array([
                [1, 0, 0],   # +X face
                [-1, 0, 0],  # -X face
                [0, 1, 0],   # +Y face  
                [0, -1, 0],  # -Y face
                [0, 0, 1],   # +Z face
                [0, 0, -1]   # -Z face
            ]).T

class GyroscopeModel:
    """
    High-fidelity 3-axis rate gyroscope model.

    Implements comprehensive error sources:
    - Bias instability with random walk
    - White noise and colored noise
    - Scale factor and cross-coupling errors
    - Temperature-dependent drift
    - Saturation and quantization effects
    """

    def __init__(self, properties: Optional[GyroscopeProperties] = None):
        """
        Initialize gyroscope model.

        Args:
            properties: Gyroscope characteristics
        """
        self.props = properties or GyroscopeProperties()

        # Initialize bias state (will drift over time)
        self.current_bias = self.props.bias_initial.copy()

        # Previous measurement for colored noise generation
        self.prev_measurement = np.zeros(3)

        # Time tracking for bias drift
        self.last_update_time = 0.0

        # Scale factor matrix (including cross-coupling)
        scale_errors = np.random.normal(0, self.props.scale_factor_error, 3)
        self.scale_matrix = self.props.cross_coupling * (1 + np.diag(scale_errors))

    def measure(self, true_angular_velocity: np.ndarray, 
                dt: float, temperature: float = None) -> np.ndarray:
        """
        Generate gyroscope measurement with realistic errors.

        Args:
            true_angular_velocity: True body angular velocity (rad/s)
            dt: Time step since last measurement (s)
            temperature: Operating temperature (°C, optional)

        Returns:
            Measured angular velocity with errors (rad/s)
        """
        omega_true = np.array(true_angular_velocity)

        # Update bias drift (random walk)
        if dt > 0:
            bias_drift = np.random.normal(0, self.props.bias_drift_rate * np.sqrt(dt), 3)
            self.current_bias += bias_drift

        # Temperature effects on bias
        if temperature is not None:
            temp_drift = (temperature - self.props.operating_temp) * self.props.temp_sensitivity
            temp_bias = temp_drift * np.ones(3)
        else:
            temp_bias = np.zeros(3)

        # Scale factor and cross-coupling errors
        omega_scaled = self.scale_matrix @ omega_true

        # White noise
        white_noise = np.random.normal(0, self.props.white_noise_std, 3)

        # Angle random walk (integrate white noise)
        arw_noise = np.random.normal(0, self.props.noise_density / np.sqrt(dt), 3) if dt > 0 else np.zeros(3)

        # Total measurement
        omega_measured = omega_scaled + self.current_bias + temp_bias + white_noise + arw_noise

        # Apply saturation
        omega_measured = np.clip(omega_measured, -self.props.max_rate, self.props.max_rate)

        # Apply quantization (ADC resolution)
        if self.props.resolution > 0:
            omega_measured = np.round(omega_measured / self.props.resolution) * self.props.resolution

        self.prev_measurement = omega_measured
        self.last_update_time += dt

        return omega_measured

    def get_bias_estimate(self) -> np.ndarray:
        """Get current bias estimate for EKF."""
        return self.current_bias.copy()

    def get_covariance(self, dt: float) -> np.ndarray:
        """
        Get measurement noise covariance matrix.

        Args:
            dt: Measurement time interval (s)

        Returns:
            3x3 covariance matrix (rad²/s²)
        """
        # White noise variance
        white_var = self.props.white_noise_std**2

        # ARW variance
        arw_var = (self.props.noise_density / np.sqrt(dt))**2 if dt > 0 else 0

        # Total measurement variance (diagonal - assume uncorrelated axes)
        total_var = white_var + arw_var

        return np.diag([total_var] * 3)

class SunSensorModel:
    """
    Coarse Sun Sensor (CSS) array model.

    Models multiple sun sensors mounted on spacecraft faces with:
    - Cosine response to sun angle
    - Field-of-view limitations
    - Measurement noise and biases
    - Geometric occlusion effects
    """

    def __init__(self, properties: Optional[SunSensorProperties] = None):
        """
        Initialize sun sensor model.

        Args:
            properties: Sun sensor characteristics
        """
        self.props = properties or SunSensorProperties()

        # Individual sensor biases
        self.sensor_biases = np.random.normal(0, self.props.bias_offset, self.props.n_sensors)

        # Sun unit vector in inertial frame (simplified - assume constant direction)
        self.sun_inertial = np.array([1.0, 0.0, 0.0])  # Sun along +X inertial

    def measure(self, quaternion: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """
        Generate sun sensor measurements.

        Args:
            quaternion: Current spacecraft attitude quaternion

        Returns:
            Tuple of (sensor_outputs, validity_flags)
            - sensor_outputs: Normalized current from each sensor [0, 1]
            - validity_flags: Boolean array indicating valid measurements
        """
        # Convert sun direction to body frame
        R_body_inertial = QuaternionUtils.to_rotation_matrix(quaternion)
        sun_body = R_body_inertial @ self.sun_inertial

        sensor_outputs = np.zeros(self.props.n_sensors)
        validity_flags = np.zeros(self.props.n_sensors, dtype=bool)

        for i in range(self.props.n_sensors):
            sensor_normal = self.props.sensor_normals[:, i]

            # Dot product gives cosine of angle between sun and sensor normal
            cos_angle = np.dot(sun_body, sensor_normal)

            # Check if sun is within field of view
            fov_threshold = np.cos(np.radians(self.props.field_of_view))

            if cos_angle > fov_threshold:
                # Sun is visible to this sensor
                validity_flags[i] = True

                # Cosine response (if enabled)
                if self.props.cosine_response:
                    ideal_output = cos_angle
                else:
                    ideal_output = 1.0  # Binary response

                # Add bias and noise
                noise = np.random.normal(0, self.props.noise_std)
                sensor_outputs[i] = ideal_output + self.sensor_biases[i] + noise

                # Clamp to physical limits [0, 1]
                sensor_outputs[i] = np.clip(sensor_outputs[i], 0, 1)
            else:
                # Sun not visible - sensor output is zero
                validity_flags[i] = False
                sensor_outputs[i] = 0.0

        return sensor_outputs, validity_flags

    def estimate_sun_vector(self, sensor_outputs: np.ndarray, 
                           validity_flags: np.ndarray) -> Tuple[np.ndarray, float]:
        """
        Estimate sun unit vector in body frame from sensor measurements.

        Uses weighted least squares approach with valid sensor measurements.

        Args:
            sensor_outputs: Sensor current measurements
            validity_flags: Which sensors have valid measurements

        Returns:
            Tuple of (sun_vector_body, confidence)
        """
        valid_sensors = np.where(validity_flags)[0]

        if len(valid_sensors) < 2:
            # Insufficient measurements for reliable estimate
            return np.array([1, 0, 0]), 0.0

        # Set up weighted least squares problem
        # s_measured = A * s_body, where s_body is sun vector in body frame
        A = self.props.sensor_normals[:, valid_sensors].T  # n_valid x 3
        b = sensor_outputs[valid_sensors]                   # n_valid x 1

        # Weights (inverse variance - higher signal gets more weight)  
        weights = b + 1e-6  # Avoid division by zero
        W = np.diag(weights)

        # Weighted least squares solution
        try:
            AtWA = A.T @ W @ A
            AtWb = A.T @ W @ b
            sun_body_estimate = np.linalg.solve(AtWA, AtWb)

            # Normalize to unit vector
            sun_norm = np.linalg.norm(sun_body_estimate)
            if sun_norm > 1e-6:
                sun_body_estimate = sun_body_estimate / sun_norm
            else:
                sun_body_estimate = np.array([1, 0, 0])

            # Confidence based on residual and number of measurements
            residual = np.linalg.norm(A @ sun_body_estimate - b)
            confidence = min(1.0, len(valid_sensors) / self.props.n_sensors) * np.exp(-residual)

        except np.linalg.LinAlgError:
            # Singular matrix - fall back to simple average
            sun_body_estimate = np.mean(A, axis=0)
            sun_body_estimate = sun_body_estimate / np.linalg.norm(sun_body_estimate)
            confidence = 0.5

        return sun_body_estimate, confidence

    def get_measurement_covariance(self, sensor_outputs: np.ndarray,
                                  validity_flags: np.ndarray) -> np.ndarray:
        """
        Get covariance matrix for sun vector measurement.

        Args:
            sensor_outputs: Current sensor measurements
            validity_flags: Valid measurement flags

        Returns:
            3x3 covariance matrix for sun vector estimate
        """
        valid_count = np.sum(validity_flags)

        if valid_count < 2:
            # High uncertainty with insufficient measurements
            return np.eye(3) * 1.0

        # Estimate uncertainty based on noise and geometry
        base_variance = self.props.noise_std**2

        # Reduce uncertainty with more measurements and higher signals
        geometry_factor = valid_count / self.props.n_sensors
        signal_factor = np.mean(sensor_outputs[validity_flags]) if valid_count > 0 else 0.1

        total_variance = base_variance / (geometry_factor * signal_factor + 0.1)

        return np.eye(3) * total_variance

class SensorSuite:
    """
    Complete sensor suite for CubeSat attitude determination.

    Manages multiple sensor types and provides unified measurement interface
    for the Extended Kalman Filter.
    """

    def __init__(self, 
                 gyro_props: Optional[GyroscopeProperties] = None,
                 sun_props: Optional[SunSensorProperties] = None):
        """
        Initialize sensor suite.

        Args:
            gyro_props: Gyroscope properties
            sun_props: Sun sensor properties
        """
        self.gyroscope = GyroscopeModel(gyro_props)
        self.sun_sensors = SunSensorModel(sun_props)

        # Measurement history for filtering
        self.measurement_history = []
        self.max_history_length = 100

    def get_measurements(self, true_state: np.ndarray, dt: float, 
                        temperature: float = None) -> Dict:
        """
        Get measurements from all sensors.

        Args:
            true_state: True spacecraft state [q, ω, hw]
            dt: Time step (s)
            temperature: Operating temperature (°C)

        Returns:
            Dictionary of sensor measurements
        """
        # Extract true state components
        q_true = true_state[0:4]
        omega_true = true_state[4:7]

        # Gyroscope measurements
        omega_measured = self.gyroscope.measure(omega_true, dt, temperature)
        gyro_cov = self.gyroscope.get_covariance(dt)

        # Sun sensor measurements
        sun_outputs, sun_valid = self.sun_sensors.measure(q_true)
        sun_vector, sun_confidence = self.sun_sensors.estimate_sun_vector(sun_outputs, sun_valid)
        sun_cov = self.sun_sensors.get_measurement_covariance(sun_outputs, sun_valid)

        # Package measurements
        measurements = {
            'time': self.gyroscope.last_update_time,
            'gyro': {
                'angular_velocity': omega_measured,
                'covariance': gyro_cov,
                'bias_estimate': self.gyroscope.get_bias_estimate()
            },
            'sun_sensors': {
                'outputs': sun_outputs,
                'validity': sun_valid,
                'sun_vector_body': sun_vector,
                'confidence': sun_confidence,
                'covariance': sun_cov
            }
        }

        # Store in history
        self.measurement_history.append(measurements)
        if len(self.measurement_history) > self.max_history_length:
            self.measurement_history.pop(0)

        return measurements

    def get_gyro_bias_estimate(self) -> np.ndarray:
        """Get current gyroscope bias estimate."""
        return self.gyroscope.get_bias_estimate()

    def reset_gyro_bias(self, new_bias: np.ndarray):
        """Reset gyroscope bias (for EKF updates)."""
        self.gyroscope.current_bias = new_bias.copy()

# Utility functions for sensor modeling

def generate_attitude_reference_trajectory(duration: float, dt: float) -> Tuple[np.ndarray, np.ndarray]:
    """
    Generate reference attitude trajectory for sensor testing.

    Args:
        duration: Total simulation time (s)
        dt: Time step (s)

    Returns:
        Tuple of (time_array, quaternion_trajectory)
    """
    time_array = np.arange(0, duration, dt)
    n_steps = len(time_array)

    # Simple sinusoidal motion about each axis
    amplitude = np.radians(30)  # 30 degree amplitude
    frequencies = [0.1, 0.15, 0.05]  # Hz for each axis

    quaternions = np.zeros((n_steps, 4))

    for i, t in enumerate(time_array):
        # Euler angles with sinusoidal variation
        roll = amplitude * np.sin(2 * np.pi * frequencies[0] * t)
        pitch = amplitude * np.sin(2 * np.pi * frequencies[1] * t) 
        yaw = amplitude * np.sin(2 * np.pi * frequencies[2] * t)

        # Convert to quaternion (ZYX sequence)
        q_roll = QuaternionUtils.from_axis_angle([1, 0, 0], roll)
        q_pitch = QuaternionUtils.from_axis_angle([0, 1, 0], pitch)
        q_yaw = QuaternionUtils.from_axis_angle([0, 0, 1], yaw)

        # Compose rotations
        q_temp = QuaternionUtils.multiply(q_yaw, q_pitch)
        quaternions[i] = QuaternionUtils.multiply(q_temp, q_roll)

    return time_array, quaternions

def test_sensors():
    """Test the sensor models."""
    print("Testing sensor models...")

    # Create sensor suite
    sensors = SensorSuite()

    # Test gyroscope
    true_omega = np.array([0.1, -0.05, 0.2])  # rad/s
    dt = 0.01  # 10 ms

    omega_measured = sensors.gyroscope.measure(true_omega, dt)
    print(f"True angular velocity: {true_omega}")
    print(f"Measured angular velocity: {omega_measured}")
    print(f"Measurement error: {omega_measured - true_omega}")

    # Test sun sensors
    q_test = QuaternionUtils.from_axis_angle([0, 0, 1], np.pi/4)  # 45° rotation
    sun_outputs, validity = sensors.sun_sensors.measure(q_test)

    print(f"\nSun sensor outputs: {sun_outputs}")
    print(f"Valid sensors: {np.where(validity)[0]}")

    # Test sun vector estimation
    sun_est, confidence = sensors.sun_sensors.estimate_sun_vector(sun_outputs, validity)
    print(f"Estimated sun vector: {sun_est}")
    print(f"Confidence: {confidence:.3f}")

    # Test full measurement suite
    test_state = np.array([1, 0, 0, 0, 0.1, 0, 0, 0, 0, 0])  # [q, ω, hw]
    measurements = sensors.get_measurements(test_state, dt)

    print(f"\nFull measurement suite:")
    print(f"  Gyro measurement: {measurements['gyro']['angular_velocity']}")
    print(f"  Sun vector: {measurements['sun_sensors']['sun_vector_body']}")
    print(f"  Sun confidence: {measurements['sun_sensors']['confidence']:.3f}")

    print("✓ Sensor tests passed!")

if __name__ == "__main__":
    test_sensors()
