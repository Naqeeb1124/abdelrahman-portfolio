# orbital_mechanics.py
# Functions for Keplerian orbital mechanics calculations

import numpy as np

def state_to_elements(r_vec, v_vec, mu):
    """Converts state vectors (position, velocity) to Keplerian orbital elements.

    Args:
        r_vec (np.ndarray): Position vector [m] (shape: (3,)).
        v_vec (np.ndarray): Velocity vector [m/s] (shape: (3,)).
        mu (float): Standard gravitational parameter of the central body [m^3/s^2].

    Returns:
        tuple: (a, e, i, Omega, omega, nu)
            a (float): Semi-major axis [m]. Can be negative for hyperbolas.
            e (float): Eccentricity.
            i (float): Inclination [rad] (0 to pi).
            Omega (float): Longitude of the ascending node [rad] (0 to 2*pi).
            omega (float): Argument of periapsis [rad] (0 to 2*pi).
            nu (float): True anomaly [rad] (0 to 2*pi).
    """
    r = np.linalg.norm(r_vec)
    v = np.linalg.norm(v_vec)

    h_vec = np.cross(r_vec, v_vec)  # Specific angular momentum vector
    h = np.linalg.norm(h_vec)

    n_vec = np.cross([0, 0, 1], h_vec)  # Node vector
    n = np.linalg.norm(n_vec)

    # Eccentricity vector
    e_vec = ((v**2 - mu / r) * r_vec - np.dot(r_vec, v_vec) * v_vec) / mu
    e = np.linalg.norm(e_vec)

    # Specific mechanical energy
    energy = v**2 / 2 - mu / r

    # Semi-major axis
    if abs(e - 1.0) > 1e-9:  # Non-parabolic orbit
        a = -mu / (2 * energy)
        # p = a * (1 - e**2) # Semi-latus rectum (alternative calculation: p = h**2 / mu)
    else: # Parabolic orbit (handle potential division by zero)
        a = np.inf
        # p = h**2 / mu

    # Inclination
    i = np.arccos(h_vec[2] / h)

    # Longitude of the Ascending Node (Omega)
    if abs(i) < 1e-9 or abs(i - np.pi) < 1e-9: # Equatorial orbit (including retrograde)
        Omega = 0.0 # Define relative to x-axis if no ascending node
        if abs(e) < 1e-9: # Circular equatorial
             omega = 0.0 # Define relative to ascending node (which is along x-axis)
        else: # Elliptical equatorial
            # Angle between x-axis and eccentricity vector
            omega = np.arccos(e_vec[0] / e)
            if e_vec[1] < 0:
                omega = 2 * np.pi - omega
    else: # Inclined orbit
        Omega = np.arccos(n_vec[0] / n)
        if n_vec[1] < 0:
            Omega = 2 * np.pi - Omega

        # Argument of Periapsis (omega)
        if abs(e) < 1e-9: # Circular inclined
            omega = 0.0 # Define relative to ascending node
            # True anomaly becomes argument of latitude u = omega + nu
            # Calculate u based on position vector relative to ascending node
            # cos_u = np.dot(n_vec, r_vec) / (n * r)
            # if r_vec[2] < 0:
            #     u = 2 * np.pi - np.arccos(cos_u)
            # else:
            #     u = np.arccos(cos_u)
            # nu = u # For circular orbits, nu is often measured from ascending node
        else: # Elliptical inclined
            omega = np.arccos(np.dot(n_vec, e_vec) / (n * e))
            if e_vec[2] < 0:
                omega = 2 * np.pi - omega

    # True Anomaly (nu)
    if abs(e) < 1e-9: # Circular orbit
        if abs(i) < 1e-9 or abs(i - np.pi) < 1e-9: # Equatorial circular
            # Angle between x-axis and position vector
            nu = np.arccos(r_vec[0] / r)
            if r_vec[1] < 0:
                nu = 2 * np.pi - nu
        else: # Inclined circular
            # Argument of latitude u = omega + nu. Since omega=0, u = nu
            # Angle between ascending node and position vector
            cos_u = np.dot(n_vec, r_vec) / (n * r)
            # Clamp cos_u to avoid domain errors due to precision
            cos_u = np.clip(cos_u, -1.0, 1.0)
            if r_vec[2] < 0:
                nu = 2 * np.pi - np.arccos(cos_u)
            else:
                nu = np.arccos(cos_u)
    else: # Non-circular orbit
        nu = np.arccos(np.dot(e_vec, r_vec) / (e * r))
        # Clamp cos_nu to avoid domain errors due to precision
        nu = np.arccos(np.clip(np.dot(e_vec, r_vec) / (e * r), -1.0, 1.0))
        if np.dot(r_vec, v_vec) < 0:  # If object is moving towards periapsis
            nu = 2 * np.pi - nu

    return a, e, i, Omega, omega, nu

