# Abdelrahman Mohamed Alnaqeeb — Engineering Portfolio

**Website:** https://naqeeb1124.github.io/abdelrahman-portfolio/
**Location:** Dubai, UAE / Giza, Egypt
**Email:** abdelrahmanalnaqeeb@gmail.com

B.Sc. Aerospace Engineering student at Zewail City of Science and Technology (expected June 2027). Research interests: guidance, navigation and control (flight control, multi-agent guidance) and optimization (PDE-constrained and topology optimization, optimal control, CFD).

This repository is the source of the website. Each project lives in `_projects/<folder>/`, with an `index.md` page (summary, results, files) plus its report, code, and CAD.

## Aerospace, controls & engineering

- [CubeSat ADCS Design](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/15-cubesat-attitude-control/index): B-dot detumbling and quaternion nadir pointing in MATLAB/Simulink
- [Jupiter Icy Moons Explorer (JUICE) Trajectory](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/10-juice-orbital-analysis/index): SPICE kernels, Lambert arcs, and DSM optimization with fmincon
- [Topology Optimization of a Satellite Bracket](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/14-topopt-satellite-bracket/index): SIMP and adjoint sensitivities for a 65% mass reduction
- [ASME Cold Plate Design Competition](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/08-cold-plate-topopt/index): 10 fin concepts and a topology-optimized channel layout
- [Active Suspension Design (LQR)](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/18-active-suspension-design/index): quarter-car LQR with ISO 8608 road profiles
- [Robotic Arm Design & Control](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/19-robotic-arm/index): 3-DOF kinematics with a MATLAB digital twin and Arduino
- [Simplex Method for Linear Programming](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/12-simplex-method-implementation/index): MATLAB implementation
- [CFD Analysis of NACA0015 Airfoil](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/11-naca0015-cfd-study/index): Ansys, k-omega SST, comparison with experiment
- [Joukowsky Airfoil Analysis](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/23-joukowsky-analysis/index): conformal mapping in MATLAB and CFD in Ansys
- [Joukowsky Airfoils (potential flow)](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/03-joukowski-airfoil-tool/index): theory and a Python visualizer
- [Ramjet Engine Design](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/21-ramjet-design/index) and [Rocket Engine Design](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/22-rocket-engine/index): gas dynamics in MATLAB
- [Matched Filter Design](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/20-matched-filter-design/index): PAM symbol error rate, MATLAB/Simulink
- [Two-Stage Gearbox Design](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/07-gearbox-design/index): gears, shafts, and bearings
- [Glider Design Project](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/01-glider-design/index): OpenVSP analysis, built and flight-tested
- [Rocket Part CAD + CAM](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/04-rocket-part-cad-cam/index): SolidWorks and Mastercam
- [Aquaponics System Design](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/02-aquaponics-design/index): fluid-mechanics sizing

## Software & data science

- [Web-Based Airfoil Coordinate Generator](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/16-airfoil-coord-generator-xyz/index): Flask and React
- [Latex Equation Extractor](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/17-latex-equation-extractor/index): TypeScript ([repo](https://github.com/Naqeeb1124/latex-equation-extractor))
- [Shape Hunt Game](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/05-cpp-shape-matching-game/index): object-oriented C++ ([repo](https://github.com/Naqeeb1124/FOR-C-PROJECT))
- [Ambulance Management System](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/06-cpp-hospital-ambulance/index): C++ data structures ([repo](https://github.com/Fatma-Hassaan/Ambulance_management_system))
- [Empower Kids](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/13-child-development-program-website/index): business plan and React website ([repo](https://github.com/Naqeeb1124/Child-development-Project-Website))
- Machine learning exercises: [Medical Insurance Premium](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/30-Machine-Learning-InsurancePremium/index) · [Breast Cancer Diagnosis](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/27-Machine-Learning-DiseasePrediction/index) · [Credit Scoring](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/25-Machine-Learning-CreditScoring/index) · [Handwritten Digits](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/26-Machine-Learning-HandwrittenRecognition/index) · [Stock Time Series](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/28-Machine-Learning-TimeSeriesAnalysis/index) · [House Prices](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/29-Machine-Learning-HousePrice/index) · [Emotion Recognition](https://naqeeb1124.github.io/abdelrahman-portfolio/projects/24-Machine-Learning-EmotionRecognition/index)

## Adding a project

1. Create `_projects/NN-short-name/` and add an `index.md` with front matter: `title`, `description` (one or two sentences with real results), `categories`, `image`, and `files` (each with `name` and `path`).
2. Large binaries (CAD, `.zip`, simulation results) are stored with Git LFS (see `.gitattributes`). GitHub Pages cannot serve LFS files, so the layout automatically links those extensions through `media.githubusercontent.com`. If you add a new LFS extension, add it to both `.gitattributes` and the `lfs_exts` list in `_layouts/default.html`.
3. Don't commit virtual environments, `node_modules`, or Simulink caches (`slprj/`, `*.slxc`); `.gitignore` already excludes them.

## License
MIT — feel free to reuse code with attribution.
