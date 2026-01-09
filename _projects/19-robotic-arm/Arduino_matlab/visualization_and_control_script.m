function robot_arm_floor_safety()
    close all; clc;

    %% --- CONFIGURATION ---
    PORT = 'COM2';
    BAUD = 9600;
    
    L1 = 17; 
    L2 = 18.95; 
    H1 = 6; 
    
    OFFSET_SHOULDER = -12.5; 
    OFFSET_ELBOW    = 35;    
    
    FLOOR_CLEARANCE = 1.5; % Distance from tip to floor at Home

    % SERVO LIMITS
    LIM_B = [0, 180];
    LIM_S = [0, 180]; 
    LIM_E = [0, 180]; 

    target_home = [90, 65, 25]; 

    %% --- CONNECT ---
    fprintf('Connecting to %s...\n', PORT);
    s = [];
    try
        s = serialport(PORT, BAUD);
        configureTerminator(s, "LF");
    catch
        fprintf('Arduino not found. Running in Simulation Mode.\n');
    end

    %% --- SETUP ---
    curr_angles = target_home;
    is_spinning = false;
    
    % Calculate Floor Z Level
    [home_abs, ~, ~] = calculateFK(target_home, L1, L2, H1, OFFSET_SHOULDER, OFFSET_ELBOW);
    FLOOR_Z_LEVEL = home_abs(3) - FLOOR_CLEARANCE;
    
    % --- SAFETY THRESHOLD ---
    % We stop 0.5cm ABOVE the floor to be safe
    MIN_SAFE_Z = FLOOR_Z_LEVEL + 0.5; 

    if ~isempty(s)
        smoothMove(s, [90 90 90], target_home, 30);
    end

    %% --- GUI SETUP ---
    f = figure('Name', 'Mechatronics Control (Floor Safety Active)', ...
        'Position', [50 50 1200 700], ...
        'KeyPressFcn', @handleKey, ...
        'CloseRequestFcn', @cleanUp);

    % 3D Plot
    subplot(1, 4, [1 3]);
    hold on; grid on; axis equal;
    view(135, 25);
    axis([-40 40 -40 40 -10 50]); 
    xlabel('X'); ylabel('Y'); zlabel('Z');
    
    % Draw Floor
    patch([-45 45 45 -45], [-45 -45 45 45], ...
          [FLOOR_Z_LEVEL FLOOR_Z_LEVEL FLOOR_Z_LEVEL FLOOR_Z_LEVEL], ...
          [0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    
    % Draw Base Square
    sq_x = [-12.5 12.5 12.5 -12.5 -12.5];
    sq_y = [-12.5 -12.5 12.5 12.5 -12.5];
    plot3(sq_x, sq_y, ones(1,5)*FLOOR_Z_LEVEL, 'k--', 'LineWidth', 1);
    
    % Markers
    plot3(0,0,0, 'ko', 'MarkerSize', 10, 'LineWidth', 2);
    plot3(home_abs(1), home_abs(2), home_abs(3), 'g+', 'MarkerSize', 15, 'LineWidth', 3);

    % Robot Links
    h_link0 = plot3([0 0], [0 0], [0 0], 'k-', 'LineWidth', 6);
    h_link1 = plot3([0 0], [0 0], [0 0], 'b-o', 'LineWidth', 5, 'MarkerSize', 6);
    h_link2 = plot3([0 0], [0 0], [0 0], 'r-o', 'LineWidth', 5, 'MarkerSize', 8, 'MarkerFaceColor', 'r');

    % Controls
    subplot(1, 4, 4); axis off;
    
    text(0, 0.90, 'POS (Base Frame):', 'FontSize', 12, 'FontWeight', 'bold');
    t_vec_x = text(0, 0.82, 'X: 0.0', 'FontSize', 14, 'Color', 'b', 'FontName', 'Consolas');
    t_vec_y = text(0.5, 0.82, 'Y: 0.0', 'FontSize', 14, 'Color', 'b', 'FontName', 'Consolas');
    t_vec_z = text(0, 0.74, 'Z: 0.0', 'FontSize', 14, 'Color', 'b', 'FontName', 'Consolas');
    
    text(0, 0.64, 'MAGNITUDE:', 'FontSize', 10);
    t_mag = text(0, 0.57, '0.00', 'FontSize', 18, 'Color', 'm', 'FontName', 'Consolas', 'FontWeight', 'bold');

    text(0, 0.45, 'ANGLES:', 'FontSize', 10);
    t_ang = text(0, 0.38, '[0, 0, 0]', 'FontSize', 12, 'FontName', 'Consolas');

    % Inputs
    uicontrol('Style', 'text', 'String', 'Move to XYZ:', 'Units', 'normalized', 'Position', [0.75 0.28 0.2 0.03]);
    in_x = uicontrol('Style', 'edit', 'String', '0', 'Units', 'normalized', 'Position', [0.75 0.24 0.06 0.04]);
    in_y = uicontrol('Style', 'edit', 'String', '17.5', 'Units', 'normalized', 'Position', [0.82 0.24 0.06 0.04]);
    in_z = uicontrol('Style', 'edit', 'String', '2', 'Units', 'normalized', 'Position', [0.89 0.24 0.06 0.04]);
    
    uicontrol('Style', 'pushbutton', 'String', 'MOVE', 'Units', 'normalized', 'Position', [0.75 0.18 0.2 0.05], 'BackgroundColor', [1 0.8 0.4], 'Callback', @moveToTarget);
    uicontrol('Style', 'togglebutton', 'String', 'AUTO SPIN', 'Units', 'normalized', 'Position', [0.75 0.12 0.2 0.05], 'BackgroundColor', [0.4 0.6 1], 'Callback', @toggleSpin);
    uicontrol('Style', 'pushbutton', 'String', 'GO HOME', 'Units', 'normalized', 'Position', [0.75 0.06 0.2 0.05], 'BackgroundColor', [0.2 0.8 0.2], 'Callback', @goHome);

    updateSystem();

    %% --- MOVEMENT LOGIC (WITH FLOOR SAFETY) ---
    function moveToTarget(~, ~)
        tx = str2double(get(in_x, 'String'));
        ty = str2double(get(in_y, 'String'));
        tz = str2double(get(in_z, 'String'));
        
        if isnan(tx) || isnan(ty) || isnan(tz), return; end
        
        was_modified = false;

        % --- 1. FLOOR SAFETY CHECK ---
        if tz < MIN_SAFE_Z
            fprintf('WARNING: Target Z (%.2f) is below floor limit (%.2f). Clamping.\n', tz, MIN_SAFE_Z);
            tz = MIN_SAFE_Z;
            was_modified = true;
        end
        % -----------------------------

        % --- 2. REACH SPHERE CHECK ---
        z_rel = tz - H1;
        dist = sqrt(tx^2 + ty^2 + z_rel^2);
        max_r = L1 + L2 - 0.1;
        
        if dist > max_r
            scale = max_r / dist;
            tx = tx * scale;
            ty = ty * scale;
            z_rel = z_rel * scale;
            tz = z_rel + H1;
        end

        % --- 3. PRIORITIZED IK SOLVER ---
        [sol_angs, valid] = solveIK_Calibrated(tx, ty, tz, L1, L2, H1, OFFSET_SHOULDER, OFFSET_ELBOW, curr_angles(1));
        
        final_x = tx; final_y = ty; final_z = tz;
        
        if ~valid
            was_modified = true;
            
            % If direct target fails, project vector towards Target (not Home)
            % This makes it reach "as far as possible" in that specific direction
            
            % Vector from Shoulder (0,0,H1) to Target
            vec_x = tx; vec_y = ty; vec_z = tz - H1;
            
            steps = 50; 
            found = false;
            
            % Pull back along the vector until we find a valid point
            for i = 0:steps
                scale = 1.0 - (i / steps); % 1.0 down to 0.0
                
                test_x = vec_x * scale;
                test_y = vec_y * scale;
                test_z = (vec_z * scale) + H1;
                
                % Floor Check again inside loop
                if test_z < MIN_SAFE_Z, test_z = MIN_SAFE_Z; end
                
                [test_angs, test_valid] = solveIK_Calibrated(test_x, test_y, test_z, L1, L2, H1, OFFSET_SHOULDER, OFFSET_ELBOW, curr_angles(1));
                
                if test_valid
                    sol_angs = test_angs;
                    final_x = test_x; final_y = test_y; final_z = test_z;
                    found = true;
                    break;
                end
            end
            
            if ~found
                msgbox('Target unreachable.', 'Error');
                return;
            end
        end
        
        smoothMove(s, curr_angles, sol_angs, 30);
        curr_angles = sol_angs;
        updateSystem();
        
        set(in_x, 'String', sprintf('%.1f', final_x));
        set(in_y, 'String', sprintf('%.1f', final_y));
        set(in_z, 'String', sprintf('%.1f', final_z));
        
        if was_modified
            fprintf('Safety/Limits active. Moved to: %.1f, %.1f, %.1f\n', final_x, final_y, final_z);
        end
    end

    function toggleSpin(src, ~)
        if src.Value == 1, is_spinning = true; set(src, 'String', 'STOP'); startSpinLoop();
        else, is_spinning = false; set(src, 'String', 'AUTO SPIN'); end
    end

    function startSpinLoop()
        t = 0; speed = 0.05; 
        while is_spinning && ishandle(f)
            t = t + speed;
            a_base = 90 + 40 * sin(t);
            a_shld = 82 + 15 * sin(t * 1.5 + pi/2);
            a_elb  = 90 + 30 * sin(t * 1.2);
            
            new_angs = [a_base, a_shld, a_elb];
            % Limits applied in loop
            new_angs(1) = max(LIM_B(1), min(LIM_B(2), new_angs(1)));
            new_angs(2) = max(LIM_S(1), min(LIM_S(2), new_angs(2)));
            new_angs(3) = max(LIM_E(1), min(LIM_E(2), new_angs(3)));
            
            curr_angles = new_angs;
            sendCmd(s, curr_angles);
            updateSystem();
            pause(0.05); drawnow;
        end
    end

    function handleKey(~, e)
        if is_spinning, is_spinning=false; return; end
        step = 1.0; new_angs = curr_angles;
        switch e.Key
            case 'leftarrow',  new_angs(1) = new_angs(1) + step;
            case 'rightarrow', new_angs(1) = new_angs(1) - step;
            case 'uparrow',    new_angs(2) = new_angs(2) + step;
            case 'downarrow',  new_angs(2) = new_angs(2) - step;
            case 'w',          new_angs(3) = new_angs(3) + step; 
            case 's',          new_angs(3) = new_angs(3) - step; 
        end
        new_angs(1) = max(LIM_B(1), min(LIM_B(2), new_angs(1)));
        new_angs(2) = max(LIM_S(1), min(LIM_S(2), new_angs(2)));
        new_angs(3) = max(LIM_E(1), min(LIM_E(2), new_angs(3)));
        curr_angles = new_angs;
        sendCmd(s, curr_angles);
        updateSystem();
    end

    function goHome(~, ~)
        is_spinning = false;
        smoothMove(s, curr_angles, target_home, 40);
        curr_angles = target_home;
        updateSystem();
    end

    function [angs, valid] = solveIK_Calibrated(x, y, z, L1, L2, H1, off_sh, off_el, prev_base)
        z_prime = z - H1; 
        r = sqrt(x^2 + y^2 + z_prime^2);
        
        if r > (L1 + L2) || r < abs(L1 - L2)
            angs = [90,90,90]; valid = false; return;
        end
        
        if abs(x) < 0.1 && abs(y) < 0.1
            theta1 = prev_base;
        else
            theta1 = atan2(y, x) * 180/pi;
            if theta1 < 0, theta1 = theta1 + 360; end
        end
        
        num = x^2 + y^2 + z_prime^2 - L1^2 - L2^2;
        den = 2 * L1 * L2;
        val = max(-1, min(1, num / den));
        phi_rad = acos(val); 
        phi_deg = phi_rad * 180/pi;
        
        alpha = asin(z_prime / r);
        beta  = atan2(L2 * sin(phi_rad), L1 + L2 * cos(phi_rad));
        theta2_phys_deg = (alpha + beta) * 180/pi;
        
        theta2_servo = theta2_phys_deg - off_sh;
        theta3_servo = 180 - phi_deg - off_el;
        
        angs = [theta1, theta2_servo, theta3_servo];
        
        valid = true;
        if angs(1) < LIM_B(1) || angs(1) > LIM_B(2), valid = false; end
        if angs(2) < LIM_S(1) || angs(2) > LIM_S(2), valid = false; end
        if angs(3) < LIM_E(1) || angs(3) > LIM_E(2), valid = false; end
    end

    function [tip, shoulder, elbow] = calculateFK(angs, L1, L2, H1, off_sh, off_el)
        t1 = angs(1) * pi/180;
        t2_phys_deg = angs(2) + off_sh;
        t2 = t2_phys_deg * pi/180;
        phi_deg = 180 - angs(3) - off_el;
        phi_rad = phi_deg * pi/180;
        rel_angle = t2 - phi_rad; 
        
        shoulder = [0, 0, H1];
        r1 = L1 * cos(t2);
        z1 = H1 + L1 * sin(t2);
        elbow = [r1*cos(t1), r1*sin(t1), z1];
        
        r2 = L1 * cos(t2) + L2 * cos(rel_angle);
        z2 = H1 + L1 * sin(t2) + L2 * sin(rel_angle);
        tip = [r2*cos(t1), r2*sin(t1), z2];
    end

    function updateSystem()
        [abs_tip, abs_sh, abs_el] = calculateFK(curr_angles, L1, L2, H1, OFFSET_SHOULDER, OFFSET_ELBOW);
        
        vec_x = abs_tip(1);
        vec_y = abs_tip(2);
        vec_z = abs_tip(3);
        mag = sqrt(vec_x^2 + vec_y^2 + vec_z^2);
        
        set(t_vec_x, 'String', sprintf('X: %.1f', vec_x));
        set(t_vec_y, 'String', sprintf('Y: %.1f', vec_y));
        set(t_vec_z, 'String', sprintf('Z: %.1f', vec_z));
        set(t_mag, 'String', sprintf('%.2f cm', mag));
        set(t_ang, 'String', sprintf('[%d, %d, %d]', round(curr_angles)));

        p_base = [0 0 0];
        set(h_link0, 'XData', [p_base(1) p_base(1)], 'YData', [p_base(2) p_base(2)], 'ZData', [p_base(3) abs_sh(3)]);
        set(h_link1, 'XData', [p_base(1) abs_el(1)], 'YData', [p_base(2) abs_el(2)], 'ZData', [abs_sh(3)   abs_el(3)]);
        set(h_link2, 'XData', [abs_el(1) abs_tip(1)], 'YData', [abs_el(2) abs_tip(2)], 'ZData', [abs_el(3)   abs_tip(3)]);
    end

    function smoothMove(serialObj, start_a, end_a, steps)
        for t = linspace(0, 1, steps)
            fr = start_a + (end_a - start_a) * t;
            sendCmd(serialObj, fr);
            pause(0.02);
        end
    end

    function sendCmd(serialObj, angs)
        if ~isempty(serialObj)
            try
                writeline(serialObj, sprintf('B %d', round(angs(1))));
                writeline(serialObj, sprintf('S %d', round(angs(2))));
                writeline(serialObj, sprintf('E %d', round(angs(3))));
            catch
            end
        end
    end

    function cleanUp(~,~)
        try delete(s); catch; end; delete(f);
    end
end