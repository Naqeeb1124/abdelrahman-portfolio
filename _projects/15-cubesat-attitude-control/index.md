---
layout: default
categories: [Aerospace, Control Systems, Simulation]
title: "CubeSat ADCS Design"
image: "image.png"
description: "Programmatic development of a 1U CubeSat Attitude Control System (ADCS) using MATLAB/Simulink API. Features a B-Dot detumbling controller and Nadir-pointing GNC loops."
files:
  - name: "Technical Report"
    path: "CubeSat_ADCS_Report.pdf"
  - name: "Nadir Pointing Model"
    path: "CubeSat_ADCS_Nadir.slx"
  - name: "RWA Simple Model"
    path: "CubeSat_RWA_Simple.slx"
  - name: "Initialization Script"
    path: "init_sim.m"
  - name: "3D Visualization Script"
    path: "visualize_cubesat.m"
---

## Overview
This project involves the end-to-end development of an Attitude Control System (ADCS) for a 1U CubeSat. The simulation architecture was constructed programmatically using the MATLAB/Simulink API, allowing for rapid parameter iteration and a "Digital Twin" approach to GNC (Guidance, Navigation, and Control) development.

## Key Features
- **Programmatic Model Generation:** Built entirely through code, resolving critical API dimension errors and ensuring a robust simulation framework.
- **B-Dot Controller:** Implemented for satellite detumbling, successfully dissipating kinetic energy to bring the spacecraft into a stable state relative to the magnetic field.
- **Nadir-Pointing Control:** A quaternion-based PD controller that pitches the satellite to track the Earth (Nadir) during its orbit.
- **Actuator Modeling:** Includes detailed models for Reaction Wheel Assemblies (RWA) and Magnetorquers.
- **3D Visualization:** A custom MATLAB script for real-time animation of the CubeSat's attitude and orbital position.

## Technical Details
- **Satellite Type:** 1U CubeSat (1.33 kg, 10x10x10 cm).
- **Control Laws:** B-Dot for detumbling and Quaternion PD for pointing.
- **Environment:** Low Earth Orbit (LEO) magnetic field modeling.
- **Solver:** Fixed-step Runge-Kutta (ode4) with 0.1s sampling time.

## Results
The simulation confirms that the detumbling phase is completed within approximately 1.5 orbits (90 minutes). The Nadir-pointing controller achieves stable tracking with minimal error, as verified by the 3D attitude reconstruction.

## How to Run
1. Run `init_sim.m` to load parameters into the workspace.
2. Open and run `CubeSat_ADCS_Nadir.slx` or `CubeSat_RWA_Simple.slx`.
3. After simulation, run `visualize_cubesat.m` to view the 3D animation.
