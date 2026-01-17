clear; clc; close all;
gamma = 1.4;
R = 287;
Cp = 1004;
M_inf = 2.75;
P_inf = 12.11e3;
T_inf = 216.5;
Side_Length = 0.25;
A_cross_max = Side_Length^2;
T_comb_max = 2200;
theta_range = 3:0.5:22;
fprintf('Running Design Optimization (Grid Search)...\n');
best_F_net = -inf;
best_design = [];
valid_count = 0;
for theta1 = theta_range
    for theta2 = theta_range

        Tt0 = T_inf * (1 + (gamma-1)/2 * M_inf^2);
        Pt0 = P_inf * (1 + (gamma-1)/2 * M_inf^2)^(gamma/(gamma-1));
        A0 = A_cross_max;

        rho_inf = P_inf / (R * T_inf);
        V_inf = M_inf * sqrt(gamma * R * T_inf);
        mdot = rho_inf * V_inf * A0;

        [~, M1, pt1_rat, valid1] = solve_oblique_robust(M_inf, theta1, gamma);
        if ~valid1, continue; end

        Pt1 = Pt0 * pt1_rat;
        Tt1 = Tt0;
        T1 = Tt1 / (1 + (gamma-1)/2 * M1^2);
        P1 = Pt1 / ((1 + (gamma-1)/2 * M1^2)^(gamma/(gamma-1)));

        [~, M2, pt2_rat, valid2] = solve_oblique_robust(M1, theta2, gamma);
        if ~valid2, continue; end

        Pt2 = Pt1 * pt2_rat;
        Tt2 = Tt0;
        T2 = Tt2 / (1 + (gamma-1)/2 * M2^2);
        P2 = Pt2 / ((1 + (gamma-1)/2 * M2^2)^(gamma/(gamma-1)));

        [M3, pt3_rat] = solve_normal(M2, gamma);

        Pt3 = Pt2 * pt3_rat;
        Tt3 = Tt0;
        T3 = Tt3 / (1 + (gamma-1)/2 * M3^2);
        P3 = Pt3 / ((1 + (gamma-1)/2 * M3^2)^(gamma/(gamma-1)));

        Intake_Recovery = Pt3 / Pt0;

        M4 = 0.22;

        Pt4 = Pt3;
        Tt4 = Tt3;
        P4 = Pt4 / ((1 + (gamma-1)/2 * M4^2)^(gamma/(gamma-1)));
        T4 = Tt4 / (1 + (gamma-1)/2 * M4^2);


        ray_rat_4 = (2*(gamma+1)*M4^2 * (1 + (gamma-1)/2*M4^2)) / (1 + gamma*M4^2)^2;
        Tt_star = Tt4 / ray_rat_4;

        if T_comb_max > Tt_star
            Tt5 = Tt_star;
            M5 = 1.0;
        else
            Tt5 = T_comb_max;
            ray_rat_5 = Tt5 / Tt_star;
            M5 = solve_rayleigh_M(ray_rat_5, gamma);
        end

        pt_star_rat_4 = (gamma+1)/(1+gamma*M4^2) * ((2/(gamma+1)) * (1+(gamma-1)/2*M4^2))^(gamma/(gamma-1));
        pt_star_rat_5 = (gamma+1)/(1+gamma*M5^2) * ((2/(gamma+1)) * (1+(gamma-1)/2*M5^2))^(gamma/(gamma-1));

        Pt5_rayleigh = Pt4 * (pt_star_rat_5 / pt_star_rat_4);

        Pt5 = 0.95 * Pt5_rayleigh;

        sonic_const = sqrt(gamma/R) * (2/(gamma+1))^((gamma+1)/(2*(gamma-1)));
        A_throat = mdot / (Pt5 * sonic_const / sqrt(Tt5));

        if A_throat > A_cross_max
            continue;
        end

        Pa = P_inf;
        if Pa >= Pt5
            F_net = -inf;
        else
            Me_ideal = sqrt( ( (Pt5/Pa)^((gamma-1)/gamma) - 1 ) * 2/(gamma-1) );

            Ae_At_ideal = (1/Me_ideal) * ((2/(gamma+1)) * (1 + (gamma-1)/2*Me_ideal^2))^((gamma+1)/(2*(gamma-1)));
            Ae_required = Ae_At_ideal * A_throat;

            if Ae_required > A_cross_max
                Ae = A_cross_max;
                Ae_At = Ae / A_throat;
                [Me, ~] = solve_area_mach(Ae_At, gamma, 'supersonic');
                Pe = Pt5 * (1 + (gamma-1)/2*Me^2)^(-gamma/(gamma-1));
            else
                Ae = Ae_required;
                Me = Me_ideal;
                Pe = Pa;
            end

            Ve = Me * sqrt(gamma * R * (Tt5 / (1 + (gamma-1)/2*Me^2)));

            F_gross_term = mdot * Ve + (Pe - Pa) * Ae;

            F_net = F_gross_term - (mdot * V_inf);

            valid_count = valid_count + 1;
        end

        if F_net > best_F_net
            best_F_net = F_net;

            best_design.theta1 = theta1;
            best_design.theta2 = theta2;
            best_design.recovery = Intake_Recovery;
            best_design.F_net = F_net;
            best_design.mdot = mdot;
            best_design.Ae = Ae;
            best_design.At = A_throat;
            best_design.Tt5 = Tt5;

            Te = Tt5 / (1 + (gamma-1)/2*Me^2);

            best_design.M = [M_inf, M1, M2, M3, M4, M5, 1.0, Me];
            best_design.Pt = [Pt0, Pt1, Pt2, Pt3, Pt4, Pt5, Pt5, Pt5];
            best_design.Tt = [Tt0, Tt0, Tt0, Tt0, Tt4, Tt5, Tt5, Tt5];
            best_design.P = [P_inf, P1, P2, P3, P4, Pt5/((1+(gamma-1)/2*M5^2)^(gamma/(gamma-1))), Pt5*(2/(gamma+1))^(gamma/(gamma-1)), Pe];
            best_design.T = [T_inf, T1, T2, T3, T4, Tt5/(1+(gamma-1)/2*M5^2), Tt5*(2/(gamma+1)), Te];

            rho2 = P2 / (R * T2);
            V2 = M2 * sqrt(gamma * R * T2);
            A2 = mdot / (rho2 * V2);

            h_cap = sqrt(A0);
            h_2 = A2 / h_cap;
            dh = h_cap - h_2;

            best_design.L_wedge1 = (0.5 * dh) / tand(theta1);
            best_design.L_wedge2 = (0.5 * dh) / tand(theta1 + theta2);
        end
    end
