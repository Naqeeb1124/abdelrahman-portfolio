% REE 310 Course Project - Aircraft Pitch Control System
% PID Tuner Analysis Script
% This script demonstrates MATLAB PID Tuner functionality and compares results

clear all; clc; close all;

% Load system parameters and designed controller
load('aircraft_pitch_parameters.mat');
load('controller_design.mat');

fprintf('===================================================\n');
fprintf('   MATLAB PID TUNER ANALYSIS\n');
fprintf('===================================================\n\n');

%% Manual vs Automatic PID Tuning Comparison
fprintf('1. PID CONTROLLER COMPARISON\n');
fprintf('----------------------------\n');

fprintf('Manual Root Locus Design:\n');
fprintf('Kp = %.6f\n', Kp_final);
fprintf('Ki = %.6f\n', Ki_final);
fprintf('Kd = %.6f\n', Kd_final);

%% Automatic PID Tuning using pidtune
fprintf('\n2. AUTOMATIC PID TUNING\n');
fprintf('-----------------------\n');

% Design specifications for automatic tuning
wc_desired = 2; % Desired crossover frequency (rad/s)

% Automatic PID tuning
C_auto = pidtune(G, 'PID', wc_desired);
[Kp_auto, Ki_auto, Kd_auto] = piddata(C_auto);

fprintf('Automatic PID Tuning (pidtune):\n');
fprintf('Kp = %.6f\n', Kp_auto);
fprintf('Ki = %.6f\n', Ki_auto);
fprintf('Kd = %.6f\n', Kd_auto);

% Alternative: tune for specific response time
opts = pidtuneOptions('CrossoverFrequency', wc_desired, 'PhaseMargin', 60);
C_auto_opts = pidtune(G, 'PID', opts);
[Kp_auto2, Ki_auto2, Kd_auto2] = piddata(C_auto_opts);

fprintf('\nAutomatic PID with Options (60° Phase Margin):\n');
fprintf('Kp = %.6f\n', Kp_auto2);
fprintf('Ki = %.6f\n', Ki_auto2);
fprintf('Kd = %.6f\n', Kd_auto2);

%% Performance Comparison
fprintf('\n3. PERFORMANCE COMPARISON\n');
fprintf('-------------------------\n');

% Closed-loop systems
T_manual = feedback(C_final * G, 1);
T_auto = feedback(C_auto * G, 1);
T_auto2 = feedback(C_auto_opts * G, 1);

% Step response comparison
t = 0:0.01:8;
figure('Name', 'PID Controller Comparison', 'Position', [100, 100, 1200, 800]);

% Step responses
subplot(2,3,1);
step(T_manual, 'b-', T_auto, 'r--', T_auto2, 'g:', t);
grid on;
title('Step Response Comparison');
legend('Manual (Root Locus)', 'Auto (pidtune)', 'Auto (with options)', 'Location', 'best');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');

% Control signals
subplot(2,3,2);
S_manual = feedback(1, C_final * G);
S_auto = feedback(1, C_auto * G);
S_auto2 = feedback(1, C_auto_opts * G);

step(C_final * S_manual, 'b-', C_auto * S_auto, 'r--', C_auto_opts * S_auto2, 'g:', t);
grid on;
title('Control Signal Comparison');
legend('Manual', 'Auto', 'Auto (opts)', 'Location', 'best');
xlabel('Time (s)');
ylabel('Control Signal δe (rad)');

% Bode plots
subplot(2,3,3);
bode(T_manual, 'b-', T_auto, 'r--', T_auto2, 'g:');
grid on;
title('Closed-Loop Frequency Response');
legend('Manual', 'Auto', 'Auto (opts)', 'Location', 'best');

% Root locus comparison
subplot(2,3,4);
rlocus(G);
hold on;
% Mark closed-loop poles
poles_manual = pole(T_manual);
poles_auto = pole(T_auto);
poles_auto2 = pole(T_auto2);

plot(real(poles_manual), imag(poles_manual), 'bo', 'MarkerSize', 8, 'LineWidth', 2);
plot(real(poles_auto), imag(poles_auto), 'r^', 'MarkerSize', 8, 'LineWidth', 2);
plot(real(poles_auto2), imag(poles_auto2), 'gs', 'MarkerSize', 8, 'LineWidth', 2);
grid on;
title('Root Locus with Pole Locations');
legend('Root Locus', 'Manual Poles', 'Auto Poles', 'Auto (opts) Poles', 'Location', 'best');

