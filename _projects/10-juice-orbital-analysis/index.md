---
layout: default
categories: [Aerospace, Orbital Mechanics, MATLAB, Math]
title: "Jupiter Icy Moons Explorer Investigation"
description: "Project description here"
image: "image.png"
files:
  - name: "Mission Analysis Report"
    path: "202200281 mission analysis.pdf"
  - name: "Mathematical Analysis"
    path: "JUICE_Mathematical_Analysis.pdf"
  - name: "Replication Report"
    path: "juice_replication_report.pdf"
  - name: "Trajectory Visualization"
    path: "image.png"
  - name: "MATLAB Code - Phase A"
    path: "phaseA_uncommented.m"
  - name: "MATLAB Code - Phase B"
    path: "phaseB_uncommented.m"
---
 
Abdelrahman Al Naqeeb 
March 2025 (updated on January 2026)

## Project Phases

### Phase A: Mission Analysis & SPICE Integration
Phase A focused on the extraction and processing of high-fidelity mission data using **NAIF SPICE kernels**. The investigation involved:
- **Data Acquisition:** Integrating planetary constants and spacecraft ephemeris data.
- **Event Identification:** Precise tracking of key mission milestones, including the **Lunar-Earth Flyby (2024)**, **Venus Flyby (2025)**, and multiple Earth gravity assists.
- **State Vector Analysis:** Calculating position and velocity vectors relative to various celestial bodies to validate the mission timeline.

### Phase B: Trajectory Optimization & Simulation
Phase B shifted towards numerical modeling and optimization of the spacecraft's path:
- **DSM Optimization:** Implementing **Deep Space Maneuver (DSM)** timing optimization using MATLAB's `fmincon` with a Sequential Quadratic Programming (SQP) algorithm.
- **Cost Function Development:** Minimizing the delta-V requirements and matching the simulated trajectory to "truth data" from the ESA mission profile.
- **Lambert Solver Implementation:** Solving the orbital transfer problems between planetary encounters to determine the most efficient trajectory legs.

## Contents

- Introduction
- Construction of the Undertaken System
- Design of the System
- Self-Reflection and Potential Enhancements
- Conclusions
- References


