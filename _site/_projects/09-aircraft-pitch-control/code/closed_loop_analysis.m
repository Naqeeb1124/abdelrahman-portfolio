% REE 310 Course Project - Aircraft Pitch Control System
% Closed-Loop Analysis Script
% This script analyzes the closed-loop system performance with PID controller

clear all; clc; close all;

% Load system parameters and controller design
load('aircraft_pitch_parameters.mat');
load('controller_design.mat');

fprintf('===================================================\n');
fprintf('   CLOSED-LOOP SYSTEM ANALYSIS\n');
fprintf('===================================================\n\n');

%% Closed-Loop System Setup
fprintf('1. CLOSED-LOOP SYSTEM CONFIGURATION\n');
fprintf('-----------------------------------\n');

fprintf('Plant Transfer Function G(s):\n');
disp(G);

fprintf('PID Controller C(s):\n');
disp(C_final);

fprintf('Closed-Loop Transfer Function T(s) = C(s)G(s)/(1+C(s)G(s)):\n');
disp(T_final);

% System type and error constants
L = C_final * G; % Loop transfer function
fprintf('\nLoop Transfer Function L(s) = C(s)G(s):\n');
disp(L);

% Error constants
Kp_error = dcgain(L); % Position error constant
s = tf('s');
Ki_error = dcgain(L/s); % Velocity error constant
Kd_error = dcgain(L/s^2); % Acceleration error constant

fprintf('\nError Constants:\n');
fprintf('Position Error Constant (Kp): %.4f\n', Kp_error);
fprintf('Velocity Error Constant (Kv): %.4f\n', Ki_error);
fprintf('Acceleration Error Constant (Ka): %.4f\n', Kd_error);

%% Step Response Analysis
fprintf('\n2. STEP RESPONSE ANALYSIS\n');
fprintf('-------------------------\n');

% Time vector for simulation
t = 0:0.01:10;

% Different step input amplitudes
step_amplitudes = [0.1, 0.2, 0.5, 1.0]; % radians
colors = {'b-', 'g-', 'r-', 'm-'};

figure('Name', 'Closed-Loop Step Responses', 'Position', [100, 100, 1000, 800]);

% Plot step responses for different amplitudes
subplot(2,2,1);
for i = 1:length(step_amplitudes)
    [y, t_resp] = step(step_amplitudes(i) * T_final, t);
    plot(t_resp, y, colors{i}, 'LineWidth', 2);
    hold on;
end
grid on;
title('Closed-Loop Step Responses (Different Amplitudes)');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');
legend('0.1 rad', '0.2 rad', '0.5 rad', '1.0 rad', 'Location', 'best');

% Control signal analysis
subplot(2,2,2);
S = feedback(1, C_final * G); % Sensitivity function
for i = 1:length(step_amplitudes)
    u = step_amplitudes(i) * step(C_final * S, t);
    plot(t, u, colors{i}, 'LineWidth', 2);
    hold on;
end
grid on;
title('Control Signal (Elevator Deflection)');
xlabel('Time (s)');
ylabel('Control Signal δe (rad)');
legend('0.1 rad input', '0.2 rad input', '0.5 rad input', '1.0 rad input', 'Location', 'best');

% Error signal
subplot(2,2,3);
for i = 1:length(step_amplitudes)
    e = step_amplitudes(i) * step(S, t);
    plot(t, e, colors{i}, 'LineWidth', 2);
    hold on;
end
grid on;
title('Error Signal e(t) = r(t) - y(t)');
xlabel('Time (s)');
ylabel('Error Signal (rad)');
legend('0.1 rad input', '0.2 rad input', '0.5 rad input', '1.0 rad input', 'Location', 'best');

% Compare with open-loop response
subplot(2,2,4);
[y_ol, t_ol] = step(G, t);
[y_cl, t_cl] = step(T_final, t);
plot(t_ol, y_ol, 'r--', 'LineWidth', 2);
hold on;
plot(t_cl, y_cl, 'b-', 'LineWidth', 2);
grid on;
title('Open-Loop vs Closed-Loop Comparison');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');
legend('Open-Loop', 'Closed-Loop', 'Location', 'best');

% Save step response plots
saveas(gcf, 'closed_loop_step_responses.png');

%% Frequency Response Analysis
fprintf('\n3. FREQUENCY RESPONSE ANALYSIS\n');
fprintf('------------------------------\n');

figure('Name', 'Closed-Loop Frequency Response', 'Position', [150, 150, 1000, 700]);

% Closed-loop bode plot
subplot(2,2,1);
bode(T_final);
grid on;
title('Closed-Loop Bode Plot T(s)');

% Open-loop bode plot for comparison
subplot(2,2,2);
bode(L);
grid on;
title('Loop Transfer Function L(s) = C(s)G(s)');

% Nyquist plot
subplot(2,2,3);
nyquist(L);
grid on;
title('Nyquist Plot of L(s)');

% Sensitivity and complementary sensitivity
subplot(2,2,4);
T_comp = T_final; % Complementary sensitivity
S_sens = S;       % Sensitivity
bode(S_sens, 'r-', T_comp, 'b-');
grid on;
title('Sensitivity Functions');
legend('S(s) = 1/(1+L)', 'T(s) = L/(1+L)', 'Location', 'best');

% Save frequency response plots
saveas(gcf, 'closed_loop_frequency_response.png');

%% Disturbance Rejection Analysis
fprintf('\n4. DISTURBANCE REJECTION ANALYSIS\n');
fprintf('---------------------------------\n');

% Output disturbance rejection (at plant output)
T_dist_out = feedback(G, C_final); % Transfer function from output disturbance to output

