fprintf('Looking for simulation data...\n');

raw_data = [];
if exist('Q_Log', 'var')
    raw_data = Q_Log;
    fprintf('-> Found "Q_Log" in Workspace.\n');
elseif exist('simOut', 'var')
    if isfield(simOut, 'Q_Log') || isprop(simOut, 'Q_Log')
        raw_data = simOut.Q_Log;
        fprintf('-> Found "Q_Log" inside simOut.\n');
    elseif ismethod(simOut, 'get')
        try
            raw_data = simOut.get('Q_Log');
            fprintf('-> Found "Q_Log" using .get()\n');
        catch
            vars = who(simOut);
            raw_data = simOut.get(vars{1});
            fprintf('-> Warning: Guessing data is in "%s"\n', vars{1});
        end
    end
end

if isempty(raw_data)
    error('Could not find Q_Log! Please re-run the Simulink Model.');
end

Q_Final = squeeze(raw_data);
if size(Q_Final,1) < size(Q_Final,2), Q_Final = Q_Final'; end
if size(Q_Final,2) == 5, Q_Final = Q_Final(:,2:5); end

close all;
fig = figure('Color','k','Name','Nadir Pointing Check');
axis equal; grid on; hold on;
axis([-10 10 -10 10 -10 10]); 
view(120, 20);
gray = [0.2 0.2 0.2];
set(gca, 'Color', 'k', 'XColor', gray, 'YColor', gray, 'ZColor', gray);
xlabel('X'); ylabel('Y'); zlabel('Z');

Re = 3; 
[xe, ye, ze] = sphere(25);
surf(xe*Re, ye*Re, ze*Re, 'FaceColor', [0 0.4 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
plot3(Re*cos(0:0.1:2*pi), Re*sin(0:0.1:2*pi), zeros(size(0:0.1:2*pi)), 'b:');

R_orbit = 8;
theta_orbit = linspace(0, 2*pi, 100);
plot3(R_orbit*cos(theta_orbit), zeros(size(theta_orbit)), R_orbit*sin(theta_orbit), 'c:', 'LineWidth', 0.5);

v_sat = 0.6 * [-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 1; 1 -1 1; 1 1 1; -1 1 1];
f_sat = [1 2 3 4; 2 6 7 3; 4 3 7 8; 1 5 8 4; 1 2 6 5; 5 6 7 8];
sat_h = patch('Vertices', v_sat, 'Faces', f_sat, 'FaceColor', [1 0.8 0], 'EdgeColor', 'k');

arrow_h = quiver3(0,0,0, 0,0,1, 0, 'Color', 'r', 'LineWidth', 3, 'MaxHeadSize', 0.5, 'AutoScale', 'off');

target_line_h = plot3([0 0], [0 0], [0 0], 'g--', 'LineWidth', 1);

[n_steps, ~] = size(Q_Final);
step_skip = max(1, floor(n_steps / 500)); 
T_sample = 0.1;
n_mean = 0.0011;

fprintf('Starting Animation...\n');
title_h = title('Initializing...', 'Color', 'w');

for i = 1:step_skip:n_steps
    if ~isvalid(fig), break; end
    
    t = i * T_sample;
    
    theta = -n_mean * t - pi/2;    
    Pos = [R_orbit * cos(theta); 0; R_orbit * sin(theta)]; 
    
    q = Q_Final(i, :); 
    if norm(q) < 1e-6, q = [1 0 0 0]; end
    q = q / norm(q);
    
    w=q(1); x=q(2); y=q(3); z=q(4);
    R_att = [1-2*(y^2+z^2), 2*(x*y-z*w), 2*(x*z+y*w); 
             2*(x*y+z*w), 1-2*(x^2+z^2), 2*(y*z-x*w); 
             2*(x*z-y*w), 2*(y*z+x*w), 1-2*(x^2+y^2)];
         
    v_new = (R_att * v_sat')' + Pos';
    set(sat_h, 'Vertices', v_new);
    
    Dir = R_att * [0; 0; 5]; 
    set(arrow_h, 'XData', Pos(1), 'YData', Pos(2), 'ZData', Pos(3), ...
                 'UData', Dir(1), 'VData', Dir(2), 'WData', Dir(3));

    set(target_line_h, 'XData', [Pos(1) 0], 'YData', [Pos(2) 0], 'ZData', [Pos(3) 0]);
    
    set(title_h, 'String', sprintf('Time: %.0f s', t));
    drawnow;
end
set(title_h, 'String', 'Simulation Complete', 'Color', 'g');
