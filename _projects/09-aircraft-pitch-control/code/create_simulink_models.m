% REE 310 Course Project - Aircraft Pitch Control System
% Simulink Model Creation Script
% This script provides code structure for creating Simulink models

clear all; clc; close all;

% Load system parameters
load('aircraft_pitch_parameters.mat');
load('controller_design.mat');

fprintf('===================================================\n');
fprintf('   SIMULINK MODEL CREATION GUIDE\n');
fprintf('===================================================\n\n');

%% Model Parameters
fprintf('1. SYSTEM PARAMETERS FOR SIMULINK\n');
fprintf('---------------------------------\n');

fprintf('Aircraft Pitch System Parameters:\n');
fprintf('Transfer Function Numerator: [%.6f]\n', K);
fprintf('Transfer Function Denominator: [1 %.4f %.6f]\n', a, b);
fprintf('\n');

fprintf('PID Controller Parameters:\n');
fprintf('Kp (Proportional): %.6f\n', Kp_final);
fprintf('Ki (Integral):     %.6f\n', Ki_final);
fprintf('Kd (Derivative):   %.6f\n', Kd_final);
fprintf('\n');

%% Create Open-Loop Simulink Model Structure
fprintf('2. OPEN-LOOP MODEL CREATION\n');
fprintf('---------------------------\n');

model_name_ol = 'aircraft_pitch_openloop';

fprintf('Creating open-loop model: %s.slx\n', model_name_ol);

% Create new Simulink model
new_system(model_name_ol);
open_system(model_name_ol);

% Add blocks to the model
add_block('simulink/Sources/Step', [model_name_ol '/Step_Input']);
add_block('simulink/Continuous/Transfer Fcn', [model_name_ol '/Aircraft_Dynamics']);
add_block('simulink/Sinks/Scope', [model_name_ol '/Pitch_Angle_Output']);
add_block('simulink/Sinks/To Workspace', [model_name_ol '/To_Workspace_Output']);

% Configure Transfer Function block
set_param([model_name_ol '/Aircraft_Dynamics'], 'Numerator', mat2str(K));
set_param([model_name_ol '/Aircraft_Dynamics'], 'Denominator', mat2str([1, a, b]));

% Configure Step Input
set_param([model_name_ol '/Step_Input'], 'Time', '0');
set_param([model_name_ol '/Step_Input'], 'After', '1');
set_param([model_name_ol '/Step_Input'], 'SampleTime', '0');

% Configure To Workspace block
set_param([model_name_ol '/To_Workspace_Output'], 'VariableName', 'pitch_angle_ol');
set_param([model_name_ol '/To_Workspace_Output'], 'MaxDataPoints', 'inf');

% Position blocks
set_param([model_name_ol '/Step_Input'], 'Position', [50, 100, 80, 130]);
set_param([model_name_ol '/Aircraft_Dynamics'], 'Position', [150, 90, 230, 140]);
set_param([model_name_ol '/Pitch_Angle_Output'], 'Position', [300, 95, 350, 125]);
set_param([model_name_ol '/To_Workspace_Output'], 'Position', [300, 150, 380, 180]);

% Add connections
add_line(model_name_ol, 'Step_Input/1', 'Aircraft_Dynamics/1');
add_line(model_name_ol, 'Aircraft_Dynamics/1', 'Pitch_Angle_Output/1');
add_line(model_name_ol, 'Aircraft_Dynamics/1', 'To_Workspace_Output/1');

% Add annotations
add_block('built-in/Note', [model_name_ol '/Title']);
set_param([model_name_ol '/Title'], 'Position', [50, 50, 200, 70]);
set_param([model_name_ol '/Title'], 'Text', 'Aircraft Pitch Control - Open Loop');

% Save the model
save_system(model_name_ol);

fprintf('✓ Open-loop model created and saved\n\n');

%% Create Closed-Loop Simulink Model Structure
fprintf('3. CLOSED-LOOP MODEL CREATION\n');
fprintf('-----------------------------\n');

model_name_cl = 'aircraft_pitch_closedloop';

fprintf('Creating closed-loop model: %s.slx\n', model_name_cl);

