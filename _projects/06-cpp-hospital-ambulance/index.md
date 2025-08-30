---
layout: default
programming_project: true
title: "06-cpp-hospital-ambulance"
description: "A program that simulates the ambulance service operations and calculates relevant statistics to aid in improving the overall ambulance allocation process."
link: https://github.com/Fatma-Hassaan/Ambulance_management_system
files:
  - name: "Full code(ZIP)"
    path: "Ambulance-management.zip"
---

# Ambulance Management System

## Project Description
This is a complete implementation of the Ambulance Management System as specified in the CIE 205 Data Structures and Algorithms project requirements. The system simulates ambulance service operations across multiple hospitals and calculates relevant statistics.

## Files Included
- **Patient.h / Patient.cpp**: Patient class implementation
- **Car.h / Car.cpp**: Ambulance car class implementation  
- **Hospital.h / Hospital.cpp**: Hospital class with car management and patient queues
- **AmbulanceSystem.h / AmbulanceSystem.cpp**: Main system class handling simulation
- **main.cpp**: Program entry point with interactive and silent modes
- **Makefile**: Compilation configuration
- **sample_input.txt**: Sample input file for testing

## Compilation Instructions
```bash
make
```
or manually:
```bash
g++ -std=c++11 -Wall -Wextra -O2 -c *.cpp
g++ -std=c++11 -o ambulance_system *.o
```

## Running the Program
```bash
./ambulance_system
```

The program will prompt you to:
1. Select mode (Interactive or Silent)
2. Enter input filename
3. Enter output filename

## Input File Format
The input file should follow this format:
- Line 1: Number of hospitals (H)
- Line 2: SC car speed, NC car speed
- Next H lines: Distance matrix between hospitals
- Next H lines: Number of SC cars and NC cars per hospital
- Line: Total number of requests (R)
- Next R lines: Patient requests (TYPE QT PID HID DST [SVR])
- Line: Number of cancellations (C)
- Next C lines: Cancellation requests (CT PID)

## Features Implemented
- Priority-based patient assignment (EP > SP > NP)
- Car type restrictions (EP/NP use NC first, SP uses SC only)
- Patient cancellation handling
- EP request forwarding to other hospitals
- Interactive and Silent simulation modes
- Complete statistics calculation
- Output file generation

## Patient Types
- **EP (Emergency)**: Highest priority, served by severity level
- **SP (Special)**: Can only be served by Special Cars (SC)
- **NP (Normal)**: Served by Normal Cars (NC), can be cancelled

## Car Types  
- **SC (Special Car)**: Can serve EP and SP patients
- **NC (Normal Car)**: Can serve EP and NP patients

## Assignment Priority
1. EP patients (by severity, highest first)
2. SP patients (FCFS, SC cars only)
3. NP patients (FCFS, NC cars only)

## Clean Up
```bash
make clean
```

## Sample Usage
```bash
make
./ambulance_system
# Select mode 2 (Silent)
# Enter: sample_input.txt
# Enter: output.txt
```