def elements_to_state(a, e, i, Omega, omega, nu, mu):
    """Converts Keplerian orbital elements to state vectors (position, velocity).

    Args:
        a (float): Semi-major axis [m].
        e (float): Eccentricity.
        i (float): Inclination [rad].
        Omega (float): Longitude of the ascending node [rad].
        omega (float): Argument of periapsis [rad].
        nu (float): True anomaly [rad].
        mu (float): Standard gravitational parameter of the central body [m^3/s^2].

    Returns:
        tuple: (r_vec, v_vec)
            r_vec (np.ndarray): Position vector in the inertial frame [m] (shape: (3,)).
            v_vec (np.ndarray): Velocity vector in the inertial frame [m/s] (shape: (3,)).
    """
    # Semi-latus rectum
    if abs(e - 1.0) < 1e-9: # Parabolic
        # Need periapsis distance rp for parabolic case, which isn't directly provided.
        # If derived from state vectors, h is known: p = h**2 / mu
        # This function assumes standard elements are given, which is ambiguous for parabola.
        # Assuming 'a' might represent periapsis distance for parabola input (needs clarification)
        # For now, raise error or handle based on expected input convention.
        raise ValueError("Parabolic elements_to_state requires periapsis distance or h.")
        # If rp is given instead of a:
        # p = 2 * rp
        # r = p / (1 + np.cos(nu))
    elif e < 1.0: # Elliptical
        p = a * (1 - e**2)
    else: # Hyperbolic
        p = a * (1 - e**2) # Note: a is negative for hyperbola, so p is positive

    # Distance from central body
    r = p / (1 + e * np.cos(nu))

    # Position and velocity in the perifocal frame (PQW frame)
    r_pqw = r * np.array([np.cos(nu), np.sin(nu), 0])
    
    # Check for parabolic case velocity calculation
    if abs(e - 1.0) < 1e-9:
         v_pqw = np.sqrt(2 * mu / r) * np.array([-np.sin(nu), (1 + np.cos(nu)), 0]) # Incorrect, needs h
         # Correct using h: v_pqw = (mu / h) * np.array([-np.sin(nu), e + np.cos(nu), 0]) with e=1
         # Requires h, which depends on initial state or rp. Assuming p is known:
         h = np.sqrt(p * mu)
         v_pqw = (mu / h) * np.array([-np.sin(nu), 1 + np.cos(nu), 0])
    else:
        h = np.sqrt(p * mu)
        v_pqw = (mu / h) * np.array([-np.sin(nu), e + np.cos(nu), 0])


    # Rotation matrices
    # Rotation about z-axis by Omega
    R_Omega = np.array([
        [np.cos(Omega), -np.sin(Omega), 0],
        [np.sin(Omega), np.cos(Omega), 0],
        [0, 0, 1]
    ])

    # Rotation about x-axis by i
    R_i = np.array([
        [1, 0, 0],
        [0, np.cos(i), -np.sin(i)],
        [0, np.sin(i), np.cos(i)]
    ])

    # Rotation about z-axis by omega
    R_omega = np.array([
        [np.cos(omega), -np.sin(omega), 0],
        [np.sin(omega), np.cos(omega), 0],
        [0, 0, 1]
    ])

    # Combined rotation matrix from PQW to Inertial (IJK)
    # Transpose of rotation from IJK to PQW
    Q_pqw_ijk = R_Omega.T @ R_i.T @ R_omega.T

    # Transform position and velocity vectors to the inertial frame
    r_vec = Q_pqw_ijk @ r_pqw
    v_vec = Q_pqw_ijk @ v_pqw

    return r_vec, v_vec

