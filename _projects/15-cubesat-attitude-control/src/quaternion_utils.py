"""
Quaternion Utilities for CubeSat Attitude Control
================================================

This module provides comprehensive quaternion operations for attitude representation
and kinematics in spacecraft applications. Quaternions are used to avoid singularities
inherent in Euler angle representations.

Mathematical Foundation:
- Unit quaternions represent rotations in 3D space
- Quaternion: q = [q0, q1, q2, q3] = [cos(θ/2), sin(θ/2)*u]
- Where θ is rotation angle and u is unit rotation axis
- Quaternion multiplication represents rotation composition
- Conjugate quaternion represents inverse rotation

Author: CubeSat GN&C System
"""

import numpy as np
from typing import Tuple, Union
import warnings

class QuaternionUtils:
    """
    Comprehensive quaternion operations for spacecraft attitude control.

    Convention: Quaternion [q0, q1, q2, q3] where q0 is scalar part
    Unit quaternion constraint: ||q|| = 1
    """

    @staticmethod
    def normalize(q: np.ndarray) -> np.ndarray:
        """
        Normalize quaternion to unit length with numerical stability.

        Args:
            q: Quaternion [q0, q1, q2, q3]

        Returns:
            Normalized unit quaternion

        Raises:
            ValueError: If quaternion has zero norm (undefined)
        """
        q = np.array(q, dtype=float)
        norm = np.linalg.norm(q)

        if norm < 1e-12:
            raise ValueError("Cannot normalize zero quaternion")

        return q / norm

    @staticmethod
    def multiply(q1: np.ndarray, q2: np.ndarray) -> np.ndarray:
        """
        Quaternion multiplication: q_result = q1 * q2

        Mathematical formula:
        q1 * q2 = [q1[0]*q2[0] - q1[1:4]·q2[1:4], 
                   q1[0]*q2[1:4] + q2[0]*q1[1:4] + q1[1:4] × q2[1:4]]

        Args:
            q1: Left quaternion [q0, q1, q2, q3]
            q2: Right quaternion [q0, q1, q2, q3]

        Returns:
            Product quaternion
        """
        q1, q2 = np.array(q1), np.array(q2)

        # Scalar parts
        w1, w2 = q1[0], q2[0]
        # Vector parts
        v1, v2 = q1[1:4], q2[1:4]

        # Quaternion multiplication formula
        w = w1 * w2 - np.dot(v1, v2)
        v = w1 * v2 + w2 * v1 + np.cross(v1, v2)

        return np.array([w, v[0], v[1], v[2]])

    @staticmethod
    def conjugate(q: np.ndarray) -> np.ndarray:
        """
        Quaternion conjugate: q* = [q0, -q1, -q2, -q3]
        For unit quaternions, conjugate equals inverse.

        Args:
            q: Quaternion [q0, q1, q2, q3]

        Returns:
            Conjugate quaternion
        """
        q = np.array(q)
        return np.array([q[0], -q[1], -q[2], -q[3]])

    @staticmethod
    def inverse(q: np.ndarray) -> np.ndarray:
        """
        Quaternion inverse: q^(-1) = q* / ||q||^2
        For unit quaternions, this simplifies to conjugate.

        Args:
            q: Quaternion [q0, q1, q2, q3]

        Returns:
            Inverse quaternion
        """
        q = np.array(q)
        norm_sq = np.dot(q, q)

        if norm_sq < 1e-12:
            raise ValueError("Cannot invert zero quaternion")

        return QuaternionUtils.conjugate(q) / norm_sq

    @staticmethod
    def to_rotation_matrix(q: np.ndarray) -> np.ndarray:
        """
        Convert unit quaternion to 3x3 rotation matrix.

        Mathematical derivation from quaternion rotation formula:
        R = I + 2*q0*[q_vec]× + 2*[q_vec]×²

        Where [v]× is the skew-symmetric matrix of vector v.

        Args:
            q: Unit quaternion [q0, q1, q2, q3]

        Returns:
            3x3 rotation matrix (DCM)
        """
        q = QuaternionUtils.normalize(q)  # Ensure unit quaternion
        q0, q1, q2, q3 = q

        # More numerically stable formulation
        R = np.array([
            [1 - 2*(q2**2 + q3**2), 2*(q1*q2 - q0*q3), 2*(q1*q3 + q0*q2)],
            [2*(q1*q2 + q0*q3), 1 - 2*(q1**2 + q3**2), 2*(q2*q3 - q0*q1)],
            [2*(q1*q3 - q0*q2), 2*(q2*q3 + q0*q1), 1 - 2*(q1**2 + q2**2)]
        ])

        return R

    @staticmethod
    def from_rotation_matrix(R: np.ndarray) -> np.ndarray:
        """
        Convert 3x3 rotation matrix to unit quaternion.
        Uses Shepperd's method for numerical stability.

        Args:
            R: 3x3 rotation matrix

        Returns:
            Unit quaternion [q0, q1, q2, q3]
        """
        R = np.array(R)

        # Shepperd's method - choose largest diagonal element
        trace = np.trace(R)

        if trace > 0:
            s = np.sqrt(trace + 1) * 2  # s = 4 * q0
            q0 = 0.25 * s
            q1 = (R[2, 1] - R[1, 2]) / s
            q2 = (R[0, 2] - R[2, 0]) / s
            q3 = (R[1, 0] - R[0, 1]) / s
        elif R[0, 0] > R[1, 1] and R[0, 0] > R[2, 2]:
            s = np.sqrt(1 + R[0, 0] - R[1, 1] - R[2, 2]) * 2  # s = 4 * q1
            q0 = (R[2, 1] - R[1, 2]) / s
            q1 = 0.25 * s
            q2 = (R[0, 1] + R[1, 0]) / s
            q3 = (R[0, 2] + R[2, 0]) / s
        elif R[1, 1] > R[2, 2]:
            s = np.sqrt(1 + R[1, 1] - R[0, 0] - R[2, 2]) * 2  # s = 4 * q2
            q0 = (R[0, 2] - R[2, 0]) / s
            q1 = (R[0, 1] + R[1, 0]) / s
            q2 = 0.25 * s
            q3 = (R[1, 2] + R[2, 1]) / s
        else:
            s = np.sqrt(1 + R[2, 2] - R[0, 0] - R[1, 1]) * 2  # s = 4 * q3
            q0 = (R[1, 0] - R[0, 1]) / s
            q1 = (R[0, 2] + R[2, 0]) / s
            q2 = (R[1, 2] + R[2, 1]) / s
            q3 = 0.25 * s

        return np.array([q0, q1, q2, q3])

    @staticmethod
    def from_axis_angle(axis: np.ndarray, angle: float) -> np.ndarray:
        """
        Create quaternion from rotation axis and angle.

        Formula: q = [cos(θ/2), sin(θ/2) * û]

        Args:
            axis: 3D rotation axis (will be normalized)
            angle: Rotation angle in radians

        Returns:
            Unit quaternion representing rotation
        """
        axis = np.array(axis, dtype=float)
        axis_norm = np.linalg.norm(axis)

        if axis_norm < 1e-12:
            return np.array([1.0, 0.0, 0.0, 0.0])  # Identity quaternion

        unit_axis = axis / axis_norm
        half_angle = angle / 2

        q0 = np.cos(half_angle)
        q_vec = np.sin(half_angle) * unit_axis

        return np.array([q0, q_vec[0], q_vec[1], q_vec[2]])

    @staticmethod
    def to_axis_angle(q: np.ndarray) -> Tuple[np.ndarray, float]:
        """
        Extract rotation axis and angle from quaternion.

        Args:
            q: Unit quaternion [q0, q1, q2, q3]

        Returns:
            Tuple of (axis, angle) where axis is 3D unit vector
        """
        q = QuaternionUtils.normalize(q)
        q0 = q[0]
        q_vec = q[1:4]

        # Handle identity quaternion
        vec_norm = np.linalg.norm(q_vec)
        if vec_norm < 1e-12:
            return np.array([0.0, 0.0, 1.0]), 0.0

        # Extract axis and angle
        axis = q_vec / vec_norm
        angle = 2 * np.arccos(np.clip(np.abs(q0), 0, 1))

        # Ensure shortest rotation (angle <= π)
        if angle > np.pi:
            angle = 2*np.pi - angle
            axis = -axis

        return axis, angle

    @staticmethod
    def error_quaternion(q_desired: np.ndarray, q_current: np.ndarray) -> np.ndarray:
        """
        Compute quaternion error for control applications.

        Error quaternion: q_e = q_desired * q_current^(-1)
        This represents the rotation needed to go from current to desired.

        Args:
            q_desired: Desired quaternion
            q_current: Current quaternion

        Returns:
            Error quaternion
        """
        q_desired = QuaternionUtils.normalize(q_desired)
        q_current = QuaternionUtils.normalize(q_current)

        q_current_inv = QuaternionUtils.conjugate(q_current)
        q_error = QuaternionUtils.multiply(q_desired, q_current_inv)

        # Ensure shortest path (q and -q represent same rotation)
        if q_error[0] < 0:
            q_error = -q_error

        return q_error

    @staticmethod
    def angular_velocity_to_quaternion_rate(q: np.ndarray, omega: np.ndarray) -> np.ndarray:
        """
        Convert angular velocity to quaternion rate of change.

        Kinematic differential equation:
        q̇ = (1/2) * Ω(ω) * q

        Where Ω(ω) is the angular velocity matrix:
        Ω = [[ 0,   -ωx, -ωy, -ωz],
             [ ωx,   0,   ωz, -ωy],
             [ ωy, -ωz,   0,   ωx],
             [ ωz,  ωy, -ωx,   0]]

        Args:
            q: Current quaternion [q0, q1, q2, q3]
            omega: Angular velocity vector [ωx, ωy, ωz] in rad/s

        Returns:
            Quaternion rate [q̇0, q̇1, q̇2, q̇3]
        """
        q = np.array(q)
        omega = np.array(omega)

        # Angular velocity matrix
        Omega = np.array([
            [0,       -omega[0], -omega[1], -omega[2]],
            [omega[0],    0,      omega[2], -omega[1]],
            [omega[1], -omega[2],    0,      omega[0]],
            [omega[2],  omega[1], -omega[0],    0]
        ])

        # Quaternion rate of change
        q_dot = 0.5 * Omega @ q

        return q_dot

    @staticmethod
    def integrate_angular_velocity(q0: np.ndarray, omega: np.ndarray, dt: float) -> np.ndarray:
        """
        Integrate angular velocity to update quaternion (first-order approximation).

        For small time steps: q(t+dt) ≈ q(t) + q̇*dt
        More accurate methods should use higher-order integration.

        Args:
            q0: Initial quaternion
            omega: Angular velocity vector (assumed constant over dt)
            dt: Time step

        Returns:
            Updated quaternion
        """
        q_dot = QuaternionUtils.angular_velocity_to_quaternion_rate(q0, omega)
        q_new = q0 + q_dot * dt

        # Normalize to maintain unit constraint
        return QuaternionUtils.normalize(q_new)

    @staticmethod
    def slerp(q1: np.ndarray, q2: np.ndarray, t: float) -> np.ndarray:
        """
        Spherical linear interpolation between quaternions.

        SLERP provides smooth interpolation along the shortest path on the
        unit quaternion sphere.

        Args:
            q1: Start quaternion
            q2: End quaternion  
            t: Interpolation parameter [0, 1]

        Returns:
            Interpolated quaternion
        """
        q1 = QuaternionUtils.normalize(q1)
        q2 = QuaternionUtils.normalize(q2)

        # Compute angle between quaternions
        dot = np.dot(q1, q2)

        # If dot < 0, negate one quaternion to take shorter path
        if dot < 0:
            q2 = -q2
            dot = -dot

        # If very close, use linear interpolation to avoid numerical issues
        if dot > 0.9995:
            result = q1 + t * (q2 - q1)
            return QuaternionUtils.normalize(result)

        # Calculate angle and sines
        angle = np.arccos(np.abs(dot))
        sin_angle = np.sin(angle)

        # Compute SLERP
        factor1 = np.sin((1 - t) * angle) / sin_angle
        factor2 = np.sin(t * angle) / sin_angle

        return factor1 * q1 + factor2 * q2

    @staticmethod
    def to_euler_angles(q: np.ndarray, sequence: str = 'ZYX') -> np.ndarray:
        """
        Convert quaternion to Euler angles.

        Args:
            q: Unit quaternion [q0, q1, q2, q3]
            sequence: Rotation sequence (e.g., 'ZYX', 'XYZ')

        Returns:
            Euler angles [φ, θ, ψ] in radians
        """
        R = QuaternionUtils.to_rotation_matrix(q)

        if sequence == 'ZYX':  # Yaw-Pitch-Roll
            # Extract angles from rotation matrix
            phi = np.arctan2(R[2, 1], R[2, 2])     # Roll
            theta = -np.arcsin(R[2, 0])             # Pitch  
            psi = np.arctan2(R[1, 0], R[0, 0])     # Yaw

            return np.array([phi, theta, psi])
        else:
            raise NotImplementedError(f"Sequence {sequence} not implemented")

