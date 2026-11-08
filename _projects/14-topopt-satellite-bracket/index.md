---
layout: default
categories: [Mechanical Design, Simulation, CAD, Math, Python, Topology Optimization]
title: "Topology Optimization of a Satellite Bracket"
image: "image.png"
description: "Topology optimization of an Al 7075-T6 satellite bracket: mass minimization subject to compliance and stress constraints under multiple launch load cases. It uses SIMP with adjoint sensitivities, P-norm stress aggregation, and MMA. The optimized design is 65% lighter at a 35% volume fraction, keeps a safety factor of 1.50, and forms three bone-like gussets."
files:
  - name: "Mathematical Analysis (report)"
    path: "analysis-and-code/Topology_optimization_of_Satellite_Bracket.pdf"
  - name: "Python outline of the optimization loop"
    path: "analysis-and-code/topology_optimization.py"
  - name: "Bracket CAD file"
    path: "bracket.SLDPRT"
---

## Project Overview

The goal was a lightweight satellite bracket that still meets its structural requirements under multiple launch load cases.

*   **Formulation:** Mass minimization subject to compliance and von Mises stress constraints. Material: Al 7075-T6, chosen for its strength-to-weight ratio and space heritage.
*   **Method:** SIMP material interpolation, adjoint sensitivity analysis for compliance and stress (with P-norm aggregation), density filtering, Heaviside projection, and the Method of Moving Asymptotes (MMA).
*   **Result:** At a 35% volume fraction the bracket is **65% lighter**. Maximum von Mises stress rises from 124.2 MPa to 334.7 MPa, giving a safety factor of 1.50 (4.05 for the solid part). The design stays clear of resonance in the 50–150 Hz launch excitation range. The optimized geometry forms three bone-like gussets along the main load paths.
*   **Post-processing:** Elements with density above 0.5 are extracted with marching cubes into a watertight STL surface for manufacturing.

The Python file is a structural outline of the optimization loop (element stiffness, compliance sensitivity, density filter, Heaviside projection) that accompanies the report. It is not a complete solver.
