% Parameters
m1 = 290; m2 = 59; 
k1 = 16000; k2 = 190000;
b1 = 1000;  b2 = 0;      % keep b2=0 to avoid needing Wdot

% State-space (x=[x1 x1dot x2 x2dot]')
A = [ 0        1           0           0;
     -k1/m1   -b1/m1      k1/m1       b1/m1;
      0        0           0           1;
      k1/m2    b1/m2   -(k1+k2)/m2  -(b1+b2)/m2 ];

Bu = [0; 1/m1; 0; -1/m2];
Bw = [0; 0; 0;  k2/m2];

C_y1 = [1 0 -1 0];   % y1 = x1 - x2
D_y1 = [0 0];

% Part (8) desired poles (example)
p_des = [-7.91+5.90j, -7.91-5.90j, -20.19+45.53j, -20.19-45.53j];

% State feedback gain
K  = place(A, Bu, p_des);

% Feedforward so steady-state y1 -> 0 for a step in W (important)
Acl = A - Bu*K;
Nw  = -(C_y1*(Acl\Bw)) / (C_y1*(Acl\Bu));   % scalar