% Nyquist plots
subplot(2,3,5);
L_manual = C_final * G;
L_auto = C_auto * G;
L_auto2 = C_auto_opts * G;

nyquist(L_manual, 'b-', L_auto, 'r--', L_auto2, 'g:');
grid on;
title('Nyquist Plot Comparison');
legend('Manual', 'Auto', 'Auto (opts)', 'Location', 'best');

% Stability margins comparison
subplot(2,3,6);
[Gm_m, Pm_m, Wgm_m, Wpm_m] = margin(L_manual);
[Gm_a, Pm_a, Wgm_a, Wpm_a] = margin(L_auto);
[Gm_a2, Pm_a2, Wgm_a2, Wpm_a2] = margin(L_auto2);

% Create bar plot for phase margins
controllers = {'Manual', 'Auto', 'Auto (opts)'};
phase_margins = [Pm_m, Pm_a, Pm_a2];
gain_margins_db = [20*log10(Gm_m), 20*log10(Gm_a), 20*log10(Gm_a2)];

yyaxis left;
bar(phase_margins);
set(gca, 'XTickLabel', controllers);
ylabel('Phase Margin (degrees)');
title('Stability Margins Comparison');

yyaxis right;
plot(1:3, gain_margins_db, 'ro-', 'LineWidth', 2);
ylabel('Gain Margin (dB)');
grid on;

% Save comparison plots
saveas(gcf, 'pid_controller_comparison.png');

%% Performance Metrics Summary
fprintf('\n4. PERFORMANCE METRICS SUMMARY\n');
fprintf('------------------------------\n');

% Get step response info for all controllers
info_manual = stepinfo(T_manual);
info_auto = stepinfo(T_auto);
info_auto2 = stepinfo(T_auto2);

fprintf('\n%-20s %-15s %-15s %-15s\n', 'Metric', 'Manual', 'Auto', 'Auto (opts)');
fprintf('%-20s %-15s %-15s %-15s\n', repmat('-', 1, 20), repmat('-', 1, 15), repmat('-', 1, 15), repmat('-', 1, 15));
fprintf('%-20s %-15.3f %-15.3f %-15.3f\n', 'Rise Time (s)', info_manual.RiseTime, info_auto.RiseTime, info_auto2.RiseTime);
fprintf('%-20s %-15.3f %-15.3f %-15.3f\n', 'Settling Time (s)', info_manual.SettlingTime, info_auto.SettlingTime, info_auto2.SettlingTime);
fprintf('%-20s %-15.2f %-15.2f %-15.2f\n', 'Overshoot (%%)', info_manual.Overshoot, info_auto.Overshoot, info_auto2.Overshoot);
fprintf('%-20s %-15.3f %-15.3f %-15.3f\n', 'Peak Time (s)', info_manual.PeakTime, info_auto.PeakTime, info_auto2.PeakTime);
fprintf('%-20s %-15.2f %-15.2f %-15.2f\n', 'Phase Margin (°)', Pm_m, Pm_a, Pm_a2);

if isinf(Gm_m), gm_m_str = 'Inf'; else, gm_m_str = sprintf('%.2f', 20*log10(Gm_m)); end
if isinf(Gm_a), gm_a_str = 'Inf'; else, gm_a_str = sprintf('%.2f', 20*log10(Gm_a)); end
if isinf(Gm_a2), gm_a2_str = 'Inf'; else, gm_a2_str = sprintf('%.2f', 20*log10(Gm_a2)); end

fprintf('%-20s %-15s %-15s %-15s\n', 'Gain Margin (dB)', gm_m_str, gm_a_str, gm_a2_str);

% Steady-state errors
ss_error_manual = abs(1 - dcgain(T_manual));
ss_error_auto = abs(1 - dcgain(T_auto));
ss_error_auto2 = abs(1 - dcgain(T_auto2));

fprintf('%-20s %-15.6f %-15.6f %-15.6f\n', 'SS Error', ss_error_manual, ss_error_auto, ss_error_auto2);

