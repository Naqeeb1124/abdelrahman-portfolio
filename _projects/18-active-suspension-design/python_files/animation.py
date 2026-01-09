import numpy as np
import control as ct
import scipy.signal as signal
import scipy.ndimage as ndimage
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.patches import Rectangle, Circle
from matplotlib.widgets import CheckButtons

m1, m2 = 250.0, 45.0
k1, k2 = 16000.0, 160000.0
b1, b2 = 1000.0, 0.0

A = np.array([
    [0, 1, 0, 0],
    [-k1/m1, -b1/m1, k1/m1, b1/m1],
    [0, 0, 0, 1],
    [k1/m2, b1/m2, -(k1+k2)/m2, -(b1+b2)/m2]
])
B_u = np.array([[0], [1/m1], [0], [-1/m2]])
B_w = np.array([[0], [0], [0], [k2/m2]])

sys_pass = ct.ss(A, B_w, np.eye(4), np.zeros((4,1)))

q_body_pos = 500.0
q_body_vel = 100000.0
q_whl_pos  = 100.0
q_whl_vel  = 10.0
r_force    = 0.0001 

Q = np.diag([q_body_pos, q_body_vel, q_whl_pos, q_whl_vel])
R = r_force

K_lqr, _, _ = ct.lqr(A, B_u, Q, R)
sys_cl = ct.ss(A - B_u @ K_lqr, B_w, np.eye(4), np.zeros((4,1)))

T_max = 20.0  
dt = 0.001
T = np.arange(0, T_max, dt)
velocity = 12.0 

np.random.seed(60) 
ROUGHNESS_SCALE = 0.1
white_noise = np.random.normal(0, 2.0, len(T))
b_filter, a_filter = signal.butter(1, 3.0, btype='low', analog=False, fs=1/dt)
raw_roughness = signal.lfilter(b_filter, a_filter, white_noise) * ROUGHNESS_SCALE

raw_bumps = np.zeros_like(T)
num_bumps = 6
bump_times = np.sort(np.random.uniform(2.0, T_max - 2.0, num_bumps))
for t_bump in bump_times:
    h = 0.15 
    width_spatial = 0.4
    sigma_t = (width_spatial / velocity) / (2 * np.sqrt(2 * np.log(2)))
    raw_bumps += h * np.exp(-0.5 * ((T - t_bump) / sigma_t) ** 2)

freq_resonance = 1.27 
raw_resonance = 0.1 * np.sin(2 * np.pi * freq_resonance * T)
raw_resonance[T < 1.0] = 0

W = np.zeros_like(T)
x1_p, x2_p = np.zeros_like(T), np.zeros_like(T)
x1_a, x2_a = np.zeros_like(T), np.zeros_like(T)
rms_p, rms_a = np.zeros_like(T), np.zeros_like(T)

def calculate_rolling_rms(signal_data, window_size):
    return np.sqrt(ndimage.uniform_filter1d(signal_data**2, size=window_size))

def run_simulation(use_rough, use_bumps, use_resonance):
    global W, x1_p, x2_p, x1_a, x2_a, rms_p, rms_a
    
    W[:] = 0
    if use_resonance:
        W = raw_resonance.copy()
    else:
        if use_rough: W += raw_roughness
        if use_bumps: W += raw_bumps
        W[T < 0.5] = 0 

    _, x_pass = ct.forced_response(sys_pass, T, W)
    _, x_act = ct.forced_response(sys_cl, T, W)
    
    x1_p, x2_p = x_pass[0], x_pass[2] 
    x1_a, x2_a = x_act[0], x_act[2]
    
    vert_acc_p = np.gradient(x_pass[1], dt)
    vert_acc_a = np.gradient(x_act[1], dt)
    
    window = int(1.0 / dt) 
    rms_p = calculate_rolling_rms(vert_acc_p, window)
    rms_a = calculate_rolling_rms(vert_acc_a, window)
    
    try:
        if use_resonance:
            ax_pass.set_title("Passive (RESONANCE FAILURE!)", fontsize=12, color='red', fontweight='bold')
        else:
            ax_pass.set_title("Passive Suspension", fontsize=12, color='red', fontweight='bold')
    except NameError:
        pass 

fig1 = plt.figure(figsize=(10, 8))
fig1.canvas.manager.set_window_title("Main Simulation")
gs1 = fig1.add_gridspec(2, 2, height_ratios=[2, 1])

ax_pass = fig1.add_subplot(gs1[0, 0])
ax_pass.set_title("Passive Suspension", fontsize=12, color='red', fontweight='bold')
ax_pass.set_xlim(-2, 4); ax_pass.set_ylim(-0.3, 2.3); ax_pass.set_aspect('equal'); ax_pass.axis('off')

ax_act = fig1.add_subplot(gs1[0, 1])
ax_act.set_title("Active LQR", fontsize=12, color='blue', fontweight='bold')
ax_act.set_xlim(-2, 4); ax_act.set_ylim(-0.3, 2.3); ax_act.set_aspect('equal'); ax_act.axis('off')

ax_plot = fig1.add_subplot(gs1[1, :])
ax_plot.set_xlim(0, T_max); ax_plot.set_ylim(-0.2, 0.4)
ax_plot.set_xlabel("Time (s)"); ax_plot.set_ylabel("Road Profile (m)")
ax_plot.grid(True)