% Create new Simulink model
new_system(model_name_cl);
open_system(model_name_cl);

% Add blocks to the model
add_block('simulink/Sources/Step', [model_name_cl '/Reference_Input']);
add_block('simulink/Math Operations/Sum', [model_name_cl '/Error_Sum']);
add_block('simulink/Continuous/PID Controller', [model_name_cl '/PID_Controller']);
add_block('simulink/Continuous/Transfer Fcn', [model_name_cl '/Aircraft_Dynamics']);
add_block('simulink/Sinks/Scope', [model_name_cl '/Pitch_Angle_Scope']);
add_block('simulink/Sinks/Scope', [model_name_cl '/Control_Signal_Scope']);
add_block('simulink/Sinks/To Workspace', [model_name_cl '/Output_To_Workspace']);
add_block('simulink/Sinks/To Workspace', [model_name_cl '/Control_To_Workspace']);

% Configure blocks
% Transfer Function
set_param([model_name_cl '/Aircraft_Dynamics'], 'Numerator', mat2str(K));
set_param([model_name_cl '/Aircraft_Dynamics'], 'Denominator', mat2str([1, a, b]));

% PID Controller
set_param([model_name_cl '/PID_Controller'], 'P', num2str(Kp_final));
set_param([model_name_cl '/PID_Controller'], 'I', num2str(Ki_final));
set_param([model_name_cl '/PID_Controller'], 'D', num2str(Kd_final));

% Sum block for error calculation
set_param([model_name_cl '/Error_Sum'], 'Inputs', '+-');

% Step Input
set_param([model_name_cl '/Reference_Input'], 'Time', '0');
set_param([model_name_cl '/Reference_Input'], 'After', '1');

% To Workspace blocks
set_param([model_name_cl '/Output_To_Workspace'], 'VariableName', 'pitch_angle_cl');
set_param([model_name_cl '/Output_To_Workspace'], 'MaxDataPoints', 'inf');
set_param([model_name_cl '/Control_To_Workspace'], 'VariableName', 'control_signal');
set_param([model_name_cl '/Control_To_Workspace'], 'MaxDataPoints', 'inf');

% Position blocks
set_param([model_name_cl '/Reference_Input'], 'Position', [50, 100, 80, 130]);
set_param([model_name_cl '/Error_Sum'], 'Position', [130, 100, 160, 130]);
set_param([model_name_cl '/PID_Controller'], 'Position', [200, 90, 260, 140]);
set_param([model_name_cl '/Aircraft_Dynamics'], 'Position', [300, 90, 380, 140]);
set_param([model_name_cl '/Pitch_Angle_Scope'], 'Position', [430, 95, 480, 125]);
set_param([model_name_cl '/Control_Signal_Scope'], 'Position', [280, 180, 330, 210]);
set_param([model_name_cl '/Output_To_Workspace'], 'Position', [430, 150, 510, 180]);
set_param([model_name_cl '/Control_To_Workspace'], 'Position', [280, 220, 360, 250]);

% Add connections
add_line(model_name_cl, 'Reference_Input/1', 'Error_Sum/1');
add_line(model_name_cl, 'Error_Sum/1', 'PID_Controller/1');
add_line(model_name_cl, 'PID_Controller/1', 'Aircraft_Dynamics/1');
add_line(model_name_cl, 'Aircraft_Dynamics/1', 'Pitch_Angle_Scope/1');
add_line(model_name_cl, 'Aircraft_Dynamics/1', 'Output_To_Workspace/1');
add_line(model_name_cl, 'PID_Controller/1', 'Control_Signal_Scope/1');
add_line(model_name_cl, 'PID_Controller/1', 'Control_To_Workspace/1');

% Add feedback line
add_line(model_name_cl, 'Aircraft_Dynamics/1', 'Error_Sum/2', 'autorouting', 'on');

% Add annotations
add_block('built-in/Note', [model_name_cl '/Title']);
set_param([model_name_cl '/Title'], 'Position', [50, 50, 250, 70]);
set_param([model_name_cl '/Title'], 'Text', 'Aircraft Pitch Control - Closed Loop with PID');

% Save the model
save_system(model_name_cl);

fprintf('✓ Closed-loop model created and saved\n\n');