# Utility functions for common operations
def identity_quaternion() -> np.ndarray:
    """Return identity quaternion [1, 0, 0, 0]."""
    return np.array([1.0, 0.0, 0.0, 0.0])

def random_quaternion() -> np.ndarray:
    """Generate random unit quaternion uniformly distributed on S³."""
    u1, u2, u3 = np.random.uniform(0, 1, 3)

    q = np.array([
        np.sqrt(1 - u1) * np.sin(2 * np.pi * u2),
        np.sqrt(1 - u1) * np.cos(2 * np.pi * u2), 
        np.sqrt(u1) * np.sin(2 * np.pi * u3),
        np.sqrt(u1) * np.cos(2 * np.pi * u3)
    ])

    return q

def skew_symmetric(v: np.ndarray) -> np.ndarray:
    """
    Create skew-symmetric matrix from 3D vector.

    [v]× = [[ 0,   -v2,  v1],
            [ v2,   0,  -v0],
            [-v1,  v0,   0]]
    """
    v = np.array(v)
    return np.array([
        [0,     -v[2],  v[1]],
        [v[2],   0,    -v[0]], 
        [-v[1],  v[0],   0]
    ])

# Test functions for validation
def test_quaternion_operations():
    """Comprehensive test suite for quaternion operations."""
    print("Testing quaternion operations...")

    # Test normalization
    q = np.array([0.5, 0.5, 0.5, 0.5])
    q_norm = QuaternionUtils.normalize(q)
    assert np.abs(np.linalg.norm(q_norm) - 1.0) < 1e-12, "Normalization failed"

    # Test multiplication
    q1 = identity_quaternion()
    q2 = QuaternionUtils.from_axis_angle([0, 0, 1], np.pi/2)
    q_mult = QuaternionUtils.multiply(q1, q2)
    assert np.allclose(q_mult, q2), "Multiplication with identity failed"

    # Test rotation matrix conversion
    q = QuaternionUtils.from_axis_angle([0, 0, 1], np.pi/4)
    R = QuaternionUtils.to_rotation_matrix(q)
    q_back = QuaternionUtils.from_rotation_matrix(R)
    assert np.allclose(np.abs(q), np.abs(q_back)), "Rotation matrix conversion failed"

    # Test conjugate/inverse for unit quaternions
    q = QuaternionUtils.normalize(np.array([1, 2, 3, 4]))
    q_conj = QuaternionUtils.conjugate(q)
    q_mult = QuaternionUtils.multiply(q, q_conj)
    identity = identity_quaternion()
    assert np.allclose(q_mult, identity, atol=1e-12), "Conjugate property failed"

    print("✓ All quaternion tests passed!")

if __name__ == "__main__":
    test_quaternion_operations()
