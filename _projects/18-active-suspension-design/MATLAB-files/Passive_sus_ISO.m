%% ACTIVE SUSPENSION 


clear; close all; clc

%% =========================
% 0) Parameters
%% =========================
m1 = 290;       % kg  (sprung mass)
m2 = 59;        % kg  (unsprung mass)
k1 = 16000;     % N/m (suspension spring)
k2 = 190000;    % N/m (tire stiffness)
b1 = 1000;      % N*s/m (suspension damper)
b2 = 0;         % N*s/m (tire damper)  <-- keep 0 so road input is W only (no Wdot)

W_step = 0.1;   % [m] step road disturbance this is the form the passive suspension code
%% =========================
% 1) State-space model (x = [x1; x1dot; x2; x2dot])
%% =========================
A = [ 0        1           0           0;
     -k1/m1   -b1/m1      k1/m1       b1/m1;
      0        0           0           1;
      k1/m2    b1/m2   -(k1+k2)/m2  -(b1+b2)/m2 ];

Bu = [0; 1/m1; 0; -1/m2];   % control force u
Bw = [0; 0; 0; k2/m2];      % road displacement W(t)  (valid cleanly when b2=0)

C  = [1 0 -1 0];            % y1 = x1 - x2 (suspension deflection)
Du = 0;

n = size(A,1);

%% =========================
% 2) Controllability check (needed for place)
%% =========================
Co = ctrb(A, Bu);
rCo = rank(Co);

fprintf('\n=== Controllability ===\n');
fprintf('rank(ctrb(A,Bu)) = %d,  n = %d\n', rCo, n);

if rCo < n
    error("System NOT controllable w.r.t. u: rank=%d < %d. Can't use place().", rCo, n);
end

%% =========================
% 3) State feedback design (u = -Kx + Nw*W)
%% =========================
% Choose desired closed-loop poles (edit/tune)
p_des = [-7.91+5.90j, -7.91-5.90j, -20.19+45.53j, -20.19-45.53j];

K = place(A, Bu, p_des);

Acl = A - Bu*K;

% Disturbance feedforward to make y_ss ≈ 0 for constant W (if possible)
den = C*(Acl\Bu);
if abs(den) < 1e-12
    warning('C*(Acl\\Bu) is ~0 -> setting Nw=0 (no road feedforward).');
    Nw = 0;
else
    Nw = -(C*(Acl\Bw)) / den;   % scalar
end

Bcl = Bw + Bu*Nw;

fprintf('\n=== Controller ===\n');
fprintf('K  = [%.6f  %.6f  %.6f  %.6f]\n', K);
fprintf('Nw = %.6f\n', Nw);

%% =========================
% 4) STEP road simulation (lsim)
%% =========================
% Closed-loop from W -> outputs [y1; u]
sys_cl = ss(Acl, Bcl, [C; -K], [0; Nw]);

t_step = 0:0.001:10;
w_vec  = W_step*ones(size(t_step));

yout = lsim(sys_cl, w_vec, t_step);
y1_step = yout(:,1);
u_step  = yout(:,2);

peakY = max(abs(y1_step));
TsY   = settling_time_to_zero(t_step, y1_step, 0.02);

fprintf('\n=== STEP road results (W = 0.1 m) ===\n');
fprintf('Peak |y1| = %.4f m (require <= 0.1 m)\n', peakY);
fprintf('SettlingTime(~2%%peak) = %.3f s (require <= 5 s)\n', TsY);




%% =========================
% 5) ISO 8608 random road + RK4 simulation
%% =========================


% --- Road parameters (edit) ---
L    = 500;        % [m]
dx   = 0.02;       % [m]
v    = 50;         % [m/s]
Gd0  = 64e-6;      % [m^3] choose ISO class value
wavE = 2;          % ISO exponent form the reference 
seed = 1;

[tRoad, WRoad] = Roadsimulation(L, dx, v, Gd0, wavE, seed);

% Continuous w(t) for RK4 midpoints
w_of_t = @(tt) interp1(tRoad, WRoad, tt, 'linear', 'extrap');