end
fprintf('\n========================================\n');
fprintf('   OPTIMIZED RAMJET DESIGN REPORT\n');
fprintf('========================================\n');
if isempty(best_design)
    fprintf('ERROR: No valid design found.\n');
else
    fprintf('Optimized Intake Angles:\n');
    fprintf('  Theta 1: %.2f deg\n', best_design.theta1);
    fprintf('  Theta 2: %.2f deg\n', best_design.theta2);
    fprintf('\nPerformance Metrics:\n');
    fprintf('  Intake Pressure Recovery: %.4f\n', best_design.recovery);
    fprintf('  Combustor Total Temp: %.1f K\n', best_design.Tt5);
    fprintf('  Net Thrust: %.2f N\n', best_design.F_net);
    fprintf('  Specific Thrust: %.2f N/(kg/s)\n', best_design.F_net/best_design.mdot);

    fprintf('\nGeometry:\n');
    fprintf('  Capture Area: %.4f m^2\n', A_cross_max);
    fprintf('  Nozzle Throat Area: %.6f m^2\n', best_design.At);
    fprintf('  Nozzle Exit Area: %.4f m^2\n', best_design.Ae);
    fprintf('  Wedge 1 Length: %.4f m\n', best_design.L_wedge1);
    fprintf('  Wedge 2 Length: %.4f m\n', best_design.L_wedge2);

    fprintf('\nStation Properties (M, P [kPa], T [K], Pt [kPa], Tt [K]):\n');
    stations = {'0 (Free)', '1 (Obli1)', '2 (Obli2)', '3 (Norm)', '4 (Diff)', '5 (Comb)', '6 (Throat)', '7 (Exit)'};
    for i = 1:8
        fprintf('%-10s: M=%.2f, P=%7.2f, T=%6.1f, Pt=%7.2f, Tt=%6.1f\n', ...
            stations{i}, best_design.M(i), best_design.P(i)/1000, best_design.T(i), ...
            best_design.Pt(i)/1000, best_design.Tt(i));
    end

    fprintf('\n========================================\n');
    fprintf('   BONUS: OFF-DESIGN (Fixed Geom)\n');
    fprintf('========================================\n');
    theta1_fix = best_design.theta1;
    theta2_fix = best_design.theta2;
    At_fix = best_design.At;
    Ae_fix = best_design.Ae;

    off_design_Machs = [2.0, 4.0];

    for M_off = off_design_Machs
        fprintf('\n--- Analyzing Off-Design Mach %.1f ---\n', M_off);

        Tt0_off = T_inf * (1 + (gamma-1)/2 * M_off^2);
        Pt0_off = P_inf * (1 + (gamma-1)/2 * M_off^2)^(gamma/(gamma-1));

        V_off = M_off * sqrt(gamma*R*T_inf);
        mdot_off = (P_inf/(R*T_inf)) * V_off * A_cross_max;

        [~, M1_o, pt1_r, v1] = solve_oblique_robust(M_off, theta1_fix, gamma);

        if v1
            [~, M2_o, pt2_r, v2] = solve_oblique_robust(M1_o, theta2_fix, gamma);
            if v2
                [~, pt3_r] = solve_normal(M2_o, gamma);
                Pt3_off = Pt0_off * pt1_r * pt2_r * pt3_r;
                Tt4_off = Tt0_off;

                T_sweep = linspace(Tt4_off, T_comb_max, 100);
                max_F_off = -inf;
                opt_T_off = Tt4_off;

                for T_try = T_sweep


                    M4_est = 0.22;
                    ray_rat_4 = (2*(gamma+1)*M4_est^2 * (1 + (gamma-1)/2*M4_est^2)) / (1 + gamma*M4_est^2)^2;
                    Tt_star = Tt4_off / ray_rat_4;

                    if T_try > Tt_star, T_actual = Tt_star; else, T_actual = T_try; end

                    ray_rat_5 = T_actual / Tt_star;
                    M5_off = solve_rayleigh_M(ray_rat_5, gamma);

                    pt_rat_4 = (gamma+1)/(1+gamma*M4_est^2) * ((2/(gamma+1)) * (1+(gamma-1)/2*M4_est^2))^(gamma/(gamma-1));
                    pt_rat_5 = (gamma+1)/(1+gamma*M5_off^2) * ((2/(gamma+1)) * (1+(gamma-1)/2*M5_off^2))^(gamma/(gamma-1));

                    Pt5_off = 0.95 * Pt3_off * (pt_rat_5 / pt_rat_4);

                    Ae_At = Ae_fix / At_fix;
                    [Me_off, ~] = solve_area_mach(Ae_At, gamma, 'supersonic');
                    Pe_off = Pt5_off * (1 + (gamma-1)/2*Me_off^2)^(-gamma/(gamma-1));
                    Ve_off = Me_off * sqrt(gamma * R * (T_actual / (1 + (gamma-1)/2*Me_off^2)));

                    F_net_now = mdot_off * (Ve_off - V_off) + (Pe_off - P_inf) * Ae_fix;

                    if F_net_now > max_F_off
                        max_F_off = F_net_now;
                        opt_T_off = T_actual;
                    end
                end
                fprintf('  Optimal Combustor Temp: %.1f K\n', opt_T_off);
                fprintf('  Max Net Thrust: %.2f N\n', max_F_off);
            else
                fprintf('  Intake Unstart (Shock 2 detached)\n');
            end
        else
            fprintf('  Intake Unstart (Shock 1 detached)\n');
        end
    end