def solve_kepler_elliptic(M, e, tol=1e-10, max_iter=100):
    """Solves Kepler's equation M = E - e*sin(E) for the eccentric anomaly E.

    Args:
        M (float): Mean anomaly [rad].
        e (float): Eccentricity (0 <= e < 1).
        tol (float): Tolerance for convergence.
        max_iter (int): Maximum number of iterations.

    Returns:
        float: Eccentric anomaly E [rad].
    """
    # Initial guess
    if e < 0.8:
        E = M
    else:
        E = np.pi

    for _ in range(max_iter):
        f_E = E - e * np.sin(E) - M
        fp_E = 1 - e * np.cos(E)
        
        delta_E = -f_E / fp_E
        E += delta_E

        if abs(delta_E) < tol:
            return E
            
    print(f"Warning: Kepler solver did not converge within {max_iter} iterations.")
    return E # Return best estimate

def solve_kepler_hyperbolic(M, e, tol=1e-10, max_iter=100):
    """Solves the hyperbolic Kepler's equation M = e*sinh(H) - H for H.

    Args:
        M (float): Mean anomaly (hyperbolic) [rad].
        e (float): Eccentricity (e > 1).
        tol (float): Tolerance for convergence.
        max_iter (int): Maximum number of iterations.

    Returns:
        float: Hyperbolic anomaly H [rad].
    """
    # Initial guess (using approximation for large M)
    # M approx e*exp(H)/2 => H approx ln(2*M/e)
    # Need a robust initial guess. Using Newton's method starting point:
    H = np.arcsinh(M / e) # A simple starting point
    # Alternative: Danby's initial guess or Laguerre-Conway
    # H = np.sign(M) * np.log(2 * abs(M) / e + 1.8) # Seems more robust

    for _ in range(max_iter):
        f_H = e * np.sinh(H) - H - M
        fp_H = e * np.cosh(H) - 1
        
        # Avoid division by zero if fp_H is too small (unlikely for e>1)
        if abs(fp_H) < 1e-15:
             print(f"Warning: Hyperbolic Kepler solver encountered near-zero derivative.")
             # Consider alternative step or return current H
             return H

        delta_H = -f_H / fp_H
        H += delta_H

        if abs(delta_H) < tol:
            return H
            
    print(f"Warning: Hyperbolic Kepler solver did not converge within {max_iter} iterations.")
    return H # Return best estimate

