clear; clc; close all;
gamma = 1.4; R = 287;
theta1 = 14.5;
theta2 = 17.5;
At_fixed = 0.0562;
Ae_fixed = 0.0625;
A_cap    = 0.0625;
M_flight = 2.0;
fprintf('--- MACH 2.0 FAILURE ANALYSIS ---\n');
[~, M1, ~, valid1] = solve_oblique_robust(M_flight, theta1, gamma);
if valid1
    beta_scan = linspace(asin(1/M1), pi/2, 1000);
    theta_scan_rad = atan( 2*cot(beta_scan) .* (M1^2 .* sin(beta_scan).^2 - 1) ./ ...
        (M1^2 .* (gamma + cos(2*beta_scan)) + 2) );
    theta_max_deg = rad2deg(max(theta_scan_rad));

    fprintf('M_inf: %.2f\n', M_flight);
    fprintf('Theta 1: %.2f deg -> M1: %.3f\n', theta1, M1);
    fprintf('Design Theta 2: %.2f deg\n', theta2);
    fprintf('Max Theta possible at M1: %.2f deg\n', theta_max_deg);

    if theta2 > theta_max_deg
        fprintf('RESULT: UNSTART (Theta 2 > Theta Max)\n');
    else
        fprintf('RESULT: ATTACHED\n');
    end
else
    fprintf('Unstart at Shock 1\n');
end
M_flight = 4.0;
P_inf = 12.11e3; T_inf = 216.5;
Tt0 = T_inf * (1 + (gamma-1)/2 * M_flight^2);
Pt0 = P_inf * (1 + (gamma-1)/2 * M_flight^2)^(gamma/(gamma-1));
V_inf = M_flight * sqrt(gamma*R*T_inf);
mdot = (P_inf/(R*T_inf)) * V_inf * A_cap;
[~, M1, pt1_r, ~] = solve_oblique_robust(M_flight, theta1, gamma);
[~, M2, pt2_r, ~] = solve_oblique_robust(M1, theta2, gamma);
[~, pt3_r] = solve_normal(M2, gamma);
Pt3 = Pt0 * pt1_r * pt2_r * pt3_r;
T_vec = linspace(Tt0, 2200, 50);
F_vec = zeros(size(T_vec));
for i = 1:length(T_vec)
    Tt5 = T_vec(i);

    M4_est = 0.22;
    ray_rat_4 = (2*(gamma+1)*M4_est^2 * (1 + (gamma-1)/2*M4_est^2)) / (1 + gamma*M4_est^2)^2;
    Tt_star = Tt0 / ray_rat_4;

    if Tt5 > Tt_star, T_use = Tt_star; else, T_use = Tt5; end

    ray_rat_5 = T_use / Tt_star;
    M5 = solve_rayleigh_M(ray_rat_5, gamma);

    pt_rat_4 = (gamma+1)/(1+gamma*M4_est^2) * ((2/(gamma+1)) * (1+(gamma-1)/2*M4_est^2))^(gamma/(gamma-1));
    pt_rat_5 = (gamma+1)/(1+gamma*M5^2) * ((2/(gamma+1)) * (1+(gamma-1)/2*M5^2))^(gamma/(gamma-1));

    Pt5 = 0.95 * Pt3 * (pt_rat_5 / pt_rat_4);

    Ae_At = Ae_fixed / At_fixed;
    [Me, ~] = solve_area_mach(Ae_At, gamma, 'supersonic');
    Pe = Pt5 * (1 + (gamma-1)/2*Me^2)^(-gamma/(gamma-1));
    Ve = Me * sqrt(gamma * R * (T_use / (1 + (gamma-1)/2*Me^2)));

    F_vec(i) = mdot * (Ve - V_inf) + (Pe - P_inf) * Ae_fixed;
end
figure('Color','w');
plot(T_vec, F_vec/1000, 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980]);
grid on; xlabel('Combustor Total Temp T_{t5} [K]'); ylabel('Net Thrust [kN]');
title(['Mach 4.0 Performance Sweep']);
xline(2200, '--k', 'Max T limit');
saveas(gcf, 'Mach4_Sweep.png');
function [beta, M2, Pt_ratio, valid] = solve_oblique_robust(M1, theta_deg, gamma)
theta = deg2rad(theta_deg);
valid = false; beta=0; M2=0; Pt_ratio=0;
if M1<=1, return; end

beta_scan = linspace(asin(1/M1), pi/2, 500);
theta_scan = atan( 2*cot(beta_scan).*(M1^2.*sin(beta_scan).^2-1)./(M1^2.*(gamma+cos(2*beta_scan))+2));
if theta > max(theta_scan), return; end
f = theta_scan - theta;
idx = find(f(1:end-1).*f(2:end) <= 0, 1, 'first');
if isempty(idx), return; end
beta = fzero(@(b) atan(2*cot(b)*(M1^2*sin(b)^2-1)/(M1^2*(gamma+cos(2*b))+2))-theta, [beta_scan(idx) beta_scan(idx+1)]);
Mn1 = M1*sin(beta);
Mn2 = sqrt((1+(gamma-1)/2*Mn1^2)/(gamma*Mn1^2-(gamma-1)/2));
M2 = Mn2/sin(beta-theta);
term1 = ((gamma+1)*Mn1^2/(2+(gamma-1)*Mn1^2))^(gamma/(gamma-1));
term2 = (gamma+1)/(2*gamma*Mn1^2-(gamma-1));
Pt_ratio = term1*term2^(1/(gamma-1));
valid = true;
end
function [M2, Pt_ratio] = solve_normal(M1, gamma)
M2 = sqrt( (1 + (gamma-1)/2 * M1^2) / (gamma*M1^2 - (gamma-1)/2) );
term1 = ((gamma+1)*M1^2 / (2 + (gamma-1)*M1^2))^(gamma/(gamma-1));
term2 = (gamma+1) / (2*gamma*M1^2 - (gamma-1));
Pt_ratio = term1 * term2^(1/(gamma-1));
end
function M = solve_rayleigh_M(ratio, gamma)
fun = @(m) ratio - (2*(gamma+1)*m^2 * (1 + (gamma-1)/2*m^2)) / (1 + gamma*m^2)^2;
try, M = fzero(fun, [0.001, 0.999]); catch, M = 0.999; end
end
function [M, valid] = solve_area_mach(AR, gamma, branch)
fun = @(m) AR - (1/m) * ((2/(gamma+1)) * (1 + (gamma-1)/2*m^2))^((gamma+1)/(2*(gamma-1)));
valid = true;
try
    if strcmp(branch, 'supersonic'), M = fzero(fun, [1.001, 20]);
    else, M = fzero(fun, [0.001, 0.999]); end
catch, M = 1; valid = false; end
end
