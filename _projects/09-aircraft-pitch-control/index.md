---
layout: default
categories: [Aerospace, Control Systems]
title: "Aircraft Pitch System Control"
image: "image.png"
description: "Classical control design for an aircraft pitch-attitude model: pole-zero, Routh-Hurwitz, and root-locus analysis, then PID tuning by hand and in Simulink. The final gains (Kp = 5.185, Ki = 1.74, Kd = 2.98) meet every specification: 7.5% overshoot, 0.413 s rise time, 9.25 s settling time, and zero steady-state error. Team of 2."
files:
  - name: "Control Project Report"
    path: "control_project-3.pdf"
  - name: "Closed Loop Analysis Code"
    path: "code/closed_loop_analysis.m"
  - name: "Controller Design Code"
    path: "code/controller_design.m"
  - name: "Simulink Model Creation Code"
    path: "code/create_simulink_models.m"
  - name: "Main Pitch Control Code"
    path: "code/main_pitch_control.m"
  - name: "Open Loop Analysis Code"
    path: "code/open_loop_analysis.m"
  - name: "PID Tuner Analysis Code"
    path: "code/pid_tuner_analysis.m"
  - name: "Complete Analysis Runner"
    path: "code/run_complete_analysis.m"
---
 
## Institution
Zewail City for Science and Technology    
Date: May 16, 2025

## Contents
- Abstract
1. Introduction
   - Aircraft Pitch Motion
   - Project Objectives
2. System Modeling
   - Transfer Function
3. Classical Control Analysis
   - Pole-Zero Analysis
   - Stability Analysis (Routh-Hurwitz)
   - Root Locus Analysis
   - PID Tuning
     - PID Transfer Function
     - Hand Tuning of PID Controller
     - Simulink
     - Simulink Tuning
     - Second Method of Tuning
   - Simulink Model
   - Conclusion
- References


