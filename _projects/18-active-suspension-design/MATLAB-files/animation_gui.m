function animation_gui
    clear; clc; close all;
    
    m1 = 250.0; m2 = 45.0;    
    k1 = 16000.0; k2 = 160000.0;
    b1 = 1000.0; b2 = 0.0;     
    velocity = 12.0;

    A = [0, 1, 0, 0;
        -k1/m1, -b1/m1, k1/m1, b1/m1;
         0, 0, 0, 1;
         k1/m2, b1/m2, -(k1+k2)/m2, -(b1+b2)/m2];
    Bu = [0; 1/m1; 0; -1/m2]; 
    Bw = [0; 0; 0; k2/m2];    
    B_sim = [Bu, Bw]; 
    
    dt = 0.002;
    T_end = 20;
    t = 0:dt:T_end;
    sys_pass_c = ss(A, B_sim, eye(4), 0);
    sys_pass_d = c2d(sys_pass_c, dt, 'zoh');
    
    road_profile = zeros(size(t));
    x1_p = zeros(size(t)); x2_p = zeros(size(t));
    x1_a = zeros(size(t)); x2_a = zeros(size(t));
    
    is_playing = false;
    current_idx = 1;
    
    f_main = figure('Name', 'Active Suspension Simulator', ...
        'Color', [0.95 0.95 0.95], 'Position', [100, 100, 1100, 600], ...
        'NumberTitle', 'off', 'MenuBar', 'none');
    
    pnl_ctrl = uipanel(f_main, 'Title', 'Controls', 'FontSize', 12, ...
        'Position', [0.01 0.01 0.2 0.98], 'BackgroundColor', 'w');
    
    uicontrol(pnl_ctrl, 'Style', 'text', 'String', 'Terrain Types:', ...
        'Position', [10 520 180 20], 'HorizontalAlignment', 'left', ...
        'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'w');
        
    chk_waves = uicontrol(pnl_ctrl, 'Style', 'checkbox', 'String', 'Resonant Waves', ...
        'Position', [20 490 180 20], 'Value', 1, 'FontSize', 10, ...
        'BackgroundColor', 'w', 'Callback', @update_simulation);
        
    chk_bumps = uicontrol(pnl_ctrl, 'Style', 'checkbox', 'String', 'Speedbumps', ...
        'Position', [20 460 180 20], 'Value', 0, 'FontSize', 10, ...
        'BackgroundColor', 'w', 'Callback', @update_simulation);
        
    chk_noise = uicontrol(pnl_ctrl, 'Style', 'checkbox', 'String', 'Gravel (Noise)', ...
        'Position', [20 430 180 20], 'Value', 0, 'FontSize', 10, ...
        'BackgroundColor', 'w', 'Callback', @update_simulation);
    chk_step = uicontrol(pnl_ctrl, 'Style', 'checkbox', 'String', 'Step Input (Curb)', ...
        'Position', [20 400 180 20], 'Value', 0, 'FontSize', 10, ...
        'FontWeight', 'bold', 'ForegroundColor', 'b', ...
        'BackgroundColor', 'w', 'Callback', @update_simulation);
        
    btn_play = uicontrol(pnl_ctrl, 'Style', 'pushbutton', 'String', 'PLAY', ...
        'Position', [20 100 160 50], 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.8 0.2], 'Callback', @toggle_play);
        
    btn_reset = uicontrol(pnl_ctrl, 'Style', 'pushbutton', 'String', 'RESET', ...
        'Position', [20 40 160 40], 'FontSize', 12, ...
        'BackgroundColor', [0.8 0.8 0.8], 'Callback', @reset_sim);
    
    ax_p = axes('Parent', f_main, 'Position', [0.25 0.55 0.35 0.4]);
    title(ax_p, 'Passive Suspension', 'Color', 'r', 'FontSize', 14);
    axis(ax_p, 'equal'); xlim(ax_p, [-2 4]); ylim(ax_p, [-0.5 2.5]); axis(ax_p, 'off');
    hold(ax_p, 'on');
    
    ax_a = axes('Parent', f_main, 'Position', [0.63 0.55 0.35 0.4]);
    title(ax_a, 'Active LQR Suspension', 'Color', 'b', 'FontSize', 14);
    axis(ax_a, 'equal'); xlim(ax_a, [-2 4]); ylim(ax_a, [-0.5 2.5]); axis(ax_a, 'off');
    hold(ax_a, 'on');
    
    ax_g = axes('Parent', f_main, 'Position', [0.25 0.08 0.73 0.35]);
    grid(ax_g, 'on'); hold(ax_g, 'on');
    title(ax_g, 'Displacement Tracking', 'FontSize', 11);
    xlabel(ax_g, 'Time (s)'); ylabel(ax_g, 'Amp (m)');
    xlim(ax_g, [0 T_end]); ylim(ax_g, [-0.3 0.5]);
    
    trace_road = plot(ax_g, 0, 0, 'k-', 'LineWidth', 1, 'DisplayName', 'Road');
    trace_pass = plot(ax_g, 0, 0, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Passive');
    trace_act  = plot(ax_g, 0, 0, 'b-', 'LineWidth', 2, 'DisplayName', 'Active');
    legend(ax_g, 'Location', 'northeast');
    
    road_vis_p = plot(ax_p, 0,0, 'k-', 'LineWidth', 2);
    body_vis_p = rectangle(ax_p, 'Position', [-0.4 0.8 0.8 0.3], 'FaceColor', 'r', 'EdgeColor', 'k');
    wheel_vis_p = rectangle(ax_p, 'Position', [-0.15 -0.15 0.3 0.3], 'Curvature', [1 1], 'FaceColor', 'k');
    spring_vis_p = plot(ax_p, [0 0], [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 3);
    
    road_vis_a = plot(ax_a, 0,0, 'k-', 'LineWidth', 2);
    body_vis_a = rectangle(ax_a, 'Position', [-0.4 0.8 0.8 0.3], 'FaceColor', 'b', 'EdgeColor', 'k');
    wheel_vis_a = rectangle(ax_a, 'Position', [-0.15 -0.15 0.3 0.3], 'Curvature', [1 1], 'FaceColor', 'k');
    spring_vis_a = plot(ax_a, [0 0], [0 0], 'Color', [0.5 0.5 0.5], 'LineWidth', 3);
    
    road_x_vis = linspace(-2, 4, 100);
    
    update_simulation();
    
    function update_simulation(~, ~)
        if chk_step.Value == 1
            set(chk_waves, 'Value', 0, 'Enable', 'off');
            set(chk_bumps, 'Value', 0, 'Enable', 'off');
            set(chk_noise, 'Value', 0, 'Enable', 'off');
            
            Q_gain = diag([40000, 100, 10, 10]); 
            R_gain = 0.0003;
        else
            set(chk_waves, 'Enable', 'on');
            set(chk_bumps, 'Enable', 'on');
            set(chk_noise, 'Enable', 'on');
            
            Q_gain = diag([500, 1e8, 100, 1000]);
            R_gain = 1e-6;
        end
        
        [K_lqr, ~, ~] = lqr(A, Bu, Q_gain, R_gain);
        
        sys_cont = ss(A - Bu*K_lqr, Bw, eye(4), 0);
        sys_disc = c2d(sys_cont, dt, 'zoh');
        
        use_wave = chk_waves.Value;
        use_bump = chk_bumps.Value;
        use_noise = chk_noise.Value;
        use_step  = chk_step.Value; 
        
        freq_res = 1.27; 
        fade_env = min(t / 3.0, 1); 
        
        w_comp = use_wave * (0.1 * sin(2*pi*freq_res*t)) .* fade_env;
        
        bump1 = 0.15 * exp(-((t - 5.0).^2) / (2*0.2^2));
        bump2 = 0.12 * exp(-((t - 12.0).^2) / (2*0.4^2));
        b_comp = use_bump * (bump1 + bump2);
        
        rng(100); 
        n_comp = use_noise * (0.015 * randn(size(t)));
        
        s_comp = use_step * (0.1 * (t >= 2.0));
        
        road_profile = w_comp + b_comp + n_comp + s_comp;
        
        U_pass = [zeros(size(t)); road_profile]';
        [y_p, ~] = lsim(sys_pass_d, U_pass, t);
        x1_p = y_p(:,1); x2_p = y_p(:,3);
        
        [y_a, ~] = lsim(sys_disc, road_profile, t);
        x1_a = y_a(:,1); x2_a = y_a(:,3);
        
        set(trace_road, 'XData', t, 'YData', road_profile);
        
        if ~is_playing
            draw_frame(current_idx);
        end
    end
    function toggle_play(~, ~)
        if is_playing
            is_playing = false;
            btn_play.String = 'PLAY';
            btn_play.BackgroundColor = [0.2 0.8 0.2];
        else
            is_playing = true;
            btn_play.String = 'PAUSE';
            btn_play.BackgroundColor = [0.9 0.6 0.2];
            run_animation_loop();
        end
    end
    function reset_sim(~, ~)
        is_playing = false;
        btn_play.String = 'PLAY';
        btn_play.BackgroundColor = [0.2 0.8 0.2];
        current_idx = 1;
        draw_frame(1);
    end
    function run_animation_loop()
        skip_frames = 1;
        while is_playing && current_idx < length(t)
            current_idx = current_idx + skip_frames;
            if current_idx > length(t)
                current_idx = length(t);
                is_playing = false;
                btn_play.String = 'PLAY';
            end
            draw_frame(current_idx);
            drawnow limitrate; 
        end
    end
    function draw_frame(idx)
        curr_t = t(idx);
        set(trace_pass, 'XData', t(1:idx), 'YData', x1_p(1:idx));
        set(trace_act,  'XData', t(1:idx), 'YData', x1_a(1:idx));
        
        road_y_vis = interp1(t, road_profile, curr_t + road_x_vis/velocity, 'linear', 0);
        
        set(road_vis_p, 'XData', road_x_vis, 'YData', road_y_vis);
        pos_w_p = x2_p(idx) + 0.15;
        pos_b_p = x1_p(idx) + 0.65;
        set(wheel_vis_p, 'Position', [-0.15, pos_w_p-0.15, 0.3, 0.3]);
        set(body_vis_p, 'Position', [-0.4, pos_b_p, 0.8, 0.3]);
        set(spring_vis_p, 'XData', [0 0], 'YData', [pos_w_p, pos_b_p]);
        
        set(road_vis_a, 'XData', road_x_vis, 'YData', road_y_vis);
        pos_w_a = x2_a(idx) + 0.15;
        pos_b_a = x1_a(idx) + 0.65;
        set(wheel_vis_a, 'Position', [-0.15, pos_w_a-0.15, 0.3, 0.3]);
        set(body_vis_a, 'Position', [-0.4, pos_b_a, 0.8, 0.3]);
        set(spring_vis_a, 'XData', [0 0], 'YData', [pos_w_a, pos_b_a]);
    end
end