def propagate_orbit(r0_vec, v0_vec, dt, mu):
    """Propagates an orbit from initial state vectors over a time interval dt.

    Args:
        r0_vec (np.ndarray): Initial position vector [m].
        v0_vec (np.ndarray): Initial velocity vector [m/s].
        dt (float): Time interval to propagate [s].
        mu (float): Standard gravitational parameter [m^3/s^2].

    Returns:
        tuple: (r_vec, v_vec)
            r_vec (np.ndarray): Position vector after dt [m].
            v_vec (np.ndarray): Velocity vector after dt [m].
    """
    a, e, i, Omega, omega, nu0 = state_to_elements(r0_vec, v0_vec, mu)

    if abs(e - 1.0) < 1e-9: # Parabolic
        # Parabolic propagation using Barker's equation
        # p = h**2 / mu; h = norm(cross(r0, v0))
        h_vec = np.cross(r0_vec, v0_vec)
        h = np.linalg.norm(h_vec)
        p = h**2 / mu
        rp = p / 2 # Periapsis distance
        # True anomaly to time relation (Barker's equation)
        # t = sqrt(p^3 / (2*mu)) * (tan(nu/2) + (1/3)*tan^3(nu/2))
        # Need to solve for nu at t = t0 + dt
        # Let B = tan(nu/2). Need to solve B + B^3/3 = sqrt(2*mu/p^3) * (t - T)
        # where T is time of periapsis passage.
        # First find T from nu0:
        B0 = np.tan(nu0 / 2)
        t0_minus_T = np.sqrt(p**3 / (2 * mu)) * (B0 + B0**3 / 3)
        # Target time relative to periapsis:
        target_t_minus_T = t0_minus_T + dt
        # Solve B + B^3/3 = K for B, where K = sqrt(2*mu/p^3) * target_t_minus_T
        K = np.sqrt(2 * mu / p**3) * target_t_minus_T
        # This is a cubic equation: B^3 + 3B - 3K = 0
        # Use numpy.roots to solve for B
        coeffs = [1, 0, 3, -3 * K]
        roots = np.roots(coeffs)
        # Find the real root
        real_roots = roots[np.isreal(roots)].real
        if len(real_roots) == 0:
             raise ValueError("No real root found for Barker's equation solver.")
        B = real_roots[0] # Should only be one real root
        nu = 2 * np.arctan(B)
        
    elif e < 1.0: # Elliptical
        # Calculate initial eccentric anomaly E0 from nu0
        cos_E0 = (e + np.cos(nu0)) / (1 + e * np.cos(nu0))
        sin_E0 = (np.sqrt(1 - e**2) * np.sin(nu0)) / (1 + e * np.cos(nu0))
        E0 = np.arctan2(sin_E0, cos_E0)

        # Calculate initial mean anomaly M0
        M0 = E0 - e * np.sin(E0)

        # Mean motion n
        n = np.sqrt(mu / a**3)

        # Mean anomaly at time dt
        M = M0 + n * dt
        # Normalize M to be within [0, 2*pi) or handle multiple orbits correctly
        M = M % (2 * np.pi)

        # Solve Kepler's equation for eccentric anomaly E at time dt
        E = solve_kepler_elliptic(M, e)

        # Calculate true anomaly nu from eccentric anomaly E
        cos_nu = (np.cos(E) - e) / (1 - e * np.cos(E))
        sin_nu = (np.sqrt(1 - e**2) * np.sin(E)) / (1 - e * np.cos(E))
        nu = np.arctan2(sin_nu, cos_nu)
        nu = nu % (2 * np.pi) # Ensure nu is in [0, 2*pi)

    else: # Hyperbolic
        # Calculate initial hyperbolic anomaly H0 from nu0
        cosh_H0 = (e + np.cos(nu0)) / (1 + e * np.cos(nu0))
        # Ensure argument is >= 1 for arccosh
        if cosh_H0 < 1.0: cosh_H0 = 1.0
        H0 = np.arccosh(cosh_H0)
        # Sign of H0 depends on sign of nu0 (or rather, whether approaching/leaving periapsis)
        # If nu0 > pi, spacecraft is past apoapsis (not applicable for hyperbola)
        # If nu0 is in (0, pi), sin(nu0) > 0. If nu0 is in (pi, 2pi), sin(nu0) < 0.
        # sinh(H) has the same sign as sin(nu). H0 should have same sign as nu0 if nu0 is in (-pi, pi)
        # Let's use the relation tan(nu/2) = sqrt((e+1)/(e-1)) * tanh(H/2)
        # H0 = 2 * np.arctanh(np.sqrt((e - 1) / (e + 1)) * np.tan(nu0 / 2))
        # Need to handle quadrant for nu0 carefully. Let's use the M calculation.
        sinh_H0 = (np.sqrt(e**2 - 1) * np.sin(nu0)) / (1 + e * np.cos(nu0))
        H0 = np.arcsinh(sinh_H0)

        # Calculate initial mean anomaly M0 (hyperbolic)
        M0 = e * np.sinh(H0) - H0

        # Mean motion n (hyperbolic)
        a_abs = abs(a) # a is negative for hyperbola
        n = np.sqrt(mu / a_abs**3)

        # Mean anomaly at time dt
        M = M0 + n * dt

        # Solve hyperbolic Kepler's equation for H at time dt
        H = solve_kepler_hyperbolic(M, e)

        # Calculate true anomaly nu from hyperbolic anomaly H
        cos_nu = (np.cosh(H) - e) / (1 - e * np.cosh(H))
        sin_nu = (np.sqrt(e**2 - 1) * np.sinh(H)) / (1 - e * np.cosh(H))
        nu = np.arctan2(sin_nu, cos_nu)
        nu = nu % (2 * np.pi) # Ensure nu is in [0, 2*pi)

    # Convert final elements back to state vectors
    r_vec, v_vec = elements_to_state(a, e, i, Omega, omega, nu, mu)

    return r_vec, v_vec

