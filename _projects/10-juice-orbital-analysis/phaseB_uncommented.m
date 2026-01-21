clear; clc; close all;

root_path = 'E:\Projects\general matlab space\kernels\';
kernels = {
    fullfile(root_path, 'lsk', 'naif0012.tls'),
    fullfile(root_path, 'pck', 'pck00011.tpc'),
    fullfile(root_path, 'pck', 'gm_de431.tpc'),
    fullfile(root_path, 'spk', 'de432s.bsp'),
    fullfile(root_path, 'spk', 'juice_orbc_000100_230414_310721_v01.bsp')
    };

cspice_kclear;
for k = 1:length(kernels)
    if exist(kernels{k},'file')
        cspice_furnsh(kernels{k});
    else
        fprintf('Warning: Kernel not found -> %s\n', kernels{k});
    end
end
try
    gmE = cspice_bodvrd('399','GM',1);
    fprintf('Kernel Check Passed: GM_Earth = %.2f\n', gmE);
catch
    fprintf('Kernel Check FAILED: GM kernels missing/broken.\n');
end
sc_spk = fullfile(root_path, 'spk', 'juice_orbc_000100_230414_310721_v01.bsp');
cov = cspice_spkcov(sc_spk, -28, 1000);
[beg, fin] = cspice_wnfetd(cov, 1);
global t_cov_start t_cov_end
t_cov_start = beg; t_cov_end = fin;
truth_data = struct();
truth_data(1).name = 'Launch';    truth_data(1).id = 399; truth_data(1).utc = '2023-04-14 12:45:00';
truth_data(2).name = 'Lunar-Earth'; truth_data(2).id = 399; truth_data(2).utc = '2024-08-20 21:56:12';
truth_data(3).name = 'Venus';       truth_data(3).id = 299; truth_data(3).utc = '2025-08-31 05:28:49';
truth_data(4).name = 'Earth 2';     truth_data(4).id = 399; truth_data(4).utc = '2026-09-28 11:44:55';
truth_data(5).name = 'Earth 3';     truth_data(5).id = 399; truth_data(5).utc = '2029-01-17 18:34:08';
truth_data(6).name = 'Jupiter';     truth_data(6).id = 5;   truth_data(6).utc = '2031-07-21 06:30:37';
for i = 1:length(truth_data), truth_data(i).et = cspice_str2et(truth_data(i).utc); end
fprintf('Extracting Truth Vectors (In & Out)...\n');
truth_data = extract_truth_vectors(truth_data);
alpha_guess = [0.5, 0.5, 0.5, 0.5, 0.5];
lb          = 0.01 * ones(1,5);
ub          = 0.99 * ones(1,5);

options = optimoptions('fmincon','Display','iter','Algorithm','sqp', 'StepTolerance', 1e-10);
cost_func = @(x) trajectory_cost(x, truth_data);

fprintf('\nOptimizing DSM Timing (Alpha)...\n');
[alpha_opt, J_val] = fmincon(cost_func, alpha_guess, [],[],[],[], lb, ub, [], options);
fprintf('\nFinal Cost: %.4f\n', J_val);
disp('Optimal Alphas:'); disp(alpha_opt);
[~, legs] = trajectory_cost(alpha_opt, truth_data);

check_flyby_feasibility(legs, truth_data);

plot_trajectory(truth_data, legs);

function [J, legs] = trajectory_cost(alpha, truth)
mu_sun = 132712440018;
J = 0;
legs = struct([]);

w_dep = 20;
w_arr_std = 20;
w_jup = 500;

