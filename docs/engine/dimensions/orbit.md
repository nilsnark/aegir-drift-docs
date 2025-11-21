# Orbit Dimension

## Overview

The **Orbit dimension** represents the near-body space around a planet, moon, or large station where orbital mechanics and close-proximity operations dominate. This dimension is the "KSP layer" of the Phase Space engine, handling detailed orbital maneuvers, rendezvous and docking, atmospheric entry and exit, and debris fields in planetary orbit.

Entities in this dimension include:

- Ships in low, medium, or high orbit
- Satellites and space stations
- Orbital debris and micrometeoroids
- Spacecraft performing rendezvous and docking maneuvers
- Atmospheric entry/exit vehicles transitioning to or from surface

The Orbit dimension uses finer time-steps and higher-fidelity physics than the Interplanetary dimension, providing the precision needed for accurate orbital prediction, station-keeping, and collision avoidance.

## Phase Coordinates

In the Orbit dimension, entities are expressed using phase coordinates centered on the orbited body:

### Primary Coordinates

- **Position (`r`)**: 3D coordinates relative to the planet's or moon's center of mass, measured in kilometers or meters
- **Linear Momentum (`p`)**: Mass times velocity, encoding the entity's orbital and translational motion
- **Orientation (`q`)**: Quaternion describing the entity's attitude (critical for docking, re-entry orientation, and thrust vector control)
- **Angular Momentum (`L`)**: Rotational momentum, governing spin dynamics and attitude control

### Canonical Coordinates

Orbital elements are commonly used as canonical coordinates for navigation and trajectory planning:

- **Keplerian Elements**: Semi-major axis (`a`), eccentricity (`e`), inclination (`i`), longitude of ascending node (`Ω`), argument of periapsis (`ω`), true anomaly (`ν`)
- **Derived Quantities**: Orbital period, apoapsis and periapsis altitudes, mean motion

These elements provide an intuitive description of orbital shape and orientation. However, the integrator operates on Cartesian coordinates `(r, p)` for numerical stability, especially when handling perturbations from atmospheric drag, oblateness, and thrust.

### Scale and Precision

Orbital positions span 10²–10⁵ km, with precision requirements at the meter or sub-meter level for docking operations. The engine uses double-precision floating-point or relative coordinates (e.g., relative to a reference orbit or station) to maintain accuracy.

## Reference Frame

The Orbit dimension operates in a **Planet-Centric Inertial Frame**:

- **Origin**: The center of mass of the planet or moon being orbited
- **Orientation**: Typically aligned with the planet's equatorial plane or the ecliptic plane, with the Z-axis aligned with the planet's rotation axis
- **Type**: Inertial (non-rotating relative to the stars)

### Relationship to Parent and Child Frames

The Planet-Centric Inertial Frame is nested within the System Barycentric Frame (used by the Interplanetary dimension):

- **Parent Frame (System Barycentric)**: The planet's inertial frame moves through the system. Transforming to the system frame requires adding the planet's position and velocity.
- **Child Frames (Surface)**: The planet's surface uses a **rotating frame** fixed to the planet's body. Transforming to the surface frame involves accounting for the planet's rotation and introducing fictitious forces (Coriolis, centrifugal).

### Frame Transformations

When transitioning between Orbit and Surface dimensions:

1. **To Surface**: Transform from the planet-centric inertial frame to the rotating surface frame:
   - Subtract the planet's angular velocity contribution: `v_surface = v_orbit - ω × r`
   - Account for Coriolis and centrifugal effects in the rotating frame
2. **From Surface**: Transform from the rotating surface frame back to the inertial frame:
   - Add the angular velocity contribution: `v_orbit = v_surface + ω × r`

These transformations are symplectic, preserving energy and momentum when properly handled.

## Physics Model / Integrator

The Orbit dimension uses a high-fidelity physics model optimized for accurate orbital mechanics and near-body interactions:

### Integrator

- **Type**: High-order symplectic or semi-implicit integrator (e.g., Verlet, implicit Euler, or higher-order Runge-Kutta methods)
- **Time-step**: 0.05–0.1 seconds of simulation time per tick (10–20 steps per second)
- **Tick Rate**: 20–50 Hz (twenty to fifty updates per second)

### Physics Model

The Orbit integrator simulates:

- **Point-Mass Gravity**: Primary gravitational force from the central body (planet or moon)
- **Atmospheric Drag**: Altitude-dependent drag force for entities within or near the atmosphere (modeled using exponential density profile)
- **Oblateness (J2 Perturbation)**: Deviation from spherical gravity due to planetary flattening (important for accurate orbital prediction over long periods)
- **Third-Body Perturbations**: Gravitational effects from nearby moons or the star (optional, for high-precision orbits)
- **Collision Detection**: Detection of collisions between entities (ships, stations, debris) and with the planet's surface or atmosphere boundary
- **Docking Forces**: Contact forces, latches, and joint constraints during docking maneuvers

### Simplifications

At the orbital scale, the following simplifications apply:

- **Rigid-Body Approximation**: Ships and stations are treated as rigid bodies with no structural deformation (unless explicitly modeled by a system)
- **No Detailed Surface Interactions**: Terrain collision and friction are handled by the Surface dimension
- **Simplified Atmospheric Model**: Drag uses a simplified exponential atmosphere model; detailed weather and wind are not simulated