# Example Usage (can be removed later)
if __name__ == '__main__':
    # Example: Earth orbit (Geostationary)
    mu_earth = 3.986004418e14 # m^3/s^2
    a_geo = 42164000.0 # m
    e_geo = 0.0
    i_geo = 0.0 # rad
    Omega_geo = 0.0 # rad
    omega_geo = 0.0 # rad
    nu_geo = 0.0 # rad

    r0_vec_geo, v0_vec_geo = elements_to_state(a_geo, e_geo, i_geo, Omega_geo, omega_geo, nu_geo, mu_earth)
    print(f"GEO Initial State: r = {r0_vec_geo}, v = {v0_vec_geo}")

    # Propagate for half an orbit (approx 12 hours)
    T_geo = 2 * np.pi * np.sqrt(a_geo**3 / mu_earth)
    dt_half = T_geo / 2
    r_vec_half, v_vec_half = propagate_orbit(r0_vec_geo, v0_vec_geo, dt_half, mu_earth)
    print(f"GEO State after {dt_half/3600:.2f} hours: r = {r_vec_half}, v = {v_vec_half}")

    # Convert back to elements to check
    a_new, e_new, i_new, Omega_new, omega_new, nu_new = state_to_elements(r_vec_half, v_vec_half, mu_earth)
    print(f"GEO Final Elements: a={a_new:.1f}, e={e_new:.4f}, i={np.degrees(i_new):.4f}, nu={np.degrees(nu_new):.4f}")

    # Example: Hyperbolic flyby (using arbitrary values)
    mu_earth = 3.986004418e14 # m^3/s^2
    rp_hyp = 7000000.0 # Periapsis radius [m]
    v_inf = 5000.0 # Hyperbolic excess velocity [m/s]
    e_hyp = 1 + rp_hyp * v_inf**2 / mu_earth
    a_hyp = -mu_earth / v_inf**2
    print(f"Hyperbolic: e={e_hyp:.4f}, a={a_hyp:.1f}")

    # State at periapsis (nu=0)
    r0_vec_hyp, v0_vec_hyp = elements_to_state(a_hyp, e_hyp, 0, 0, 0, 0, mu_earth)
    print(f"Hyperbolic Periapsis State: r = {r0_vec_hyp}, v = {v0_vec_hyp}")

    # Propagate for 1 hour
    dt_hyp = 3600.0
    r_vec_hyp, v_vec_hyp = propagate_orbit(r0_vec_hyp, v0_vec_hyp, dt_hyp, mu_earth)
    print(f"Hyperbolic State after {dt_hyp/3600:.1f} hour: r = {r_vec_hyp}, v = {v_vec_hyp}")

    # Convert back to elements
    a_h, e_h, i_h, O_h, o_h, nu_h = state_to_elements(r_vec_hyp, v_vec_hyp, mu_earth)
    print(f"Hyperbolic Final Elements: a={a_h:.1f}, e={e_h:.4f}, nu={np.degrees(nu_h):.4f}")




