---
layout: default
categories: [Aerospace, Control Systems, Simulation, Attitude Determination & Control]
title: "Advanced 3U CubeSat Attitude Control System"
description: "This project presents a comprehensive attitude determination and control system (ADCS) for a 3U CubeSat, integrating rigid body dynamics, sensor simulation, Extended Kalman Filter (EKF) state estimation, and PID control with reaction wheel actuation. The simulator validates performance against stringent requirements."
files:
  - name: "Full Report PDF"
    path: "cubesat_attitude_control.pdf"
  - name: "Source Code (ZIP)"
    path: "src/source-code-controlsystem.zip"
---

## Project Overview

This project develops a complete attitude control simulator for a 3U CubeSat mission, emphasizing mathematical rigor and practical implementation. The system includes:

* **Dynamics Modeling:** Nonlinear rigid body dynamics with reaction wheel coupling and environmental disturbances.
* **Sensor Simulation:** High-fidelity models for rate gyroscopes and coarse sun sensors, including noise and bias.
* **State Estimation:** Extended Kalman Filter for joint attitude and gyroscope bias estimation.
* **Control Design:** PID controller with quaternion error handling and anti-windup protection.

The simulator successfully meets all specified criteria:

**Settling Time:** <20 seconds for 30° slew maneuver  
**Steady-State Error:** <0.5° accuracy maintained  
**Wheel Speed Limits:** <6000 RPM operational envelope  
**Disturbance Rejection:** Effective solar pressure compensation  

Key results from the 30° slew simulation include a settling time of 15.2 seconds, steady-state error of 0.08°, and maximum wheel speed of 4,250 RPM, all within specifications. The system demonstrates robust performance against environmental disturbances and is suitable for real-time implementation.

## Running the Code

To run the CubeSat Attitude Control System code:

1.  **Extract the ZIP file:** Unzip `source-code-controlsystem.zip` to a directory of your choice.
2.  **Install dependencies:** The code is written in Python and uses `numpy` and `scipy`. You can install them using pip:
    ```bash
    pip install numpy scipy
    ```
3.  **Execute the PID Controller Test:** The `control_pid.py` file contains a test function that demonstrates the PID controller and its interaction with the dynamics model. Navigate to the `src` directory (where you unzipped the files) in your terminal and run:
    ```bash
    python control_pid.py
    ```
    This will execute `test_pid_controller()` and print various control and performance metrics.

4.  **Explore other modules:** Each Python file (`dynamics.py`, `ekf.py`, `quaternion_utils.py`, `sensors.py`) also contains a `if __name__ == "__main__":` block that runs its own set of tests. You can execute them similarly (e.g., `python dynamics.py`) to understand individual components.

5.  **Building a full simulation:** For a complete simulation, you would typically integrate these modules. The `analyze_step_response` function within `control_pid.py` provides an example of how the controller interacts with the dynamics. You can adapt this function or create a new script to build a custom simulation.