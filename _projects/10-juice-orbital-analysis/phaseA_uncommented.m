clear; clc;

root_path = 'E:\Projects\general matlab space\kernels\';

kernels = {
    fullfile(root_path, 'lsk', 'naif0012.tls'),
    fullfile(root_path, 'pck', 'pck00011.tpc'),
    fullfile(root_path, 'pck', 'de-403-masses.tpc'),
    fullfile(root_path, 'pck', 'gm_de431.tpc'),
    fullfile(root_path, 'pck', 'gm_noe2023_v01.tpc'),
    fullfile(root_path, 'spk', 'de432s.bsp'),
    fullfile(root_path, 'spk', 'juice_orbc_000100_230414_310721_v01.bsp')
    };

cspice_kclear;
for k = 1:length(kernels)
    if exist(kernels{k}, 'file')
        cspice_furnsh(kernels{k});
    end
end

sc_spk = fullfile(root_path, 'spk', 'juice_orbc_000100_230414_310721_v01.bsp');
sc_id  = -28;
ids = cspice_spkobj(sc_spk, 1000);
if ~ismember(sc_id, ids)
    error('JUICE (ID -28) not found in SPK file.');
end
room = 10000;
cov  = cspice_spkcov(sc_spk, sc_id, room);
nint = cspice_wncard(cov);
if nint < 1
    error('No coverage found for JUICE in SPK.');
end
[beg, ~] = cspice_wnfetd(cov, 1);
[~, fin] = cspice_wnfetd(cov, nint);
global t_cov_start t_cov_end
t_cov_start = beg;
t_cov_end   = fin;

fprintf('JUICE SPK Coverage: %s to %s\n', ...
    cspice_et2utc(t_cov_start,'C',0), cspice_et2utc(t_cov_end,'C',0));
events = struct([]);
events(1).name = 'Lunar-Earth Flyby';
events(1).id   = 399;
events(1).win  = {'2024-08-15','2024-08-25'};
events(2).name = 'Venus Flyby';
events(2).id   = 299;
events(2).win  = {'2025-08-25','2025-09-05'};
events(3).name = 'Earth Flyby 2';
events(3).id   = 399;
events(3).win  = {'2026-09-20','2026-10-05'};
events(4).name = 'Earth Flyby 3';
events(4).id   = 399;
events(4).win  = {'2029-01-10','2029-01-25'};
events(5).name = 'Jupiter Arrival';
events(5).id   = 5;
events(5).win  = {'2031-07-01','2031-08-01'};
fprintf('------------------------------------------------------------------------------------------------\n');
fprintf('%-18s | %-20s | %-9s | %-9s | %-7s | %-7s\n', 'Event', 'CA Epoch (UTC)', 'Alt(km)', 'Vinf(km/s)', 'Turn(dg)', 'B(km)');
fprintf('------------------------------------------------------------------------------------------------\n');
for i = 1:length(events)
    ev = events(i);

    if ev.id < 10, phys_id = ev.id * 100 + 99; else, phys_id = ev.id; end

    try
        dt = cspice_bodvrd(num2str(phys_id), 'GM', 1);
        mu = dt(1);
    catch
        mu = 0;
    end

    if mu == 0
        switch ev.id
            case 299, mu = 324858.59;
            case 399, mu = 398600.44;
            case 5,   mu = 126686534.0;
        end
    end
    try
        [t_ca, dist_ca, r_ca_vec, v_ca_vec] = find_ca(ev.id, ev.win);
    catch ME
        fprintf('%-18s | Error: %s\n', ev.name, ME.message);
        continue;
    end

    try
        [~, radii] = cspice_bodvrd(num2str(phys_id), 'RADII', 3);
        r_planet = radii(1);
    catch
        r_planet = 0;
    end
    alt_ca = dist_ca - r_planet;
    dt_win = 2 * 86400;

    t_in = max(t_cov_start, t_ca - dt_win);
    t_out = min(t_cov_end, t_ca + dt_win);

    [v_inf_in, turn_deg, B_mag] = compute_geometry(ev.id, t_in, t_ca, t_out, mu);
    fprintf('%-18s | %-20s | %9.0f | %9.3f | %7.2f | %7.0f\n', ...
        ev.name, cspice_et2utc(t_ca, 'C', 0), alt_ca, norm(v_inf_in), turn_deg, B_mag);
end
fprintf('------------------------------------------------------------------------------------------------\n');

function [t_opt, min_dist, r_ca, v_ca] = find_ca(target_id, win_strs)
global t_cov_start t_cov_end
et_start = cspice_str2et(win_strs{1});
et_end   = cspice_str2et(win_strs{2});

et_start = max(et_start, t_cov_start);
et_end   = min(et_end, t_cov_end);

if et_start >= et_end
    error('Search window is entirely outside SPK coverage.');
end

grid = linspace(et_start, et_end, 200);
dists = zeros(size(grid));
for k=1:length(grid)
    dists(k) = get_dist(target_id, grid(k));
end
[~, idx] = min(dists);
t_guess = grid(idx);

cost_func = @(t) get_dist(target_id, t);
options = optimset('TolX', 1e-6);

t_min = max(et_start, t_guess - 86400);
t_max = min(et_end, t_guess + 86400);

t_opt = fminbnd(cost_func, t_min, t_max, options);

st = get_rel_state(target_id, t_opt);
min_dist = norm(st(1:3));
r_ca = st(1:3);
v_ca = st(4:6);
end
function [v_vec_in, turn_angle, B_mag] = compute_geometry(body_id, t_in, t_ca, t_out, mu)
st_in = get_rel_state(body_id, t_in);
st_out = get_rel_state(body_id, t_out);

v_vec_in = st_in(4:6);
v_vec_out = st_out(4:6);

u_in = v_vec_in / norm(v_vec_in);
u_out = v_vec_out / norm(v_vec_out);

dot_prod = dot(u_in, u_out);
if dot_prod > 1, dot_prod = 1; end
if dot_prod < -1, dot_prod = -1; end
turn_angle = acosd(dot_prod);

st_ca = get_rel_state(body_id, t_ca);
r_p = norm(st_ca(1:3));
v_inf = norm(v_vec_in);

if mu > 0
    e = 1 + (r_p * v_inf^2 / mu);

    B_mag = (mu / v_inf^2) * sqrt(e^2 - 1);
else
    B_mag = NaN;
end
end
function d = get_dist(body_id, et)
st = get_rel_state(body_id, et);
d = norm(st(1:3));
end
function st = get_rel_state(body_id, et)

st_sc = cspice_spkezr('-28', et, 'ECLIPJ2000', 'NONE', 'SUN');

st_bd = cspice_spkezr(num2str(body_id), et, 'ECLIPJ2000', 'NONE', 'SUN');

st = st_sc - st_bd;
end
