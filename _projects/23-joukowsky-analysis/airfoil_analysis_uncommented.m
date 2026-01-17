clc; clear; close all;
V_inf = 125;
c = 1.25;
tc_ratio = 0.085;
hc_ratio = 0.0375;
alpha_vis = 6;
alpha_range = -5:1:10;
b = c / 4;
e = (tc_ratio) / 1.3;
beta = 2 * (hc_ratio);
a = b * (1 + e) / cos(beta);
x0 = -b * e;
y0 = a * beta;
z0 = x0 + 1i * y0;
theta = linspace(0, 2*pi, 400);
Z_prime_circle = a * exp(1i * theta);
Z_circle = Z_prime_circle + z0;
z_airfoil = Z_circle + b^2 ./ Z_circle;
figure(1);
fill(real(z_airfoil), imag(z_airfoil), [0.8 0.8 0.8], 'EdgeColor', 'k');
axis equal; grid on;
xlabel('x (m)'); ylabel('y (m)');
title(sprintf('Joukowski Airfoil (t/c=%.1f%%, h/c=%.2f%%)', tc_ratio*100, hc_ratio*100));
saveas(gcf, 'Fig1_Geometry.png');
r_vals = linspace(a, 8*a, 100);
theta_vals = linspace(0, 2*pi, 150);
[R_grid, Theta_grid] = meshgrid(r_vals, theta_vals);
Z_prime_grid = R_grid .* exp(1i * Theta_grid);
Z_grid = Z_prime_grid + z0;
Z1_grid = Z_grid + b^2 ./ Z_grid;
alpha_rad = deg2rad(alpha_vis);
Gamma = 4 * pi * V_inf * a * sin(alpha_rad + beta);
vr_prime = V_inf .* cos(Theta_grid - alpha_rad) .* (1 - a^2 ./ R_grid.^2);
vt_prime = -V_inf .* (sin(Theta_grid - alpha_rad) .* (1 + a^2 ./ R_grid.^2) + ...
    2 * (a ./ R_grid) .* sin(alpha_rad + beta));
dW_dZ_prime = (vr_prime - 1i * vt_prime) .* exp(-1i * Theta_grid);
dZ1_dZ_prime = 1 - b^2 ./ (Z_prime_grid + z0).^2;
V_complex = dW_dZ_prime ./ dZ1_dZ_prime;
V_mag = abs(V_complex);
W = V_inf .* (Z_prime_grid .* exp(-1i*alpha_rad) + (a^2 ./ Z_prime_grid) .* exp(1i*alpha_rad)) + ...
    1i * Gamma / (2*pi) * log(Z_prime_grid ./ a);
Psi = imag(W);
rot_angle = -alpha_rad;
Z1_grid_rot = Z1_grid * exp(1i * rot_angle);
z_airfoil_rot = z_airfoil * exp(1i * rot_angle);
figure(2);
contour(real(Z1_grid_rot), imag(Z1_grid_rot), Psi, 60, 'LineWidth', 1.2); hold on;
fill(real(z_airfoil_rot), imag(z_airfoil_rot), 'k');
axis equal; axis([-c c+0.5 -c c]);
title(['Streamlines at \alpha = ' num2str(alpha_vis) '^\circ (Rotated View)']);
xlabel('x (m)'); ylabel('y (m)');
saveas(gcf, 'Fig2_Streamlines.png');
figure(3);
contourf(real(Z1_grid_rot), imag(Z1_grid_rot), V_mag, 50, 'LineColor', 'none');
colorbar; hold on;
fill(real(z_airfoil_rot), imag(z_airfoil_rot), 'k');
title(['Velocity Magnitude at \alpha = ' num2str(alpha_vis) '^\circ']);
axis equal; axis([-c c+0.5 -c c]);
xlabel('x (m)'); ylabel('y (m)');
saveas(gcf, 'Fig3_Velocity.png');
theta_s = linspace(0.1, 2*pi-0.1, 300);
Z_p_s = a * exp(1i * theta_s);
Z_s = Z_p_s + z0;
Z1_s = Z_s + b^2 ./ Z_s;
vt_s = -V_inf .* (sin(theta_s - alpha_rad) * 2 + 2 * sin(alpha_rad + beta));
dZ1_dZ_p_s = 1 - b^2 ./ Z_s.^2;
V_surf = abs(vt_s ./ abs(dZ1_dZ_p_s));
Cp = 1 - (V_surf / V_inf).^2;
figure(4);
plot(real(Z1_s), Cp, 'LineWidth', 1.5);
set(gca, 'YDir', 'reverse'); grid on;
xlabel('x (m)'); ylabel('C_p');
title(['Pressure Coefficient at \alpha = ' num2str(alpha_vis) '^\circ']);
saveas(gcf, 'Fig4_Cp.png');
Cl_vec = []; Cm_vec = [];
for ang = alpha_range
    a_r = deg2rad(ang);

    Cl = 2 * pi * (1 + e) * sin(a_r + beta);
    Cl_vec = [Cl_vec, Cl];

    Gam_i = 4 * pi * V_inf * a * sin(a_r + beta);
    vt_i = -V_inf .* (sin(theta_s - a_r) * 2 + 2 * sin(a_r + beta));
    V_s_i = abs(vt_i ./ abs(dZ1_dZ_p_s));
    Cp_i = 1 - (V_s_i / V_inf).^2;

    x_ac = -b;
    M = 0;
    x_loc = real(Z1_s); y_loc = imag(Z1_s);
    for k = 1:length(x_loc)-1
        dx = x_loc(k+1) - x_loc(k);
        dy = y_loc(k+1) - y_loc(k);
        x_m = (x_loc(k+1) + x_loc(k))/2;
        y_m = (y_loc(k+1) + y_loc(k))/2;
        cp_m = (Cp_i(k+1) + Cp_i(k))/2;

        dFx = -cp_m * dy;
        dFy = cp_m * dx;

        M = M + (x_m - x_ac)*dFy - (y_m)*dFx;
    end
    Cm = M / c;
    Cm_vec = [Cm_vec, Cm];
end
figure(5);
plot(alpha_range, Cl_vec, '-o', 'LineWidth', 1.5);
grid on; xlabel('\alpha (deg)'); ylabel('C_l');
title('Lift Coefficient vs AoA');
saveas(gcf, 'Fig5_Cl_alpha.png');
figure(6);
plot(alpha_range, Cm_vec, '-s', 'LineWidth', 1.5);
grid on; xlabel('\alpha (deg)'); ylabel('C_m');
title('Moment Coefficient vs AoA');
saveas(gcf, 'Fig6_Cm_alpha.png');
disp('Simulation Complete.');
