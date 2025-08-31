% REE 310 Course Project - Aircraft Pitch Control System
% Open-Loop Analysis Script
% This script analyzes the open-loop behavior of the aircraft pitch system

clear all; clc; close all;

% Load system parameters
load('aircraft_pitch_parameters.mat');

fprintf('===================================================\n');
fprintf('   OPEN-LOOP SYSTEM ANALYSIS\n');
fprintf('===================================================\n\n');

%% Open-Loop Response Analysis
fprintf('1. OPEN-LOOP STEP RESPONSE\n');
fprintf('--------------------------\n');

% Step response parameters
t = 0:0.01:15;  % Time vector (15 seconds)
step_amplitude = 1; % 1 radian elevator input

% Calculate step response
[y_step, t_step] = step(step_amplitude * G, t);

% Plot open-loop step response
figure('Name', 'Open-Loop Step Response', 'Position', [100, 100, 800, 600]);

subplot(2,1,1);
plot(t_step, y_step, 'b-', 'LineWidth', 2);
grid on;
title('Open-Loop Step Response - Pitch Angle θ(t)');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');
legend('Pitch Angle Response', 'Location', 'best');

% Input signal plot
subplot(2,1,2);
u_step = step_amplitude * ones(size(t_step));
plot(t_step, u_step, 'r-', 'LineWidth', 2);
grid on;
title('Elevator Input Signal δe(t)');
xlabel('Time (s)');
ylabel('Elevator Angle δe (rad)');
legend('Elevator Input', 'Location', 'best');

% Save figure
saveas(gcf, 'open_loop_step_response.png');

%% Response Characteristics Analysis
fprintf('2. RESPONSE CHARACTERISTICS\n');
fprintf('---------------------------\n');

% Get step info
step_info = stepinfo(G);

fprintf('Step Response Characteristics:\n');
fprintf('Rise Time:       %.3f s\n', step_info.RiseTime);
fprintf('Settling Time:   %.3f s\n', step_info.SettlingTime);
fprintf('Overshoot:       %.2f%%\n', step_info.Overshoot);
fprintf('Peak:            %.4f rad\n', step_info.Peak);
fprintf('Peak Time:       %.3f s\n', step_info.PeakTime);

% Steady-state value
ss_value = dcgain(G);
fprintf('Steady-State Value: %.4f rad\n', ss_value);
fprintf('\n');

%% Frequency Response Analysis
fprintf('3. FREQUENCY RESPONSE ANALYSIS\n');
fprintf('------------------------------\n');

% Bode plot
figure('Name', 'Open-Loop Bode Plot', 'Position', [150, 150, 800, 600]);
bode(G);
grid on;
title('Open-Loop Bode Plot');

% Get margin information
[Gm, Pm, Wgm, Wpm] = margin(G);

fprintf('Stability Margins:\n');
if isinf(Gm)
    fprintf('Gain Margin:     Infinite (no 180° crossover)\n');
else
    fprintf('Gain Margin:     %.2f dB at %.4f rad/s\n', 20*log10(Gm), Wgm);
end
fprintf('Phase Margin:    %.2f° at %.4f rad/s\n', Pm, Wpm);

% Save bode plot
saveas(gcf, 'open_loop_bode_plot.png');

%% Root Locus Plot (for future controller design)
fprintf('\n4. ROOT LOCUS ANALYSIS\n');
fprintf('----------------------\n');

figure('Name', 'Root Locus Plot', 'Position', [200, 200, 800, 600]);
rlocus(G);
grid on;
title('Root Locus Plot of Open-Loop System');
xlabel('Real Part');
ylabel('Imaginary Part');

% Add pole locations
hold on;
plot(real(poles), imag(poles), 'rx', 'MarkerSize', 10, 'LineWidth', 3);
legend('Root Locus', 'Open-Loop Poles', 'Location', 'best');

% Save root locus plot
saveas(gcf, 'open_loop_root_locus.png');

%% Impulse Response
fprintf('\n5. IMPULSE RESPONSE\n');
fprintf('-------------------\n');

figure('Name', 'Open-Loop Impulse Response', 'Position', [250, 250, 800, 600]);

subplot(2,1,1);
[y_impulse, t_impulse] = impulse(G, t);
plot(t_impulse, y_impulse, 'g-', 'LineWidth', 2);
grid on;
title('Open-Loop Impulse Response - Pitch Angle θ(t)');
xlabel('Time (s)');
ylabel('Pitch Angle θ (rad)');
legend('Pitch Angle Response', 'Location', 'best');

% Impulse input (approximation for visualization)
subplot(2,1,2);
u_impulse = zeros(size(t_impulse));
u_impulse(1:5) = 100; % Approximate impulse as high short pulse
plot(t_impulse, u_impulse, 'm-', 'LineWidth', 2);
grid on;
title('Impulse Input Signal (Approximation)');
xlabel('Time (s)');
ylabel('Input Magnitude');
legend('Impulse Input', 'Location', 'best');

% Save impulse response
saveas(gcf, 'open_loop_impulse_response.png');

%% Summary Report
fprintf('\n6. OPEN-LOOP SYSTEM SUMMARY\n');
fprintf('----------------------------\n');

if all(real(poles) < 0)
    fprintf('✓ System is STABLE\n');
    fprintf('✓ All poles are in the left half-plane\n');
    if zeta > 0 && zeta < 1
        fprintf('✓ System is UNDERDAMPED (0 < ζ < 1)\n');
        fprintf('  - Oscillatory response expected\n');
        fprintf('  - Overshoot: %.2f%%\n', step_info.Overshoot);
    elseif zeta >= 1
        fprintf('✓ System is OVERDAMPED (ζ ≥ 1)\n');
        fprintf('  - No overshoot expected\n');
    else
        fprintf('! System is UNDAMPED (ζ = 0)\n');
        fprintf('  - Sustained oscillations\n');
    end
else
    fprintf('⚠ System is UNSTABLE\n');
    fprintf('⚠ Controller design is required for stability\n');
end

fprintf('\nKey Performance Indicators:\n');
fprintf('- Natural Frequency: %.4f rad/s\n', wn);
fprintf('- Damping Ratio: %.4f\n', zeta);
fprintf('- DC Gain: %.4f rad/rad\n', ss_value);
fprintf('- Settling Time: %.3f s\n', step_info.SettlingTime);

fprintf('\nNext Steps:\n');
fprintf('- Run controller_design.m to design PID controller\n');
fprintf('- Use Root Locus method for pole placement\n');
fprintf('- Design for desired specifications\n\n');

% Save analysis results
save('open_loop_analysis.mat', 'step_info', 'Gm', 'Pm', 'Wgm', 'Wpm', ...
     'y_step', 't_step', 'y_impulse', 't_impulse');

fprintf('Analysis results saved to open_loop_analysis.mat\n');