for i = 1:length(alpha)
    idx0 = i;
    idx1 = i + 1;

    t0 = truth(idx0).et;
    t1 = truth(idx1).et;

    st0 = get_state('SUN', truth(idx0).id, t0); r0 = st0(1:3); v_planet_dep = st0(4:6);
    st1 = get_state('SUN', truth(idx1).id, t1); r1 = st1(1:3); v_planet_arr = st1(4:6);

    t_dsm = t0 + alpha(i) * (t1 - t0);

    dt_min = 20 * 86400;
    if (t_dsm - t0) < dt_min || (t1 - t_dsm) < dt_min
        J = 1e12; legs = struct([]); return;
    end

    st_dsm_truth = get_state('SUN', -28, t_dsm);
    r_dsm = st_dsm_truth(1:3);
    v_dsm_truth = st_dsm_truth(4:6);

    [v1s, v2s, ok1s] = lambert_uv_fzero(r0, r_dsm, t_dsm-t0, mu_sun, false);
    [v1l, v2l, ok1l] = lambert_uv_fzero(r0, r_dsm, t_dsm-t0, mu_sun, true);

    if ok1s, err_s = norm(v2s - v_dsm_truth); else, err_s = inf; end
    if ok1l, err_l = norm(v2l - v_dsm_truth); else, err_l = inf; end

    if err_s <= err_l, v_dep_L1=v1s; v_arr_L1=v2s; ok1=ok1s;
    else,              v_dep_L1=v1l; v_arr_L1=v2l; ok1=ok1l; end

    if isfield(truth(idx1), 'vinf_in') && all(isfinite(truth(idx1).vinf_in))
        v_inf_target = truth(idx1).vinf_in;
        calc_err = @(v_arr) norm((v_arr - v_planet_arr) - v_inf_target);
    else
        calc_err = @(v_arr) 0;
    end

    [v1s, v2s, ok2s] = lambert_uv_fzero(r_dsm, r1, t1-t_dsm, mu_sun, false);
    [v1l, v2l, ok2l] = lambert_uv_fzero(r_dsm, r1, t1-t_dsm, mu_sun, true);

    if ok2s, err_s = calc_err(v2s); else, err_s = inf; end
    if ok2l, err_l = calc_err(v2l); else, err_l = inf; end

    if err_s <= err_l, v_dep_L2=v1s; v_arr_L2=v2s; ok2=ok2s;
    else,              v_dep_L2=v1l; v_arr_L2=v2l; ok2=ok2l; end
    if ~ok1 || ~ok2, J = 1e12; legs = struct([]); return; end

    v_inf_dep_calc = v_dep_L1 - v_planet_dep;
    v_inf_arr_calc = v_arr_L2 - v_planet_arr;
    dv_dsm = norm(v_dep_L2 - v_arr_L1);

    vdep_diff = 0;
    if idx0 >= 2 && isfield(truth(idx0),'vinf_out') && all(isfinite(truth(idx0).vinf_out))
        vdep_diff = norm(v_inf_dep_calc - truth(idx0).vinf_out);
    end

    varr_diff = 0;
    if isfield(truth(idx1),'vinf_in') && all(isfinite(truth(idx1).vinf_in))
        varr_diff = norm(v_inf_arr_calc - truth(idx1).vinf_in);
    end

    w_arr = w_arr_std;
    if idx1 == length(truth)
        w_arr = w_jup;
    end
    J = J + dv_dsm + (w_dep * vdep_diff) + (w_arr * varr_diff);

    legs(i).r0 = r0; legs(i).r_dsm = r_dsm; legs(i).r1 = r1;
    legs(i).v_dep = v_dep_L1; legs(i).v_dsm_arr = v_arr_L1;
    legs(i).v_dsm_dep = v_dep_L2; legs(i).v_arr = v_arr_L2;
    legs(i).t0 = t0; legs(i).t_dsm = t_dsm; legs(i).t1 = t1;
    legs(i).v_inf_arr_calc = v_inf_arr_calc;
    legs(i).v_inf_dep_calc = v_inf_dep_calc;
end
end
function truth = extract_truth_vectors(truth)
global t_cov_start t_cov_end
dt = 2*86400;
for i = 1:length(truth)
    et = truth(i).et;
    id = truth(i).id;
    t_in  = max(t_cov_start, et - dt);
    st_sc = get_state('SUN', -28, t_in);
    st_bd = get_state('SUN', id,  t_in);
    truth(i).vinf_in = st_sc(4:6) - st_bd(4:6);
    t_out = min(t_cov_end, et + dt);
    st_sc = get_state('SUN', -28, t_out);
    st_bd = get_state('SUN', id,  t_out);
    truth(i).vinf_out = st_sc(4:6) - st_bd(4:6);
end
end
function [v1, v2, ok] = lambert_uv_fzero(r1, r2, dt, mu, longway)
ok = false; v1 = [NaN;NaN;NaN]; v2 = v1;
if ~(isfinite(dt) && dt > 0), return; end
r1m = norm(r1); r2m = norm(r2);
if r1m < 1 || r2m < 1, return; end
theta = atan2(norm(cross(r1,r2)), dot(r1,r2));
if longway, theta = 2*pi - theta; end
if theta < 1e-4 || abs(2*pi-theta) < 1e-4, return; end
A = sin(theta) * sqrt(r1m*r2m/(1-cos(theta)));
if abs(A) < 1e-12, return; end
    function F = Fz(z)
        [C,S] = stumpff_CS(z);
        if C <= 0, F = NaN; return; end
        y = r1m + r2m + A*(z*S - 1)/sqrt(C);
        if y <= 0, F = NaN; return; end
        x = sqrt(y/C);
        dtg = (x^3*S + A*sqrt(y))/sqrt(mu);
        F = dtg - dt;
    end
F0 = Fz(0);
if ~isfinite(F0), return; end
if abs(F0) < 1e-8
    z = 0;
else
    zL = 0; zU = 0; dz = 0.5;
    if F0 < 0
        zL = 0; zU = dz;
        for k = 1:60
            FU = Fz(zU); if isfinite(FU) && FU > 0, break; end
            zU = zU*2; if zU > 1e6, return; end
        end
    else
        zU = 0; zL = -dz;
        for k = 1:60
            FL = Fz(zL); if isfinite(FL) && FL < 0, break; end
            zL = zL*2; if zL < -1e6, return; end
        end
    end
    try, z = fzero(@Fz, [zL zU]); catch, return; end
