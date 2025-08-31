% REE 310 Course Project - Aircraft Pitch Control System
% Main Analysis Script
% This script performs complete analysis of aircraft pitch control system
% including modeling, open-loop analysis, PID design, and simulation

clear all; clc; close all;

fprintf('===================================================\n');
fprintf('   REE 310 - Aircraft Pitch Control System\n');
fprintf('===================================================\n\n');

%% System Parameters and Modeling
fprintf('1. SYSTEM MODELING AND PARAMETERS\n');
fprintf('----------------------------------\n');

% Aircraft pitch dynamics parameters (typical values)
% Based on linearized longitudinal aircraft dynamics
M = 1.2;        % Pitching moment coefficient due to elevator (1/rad)
Zw = -0.37;     % Vertical force coefficient due to vertical velocity (1/s)  
Mw = -0.17;     % Pitching moment coefficient due to vertical velocity (1/s)
Mq = -0.64;     % Pitching moment coefficient due to pitch rate (1/s)
U0 = 25;        % Trim airspeed (m/s)
g = 9.81;       % Gravitational acceleration (m/s^2)

% Display system parameters
fprintf('Aircraft Parameters:\n');
fprintf('M  (Pitching moment coeff): %.2f 1/rad\n', M);
fprintf('Zw (Vertical force coeff):  %.2f 1/s\n', Zw);
fprintf('Mw (Pitching moment coeff): %.2f 1/s\n', Mw);
fprintf('Mq (Pitch rate coeff):      %.2f 1/s\n', Mq);
fprintf('U0 (Trim airspeed):         %.1f m/s\n', U0);
fprintf('\n');

%% Transfer Function Derivation
fprintf('2. TRANSFER FUNCTION DERIVATION\n');
fprintf('-------------------------------\n');

% From linearized aircraft dynamics:
% θ(s)/δe(s) = K / (s^2 + as + b)
% where: K = M*U0/g, a = -Mq, b = -Mw*Zw*U0/g

K = M * U0 / g;
a = -Mq;
b = -Mw * Zw * U0 / g;

% Create transfer function
num = K;
den = [1, a, b];
G = tf(num, den);

fprintf('Transfer Function G(s) = θ(s)/δe(s):\n');
fprintf('G(s) = %.4f / (s^2 + %.4fs + %.4f)\n', K, a, b);
fprintf('\n');
disp('Transfer Function:');
disp(G);
fprintf('\n');

%% System Properties Analysis
fprintf('3. SYSTEM PROPERTIES\n');
fprintf('--------------------\n');

% Poles and zeros
poles = pole(G);
zeros_sys = zero(G);

fprintf('System Poles: ');
for i = 1:length(poles)
    if imag(poles(i)) == 0
        fprintf('%.4f ', poles(i));
    else
        fprintf('%.4f%+.4fi ', real(poles(i)), imag(poles(i)));
    end
end
fprintf('\n');

if isempty(zeros_sys)
    fprintf('System Zeros: None\n');
else
    fprintf('System Zeros: ');
    for i = 1:length(zeros_sys)
        fprintf('%.4f ', zeros_sys(i));
    end
    fprintf('\n');
end

% Natural frequency and damping ratio
wn = sqrt(b);
zeta = a / (2 * wn);
fprintf('Natural frequency (wn): %.4f rad/s\n', wn);
fprintf('Damping ratio (zeta):   %.4f\n', zeta);

% Stability analysis
if all(real(poles) < 0)
    fprintf('System Stability: STABLE (all poles in LHP)\n');
else
    fprintf('System Stability: UNSTABLE (poles in RHP or on imaginary axis)\n');
end
fprintf('\n');

%% Save workspace for other scripts
save('aircraft_pitch_parameters.mat', 'G', 'K', 'a', 'b', 'poles', 'wn', 'zeta', ...
     'M', 'Zw', 'Mw', 'Mq', 'U0', 'g');

fprintf('Parameters saved to aircraft_pitch_parameters.mat\n');
fprintf('Run open_loop_analysis.m for open-loop response analysis\n');
fprintf('Run controller_design.m for PID controller design\n');
fprintf('Run closed_loop_analysis.m for closed-loop simulation\n\n');