%% Create Comparison Model
fprintf('4. COMPARISON MODEL CREATION\n');
fprintf('----------------------------\n');

model_name_comp = 'aircraft_pitch_comparison';

fprintf('Creating comparison model: %s.slx\n', model_name_comp);

% Create new Simulink model for comparison
new_system(model_name_comp);
open_system(model_name_comp);

% This model will have both open-loop and closed-loop responses on the same plot
add_block('simulink/Sources/Step', [model_name_comp '/Reference_Input']);
add_block('simulink/Math Operations/Sum', [model_name_comp '/Error_Sum']);
add_block('simulink/Continuous/PID Controller', [model_name_comp '/PID_Controller']);
add_block('simulink/Continuous/Transfer Fcn', [model_name_comp '/Aircraft_Dynamics_CL']);
add_block('simulink/Continuous/Transfer Fcn', [model_name_comp '/Aircraft_Dynamics_OL']);
add_block('simulink/Sinks/Scope', [model_name_comp '/Comparison_Scope']);
add_block('simulink/Signal Routing/Mux', [model_name_comp '/Mux_Signals']);

% Configure identical transfer functions
set_param([model_name_comp '/Aircraft_Dynamics_CL'], 'Numerator', mat2str(K));
set_param([model_name_comp '/Aircraft_Dynamics_CL'], 'Denominator', mat2str([1, a, b]));
set_param([model_name_comp '/Aircraft_Dynamics_OL'], 'Numerator', mat2str(K));
set_param([model_name_comp '/Aircraft_Dynamics_OL'], 'Denominator', mat2str([1, a, b]));

% Configure PID Controller
set_param([model_name_comp '/PID_Controller'], 'P', num2str(Kp_final));
set_param([model_name_comp '/PID_Controller'], 'I', num2str(Ki_final));
set_param([model_name_comp '/PID_Controller'], 'D', num2str(Kd_final));

% Configure other blocks
set_param([model_name_comp '/Error_Sum'], 'Inputs', '+-');
set_param([model_name_comp '/Reference_Input'], 'After', '1');
set_param([model_name_comp '/Mux_Signals'], 'Inputs', '2');

% Add connections for closed-loop
add_line(model_name_comp, 'Reference_Input/1', 'Error_Sum/1');
add_line(model_name_comp, 'Error_Sum/1', 'PID_Controller/1');
add_line(model_name_comp, 'PID_Controller/1', 'Aircraft_Dynamics_CL/1');

% Add connection for open-loop (direct from reference)
add_line(model_name_comp, 'Reference_Input/1', 'Aircraft_Dynamics_OL/1');

% Add feedback for closed-loop
add_line(model_name_comp, 'Aircraft_Dynamics_CL/1', 'Error_Sum/2', 'autorouting', 'on');

% Connect to comparison scope
add_line(model_name_comp, 'Aircraft_Dynamics_CL/1', 'Mux_Signals/1');
add_line(model_name_comp, 'Aircraft_Dynamics_OL/1', 'Mux_Signals/2');
add_line(model_name_comp, 'Mux_Signals/1', 'Comparison_Scope/1');

% Save the model
save_system(model_name_comp);

fprintf('✓ Comparison model created and saved\n\n');

%% Simulation Configuration
fprintf('5. SIMULATION CONFIGURATION\n');
fprintf('---------------------------\n');

% Set simulation parameters for all models
models = {model_name_ol, model_name_cl, model_name_comp};

for i = 1:length(models)
    model = models{i};

    % Set simulation parameters
    set_param(model, 'StopTime', '10');
    set_param(model, 'SolverType', 'Variable-step');
    set_param(model, 'Solver', 'ode45');
    set_param(model, 'MaxStep', '0.01');

    fprintf('✓ Configured simulation parameters for %s\n', model);
end

fprintf('\n');

%% Manual Model Creation Instructions
fprintf('6. MANUAL SIMULINK MODEL CREATION\n');
fprintf('---------------------------------\n');

fprintf('If automatic model creation fails, follow these steps manually:\n\n');