% Use road sampling time (recommended)
h   = tRoad(2) - tRoad(1);
tRK = tRoad(:);
NRK = numel(tRK);

xRK     = zeros(n, NRK);
y1RK    = zeros(NRK,1);
x1RK    = zeros(NRK,1);
x1relRK = zeros(NRK,1);
uRK     = zeros(NRK,1);
wRK     = zeros(NRK,1);

% initial condition
xRK(:,1) = zeros(n,1);

% Closed-loop dynamics: xdot = Acl*x + Bcl*w(t)
f = @(tt,xx) (Acl*xx + Bcl*w_of_t(tt));

for k = 1:NRK-1
    tk = tRK(k);
    xk = xRK(:,k);

    k1 = f(tk,       xk);
    k2 = f(tk+h/2,   xk + (h/2)*k1);
    k3 = f(tk+h/2,   xk + (h/2)*k2);
    k4 = f(tk+h,     xk + h*k3);

    xRK(:,k+1) = xk + (h/6)*(k1 + 2*k2 + 2*k3 + k4);

 wk        = w_of_t(tk);
wRK(k)    = wk;
y1RK(k)   = C*xk;
x1RK(k)   = xk(1);
x1relRK(k)= xk(1) - wk;
uRK(k)    = -K*xk + Nw*wk;

end

% last sample
wRK(end)     = w_of_t(tRK(end));
y1RK(end)    = C*xRK(:,end);
x1RK(end)    = xRK(1,end);
x1relRK(end) = xRK(1,end) - wRK(end);
uRK(end)     = -K*xRK(:,end) + Nw*wRK(end);


% Metrics (random road)
peakY_RK = max(abs(y1RK));
rmsY_RK  = sqrt(mean(y1RK.^2));

fprintf('\n=== ISO 8608 road results (RK4) ===\n');
fprintf('Peak |y1| = %.4f m\n', peakY_RK);
fprintf('RMS  y1   = %.4f m\n', rmsY_RK);

figure;
plot(tRK, WRoad, 'LineWidth', 1.2); grid on
title('ISO 8608 Road Profile W(t)');
xlabel('Time (s)'); ylabel('W(t) (m)');

figure;
plot(tRK, y1RK, 'LineWidth', 1.2); grid on
title('Active Suspension: y1 response (ISO 8608 road, RK4)');
xlabel('Time (s)'); ylabel('y1 = x1 - x2 (m)');

figure;
plot(tRK, uRK, 'LineWidth', 1.2); grid on
title('Active Suspension: Control Force u(t) (ISO 8608 road, RK4)');
xlabel('Time (s)'); ylabel('u (N)');

peakX1_RK    = max(abs(x1RK));
rmsX1_RK     = sqrt(mean(x1RK.^2));

peakX1rel_RK = max(abs(x1relRK));
rmsX1rel_RK  = sqrt(mean(x1relRK.^2));

fprintf('Peak |x1|      = %.4f m, RMS x1      = %.4f m\n', peakX1_RK, rmsX1_RK);
fprintf('Peak |x1-W|    = %.4f m, RMS x1-W    = %.4f m\n', peakX1rel_RK, rmsX1rel_RK);

figure;
plot(tRK, x1RK, 'LineWidth', 1.2); grid on
title('Active Suspension: body displacement x_1 (ISO 8608 road, RK4)');
xlabel('Time (s)'); ylabel('x_1 (m)');

figure;
plot(tRK, x1relRK, 'LineWidth', 1.2); grid on
title('Active Suspension: body relative displacement (x_1 - W) (ISO 8608 road, RK4)');
xlabel('Time (s)'); ylabel('x_1 - W (m)');





%% =========================
% Local helper
%% =========================
function Ts = settling_time_to_zero(t, y, frac)
% Settling time to 0 using +/- frac*peak band
peak = max(abs(y));
band = frac*peak;
idx = find(abs(y) > band, 1, 'last');
if isempty(idx)
    Ts = 0;
else
    Ts = t(idx);
end
end
