function simplexmethod()
    % Example problem:
    % Maximize z = 3x₁ + 2x₂
    % Subject to:
    %   2x₁ + x₂ <= 10
    %   x₁ + 2x₂ <= 8
    %   x₁, x₂ >= 0

    % Set up the problem
    c = [3; 2];             % Objective function coefficients
    A = [2, 1; 1, 2];       % Constraint coefficients
    b = [10; 8];            % Right-hand side values

    % Solve using Simplex method with plot
    [x_opt, z_opt] = simplex_with_plot(c, A, b);

    % Display results
    disp('Optimal solution:');
    for i = 1:length(x_opt)
        fprintf('x%d = %.4f\n', i, x_opt(i));
    end
    fprintf('Optimal objective value: z = %.4f\n', z_opt);
end

function [x, z] = simplex_with_plot(c, A, b)
    % SIMPLEX_WITH_PLOT Solves LP problems using the Simplex method and creates a plot
    %
    % [x, z] = simplex_with_plot(c, A, b) solves the standard form LP problem:
    %   maximize    c'x
    %   subject to  Ax <= b
    %               x >= 0
    % And displays a graphical representation of the solution
    %
    % Inputs:
    %   c - column vector of objective function coefficients (2x1 for plotting)
    %   A - constraint coefficient matrix
    %   b - right-hand side constraint vector
    %
    % Outputs:
    %   x - optimal solution vector
    %   z - optimal objective value

    % First solve the problem using the simplex method defined below
    [x, z, iterations] = simplex_algorithm(c, A, b);
    
    % Check if it's a 2-variable problem for plotting
    if length(c) ~= 2
        warning('Plotting is only supported for 2-variable problems');
        return;
    end
    
    % Create a new figure
    figure;
    hold on;
    
    % Set up axis limits
    xmax = max(20, 2*max(x));
    ymax = max(20, 2*max(x));
    axis([0 xmax 0 ymax]);
    grid on;
    
    % Plot each constraint
    [m, ~] = size(A);
    colors = hsv(m+2);  % Generate m+2 different colors
    
    % Plot constraint lines and shade the feasible region
    for i = 1:m
        if A(i, 1) == 0 && A(i, 2) == 0
            continue;  % Skip if constraint is degenerate
        elseif A(i, 1) == 0  % Horizontal line
            y_val = b(i) / A(i, 2);
            plot([0, xmax], [y_val, y_val], 'Color', colors(i,:), 'LineWidth', 2);
            % Add constraint label
            text(xmax/2, y_val+0.5, sprintf('%.2fx₂ = %.2f', A(i, 2), b(i)), 'Color', colors(i,:));
        elseif A(i, 2) == 0  % Vertical line
            x_val = b(i) / A(i, 1);
            plot([x_val, x_val], [0, ymax], 'Color', colors(i,:), 'LineWidth', 2);
            % Add constraint label
            text(x_val+0.5, ymax/2, sprintf('%.2fx₁ = %.2f', A(i, 1), b(i)), 'Color', colors(i,:));
        else
            % General line: a*x + b*y = c => y = (c - a*x)/b
            x_vals = [0, xmax];
            y_vals = (b(i) - A(i, 1) * x_vals) / A(i, 2);
            
            % Only plot within the visible range
            plot(x_vals, y_vals, 'Color', colors(i,:), 'LineWidth', 2);
            
            % Add constraint label at the middle of the line
            mid_x = xmax/2;
            mid_y = (b(i) - A(i, 1) * mid_x) / A(i, 2);
            text(mid_x, mid_y+0.5, sprintf('%.2fx₁ + %.2fx₂ = %.2f', A(i, 1), A(i, 2), b(i)), 'Color', colors(i,:));
        end
    end
    
    % Plot non-negativity constraints
    plot([0, 0], [0, ymax], 'k-', 'LineWidth', 2);
    plot([0, xmax], [0, 0], 'k-', 'LineWidth', 2);
    text(0.5, ymax/2, 'x₁ = 0', 'Color', 'k');
    text(xmax/2, 0.5, 'x₂ = 0', 'Color', 'k');
    
    % Find and plot vertices of the feasible region
    vertices = find_vertices(A, b);
    
    % Shade the feasible region if vertices are found
    if ~isempty(vertices) && size(vertices, 1) >= 3
        patch(vertices(:,1), vertices(:,2), [0.8, 0.9, 1], 'FaceAlpha', 0.3);
    end
    
    % Plot objective function contours
    if c(1) ~= 0 || c(2) ~= 0
        % Plot several level curves of the objective function
        z_values = linspace(0, 2*z, 5);
        
        for z_val = z_values
            if c(2) ~= 0
                % z = c1*x1 + c2*x2 => x2 = (z - c1*x1)/c2
                x1_vals = linspace(0, xmax, 100);
                x2_vals = (z_val - c(1) * x1_vals) / c(2);
                plot(x1_vals, x2_vals, '--', 'Color', colors(m+1,:), 'LineWidth', 1);
                
                % Label the contour line
                mid_idx = round(length(x1_vals)/2);
                if mid_idx > 0 && mid_idx <= length(x1_vals) && x2_vals(mid_idx) >= 0 && x2_vals(mid_idx) <= ymax
                    text(x1_vals(mid_idx)+0.5, x2_vals(mid_idx), sprintf('z = %.2f', z_val), 'Color', colors(m+1,:));
                end
            elseif c(1) ~= 0
                % If c2 = 0, we have vertical contour lines
                x1_val = z_val / c(1);
                plot([x1_val, x1_val], [0, ymax], '--', 'Color', colors(m+1,:), 'LineWidth', 1);
                text(x1_val+0.5, ymax/2, sprintf('z = %.2f', z_val), 'Color', colors(m+1,:));
            end
        end
    end
    
    % Plot the path taken by the Simplex algorithm
    if ~isempty(iterations)
        plot(iterations(:,1), iterations(:,2), 'go-', 'LineWidth', 2, 'MarkerSize', 8);
        for i = 1:size(iterations, 1)
            text(iterations(i,1)+0.2, iterations(i,2)+0.2, sprintf('Step %d', i-1), 'FontSize', 8);
        end
    end
    
    % Mark the optimal solution
    plot(x(1), x(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    text(x(1)+0.5, x(2)+0.5, sprintf('Optimal (%.2f, %.2f)\nz = %.2f', x(1), x(2), z), 'FontWeight', 'bold');
    
    % Labels and title
    xlabel('x₁');
    ylabel('x₂');
    title('Linear Programming Solution using Simplex Method');
    legend('', '', '', '', '', 'Feasible Region', 'Objective Contours', 'Simplex Path', 'Optimal Solution', 'Location', 'Best');
    hold off;
end

function [x, z, iteration_points] = simplex_algorithm(c, A, b)
    % SIMPLEX_ALGORITHM Solves linear programming problems using the Simplex method
    %
    % [x, z, iteration_points] = simplex_algorithm(c, A, b) solves the standard form LP problem:
    %   maximize    c'x
    %   subject to  Ax <= b
    %               x >= 0
    %
    % Inputs:
    %   c - column vector of objective function coefficients
    %   A - constraint coefficient matrix
    %   b - right-hand side constraint vector
    %
    % Outputs:
    %   x - optimal solution vector
    %   z - optimal objective value
    %   iteration_points - matrix of points visited during iterations

    % Step 1: Convert to standard form (if needed)
    % Ensure b >= 0
    for i = 1:length(b)
        if b(i) < 0
            b(i) = -b(i);
            A(i,:) = -A(i,:);
        end
    end
    
    % Step 2: Add slack variables to form initial tableau
    [m, n] = size(A);
    tableau = zeros(m+1, n+m+1);
    
    % Set up the initial tableau
    tableau(1:m, 1:n) = A;
    tableau(1:m, n+1:n+m) = eye(m);  % Add slack variables
    tableau(1:m, n+m+1) = b;
    tableau(m+1, 1:n) = -c';
    
    % Step 3: Apply Simplex iterations
    basic_vars = n+1:n+m;  % Initial basic variables (slack variables)
    
    % Store iterations for plotting
    iteration_points = zeros(m+1, n);  % +1 for potential unbounded case
    iteration_count = 0;
    
    % Extract current basic solution
    current_x = zeros(n, 1);
    for i = 1:m
        if basic_vars(i) <= n
            current_x(basic_vars(i)) = tableau(i, n+m+1);
        end
    end
    iteration_count = iteration_count + 1;
    iteration_points(iteration_count, :) = current_x';
    
    while true
        % Find the pivot column (most negative coefficient in objective row)
        [entering_val, entering_col] = min(tableau(m+1, 1:n+m));
        
        if entering_val >= -1e-10  % Tolerance for floating-point precision
            % Optimal solution reached
            break;
        end
        
        % Find the pivot row (minimum ratio test)
        ratios = zeros(m, 1);
        for i = 1:m
            if tableau(i, entering_col) > 0
                ratios(i) = tableau(i, n+m+1) / tableau(i, entering_col);
            else
                ratios(i) = inf;
            end
        end
        
        [~, leaving_row] = min(ratios);
        
        if isinf(ratios(leaving_row))
            % Problem is unbounded
            direction = zeros(n, 1);
            for j = 1:n
                if j == entering_col
                    direction(j) = 1;
                elseif j <= n
                    for i = 1:m
                        if basic_vars(i) == j
                            direction(j) = -tableau(i, entering_col);
                            break;
                        end
                    end
                end
            end
            
            % Add unbounded direction point
            unbounded_point = current_x + 100 * direction;
            iteration_count = iteration_count + 1;
            iteration_points(iteration_count, :) = unbounded_point';
            error('Problem is unbounded');
        end
        
        % Update basic variable set
        basic_vars(leaving_row) = entering_col;
        
        % Pivot operation
        pivot_element = tableau(leaving_row, entering_col);
        
        % Normalize the pivot row
        tableau(leaving_row, :) = tableau(leaving_row, :) / pivot_element;
        
        % Update all other rows
        for i = 1:m+1
            if i ~= leaving_row
                tableau(i, :) = tableau(i, :) - tableau(i, entering_col) * tableau(leaving_row, :);
            end
        end
        
        % Extract current basic solution for plotting
        current_x = zeros(n, 1);
        for i = 1:m
            if basic_vars(i) <= n
                current_x(basic_vars(i)) = tableau(i, n+m+1);
            end
        end
        iteration_count = iteration_count + 1;
        iteration_points(iteration_count, :) = current_x';
    end
    
    % Step 4: Extract the optimal solution
    x = zeros(n, 1);
    for i = 1:m
        if basic_vars(i) <= n
            x(basic_vars(i)) = tableau(i, n+m+1);
        end
    end
    
    z = -tableau(m+1, n+m+1);  % Objective value
    
    % Trim unused rows in iteration_points
    iteration_points = iteration_points(1:iteration_count, :);
end

function vertices = find_vertices(A, b)
    % Find vertices of the feasible region by finding all pairs of constraints
    % that intersect in the non-negative quadrant
    
    % Add non-negativity constraints
    [m, n] = size(A);
    A_full = [A; [1 0]; [0 1]];
    b_full = [b; 0; 0];
    m_full = m + 2;
    
    vertices = [];
    
    % Check all pairs of constraints
    for i = 1:m_full
        for j = i+1:m_full
            % Extract the two constraints
            A1 = A_full(i,:);
            b1 = b_full(i);
            A2 = A_full(j,:);
            b2 = b_full(j);
            
            % Check if they intersect
            M = [A1; A2];
            if rank(M) < 2
                continue;  % Parallel constraints
            end
            
            % Solve the system of equations to find the intersection
            v = M \ [b1; b2];
            
            % Check if the vertex is in the feasible region
            if all(v >= 0) && all(A_full * v <= b_full + 1e-10)
                vertices = [vertices; v'];
            end
        end
    end
    
    % If there are vertices, order them in counter-clockwise fashion
    if ~isempty(vertices)
        % Compute the centroid
        centroid = mean(vertices, 1);
        
        % Compute angles from centroid to vertices
        angles = atan2(vertices(:,2) - centroid(2), vertices(:,1) - centroid(1));
        
        % Sort vertices by angle
        [~, idx] = sort(angles);
        vertices = vertices(idx, :);
    end
end
