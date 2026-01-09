function [t,W,x,z] = iso8608_road_Wt(L, dx, v, Gd0, w, seed)
% ISO 8608 random road -> W(t)
% L   [m]   road length
% dx  [m]   spatial sampling step (0.025 m like profilometer sampling)
% v   [m/s] vehicle speed (constant)
% Gd0 [m^3] PSD at n0=0.1 cycles/m  (choose from ISO class table)
% w   [-]   waviness exponent (ISO suggests w=2)
% seed      RNG seed for repeatability

if nargin < 6, seed = 1; end
rng(seed);

% ISO reference
n0   = 0.1;    % cycles/m
nmin = 0.01;   % ISO typical lower bound
nmax = 10;     % ISO typical upper bound
N    = 3000; 
x = (0:dx:L).';     
n  = linspace(nmin, nmax, N);   % cycles/m
dn = n(2)-n(1);
Gd = Gd0 * (n./n0).^(-w);
phi = 2*pi*rand(1,N);
A   = sqrt(2*Gd*dn);
z = zeros(size(x));
for i = 1:N
    z = z + A(i)*cos(2*pi*n(i)*x + phi(i));
end

% Conv: x = v t
dt = dx / v;
t  = (0:length(x)-1).' * dt;

% Yo
W = z;   % W(t) [m]

end


