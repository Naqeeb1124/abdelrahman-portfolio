---
layout: default
categories: [Aerospace, Control Systems, Simulation, Attitude Determination & Control]
title: "Advanced 3U CubeSat Attitude Control System"
description: "This project presents a comprehensive attitude determination and control system (ADCS) for a 3U CubeSat, integrating rigid body dynamics, sensor simulation, Extended Kalman Filter (EKF) state estimation, and PID control with reaction wheel actuation. The simulator validates performance against stringent requirements."
files:
  - name: "Full Report PDF"
    path: "cubesat_attitude_control.pdf"
  - name: "Source Code"
    path: "src/"
---

## Project Overview

This project develops a complete attitude control simulator for a 3U CubeSat mission, emphasizing mathematical rigor and practical implementation. The system includes:

* **Dynamics Modeling:** Nonlinear rigid body dynamics with reaction wheel coupling and environmental disturbances.
* **Sensor Simulation:** High-fidelity models for rate gyroscopes and coarse sun sensors, including noise and bias.
* **State Estimation:** Extended Kalman Filter for joint attitude and gyroscope bias estimation.
* **Control Design:** PID controller with quaternion error handling and anti-windup protection.

The simulator successfully meets all specified criteria:

✅ **Settling Time:** <20 seconds for 30° slew maneuver  
✅ **Steady-State Error:** <0.5° accuracy maintained  
✅ **Wheel Speed Limits:** <6000 RPM operational envelope  
✅ **Disturbance Rejection:** Effective solar pressure compensation  

Key results from the 30° slew simulation include a settling time of 15.2 seconds, steady-state error of 0.08°, and maximum wheel speed of 4,250 RPM, all within specifications. The system demonstrates robust performance against environmental disturbances and is suitable for real-time implementation.
