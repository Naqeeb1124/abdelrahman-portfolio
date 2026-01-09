function lqr_pcode %control terrain type by modifying line 47
    clear; clc; close all;
    
    m1 = 250.0; m2 = 45.0;    
    k1 = 16000.0; k2 = 160000.0;
    b1 = 1000.0; b2 = 0.0;     
    
    A = [0, 1, 0, 0;
        -k1/m1, -b1/m1, k1/m1, b1/m1;
         0, 0, 0, 1;
         k1/m2, b1/m2, -(k1+k2)/m2, -(b1+b2)/m2];
    Bu = [0; 1/m1; 0; -1/m2]; 
    Bw = [0; 0; 0; k2/m2];    
    
    dt = 0.002;
    T_end = 20;
    t = 0:dt:T_end;
    
    sys_pass_c = ss(A, [Bu, Bw], eye(4), 0);
    sys_pass_d = c2d(sys_pass_c, dt, 'zoh');
    
    Q_step = diag([40000, 100, 10, 10]); 
    R_step = 0.0003;
    [K_step, ~, ~] = lqr(A, Bu, Q_step, R_step);
    
    sys_active_d_step = c2d(ss(A - Bu*K_step, Bw, eye(4), 0), dt, 'zoh');
    road_step = 0.1 * (t >= 2.0);
    
    [y_p_step, ~] = lsim(sys_pass_d, [zeros(size(t)); road_step]', t);
    [y_a_step, ~, x_a_step] = lsim(sys_active_d_step, road_step, t);
    
    force_step = (-K_step * x_a_step')';
    deflect_p_step = y_p_step(:,1) - y_p_step(:,3);
    deflect_a_step = y_a_step(:,1) - y_a_step(:,3);
    
    Q_mix = diag([500, 1e8, 100, 1000]);
    R_mix = 1e-6;
    [K_mix, ~, ~] = lqr(A, Bu, Q_mix, R_mix);
    
    sys_active_d_mix = c2d(ss(A - Bu*K_mix, Bw, eye(4), 0), dt, 'zoh');
    
    freq = 1.27; 
    fade = min(t / 3.0, 1);
    w_comp = (0.1 * sin(2*pi*freq*t)) .* fade;
    bumps = 0.15 * exp(-((t - 5).^2)/0.08) + 0.12 * exp(-((t - 12).^2)/0.32);
    rng(100); n_comp = 0.005 * randn(size(t));
    road_mix =  w_comp + bumps+ n_comp; %control terrain shape from here.
    
    [y_p_mix, ~] = lsim(sys_pass_d, [zeros(size(t)); road_mix]', t);
    [y_a_mix, ~, x_a_mix] = lsim(sys_active_d_mix, road_mix, t);
    
    force_mix = (-K_mix * x_a_mix')';
    deflect_p_mix = y_p_mix(:,1) - y_p_mix(:,3);
    deflect_a_mix = y_a_mix(:,1) - y_a_mix(:,3);
    
    figure('Name', 'Body Displacement', 'Color', 'w', 'Position', [50, 50, 600, 800]);
    subplot(2,1,1); hold on; grid on;
    plot(t, road_step, 'k'); plot(t, y_p_step(:,1), 'r--'); plot(t, y_a_step(:,1), 'b', 'LineWidth', 2);
    title('Step: Body Displacement (x1)'); legend('Road', 'Passive', 'Active');
    
    subplot(2,1,2); hold on; grid on;
    plot(t, road_mix, 'k'); plot(t, y_p_mix(:,1), 'r--'); plot(t, y_a_mix(:,1), 'b', 'LineWidth', 2);
    title('Mixed: Body Displacement (x1)');
    
    figure('Name', 'Control Force', 'Color', 'w', 'Position', [660, 50, 600, 800]);
    subplot(2,1,1); plot(t, force_step, 'm', 'LineWidth', 1.5); grid on;
    title('Step: Control Force u(t)'); ylabel('Force (N)'); xlim([1.5 4]);
    
    subplot(2,1,2); plot(t, force_mix, 'm', 'LineWidth', 1.5); grid on;
    title('Mixed: Control Force u(t)'); ylabel('Force (N)');
    
    figure('Name', 'Suspension Deflection', 'Color', 'w', 'Position', [1270, 50, 600, 800]);
    subplot(2,1,1); hold on; grid on;
    plot(t, deflect_p_step, 'r--'); plot(t, deflect_a_step, 'b', 'LineWidth', 2);
    title('Step: Suspension Deflection (x1 - x3)'); ylabel('Deflection (m)'); legend('Passive', 'Active');
    
    subplot(2,1,2); hold on; grid on;
    plot(t, deflect_p_mix, 'r--'); plot(t, deflect_a_mix, 'b', 'LineWidth', 2);
    title('Mixed: Suspension Deflection (x1 - x3)'); ylabel('Deflection (m)');
end