end
[C,S] = stumpff_CS(z);
y = r1m + r2m + A*(z*S - 1)/sqrt(C);
f = 1 - y/r1m; g = A*sqrt(y/mu); gdot = 1 - y/r2m;
v1 = (r2 - f*r1)/g; v2 = (gdot*r2 - r1)/g;
ok = all(isfinite([v1; v2]));
end
function [C,S] = stumpff_CS(z)
if z > 1e-8, s = sqrt(z); S = (s - sin(s))/s^3; C = (1 - cos(s))/z;
elseif z < -1e-8, s = sqrt(-z); S = (sinh(s) - s)/s^3; C = (cosh(s) - 1)/(-z);
else, C = 1/2; S = 1/6; end
end
function check_flyby_feasibility(legs, truth)
fprintf('\n=== VALIDATION: FLYBY FEASIBILITY CHECK ===\n');
fprintf('NODE (Body)         | |vin|  | |vout| | MagErr | Turn(deg) | Alt_Req(km)\n');
fprintf('------------------------------------------------------------------------\n');
for k = 2:length(truth)-1
    body_id = truth(k).id;
    v_in  = legs(k-1).v_inf_arr_calc;
    v_out = legs(k).v_inf_dep_calc;
    vin  = norm(v_in);
    vout = norm(v_out);
    magerr = abs(vout - vin);
    c = dot(v_in, v_out)/(vin*vout);
    c = max(-1,min(1,c));
    delta = acos(c);
    [mu, R] = get_body_constants(body_id);
    if mu > 0 && R > 0
        v_avg = (vin + vout) / 2;
        e  = 1/sin(delta/2);
        rp = (mu/(v_avg^2))*(e - 1);
        alt_req = rp - R;
    else
        alt_req = NaN;
    end
    fprintf('%4d (%-14s) | %6.3f | %6.3f | %6.3f | %8.2f | %12.0f\n', ...
        k, truth(k).name, vin, vout, magerr, rad2deg(delta), alt_req);
end

v_arr_jup = legs(end).v_inf_arr_calc;
v_diff = norm(v_arr_jup - truth(end).vinf_in);
fprintf('\nFinal Arrival (Jupiter):\n  |V_inf_arr|       = %.3f km/s\n  Mismatch vs Truth = %.3f km/s\n', ...
    norm(v_arr_jup), v_diff);
end
function [mu, R] = get_body_constants(id)
switch id
    case {399, 3}
        mu = 398600.44; R = 6378.14;
    case {299, 2}
        mu = 324858.59; R = 6051.8;
    case {599, 5}
        mu = 126686534.9; R = 71492.0;
    case {301}
        mu = 4902.8;    R = 1737.4;
    case {10}
        mu = 132712440018; R = 696000;
    otherwise
        mu = 0; R = 0;
end
end
function st = get_state(obs, targ, et)
if isnumeric(targ), targ = num2str(targ); end
st = cspice_spkezr(targ, et, 'ECLIPJ2000', 'NONE', obs);
end
function plot_trajectory(truth, legs)
if isempty(legs), return; end
figure('Color','w'); hold on; axis equal; grid on; xlabel('x (AU)'); ylabel('y (AU)'); view(2);
AU = 149597870.7; mu = 132712440018;
for i=1:length(truth)
    st=get_state('SUN',-28,truth(i).et)/AU;
    plot3(st(1),st(2),st(3),'o','MarkerFaceColor',[0 .4 .8]);
    text(st(1),st(2),st(3),[' ' truth(i).name]);
end
for i=1:length(legs)
    eltsA = cspice_oscelt([legs(i).r0; legs(i).v_dep], legs(i).t0, mu);
    tsA = linspace(legs(i).t0, legs(i).t_dsm, 100); pathA=zeros(3,100);
    for k=1:100, s=cspice_conics(eltsA, tsA(k)); pathA(:,k)=s(1:3); end
    plot3(pathA(1,:)/AU, pathA(2,:)/AU, pathA(3,:)/AU, 'r-');

    eltsB = cspice_oscelt([legs(i).r_dsm; legs(i).v_dsm_dep], legs(i).t_dsm, mu);
    tsB = linspace(legs(i).t_dsm, legs(i).t1, 100); pathB=zeros(3,100);
    for k=1:100, s=cspice_conics(eltsB, tsB(k)); pathB(:,k)=s(1:3); end
    plot3(pathB(1,:)/AU, pathB(2,:)/AU, pathB(3,:)/AU, 'r-');

    plot3(legs(i).r_dsm(1)/AU, legs(i).r_dsm(2)/AU, legs(i).r_dsm(3)/AU, 'y^', 'MarkerEdgeColor','k');
end
end