% Input disturbance rejection (at plant input)
T_dist_in = feedback(C_final * G, 1) * feedback(1, C_final * G) * G;

figure('Name', 'Disturbance Rejection', 'Position', [200, 200, 1000, 600]);

% Output disturbance step response
subplot(2,2,1);
[y_dist_out, t_dist] = step(T_dist_out, t);
plot(t_dist, y_dist_out, 'r-', 'LineWidth', 2);
grid on;
title('Output Disturbance Rejection');
xlabel('Time (s)');
ylabel('Output Response (rad)');

% Input disturbance step response
subplot(2,2,2);
[y_dist_in, t_dist] = step(G * S, t);
plot(t_dist, y_dist_in, 'g-', 'LineWidth', 2);
grid on;
title('Input Disturbance Rejection');
xlabel('Time (s)');
ylabel('Output Response (rad)');

% Bode plots for disturbance rejection
subplot(2,2,3);
bode(T_dist_out, 'r-', G*S, 'g-');
grid on;
title('Disturbance Rejection Frequency Response');
legend('Output Dist.', 'Input Dist.', 'Location', 'best');

% Control effort for disturbances
subplot(2,2,4);
u_dist_out = step(-C_final * T_dist_out, t);
u_dist_in = step(C_final * S, t);
plot(t, u_dist_out, 'r-', t, u_dist_in, 'g-', 'LineWidth', 2);
grid on;
title('Control Effort for Disturbance Rejection');
xlabel('Time (s)');
ylabel('Control Signal (rad)');
legend('Output Dist.', 'Input Dist.', 'Location', 'best');

% Save disturbance analysis plots
saveas(gcf, 'disturbance_rejection_analysis.png');

%% Robustness Analysis
fprintf('\n5. ROBUSTNESS ANALYSIS\n');
fprintf('----------------------\n');

% Gain and phase margins
[Gm, Pm, Wgm, Wpm] = margin(L);

fprintf('Stability Margins:\n');
if isinf(Gm)
    fprintf('Gain Margin:     Infinite dB\n');
else
    fprintf('Gain Margin:     %.2f dB (%.2f) at %.4f rad/s\n', 20*log10(Gm), Gm, Wgm);
end
fprintf('Phase Margin:    %.2f° at %.4f rad/s\n', Pm, Wpm);

% Robustness assessment
if Pm >= 45 && (isinf(Gm) || Gm >= 6)
    fprintf('✓ System has GOOD robustness margins\n');
elseif Pm >= 30 && (isinf(Gm) || Gm >= 3)
    fprintf('△ System has ADEQUATE robustness margins\n');
else
    fprintf('⚠ System has POOR robustness margins\n');
end

% Parameter variation analysis
variations = [0.8, 0.9, 1.0, 1.1, 1.2]; % ±20% variation
figure('Name', 'Parameter Sensitivity Analysis', 'Position', [250, 250, 1000, 600]);

subplot(1,2,1);
for i = 1:length(variations)
    G_var = variations(i) * G;
    T_var = feedback(C_final * G_var, 1);
    [y_var, t_var] = step(T_var, t);
    plot(t_var, y_var, 'LineWidth', 1.5);
    hold on;
end
grid on;
title('Step Response with Plant Gain Variations (±20%)');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');
legend('-20%', '-10%', 'Nominal', '+10%', '+20%', 'Location', 'best');

subplot(1,2,2);
for i = 1:length(variations)
    G_var = tf(K, [1, variations(i)*a, b]); % Vary damping coefficient
    T_var = feedback(C_final * G_var, 1);
    [y_var, t_var] = step(T_var, t);
    plot(t_var, y_var, 'LineWidth', 1.5);
    hold on;
end
grid on;
title('Step Response with Damping Variations (±20%)');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');
legend('-20%', '-10%', 'Nominal', '+10%', '+20%', 'Location', 'best');

% Save robustness analysis plots
saveas(gcf, 'robustness_analysis.png');

%% Performance Summary
fprintf('\n6. CLOSED-LOOP PERFORMANCE SUMMARY\n');
fprintf('----------------------------------\n');

fprintf('Final System Performance:\n');
fprintf('Rise Time:         %.3f s\n', step_info_final.RiseTime);
fprintf('Settling Time:     %.3f s\n', step_info_final.SettlingTime);
fprintf('Overshoot:         %.2f%%\n', step_info_final.Overshoot);
fprintf('Peak Time:         %.3f s\n', step_info_final.PeakTime);
fprintf('Steady-State Error: %.6f\n', abs(1 - dcgain(T_final)));

fprintf('\nStability Margins:\n');
if isinf(Gm)
    fprintf('Gain Margin:       Infinite\n');
else
    fprintf('Gain Margin:       %.2f dB\n', 20*log10(Gm));
end
fprintf('Phase Margin:      %.2f°\n', Pm);

fprintf('\nController Parameters:\n');
fprintf('Kp = %.6f\n', Kp_final);
fprintf('Ki = %.6f\n', Ki_final);
fprintf('Kd = %.6f\n', Kd_final);

fprintf('\nSystem Type: %d (Zero steady-state error for step inputs)\n', 1);

% Save closed-loop analysis results
save('closed_loop_analysis.mat', 'T_final', 'L', 'S', 'T_comp', ...
     'Kp_error', 'Ki_error', 'Kd_error', 'Gm', 'Pm', 'Wgm', 'Wpm');

fprintf('\nClosed-loop analysis saved to closed_loop_analysis.mat\n');
fprintf('Run pid_tuner_analysis.m for Simulink PID Tuner comparison\n\n');
