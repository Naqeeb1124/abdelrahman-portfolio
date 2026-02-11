clear; clc;

T_sample = 0.1;
T_sim = 5000;

J_body = diag([0.002, 0.002, 0.002]);
J_inv = inv(J_body);

J_w_val = 1e-5;
J_wheel = diag([J_w_val, J_w_val, J_w_val]); 
J_wheel_inv = inv(J_wheel);

Max_Dipole = 0.2;
K_desat = 1e4;

B_mag = 40e-6;
n_orbit = 0.0011;

Kp = 5e-4;
Kd = 8e-3;
Tau_Max = 1e-3;

Init_Quat = [1; 0; 0; 0];
Init_Rates = [0.0; -n_orbit; 0.0];
Init_Wheel_Speed = [0; 0; 0];

fprintf('Workspace Initialized. You can now run the Simulink models.\n');