fprintf('OPEN-LOOP MODEL (%s):\n', [model_name_ol '.slx']);
fprintf('1. Create new Simulink model\n');
fprintf('2. Add blocks:\n');
fprintf('   - Step (Sources library)\n');
fprintf('   - Transfer Fcn (Continuous library)\n');
fprintf('   - Scope (Sinks library)\n');
fprintf('3. Configure Transfer Function:\n');
fprintf('   - Numerator: [%.6f]\n', K);
fprintf('   - Denominator: [1 %.4f %.6f]\n', a, b);
fprintf('4. Connect: Step → Transfer Fcn → Scope\n\n');

fprintf('CLOSED-LOOP MODEL (%s):\n', [model_name_cl '.slx']);
fprintf('1. Create new Simulink model\n');
fprintf('2. Add blocks:\n');
fprintf('   - Step (Sources)\n');
fprintf('   - Sum (Math Operations)\n');
fprintf('   - PID Controller (Continuous)\n');
fprintf('   - Transfer Fcn (Continuous)\n');
fprintf('   - Scope × 2 (Sinks)\n');
fprintf('3. Configure PID Controller:\n');
fprintf('   - P: %.6f\n', Kp_final);
fprintf('   - I: %.6f\n', Ki_final);
fprintf('   - D: %.6f\n', Kd_final);
fprintf('4. Configure Transfer Function (same as open-loop)\n');
fprintf('5. Configure Sum block: Inputs = '+-'\n');
fprintf('6. Connect:\n');
fprintf('   - Step → Sum(+)\n');
fprintf('   - Sum → PID Controller → Transfer Fcn → Scope (output)\n');
fprintf('   - Transfer Fcn output → Sum(-) [feedback]\n');
fprintf('   - PID Controller → Scope (control signal)\n\n');

%% PID Tuner Usage
fprintf('7. USING SIMULINK PID TUNER\n');
fprintf('---------------------------\n');

fprintf('To use Simulink PID Tuner:\n');
fprintf('1. Open the closed-loop model\n');
fprintf('2. Right-click on PID Controller block\n');
fprintf('3. Select "Tune..." from context menu\n');
fprintf('4. PID Tuner app will open\n');
fprintf('5. Adjust sliders for:\n');
fprintf('   - Response Time (faster ← → slower)\n');
fprintf('   - Transient Behavior (aggressive ← → robust)\n');
fprintf('6. Compare with manual design:\n');
fprintf('   - Manual: Kp=%.4f, Ki=%.4f, Kd=%.4f\n', Kp_final, Ki_final, Kd_final);
fprintf('7. Import tuned values or keep manual design\n\n');

%% File Generation Summary
fprintf('8. GENERATED FILES SUMMARY\n');
fprintf('-------------------------\n');

fprintf('MATLAB Scripts:\n');
fprintf('✓ main_aircraft_pitch.m - Main analysis script\n');
fprintf('✓ open_loop_analysis.m - Open-loop system analysis\n');
fprintf('✓ controller_design.m - PID design using Root Locus\n');
fprintf('✓ closed_loop_analysis.m - Closed-loop performance analysis\n');
fprintf('✓ pid_tuner_analysis.m - PID tuner comparison\n\n');

fprintf('Simulink Models:\n');
fprintf('✓ %s.slx - Open-loop aircraft pitch system\n', model_name_ol);
fprintf('✓ %s.slx - Closed-loop with PID controller\n', model_name_cl);
fprintf('✓ %s.slx - Open-loop vs closed-loop comparison\n', model_name_comp);

fprintf('\nData Files:\n');
fprintf('✓ aircraft_pitch_parameters.mat - System parameters\n');
fprintf('✓ controller_design.mat - PID controller design\n');
fprintf('✓ closed_loop_analysis.mat - Closed-loop analysis results\n');
fprintf('✓ pid_tuner_analysis.mat - PID tuning comparison\n\n');

fprintf('All files have been generated successfully!\n');
fprintf('Start with: run main_aircraft_pitch.m\n\n');

% Save model information
save('simulink_models.mat', 'model_name_ol', 'model_name_cl', 'model_name_comp', ...
     'K', 'a', 'b', 'Kp_final', 'Ki_final', 'Kd_final');

fprintf('Simulink model information saved to simulink_models.mat\n');