end
function [beta, M2, Pt_ratio, valid] = solve_oblique_robust(M1, theta_deg, gamma)
valid = false; beta=0; M2=0; Pt_ratio=0;

if M1 <= 1 || theta_deg <= 0, return; end
theta = deg2rad(theta_deg);
mu = asin(1/M1);
beta_grid = linspace(mu+1e-4, pi/2-1e-4, 500);
theta_grid = atan( 2*cot(beta_grid) .* (M1^2 .* sin(beta_grid).^2 - 1) ./ ...
    (M1^2 .* (gamma + cos(2*beta_grid)) + 2) );
if theta > max(theta_grid), return; end
f = theta_grid - theta;
idx = find(f(1:end-1).*f(2:end) <= 0, 1, 'first');
if isempty(idx), return; end
try
    beta = fzero(@(b) atan( 2*cot(b) * (M1^2*sin(b)^2 - 1) / (M1^2*(gamma + cos(2*b)) + 2) ) - theta, ...
        [beta_grid(idx), beta_grid(idx+1)]);
catch
    return;
end
Mn1 = M1*sin(beta);
if Mn1 <= 1, return; end
Mn2 = sqrt( (1 + (gamma-1)/2 * Mn1^2) / (gamma*Mn1^2 - (gamma-1)/2) );
M2 = Mn2 / sin(beta - theta);
term1 = ((gamma+1)*Mn1^2 / (2 + (gamma-1)*Mn1^2))^(gamma/(gamma-1));
term2 = (gamma+1) / (2*gamma*Mn1^2 - (gamma-1));
Pt_ratio = term1 * term2^(1/(gamma-1));
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
    if strcmp(branch, 'supersonic')
        M = fzero(fun, [1.001, 20]);
    else
        M = fzero(fun, [0.001, 0.999]);
    end
catch
    M = 1; valid = false;
end
end
