% REE 310 Course Project - Aircraft Pitch Control System
% PID Controller Design Script
% This script designs a PID controller using Root Locus technique

clear all; clc; close all;

% Load system parameters
load('aircraft_pitch_parameters.mat');

fprintf('===================================================\n');
fprintf('   PID CONTROLLER DESIGN - ROOT LOCUS METHOD\n');
fprintf('===================================================\n\n');

%% Design Specifications
fprintf('1. CONTROL DESIGN SPECIFICATIONS\n');
fprintf('--------------------------------\n');

% Desired closed-loop performance specifications
overshoot_spec = 10;     % Maximum overshoot (%)
settling_time_spec = 2;  % Settling time (s)
rise_time_spec = 1;      % Rise time (s)
ess_spec = 0;           % Steady-state error for step input

fprintf('Design Specifications:\n');
fprintf('- Maximum Overshoot:    %.1f%%\n', overshoot_spec);
fprintf('- Settling Time:        %.1f s\n', settling_time_spec);
fprintf('- Rise Time:            %.1f s\n', rise_time_spec);
fprintf('- Steady-State Error:   %.1f (for step input)\n', ess_spec);
fprintf('\n');

% Convert specifications to pole locations
zeta_desired = sqrt((log(overshoot_spec/100))^2 / (pi^2 + (log(overshoot_spec/100))^2));
wn_desired = 4 / (zeta_desired * settling_time_spec); % Approximate 2% settling time

fprintf('Equivalent Pole Specifications:\n');
fprintf('- Desired Damping Ratio:    %.4f\n', zeta_desired);
fprintf('- Desired Natural Freq:     %.4f rad/s\n', wn_desired);
fprintf('\n');

%% PID Controller Structure
fprintf('2. PID CONTROLLER DESIGN\n');
fprintf('------------------------\n');

% PID Controller: C(s) = Kp + Ki/s + Kd*s = (Kd*s^2 + Kp*s + Ki)/s
% For step input with zero steady-state error, we need Type 1 system (integrator)

% Initial PID parameters (to be tuned using root locus)
Kp_initial = 1;
Ki_initial = 1;
Kd_initial = 0.1;

% Create initial PID controller
C_initial = pid(Kp_initial, Ki_initial, Kd_initial);

fprintf('Initial PID Controller:\n');
fprintf('Kp = %.3f, Ki = %.3f, Kd = %.3f\n', Kp_initial, Ki_initial, Kd_initial);
disp(C_initial);

%% Root Locus Design Process
fprintf('\n3. ROOT LOCUS DESIGN PROCESS\n');
fprintf('----------------------------\n');

% Step 1: Add integral action (Type 1 system)
s = tf('s');
Gi = G / s; % Add integrator for zero steady-state error

fprintf('Step 1: Adding Integrator\n');
fprintf('Modified Plant: G_i(s) = G(s)/s\n');

% Root locus of G(s)/s
figure('Name', 'Root Locus - With Integrator', 'Position', [100, 100, 900, 700]);
rlocus(Gi);
grid on;
title('Root Locus of G(s)/s (With Integrator)');
xlabel('Real Part');
ylabel('Imaginary Part');

% Add desired pole locations
desired_poles = [-zeta_desired*wn_desired + 1j*wn_desired*sqrt(1-zeta_desired^2), ...
                 -zeta_desired*wn_desired - 1j*wn_desired*sqrt(1-zeta_desired^2)];

hold on;
plot(real(desired_poles), imag(desired_poles), 'r*', 'MarkerSize', 15, 'LineWidth', 3);
legend('Root Locus', 'Desired Poles', 'Location', 'best');

% Find gain for desired poles
[K_integral, poles_achieved] = rlocfind(Gi, desired_poles(1));

fprintf('Integral Gain Selected: K = %.4f\n', K_integral);
fprintf('Achieved Poles:\n');
for i = 1:length(poles_achieved)
    if imag(poles_achieved(i)) == 0
        fprintf('  %.4f\n', poles_achieved(i));
    else
        fprintf('  %.4f %+.4fi\n', real(poles_achieved(i)), imag(poles_achieved(i)));
    end
end

% Save root locus plot
saveas(gcf, 'root_locus_integrator.png');

%% PD Controller Design for Improved Response
fprintf('\nStep 2: PD Controller Design\n');

% Add derivative action to improve transient response
% PD Controller: C_pd(s) = Kp + Kd*s
Kp_pd = K_integral;
Kd_pd = 0.5; % Initial guess

% PID with integral gain from root locus
Kp_design = Kp_pd;
Ki_design = K_integral;
Kd_design = Kd_pd;

C_designed = pid(Kp_design, Ki_design, Kd_design);

fprintf('Designed PID Controller (Root Locus Method):\n');
fprintf('Kp = %.4f, Ki = %.4f, Kd = %.4f\n', Kp_design, Ki_design, Kd_design);
disp(C_designed);

%% Closed-Loop Analysis
fprintf('\n4. CLOSED-LOOP SYSTEM ANALYSIS\n');
fprintf('-------------------------------\n');

% Closed-loop transfer function
T_designed = feedback(C_designed * G, 1);

