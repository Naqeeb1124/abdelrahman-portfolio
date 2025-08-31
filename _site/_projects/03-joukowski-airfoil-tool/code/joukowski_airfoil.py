

"""
JOUKOWSKY AIRFOIL VISUALIZATION PROGRAM
====================================== 

Based on "Airfoils and Joukowsky Transform" project report
Implements theoretical equations for conformal mapping and aerodynamic analysis.

AUTHORS: Implementation based on project by Al Naqeeb, Amr, Bassem (2024)
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button
import matplotlib.patches as patches

# Configure matplotlib
plt.style.use('default')
plt.rcParams['figure.figsize'] = (15, 10)
plt.rcParams['font.size'] = 10

class JoukowskyAirfoilVisualizer:
    """
    Interactive Joukowsky Airfoil Visualization Tool

    Features:
    1. Real-time Joukowsky transform visualization
    2. Flow field computation and visualization
    3. Interactive parameter adjustment
    4. Multiple airfoil configurations
    """

    def __init__(self):
        self.c = 1.0          # Transform constant
        self.a = 1.1          # Circle radius (a = c(1+f), f â‰¥ 1.0)
        self.ec = 0.1         # Horizontal displacement (ce in report)
        self.F = 0.1          # Vertical displacement (camber)
        self.U = 1.0          # Free stream velocity
        self.alpha = 0.1      # Angle of attack (radians)
        self.transform_alpha = 1.0  # Transform intensity (0 to 1)

        self.fig = plt.figure(figsize=(16, 10))
        self.setup_plots()
        self.setup_sliders()
        self.update_plots()

    def setup_plots(self):
        """Initialize subplot layout"""
        self.ax_circle = plt.subplot2grid((3, 2), (0, 0))
        self.ax_airfoil = plt.subplot2grid((3, 2), (0, 1))

        self.ax_flow_circle = plt.subplot2grid((3, 2), (1, 0))
        self.ax_flow_airfoil = plt.subplot2grid((3, 2), (1, 1))

        self.ax_params = plt.subplot2grid((3, 2), (2, 0), colspan=2)
        self.ax_params.axis('off')
        plt.tight_layout()

    def setup_sliders(self):
        slider_height = 0.02
        slider_left = 0.15
        slider_width = 0.7

        sliders_y = [0.25, 0.22, 0.19, 0.16, 0.13, 0.10]
        slider_names = ['ec', 'F', 'a', 'alpha', 'U', 'transform']

        self.slider_ec = Slider(plt.axes([slider_left, sliders_y[0], slider_width, slider_height]), 
                               'ec (horiz. shift)', -0.5, 0.5, valinit=self.ec, valfmt='%.2f')
        self.slider_F = Slider(plt.axes([slider_left, sliders_y[1], slider_width, slider_height]), 
                              'F (vert. shift)', -0.3, 0.3, valinit=self.F, valfmt='%.2f')
        self.slider_a = Slider(plt.axes([slider_left, sliders_y[2], slider_width, slider_height]), 
                              'a (radius)', 1.05, 2.0, valinit=self.a, valfmt='%.2f')
        self.slider_alpha = Slider(plt.axes([slider_left, sliders_y[3], slider_width, slider_height]), 
                                  'Î± (angle of attack)', -0.3, 0.3, valinit=self.alpha, valfmt='%.2f')
        self.slider_U = Slider(plt.axes([slider_left, sliders_y[4], slider_width, slider_height]), 
                              'U (velocity)', 0.5, 2.0, valinit=self.U, valfmt='%.2f')
        self.slider_transform = Slider(plt.axes([slider_left, sliders_y[5], slider_width, slider_height]), 
                                      'Transform Î±', 0.0, 1.0, valinit=self.transform_alpha, valfmt='%.2f')

        all_sliders = [self.slider_ec, self.slider_F, self.slider_a, 
                      self.slider_alpha, self.slider_U, self.slider_transform]
        for slider in all_sliders:
            slider.on_changed(self.update_parameters)

        button_positions = [(0.02, 0.20, 0.08, 0.04), (0.02, 0.15, 0.08, 0.04), (0.02, 0.10, 0.08, 0.04)]

        self.btn_symmetric = Button(plt.axes(button_positions[0]), 'Symmetric')
        self.btn_cambered = Button(plt.axes(button_positions[1]), 'Cambered')
        self.btn_thick = Button(plt.axes(button_positions[2]), 'Thick T.E.')

        self.btn_symmetric.on_clicked(lambda x: self.set_preset('symmetric'))
        self.btn_cambered.on_clicked(lambda x: self.set_preset('cambered'))
        self.btn_thick.on_clicked(lambda x: self.set_preset('thick'))

    def joukowsky_transform(self, zeta, alpha=1.0):
        zeta_safe = np.where(np.abs(zeta) < 1e-10, 1e-10, zeta)
        return zeta + alpha * (self.c**2) / zeta_safe

    def generate_circle(self, n_points=200):
        theta = np.linspace(0, 2*np.pi, n_points)
        x = self.ec + self.a * np.cos(theta)
        y = self.F + self.a * np.sin(theta)
        return x + 1j*y

    def compute_circulation(self):
        if abs(self.c + self.ec) < 1e-10:
            beta = 0
        else:
            F_limited = np.clip(self.F, -(self.c + abs(self.ec)), (self.c + abs(self.ec)))
            beta = np.arcsin(F_limited / (self.c + abs(self.ec)))

        K = 4 * np.pi * self.U * self.a * np.sin(self.alpha + beta)
        return K, beta

    def compute_streamlines_circle(self, n_grid=50):
        x_range = np.linspace(-3, 3, n_grid)
        y_range = np.linspace(-2, 2, n_grid)
        X, Y = np.meshgrid(x_range, y_range)
        Z = X + 1j*Y

        center = self.ec + 1j*self.F
        r = np.abs(Z - center)
        theta = np.angle(Z - center)

        K, beta = self.compute_circulation()

        psi = np.zeros_like(r)
        mask = r > self.a * 0.95  

        psi[mask] = (self.U * r[mask] * (1 - (self.a**2)/(r[mask]**2)) * np.sin(theta[mask]) + 
                    K/(2*np.pi) * np.log(r[mask]))
        psi[~mask] = np.nan

        return X, Y, psi

    def compute_streamlines_airfoil(self, n_grid=50):
        """Transform circle streamlines to airfoil coordinates"""
        X_circle, Y_circle, psi_circle = self.compute_streamlines_circle(n_grid)
        Z_circle = X_circle + 1j*Y_circle
        Z_airfoil = self.joukowsky_transform(Z_circle, self.transform_alpha)

        return Z_airfoil.real, Z_airfoil.imag, psi_circle

    def find_stagnation_points(self):
        """Find stagnation points: vÎ¸ = 2U sin(Î¸) + 2U sin(Î±+Î²) = 0"""
        K, beta = self.compute_circulation()

    
        theta1 = -(self.alpha + beta)
        theta2 = np.pi - (self.alpha + beta)

        # Convert to coordinates
        points = []
        for theta in [theta1, theta2]:
            x = self.ec + self.a * np.cos(theta)
            y = self.F + self.a * np.sin(theta)
            points.append((x, y))

        return points

    def update_parameters(self, val=None):
        """Update from slider values"""
        self.ec = self.slider_ec.val
        self.F = self.slider_F.val
        self.a = self.slider_a.val
        self.alpha = self.slider_alpha.val
        self.U = self.slider_U.val
        self.transform_alpha = self.slider_transform.val
        self.update_plots()

    def set_preset(self, preset_type):
        """Apply preset configurations from Figure 2.1"""
        presets = {
            'symmetric': (0.2, 0.0, 1.2, 0.1),    # Fig 2.1b
            'cambered': (0.1, 0.2, 1.15, 0.0),    # Fig 2.1a  
            'thick': (0.15, 0.15, 1.3, 0.05)      # Fig 2.1d
        }

        if preset_type in presets:
            ec, F, a, alpha = presets[preset_type]
            self.slider_ec.set_val(ec)
            self.slider_F.set_val(F)
            self.slider_a.set_val(a)
            self.slider_alpha.set_val(alpha)

    def update_plots(self):
        """Refresh all visualizations"""
        # Clear axes
        for ax in [self.ax_circle, self.ax_airfoil, self.ax_flow_circle, self.ax_flow_airfoil]:
            ax.clear()

        # Generate geometries
        circle_points = self.generate_circle()
        airfoil_points = self.joukowsky_transform(circle_points, self.transform_alpha)

        # Plot 1: Circle geometry
        self.ax_circle.plot(circle_points.real, circle_points.imag, 'b-', linewidth=2, label='Circle')
        self.ax_circle.plot(self.ec, self.F, 'ro', markersize=8, label='Center')
        self.ax_circle.set_xlim(-2.5, 2.5)
        self.ax_circle.set_ylim(-1.5, 1.5)
        self.ax_circle.set_aspect('equal')
        self.ax_circle.grid(True, alpha=0.3)
        self.ax_circle.set_title('Circle in Î¶-plane')
        self.ax_circle.legend()

        # Plot 2: Airfoil geometry
        self.ax_airfoil.plot(airfoil_points.real, airfoil_points.imag, 'r-', linewidth=2, 
                           label='Joukowsky Airfoil')
        self.ax_airfoil.set_xlim(-3, 3)
        self.ax_airfoil.set_ylim(-1.5, 1.5)
        self.ax_airfoil.set_aspect('equal')
        self.ax_airfoil.grid(True, alpha=0.3)
        self.ax_airfoil.set_title(f'Airfoil in z-plane (Î±={self.transform_alpha:.2f})')
        self.ax_airfoil.legend()

        # Plot 3: Circle flow field
        X_c, Y_c, psi_c = self.compute_streamlines_circle()
        self.ax_flow_circle.plot(circle_points.real, circle_points.imag, 'k-', linewidth=3)

        levels = np.linspace(-2, 2, 20)
        self.ax_flow_circle.contour(X_c, Y_c, psi_c, levels=levels, colors='blue', alpha=0.6)

        # Mark stagnation points
        stag_points = self.find_stagnation_points()
        for i, (x, y) in enumerate(stag_points):
            self.ax_flow_circle.plot(x, y, 'ro', markersize=8, 
                                   label='Stagnation Points' if i == 0 else '')

        self.ax_flow_circle.set_xlim(-3, 3)
        self.ax_flow_circle.set_ylim(-2, 2)
        self.ax_flow_circle.set_aspect('equal')
        self.ax_flow_circle.grid(True, alpha=0.3)
        self.ax_flow_circle.set_title('Flow around Circle')
        if stag_points:
            self.ax_flow_circle.legend()

        # Plot 4: Airfoil flow field
        X_a, Y_a, psi_a = self.compute_streamlines_airfoil()
        self.ax_flow_airfoil.plot(airfoil_points.real, airfoil_points.imag, 'k-', linewidth=3)
        self.ax_flow_airfoil.contour(X_a, Y_a, psi_a, levels=levels, colors='red', alpha=0.6)

        # Transform and plot stagnation points
        stag_complex = [x + 1j*y for x, y in stag_points]
        stag_transformed = [self.joukowsky_transform(np.array([pt]), self.transform_alpha)[0] 
                          for pt in stag_complex]

        for i, pt in enumerate(stag_transformed):
            self.ax_flow_airfoil.plot(pt.real, pt.imag, 'ro', markersize=8,
                                    label='Stagnation Points' if i == 0 else '')

        self.ax_flow_airfoil.set_xlim(-4, 4)
        self.ax_flow_airfoil.set_ylim(-2, 2)
        self.ax_flow_airfoil.set_aspect('equal')
        self.ax_flow_airfoil.grid(True, alpha=0.3)
        self.ax_flow_airfoil.set_title('Flow around Airfoil')
        if stag_transformed:
            self.ax_flow_airfoil.legend()

        # Parameter display
        K, beta = self.compute_circulation()
        self.ax_params.clear()
        self.ax_params.axis('off')

        param_text = f"""Current Parameters:
        â€¢ Circle: radius a={self.a:.2f}, center=({self.ec:.2f}, {self.F:.2f})
        â€¢ Flow: Uâˆž={self.U:.2f}, Î±={self.alpha:.2f} rad ({np.degrees(self.alpha):.1f}Â°)
        â€¢ Circulation: K={K:.3f}, Î²={beta:.3f} rad
        â€¢ Transform: z = Î¶ + {self.transform_alpha:.2f}Ã—cÂ²/Î¶, c={self.c:.2f}

        Theory: Joukowsky Transform (Eq. 2.1), Circulation (Eq. 2.19), Stream Function (Eq. 2.16)"""

        self.ax_params.text(0.1, 0.5, param_text, fontsize=10, verticalalignment='center',
                           bbox=dict(boxstyle="round,pad=0.3", facecolor="lightblue", alpha=0.5))

        plt.draw()

def main():
    """Main function to run the visualization"""
    print("=" * 80)
    print("JOUKOWSKY AIRFOIL VISUALIZATION")
    print("=" * 80)
    print("Interactive tool for exploring conformal mapping and aerodynamic flow")
    print()
    print("FEATURES:")
    print("â€¢ Real-time Joukowsky transform (circle â†’ airfoil)")
    print("â€¢ Flow field visualization with streamlines")
    print("â€¢ Interactive parameter control via sliders") 
    print("â€¢ Preset airfoil configurations")
    print("â€¢ Mathematical accuracy per project report equations")
    print()
    print("INSTRUCTIONS:")
    print("1. Use sliders to adjust parameters in real-time")
    print("2. Click preset buttons for specific airfoil types")
    print("3. Observe how transform intensity affects shape")
    print("4. Study circulation effects on stagnation points")
    print()
    print("Starting visualization...")
    print("-" * 80)

    # Create and display visualization
    visualizer = JoukowskyAirfoilVisualizer()
    plt.show()

if __name__ == "__main__":
    main()
