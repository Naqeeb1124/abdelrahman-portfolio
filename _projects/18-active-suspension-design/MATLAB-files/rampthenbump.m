%% Active Suspension Project (Parts 2 -> 8)
% Requires: Control System Toolbox
clear; close all; clc

%% =========================
% 0) Parameters (edit these)
%% =========================
% Use any "reasonable reference" values you choose for part (4)
m1 = 290;       % kg  (sprung mass)
m2 = 59;        % kg  (unsprung mass)
k1 = 16000;     % N/m (suspension spring)
k2 = 190000;    % N/m (tire stiffness)
b1 = 1000;      % N*s/m (suspension damper)
b2 = 0;         % N*s/m (tire damper)  <-- set to 0 to avoid Wdot in state-space parts

W_step = 0.1;   % meters (project uses 0.1 m step road disturbance)

%% ===========================================
% 2-3) Transfer matrix verification (Laplace)
%% ===========================================
s = tf('s');

a11 = m1*s^2 + b1*s + k1;
a12 = -(b1*s + k1);
a21 = a12;
a22 = m2*s^2 + (b1+b2)*s + (k1+k2);

Delta = a11*a22 - a12*a21;

% "Given" transfer matrix in the project statement
H11 = (m2*s^2 + b2*s + k2)/Delta;
H12 = (b1*b2*s^2 + (b1*k2 + b2*k1)*s + k1*k2)/Delta;
H21 = (-m1*s^2)/Delta;
H22 = (m1*b2*s^3 + (m1*k2 + b1*b2)*s^2 + (b1*k2 + b2*k1)*s + k1*k2)/Delta;

H_given = [H11 H12; H21 H22];

% Compute the same matrix using inverse of Aeq(s):
% Aeq(s)*[X1;X2] = [U; -U+(b2*s+k2)W]
invA = (1/Delta)*[a22, -(a12); -(a21), a11];
H_u = invA*[1; -1];            % column from U
H_w = invA*[0; (b2*s+k2)];     % column from W
H_calc = [H_u(1) H_w(1); H_u(2) H_w(2)];

H_diff = minreal(H_given - H_calc);
disp('Part (3) check: H_given - H_calc (should be ~0):');
disp(H_diff);

%% ===========================================
% 4) Step responses of G1 and G2 + metrics
%% ===========================================
% G1 = (X1 - X2)/U , G2 = (X1 - X2)/W
G1 = minreal(H11 - H21);
G2 = minreal(H12 - H22);

t = 0:0.001:5;

%% ---------- G1 : unit step in U ----------
figure;
step(G1,t); grid on
title('G1 = (X1 - X2) / U   (Unit Step in U)')
ylabel('x_1 - x_2  (m)')
xlabel('Time (s)')

info1 = stepinfo(G1);
p1 = pole(G1);
wd1 = abs(imag(p1(find(imag(p1)>0,1))));

fprintf('\n===== G1 RESULTS =====\n');
fprintf('Settling Time = %.3f s\n', info1.SettlingTime);
fprintf('Maximum Overshoot = %.2f %%\n', info1.Overshoot);
fprintf('Damped Frequency wd = %.3f rad/s\n', wd1);

%% ---------- G2 : 0.1 m road step ----------
W_step = 0.1;
[y2,t2] = step(W_step*G2,t);

figure;
plot(t2,y2); grid on
title('G2 = (X1 - X2) / W   (0.1 m Road Step)')
ylabel('x_1 - x_2  (m)')
xlabel('Time (s)')

info2 = stepinfo(W_step*G2);      % <-- must be scaled

peak2 = max(abs(y2));
band = 0.02*peak2;
Ts2 = t2(find(abs(y2)<=band,1,'last'));

p2 = pole(G2);
wd2 = abs(imag(p2(find(imag(p2)>0,1))));

fprintf('\n===== G2 RESULTS =====\n');
fprintf('Peak Deflection = %.4f m (%.1f %% of 0.1 m)\n', peak2,100*peak2/W_step);
fprintf('Settling Time = %.3f s\n', Ts2);
fprintf('Damped Frequency wd = %.3f rad/s\n', wd2);

%% ===========================================
% 5) State-space model with output y1 = x1 - x2
%% ===========================================
% States: x = [x1; x1dot; x2; x2dot]
A = [ 0        1           0           0;
     -k1/m1   -b1/m1      k1/m1       b1/m1;
      0        0           0           1;
      k1/m2    b1/m2   -(k1+k2)/m2  -(b1+b2)/m2 ];

Bu = [0; 1/m1; 0; -1/m2];       % control force u
Bw = [0; 0; 0; k2/m2];          % road displacement W (valid cleanly when b2 = 0)

C  = [1 0 -1 0];                % y1 = x1 - x2
Du = 0; Dw = 0;

sys_uw = ss(A, [Bu Bw], C, [Du Dw]);

%% ===========================================
% 6) Open-loop stability
%% ===========================================
eigA = eig(A);
fprintf('\n=== Part (6) Open-loop stability ===\n');
disp('eig(A) = '); disp(eigA.');
if all(real(eigA) < 0)
    disp('Open-loop is asymptotically stable (all eigenvalues have negative real parts).');
else
    disp('Open-loop is NOT asymptotically stable (at least one eigenvalue has Re >= 0).');
end

%% ===========================================
% 7) Controllability and observability
%% ===========================================
Co = ctrb(A, Bu);
Ob = obsv(A, C);