fprintf('Closed-Loop Transfer Function:\n');
disp(T_designed);

% Closed-loop poles
cl_poles = pole(T_designed);
fprintf('Closed-Loop Poles:\n');
for i = 1:length(cl_poles)
    if imag(cl_poles(i)) == 0
        fprintf('  %.4f\n', cl_poles(i));
    else
        fprintf('  %.4f %+.4fi\n', real(cl_poles(i)), imag(cl_poles(i)));
    end
end

% Check stability
if all(real(cl_poles) < 0)
    fprintf('✓ Closed-loop system is STABLE\n');
else
    fprintf('⚠ Closed-loop system is UNSTABLE\n');
end

%% Performance Evaluation
fprintf('\n5. PERFORMANCE EVALUATION\n');
fprintf('--------------------------\n');

% Step response of closed-loop system
t = 0:0.01:8;
[y_cl, t_cl] = step(T_designed, t);

% Get step response characteristics
step_info_cl = stepinfo(T_designed);

fprintf('Achieved Performance:\n');
fprintf('Rise Time:       %.3f s (Spec: < %.1f s) %s\n', ...
    step_info_cl.RiseTime, rise_time_spec, ...
    iif(step_info_cl.RiseTime <= rise_time_spec, '✓', '✗'));
fprintf('Settling Time:   %.3f s (Spec: < %.1f s) %s\n', ...
    step_info_cl.SettlingTime, settling_time_spec, ...
    iif(step_info_cl.SettlingTime <= settling_time_spec, '✓', '✗'));
fprintf('Overshoot:       %.2f%% (Spec: < %.1f%%) %s\n', ...
    step_info_cl.Overshoot, overshoot_spec, ...
    iif(step_info_cl.Overshoot <= overshoot_spec, '✓', '✗'));
fprintf('Peak:            %.4f\n', step_info_cl.Peak);
fprintf('Peak Time:       %.3f s\n', step_info_cl.PeakTime);

% Steady-state error
ss_error = abs(1 - dcgain(T_designed));
fprintf('Steady-State Error: %.6f (Spec: %.1f) %s\n', ...
    ss_error, ess_spec, iif(ss_error <= 0.02, '✓', '✗'));

%% Controller Tuning (Fine-tuning)
fprintf('\n6. CONTROLLER FINE-TUNING\n');
fprintf('-------------------------\n');

% Fine-tune PID parameters for better performance
if step_info_cl.Overshoot > overshoot_spec || step_info_cl.SettlingTime > settling_time_spec
    fprintf('Fine-tuning required...\n');

    % Reduce overshoot by adjusting Kp and Kd
    Kp_tuned = Kp_design * 0.8;
    Ki_tuned = Ki_design;
    Kd_tuned = Kd_design * 1.2;

    C_tuned = pid(Kp_tuned, Ki_tuned, Kd_tuned);
    T_tuned = feedback(C_tuned * G, 1);

    step_info_tuned = stepinfo(T_tuned);

    fprintf('\nTuned PID Controller:\n');
    fprintf('Kp = %.4f, Ki = %.4f, Kd = %.4f\n', Kp_tuned, Ki_tuned, Kd_tuned);

    fprintf('\nTuned Performance:\n');
    fprintf('Rise Time:       %.3f s\n', step_info_tuned.RiseTime);
    fprintf('Settling Time:   %.3f s\n', step_info_tuned.SettlingTime);
    fprintf('Overshoot:       %.2f%%\n', step_info_tuned.Overshoot);

    % Use tuned controller if better
    if step_info_tuned.Overshoot <= overshoot_spec && step_info_tuned.SettlingTime <= settling_time_spec
        C_final = C_tuned;
        T_final = T_tuned;
        step_info_final = step_info_tuned;
        fprintf('✓ Tuned controller meets specifications\n');
    else
        C_final = C_designed;
        T_final = T_designed;
        step_info_final = step_info_cl;
        fprintf('Using original designed controller\n');
    end
else
    C_final = C_designed;
    T_final = T_designed;
    step_info_final = step_info_cl;
    fprintf('✓ Original design meets specifications\n');
end

%% Final Controller Parameters
fprintf('\n7. FINAL CONTROLLER PARAMETERS\n');
fprintf('------------------------------\n');

[Kp_final, Ki_final, Kd_final] = piddata(C_final);

fprintf('FINAL PID Controller:\n');
fprintf('Kp = %.6f\n', Kp_final);
fprintf('Ki = %.6f\n', Ki_final);
fprintf('Kd = %.6f\n', Kd_final);
fprintf('\n');

% Controller in transfer function form
fprintf('Controller Transfer Function:\n');
disp(C_final);

%% Save Results
% Save controller design results
save('controller_design.mat', 'C_final', 'T_final', 'step_info_final', ...
     'Kp_final', 'Ki_final', 'Kd_final', 'cl_poles', ...
     'overshoot_spec', 'settling_time_spec', 'rise_time_spec');

fprintf('Controller design saved to controller_design.mat\n');
fprintf('Run closed_loop_analysis.m for detailed closed-loop simulation\n\n');

% Helper function for conditional formatting
function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
