clear; clc; close all;
gamma = 1.4;
R = 287;
Pa = 101325;
P0_design = 100 * 1e5;
T0_combustor = 2200;
P_tank_init = 200 * 1e5;
T_tank_init = 300;
Vol_tank = 0.5;
Dt = 0.020;
At = pi * (Dt/2)^2;
fprintf('--- DESIGN PARAMETERS ---\n');
fprintf('Throat Diameter: %.1f mm\n', Dt*1000);
target_PR = P0_design / Pa;
find_Mach = @(M) (1 + (gamma-1)/2 * M.^2).^(gamma/(gamma-1)) - target_PR;
Me_design = fzero(find_Mach, 3.5);
Ae_At = (1/Me_design) * ((2/(gamma+1)) * (1 + (gamma-1)/2 * Me_design^2))^((gamma+1)/(2*(gamma-1)));
Ae = At * Ae_At;
De = sqrt(4 * Ae / pi);
c_star = sqrt(R * T0_combustor) / (sqrt(gamma) * (2/(gamma+1))^((gamma+1)/(2*(gamma-1))));
mdot_design = (P0_design * At) / c_star;
Ve_design = Me_design * sqrt(gamma * R * (T0_combustor / (1 + (gamma-1)/2 * Me_design^2)));
Thrust_design = mdot_design * Ve_design;
fprintf('Design Nozzle Exit Mach: %.2f\n', Me_design);
fprintf('Design Area Ratio (Ae/At): %.2f\n', Ae_At);
fprintf('Nozzle Exit Diameter: %.1f mm\n', De*1000);
fprintf('Design Thrust: %.2f N\n', Thrust_design);
fprintf('-------------------------\n');
M_inlet_design = 0.1;
rho_cold_design = P0_design / (R * T_tank_init);
V_inlet = M_inlet_design * sqrt(gamma * R * T_tank_init);
Ac = mdot_design / (rho_cold_design * V_inlet);
Dc = sqrt(4 * Ac / pi);
fprintf('\n--- BONUS: COMBUSTOR SIZING ---\n');
fprintf('Combustor Inlet Mach (Design): %.2f\n', M_inlet_design);
fprintf('Combustor Diameter: %.1f mm\n', Dc*1000);
fprintf('-----------------------------\n');
dt = 0.05;
t_max = 60;
steps = t_max / dt;
time = 0:dt:t_max;
N = length(time);
P_tank = zeros(1, N); T_tank = zeros(1, N);
mdot = zeros(1, N); Thrust = zeros(1, N);
m_gas = zeros(1, N);
P_tank_B = zeros(1, N); T_tank_B = zeros(1, N);
mdot_B = zeros(1, N); Thrust_B = zeros(1, N);
P0_loss = zeros(1, N);
P_tank(1) = P_tank_init; T_tank(1) = T_tank_init;
m_gas(1) = (P_tank_init * Vol_tank) / (R * T_tank_init);
P_tank_B(1) = P_tank_init; T_tank_B(1) = T_tank_init;
m_gas_B = m_gas(1);
for k = 1:N-1

    if P_tank(k) > 1.5 * Pa
        P0_noz = P_tank(k);
        mdot(k) = (P0_noz * At) / c_star;

        P_exit = P0_noz / target_PR;
        Te = T0_combustor / (1 + (gamma-1)/2 * Me_design^2);
        Ve = Me_design * sqrt(gamma * R * Te);
        Thrust(k) = mdot(k) * Ve + (P_exit - Pa) * Ae;

        m_gas(k+1) = m_gas(k) - mdot(k) * dt;
        T_tank(k+1) = T_tank(k) * (m_gas(k+1) / m_gas(k))^(gamma-1);
        P_tank(k+1) = (m_gas(k+1) * R * T_tank(k+1)) / Vol_tank;
    else
        P_tank(k+1) = P_tank(k); T_tank(k+1) = T_tank(k);
        mdot(k) = 0; Thrust(k) = 0;
    end

    if P_tank_B(k) > 1.5 * Pa

        mdot_guess = mdot(k);

        func_P0_star = @(M) ((gamma+1)/(1+gamma*M^2)) * ...
            ((2/(gamma+1)) * (1+(gamma-1)/2*M^2))^(gamma/(gamma-1));

        func_T0_star = @(M) (2*(gamma+1)*M^2 * (1 + (gamma-1)/2*M^2)) / (1 + gamma*M^2)^2;
        for iter = 1:15
            rho1_stag = P_tank_B(k) / (R * T_tank_B(k));
            a1 = sqrt(gamma * R * T_tank_B(k));

            M1 = (mdot_guess / (rho1_stag * Ac)) / a1;

            T0_ratio_req = T0_combustor / T_tank_B(k);

            val_T01_star = func_T0_star(M1);
            val_T02_star = val_T01_star * T0_ratio_req;

            if val_T02_star > 1.0
                val_T02_star = 0.999;
            end

            solve_M2 = @(m) func_T0_star(m) - val_T02_star;
            M2 = fzero(solve_M2, [M1, 0.9999]);

            P0_ratio = func_P0_star(M2) / func_P0_star(M1);

            P0_noz_B = P_tank_B(k) * P0_ratio;

            mdot_new = (P0_noz_B * At) / c_star;
            if abs(mdot_new - mdot_guess) < 1e-5
                mdot_guess = mdot_new;
                break;
            end
            mdot_guess = mdot_new;
        end

        mdot_B(k) = mdot_guess;
        Thrust_B(k) = mdot_B(k) * Ve + ((P0_noz_B/target_PR) - Pa) * Ae;

        m_curr = (P_tank_B(k) * Vol_tank) / (R * T_tank_B(k));
        m_next = m_curr - mdot_B(k) * dt;
        T_tank_B(k+1) = T_tank_B(k) * (m_next / m_curr)^(gamma-1);
        P_tank_B(k+1) = (m_next * R * T_tank_B(k+1)) / Vol_tank;

    else
        P_tank_B(k+1) = P_tank_B(k); T_tank_B(k+1) = T_tank_B(k);
        mdot_B(k) = 0; Thrust_B(k) = 0;
    end