rCo = rank(Co);
rOb = rank(Ob);

fprintf('\n=== Part (7) Controllability/Observability ===\n');
fprintf('rank(ctrb) = %d (n=%d states)\n', rCo, size(A,1));
fprintf('rank(obsv) = %d (n=%d states)\n', rOb, size(A,1));

%% ===========================================
% 8) State feedback design for W = 0.1 m step
% Requirement: y1 stays within +/-0.1 m and oscillations vanish within 5 s
%% ===========================================
% Pick desired closed-loop poles (tune as needed)
p_des = [-7.91+5.90j, -7.91-5.90j, -20.19+45.53j, -20.19-45.53j];
Ks = place(A, Bu, p_des);

Acl = A - Bu*Ks;

% OPTIONAL disturbance feedforward to make y_ss = 0 for constant W (requires W available):
Nw = -(C*(Acl\Bw)) / (C*(Acl\Bu));   % scalar

% Closed-loop from W -> outputs [y1; u]
Bcl = Bw + Bu*Nw;
Caug = [C; -Ks];
Daug = [0; Nw];
sys_cl = ss(Acl, Bcl, Caug, Daug);

% Simulate W step = 0.1 m
t8 = 0:0.001:20;
w = W_step*ones(size(t8));
yout = lsim(sys_cl, w, t8);
y1 = yout(:,1);
u  = yout(:,2);

% Check requirements
peakY = max(abs(y1));
TsY   = settling_time_to_zero(t8, y1, 0.02);

fprintf('\n=== Part (8) State feedback results ===\n');
fprintf('Ks = [%.3f  %.3f  %.3f  %.3f]\n', Ks);
fprintf('Nw (feedforward) = %.3f\n', Nw);
fprintf('Peak |y1| = %.4f m  (require <= 0.1 m)\n', peakY);
fprintf('SettlingTime(~2%%peak) = %.3f s (require <= 5 s)\n', TsY);

figure; plot(t8, y1); grid on
title('Part (8): Closed-loop y1 for W = 0.1 m step'); ylabel('y1 = x1 - x2 (m)'); xlabel('Time (s)')
yline( 0.1,'--'); yline(-0.1,'--');

figure; plot(t8, u); grid on
title('Part (8): Control force u'); ylabel('u (N)'); xlabel('Time (s)')


%% ===========================================
% 8b) Road input w(t): RAMP then BUMP (after applying controller Ks)
%% ===========================================
% Ramp: 0 -> W_step over Tramp seconds (starting at t_r0)
% Bump: half-sine pulse of height A_bump over T_bump seconds (starting at t_b0)

t_r0  = 0.0;     % s  ramp start time
Tramp = 1.0;     % s  ramp duration

A_bump = 0.05;   % m  bump height
t_b0   = 3.0;    % s  bump start time
T_bump = 2;   % s  bump duration

w_rb = road_ramp_then_bump(t8, W_step, t_r0, Tramp, A_bump, t_b0, T_bump);

yout_rb = lsim(sys_cl, w_rb, t8);
y1_rb = yout_rb(:,1);
u_rb  = yout_rb(:,2);

figure; plot(t8, w_rb); grid on
title('Road input w(t): ramp then bump'); ylabel('w(t) (m)'); xlabel('Time (s)')

figure; plot(t8, y1_rb); grid on
title('Closed-loop y1 for w(t) = ramp then bump'); ylabel('y1 = x1 - x2 (m)'); xlabel('Time (s)')
yline( 0.1,'--'); yline(-0.1,'--');

figure; plot(t8, u_rb); grid on
title('Control force u for w(t) = ramp then bump'); ylabel('u (N)'); xlabel('Time (s)')


%% =========================
% Local helper functions
%% =========================
function w = road_ramp_then_bump(t, W_final, t_r0, Tramp, A_bump, t_b0, T_bump)

% --- Saturating ramp ---
if Tramp <= 0
    r = double(t >= t_r0);            % instantaneous step if Tramp is invalid
else
    r = (t - t_r0) / Tramp;
    r = max(0, min(r, 1));            % clamp to [0,1]
end
w = W_final * r;

% --- Half-sine bump ---
tau = t - t_b0;
w = w + A_bump * (tau >= 0 & tau <= T_bump) .* sin(pi * tau / T_bump);
end

function [pdom, wd] = dominant_complex_pole(p)
% Pick the complex pole closest to the imaginary axis (dominant oscillatory mode)
pc = p(imag(p) ~= 0);
if isempty(pc)
    pdom = NaN; wd = NaN; return;
end
[~, idx] = min(abs(real(pc)));
pdom = pc(idx);
wd = abs(imag(pdom)); % rad/s
end

function Ts = settling_time_to_zero(t, y, frac)
% Settling time to 0 using +/- frac*peak band, where peak = max(|y|)
peak = max(abs(y));
band = frac*peak;
idx = find(abs(y) > band, 1, 'last');
if isempty(idx), Ts = 0; else, Ts = t(idx); end
end