def gravity_assist(v_sc_helio_in, r_planet, v_planet, mu_planet, rp):
    """Calculates the post-flyby heliocentric velocity using patched conics.

    Args:
        v_sc_helio_in (np.ndarray): Incoming heliocentric velocity of the s/c [m/s].
        r_planet (np.ndarray): Heliocentric position of the planet at flyby [m].
        v_planet (np.ndarray): Heliocentric velocity of the planet at flyby [m/s].
        mu_planet (float): Gravitational parameter of the flyby planet [m^3/s^2].
        rp (float): Periapsis radius of the hyperbolic flyby [m].

    Returns:
        np.ndarray: Outgoing heliocentric velocity of the s/c [m/s].
    """
    # 1. Calculate incoming V_infinity relative to the planet
    v_inf_in = v_sc_helio_in - v_planet
    v_inf_mag = np.linalg.norm(v_inf_in)

    if v_inf_mag < 1e-6: # Avoid division by zero if relative velocity is negligible
        print("Warning: Near-zero relative velocity in gravity assist.")
        return v_sc_helio_in # No change if relative velocity is zero

    # 2. Calculate hyperbolic trajectory parameters
    e = 1.0 + (rp * v_inf_mag**2) / mu_planet
    if e <= 1.0: # Should always be > 1 for a flyby
        print(f"Warning: Flyby eccentricity <= 1 (e={e:.4f}). Check rp and v_inf.")
        # This might happen with very low v_inf or large rp. Treat as no turn?
        delta = 0.0
    else:
        # 3. Calculate the turning angle
        delta = 2.0 * np.arcsin(1.0 / e)

    # 4. Determine the rotation axis (perpendicular to the flyby hyperbola plane)
    # The plane contains v_inf_in and the vector from planet center to periapsis.
    # A common simplification is to assume the rotation axis is perpendicular
    # to the plane containing v_inf_in and the planet's heliocentric position/velocity.
    # Let's use the cross product of v_inf_in and v_planet as a proxy for the normal
    # to the plane where the turn happens relative to the heliocentric frame.
    # Normalization is crucial.
    k_rot = np.cross(v_inf_in, v_planet)
    norm_k_rot = np.linalg.norm(k_rot)
    if norm_k_rot < 1e-9:
        # If v_inf_in and v_planet are parallel (unlikely but possible), choose arbitrary axis perp to v_inf_in
        print("Warning: v_inf_in and v_planet nearly parallel. Using arbitrary rotation axis.")
        if abs(v_inf_in[0]) > 1e-6 or abs(v_inf_in[1]) > 1e-6:
            k_rot = np.array([-v_inf_in[1], v_inf_in[0], 0.0]) # Perpendicular in xy plane
        else:
            k_rot = np.array([1.0, 0.0, 0.0]) # If v_inf_in is along z
        norm_k_rot = np.linalg.norm(k_rot)
        if norm_k_rot < 1e-9: # Should not happen now
             print("Error: Could not determine rotation axis.")
             return v_sc_helio_in # Return unchanged velocity
    k_rot = k_rot / norm_k_rot

    # 5. Rotate v_inf_in by delta around k_rot (Rodrigues' rotation formula)
    cos_delta = np.cos(delta)
    sin_delta = np.sin(delta)
    v_inf_out = (v_inf_in * cos_delta + 
                 np.cross(k_rot, v_inf_in) * sin_delta + 
                 k_rot * np.dot(k_rot, v_inf_in) * (1.0 - cos_delta))

    # 6. Calculate outgoing heliocentric velocity
    v_sc_helio_out = v_planet + v_inf_out

    print(f"Gravity Assist: Planet MU={mu_planet:.2e}, rp={rp/1000:.1f}km, v_inf={v_inf_mag/1000:.3f}km/s, e={e:.4f}, delta={np.degrees(delta):.2f}deg")
    print(f"  V_helio_in: {np.linalg.norm(v_sc_helio_in)/1000:.3f} km/s")
    print(f"  V_helio_out: {np.linalg.norm(v_sc_helio_out)/1000:.3f} km/s")

    return v_sc_helio_out