end
time = time(1:end-1);
P_tank = P_tank(1:end-1); T_tank = T_tank(1:end-1);
mdot = mdot(1:end-1); Thrust = Thrust(1:end-1);
P_tank_B = P_tank_B(1:end-1); T_tank_B = T_tank_B(1:end-1);
mdot_B = mdot_B(1:end-1); Thrust_B = Thrust_B(1:end-1);
figure('Name', 'Rocket Engine Performance', 'Position', [100, 100, 1000, 600]);
subplot(2,2,1);
plot(time, P_tank/1e5, 'LineWidth', 2); hold on;
plot(time, P_tank_B/1e5, '--r', 'LineWidth', 1.5);
yline(100, 'k:', 'Design Point');
xlabel('Time (s)'); ylabel('Pressure (bar)');
title('Tank Pressure History');
legend('Base Model', 'Bonus (Rayleigh)', 'Location','best');
grid on;
subplot(2,2,2);
plot(time, T_tank, 'LineWidth', 2); hold on;
plot(time, T_tank_B, '--r', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Temperature (K)');
title('Tank Temperature History');
grid on;
subplot(2,2,3);
plot(time, mdot, 'LineWidth', 2); hold on;
plot(time, mdot_B, '--r', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Mass Flow (kg/s)');
title('Mass Flow Rate');
grid on;
subplot(2,2,4);
plot(time, Thrust/1000, 'LineWidth', 2); hold on;
plot(time, Thrust_B/1000, '--r', 'LineWidth', 1.5);
yline(Thrust_design/1000, 'k:', 'Design Thrust');
xlabel('Time (s)'); ylabel('Thrust (kN)');
title('Thrust Time Curve');
grid on;
fprintf('\nSimulation Complete.\n');
