clc; clear;
c = 1.25;
tc_ratio = 0.085;
hc_ratio = 0.0375;
b = c / 4;
e = tc_ratio / 1.3;
beta = 2 * hc_ratio;
a = b * (1 + e) / cos(beta);
x0 = -b * e;
y0 = a * beta;
z0 = x0 + 1i * y0;
num_points = 100;
theta = linspace(0, 2*pi - 0.05, num_points);
Z_prime = a * exp(1i * theta);
Z_circle = Z_prime + z0;
Z_airfoil = Z_circle + b^2 ./ Z_circle;
x_coords = real(Z_airfoil);
y_coords = imag(Z_airfoil);
z_coords = zeros(size(x_coords));
filename = 'Joukowski_OpenTE.txt';
fileID = fopen(filename, 'w');
fprintf(fileID, '# Joukowski Open TE\n');
fprintf(fileID, '# Group Point X Y Z\n');
for i = 1:num_points
    fprintf(fileID, '1 %d %12.6f %12.6f %12.6f\n', ...
        i, x_coords(i), y_coords(i), z_coords(i));
end
fclose(fileID);
disp(['File created: ' filename]);
disp('Instructions:');
disp('1. Import into DesignModeler (Concept -> 3D Curve).');
disp('2. Use "Concept -> Lines From Points" to connect the start and end points.');
disp('3. Use "Concept -> Surfaces From Edges" and select BOTH the curve and the closing line.');