%% Recommendations
fprintf('\n5. DESIGN RECOMMENDATIONS\n');
fprintf('--------------------------\n');

% Determine best controller based on specifications
spec_overshoot = 10; % Maximum 10% overshoot
spec_settling = 2;   % Maximum 2s settling time

controllers_data = {
    struct('name', 'Manual (Root Locus)', 'info', info_manual, 'C', C_final, 'Pm', Pm_m);
    struct('name', 'Auto (pidtune)', 'info', info_auto, 'C', C_auto, 'Pm', Pm_a);
    struct('name', 'Auto (with options)', 'info', info_auto2, 'C', C_auto_opts, 'Pm', Pm_a2);
};

fprintf('Design Specifications:\n');
fprintf('- Maximum Overshoot: %.1f%%\n', spec_overshoot);
fprintf('- Maximum Settling Time: %.1fs\n', spec_settling);
fprintf('\n');

best_score = -1;
best_controller = [];

for i = 1:length(controllers_data)
    data = controllers_data{i};
    score = 0;

    fprintf('%s:\n', data.name);

    % Check overshoot
    if data.info.Overshoot <= spec_overshoot
        fprintf('  ✓ Overshoot: %.2f%% (meets spec)\n', data.info.Overshoot);
        score = score + 1;
    else
        fprintf('  ✗ Overshoot: %.2f%% (exceeds spec)\n', data.info.Overshoot);
    end

    % Check settling time
    if data.info.SettlingTime <= spec_settling
        fprintf('  ✓ Settling Time: %.3fs (meets spec)\n', data.info.SettlingTime);
        score = score + 1;
    else
        fprintf('  ✗ Settling Time: %.3fs (exceeds spec)\n', data.info.SettlingTime);
    end

    % Check stability margins
    if data.Pm >= 45
        fprintf('  ✓ Phase Margin: %.1f° (excellent)\n', data.Pm);
        score = score + 1;
    elseif data.Pm >= 30
        fprintf('  △ Phase Margin: %.1f° (adequate)\n', data.Pm);
        score = score + 0.5;
    else
        fprintf('  ✗ Phase Margin: %.1f° (poor)\n', data.Pm);
    end

    fprintf('  Overall Score: %.1f/3\n\n', score);

    if score > best_score
        best_score = score;
        best_controller = data;
    end
end

fprintf('RECOMMENDED CONTROLLER: %s\n', best_controller.name);
fprintf('This controller achieves the best overall performance with a score of %.1f/3.\n\n', best_score);

%% Simulink Model Information
fprintf('6. SIMULINK MODEL SETUP\n');
fprintf('-----------------------\n');

fprintf('For Simulink implementation:\n');
fprintf('\n1. Open-Loop Model:\n');
fprintf('   - Use Transfer Function block with numerator [%.6f] and denominator [1 %.4f %.6f]\n', K, a, b);
fprintf('   - Input: Step or Signal Builder for elevator deflection\n');
fprintf('   - Output: Scope for pitch angle\n');

fprintf('\n2. Closed-Loop Model:\n');
fprintf('   - Add PID Controller block with Kp=%.6f, Ki=%.6f, Kd=%.6f\n', Kp_final, Ki_final, Kd_final);
fprintf('   - Use Unity Feedback configuration\n');
fprintf('   - Input: Reference pitch angle command\n');
fprintf('   - Outputs: Pitch angle response and control signal\n');

fprintf('\n3. PID Tuner:\n');
fprintf('   - Right-click PID Controller block → Tune\n');
fprintf('   - Set Response Time and Transient Behavior sliders\n');
fprintf('   - Compare with manual design results\n\n');

% Save all tuning results
save('pid_tuner_analysis.mat', 'C_final', 'C_auto', 'C_auto_opts', ...
     'T_manual', 'T_auto', 'T_auto2', 'info_manual', 'info_auto', 'info_auto2', ...
     'Pm_m', 'Pm_a', 'Pm_a2', 'best_controller');

fprintf('PID tuner analysis saved to pid_tuner_analysis.mat\n');
fprintf('Use create_simulink_models.m to generate Simulink models\n\n');