line_road, = ax_plot.plot([], [], 'k-', linewidth=1.5, alpha=0.6, label='Terrain')
line_pass, = ax_plot.plot([], [], 'r--', linewidth=1.5, label='Passive Disp.')
line_act, = ax_plot.plot([], [], 'b-', linewidth=2, label='Active Disp.')
ax_plot.legend(loc='upper right')

run_simulation(True, True, False)

rax = plt.axes([0.02, 0.82, 0.15, 0.14])
check = CheckButtons(rax, ('Roughness', 'Bumps', 'Resonant Road'), (True, True, False))

def toggle_callback(label):
    status = check.get_status()
    run_simulation(status[0], status[1], status[2])
    fig1.canvas.draw_idle() 

check.on_clicked(toggle_callback)

fig2 = plt.figure(figsize=(9, 5)) 
fig2.canvas.manager.set_window_title("Comfort Analysis")
ax_rms = fig2.add_subplot(111)
ax_rms.set_title("Vertical Vibration Intensity (RMS)", fontsize=11, fontweight='bold')
ax_rms.set_xlim(0, T_max); ax_rms.set_ylim(0, 12.0) 
ax_rms.set_xlabel("Time (s)"); ax_rms.set_ylabel("Vertical Accel RMS (m/s²)")
ax_rms.grid(True, alpha=0.3)

line_rms_p, = ax_rms.plot([], [], 'r--', linewidth=1.5, alpha=0.6, label='Passive')
line_rms_a, = ax_rms.plot([], [], 'b-', linewidth=2, label='Active')
text_score = ax_rms.text(0.02, 0.9, "", transform=ax_rms.transAxes, fontsize=12, fontweight='bold', color='green')
ax_rms.legend(loc='upper right')
fig2.tight_layout()

def create_car_artists(ax, color):
    road, = ax.plot([], [], 'k-', linewidth=2)
    wheel = Circle((0, 0), 0.15, color='black', zorder=10)
    body = Rectangle((0, 0), 0.8, 0.3, color=color, ec='black', alpha=0.8, zorder=5)
    spring, = ax.plot([], [], color='gray', linewidth=3, linestyle='-')
    ref_line, = ax.plot([], [], color='black', linewidth=0.5, linestyle=':')
    deflection_line, = ax.plot([], [], color='orange', linewidth=2, zorder=20)
    label = ax.text(0, 0, "Body Deflection", ha='center', fontsize=8)
    ax.add_patch(wheel); ax.add_patch(body)
    return road, wheel, body, spring, ref_line, deflection_line, label

artists_p = create_car_artists(ax_pass, 'red')
artists_a = create_car_artists(ax_act, 'blue')
SKIP = 25

def update_main(frame_idx):
    idx = frame_idx * SKIP
    if idx >= len(T): idx = len(T) - 1
    
    line_pass.set_data(T[:idx], x1_p[:idx])
    line_act.set_data(T[:idx], x1_a[:idx])
    line_road.set_data(T[:idx], W[:idx])
    
    road_x = np.linspace(-2, 4, 150) 
    road_y = np.interp(T[idx] + road_x/velocity, T, W, left=0, right=0)
    
    def update_car(artists, x1, x2):
        road, wheel, body, spring, ref, line, lbl = artists
        road.set_data(road_x, road_y)
        wheel.center = (0, x2[idx] + 0.15)
        by = x1[idx] + 0.65
        body.set_xy((-0.4, by))
        spring.set_data([0, 0], [x2[idx]+0.15, by])
        ref.set_data([-0.4, 0.4], [by+0.9, by+0.9])
        lbl.set_position((0, by+1.05))
        win = max(2, int(1.0/dt))
        start = max(0, idx-win)
        seg = x1[start:idx+1]
        if len(seg) > 1:
            line.set_data(np.linspace(-0.4, 0.4, len(seg)), by+0.9 + seg*2.0)
        else: line.set_data([], [])

    update_car(artists_p, x1_p, x2_p)
    update_car(artists_a, x1_a, x2_a)
    return [line_pass, line_act, line_road] + list(artists_p) + list(artists_a)

def update_rms(frame_idx):
    idx = frame_idx * SKIP
    if idx >= len(T): idx = len(T) - 1
    line_rms_p.set_data(T[:idx], rms_p[:idx])
    line_rms_a.set_data(T[:idx], rms_a[:idx])
    
    if idx > 200 and frame_idx % 10 == 0:
        avg_p = np.mean(rms_p[:idx])
        avg_a = np.mean(rms_a[:idx])
        if avg_p > 0:
            imp = (1 - avg_a/avg_p) * 100
            text_score.set_text(f"Vertical Vib Reduced: +{int(imp)}%")
            if imp > 50: text_score.set_color('green')
            elif imp > 0: text_score.set_color('orange')
            else: text_score.set_color('red')

    return [line_rms_p, line_rms_a, text_score]

ani1 = animation.FuncAnimation(fig1, update_main, frames=len(T)//SKIP, interval=1, blit=True)
ani2 = animation.FuncAnimation(fig2, update_rms, frames=len(T)//SKIP, interval=1, blit=True)

plt.show()