### When This Physics Model Applies

The Orbit integrator runs when:

- An entity is within the planet's or moon's **sphere of influence** (SOI) but above the transition altitude to the Surface dimension (typically 30–100 km altitude, depending on atmospheric extent)
- Orbital maneuvers, rendezvous, or station-keeping operations are in progress
- Collision risk with debris or other orbital entities exists

## Handoff Behavior

Entities transition between Orbit and adjacent dimensions based on altitude, velocity, and operational state.

### Transition Into Orbit

An entity enters the Orbit dimension from:

- **Interplanetary Dimension**: When it crosses into the planet's or moon's sphere of influence (SOI)
- **Surface Dimension**: When it ascends above the transition altitude (typically 30–100 km, where atmospheric effects become negligible for orbital mechanics)
- **Interior Dimension**: When it undocks from a station or ship and enters orbital space

**Handoff Process (from Interplanetary)**:

1. Extract the entity's phase state in the system barycentric chart: `(r_system, p_system, q, L)`
2. Transform to the planet-centric inertial frame:
   - `r_orbit = r_system - r_planet_pos`
   - `p_orbit = p_system - m * v_planet`
3. Spawn the entity in the Orbit dimension with the transformed state

**Handoff Process (from Surface)**:

1. Extract the entity's phase state in the rotating surface frame: `(r_surface, p_surface, q, L)`
2. Transform to the planet-centric inertial frame:
   - `r_orbit = r_surface` (position is the same, just re-expressed)
   - `v_orbit = v_surface + ω × r_surface` (account for planetary rotation)
   - `p_orbit = m * v_orbit`
3. Spawn the entity in the Orbit dimension with the transformed state

### Transition Out of Orbit

An entity exits the Orbit dimension when:

- **To Interplanetary**: It leaves the planet's sphere of influence (SOI), typically by achieving escape velocity or traveling beyond the SOI boundary
- **To Surface**: It descends below the transition altitude (e.g., 30–100 km) and enters the atmospheric or surface physics regime
- **To Interior**: It docks with a station or ship, entering the interior's co-moving frame

**Handoff Process (to Surface)**:

1. Extract the entity's phase state in the planet-centric inertial chart: `(r_orbit, p_orbit, q, L)`
2. Transform to the rotating surface frame:
   - `r_surface = r_orbit`
   - `v_surface = v_orbit - ω × r_orbit` (subtract rotational velocity contribution)
   - `p_surface = m * v_surface`
3. Spawn the entity in the Surface dimension with the transformed state

### Transition Thresholds

Typical thresholds for Orbit dimension transitions:

- **To Surface**: Altitude < 30–100 km (or when atmospheric drag becomes significant relative to orbital mechanics)
- **To Interplanetary**: Distance > SOI radius (e.g., for Earth, ~0.93 million km) or escape velocity achieved
- **To Interior**: Proximity and relative velocity conditions for docking are met

## Invariants Preserved

Handoffs to and from the Orbit dimension preserve the following physical quantities:

### Momentum Conservation

- **Linear Momentum**: The entity's total momentum in the planet-centric inertial frame is conserved during transformation (accounting for frame rotation when transitioning to/from Surface)
- **Angular Momentum**: Spin state (`L`) is preserved, ensuring continuous rotational dynamics across transitions

### Energy Consistency

- **Kinetic Energy**: The entity's kinetic energy in the inertial frame remains constant (up to numerical precision). When transitioning to the rotating surface frame, energy associated with the planet's rotation is correctly accounted for.
- **Potential Energy**: Gravitational potential energy from the central body is consistently tracked before and after the transition, ensuring no artificial energy gain or loss

### Mass Conservation

- **Mass Invariance**: The entity's mass (`m`) is unchanged during handoff
- **Internal State**: Fuel reserves, cargo mass, structural integrity, and other internal properties are preserved

### Frame-Invariant Quantities

- **Proper Time**: For entities with custom time scaling (e.g., Fold pockets aboard stations), proper time is tracked consistently across dimension boundaries
- **Orientation**: The entity's quaternion (`q`) is frame-independent and preserved exactly

### No Artificial Forces

Coordinate transformations between inertial and rotating frames are purely kinematic. The transformation accounts for Coriolis and centrifugal effects as fictitious forces in the rotating frame, but these are mathematically consistent—no arbitrary forces are introduced. The entity's trajectory is continuous across the boundary; only the coordinate description changes.

## Summary

The Orbit dimension is the high-fidelity orbital mechanics layer of the Phase Space engine, providing detailed simulation of near-body space where precise trajectory prediction and collision avoidance are critical. Using a planet-centric inertial frame and a high-order symplectic integrator, this dimension models gravitational dynamics, atmospheric drag, and docking operations with accuracy suitable for realistic spaceflight. Transitions to Interplanetary dimensions involve simple frame translations, while transitions to Surface dimensions require careful handling of the rotating frame and fictitious forces. All handoffs preserve momentum, energy, and mass, ensuring that orbital insertions, atmospheric entries, and interplanetary departures are seamless and deterministic within the multiscale phase-space architecture.
