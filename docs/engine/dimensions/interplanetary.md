# Interplanetary Dimension

## Overview

The **Interplanetary dimension** represents the space within a star system, spanning the region between planets, moons, asteroids, and other celestial bodies. This dimension handles large-scale orbital mechanics and transfer trajectories, simulating the motion of ships, probes, and natural objects under the gravitational influence of the system's star and major planets.

Entities in this dimension include:

- Ships performing transfer burns between planets
- Convoys traveling through interplanetary space
- Asteroids, comets, and debris in system-wide orbits
- Stations positioned at Lagrange points or in deep space
- Wormhole gate structures anchored in interplanetary space

The Interplanetary dimension uses coarser time-steps than planetary orbit or surface simulations, but finer than the Interstellar dimension. It balances computational efficiency with the accuracy needed for long-duration burns and multi-body gravitational interactions.

## Phase Coordinates

In the Interplanetary dimension, entities are expressed using phase coordinates suited for system-scale orbital mechanics:

### Primary Coordinates

- **Position (`r`)**: 3D coordinates relative to the star system's barycenter (center of mass), measured in kilometers or astronomical units (AU)
- **Linear Momentum (`p`)**: Mass times velocity, encoding the entity's orbital and translational motion through the system
- **Orientation (`q`)**: Quaternion describing the entity's rotational state (important for ship attitude, solar panel alignment, etc.)
- **Angular Momentum (`L`)**: Rotational momentum, governing the entity's spin dynamics

### Canonical Coordinates

For certain applications (e.g., patched conic trajectory planning), **orbital elements** may be used as canonical coordinates:

- Semi-major axis (`a`), eccentricity (`e`), inclination (`i`)
- Longitude of ascending node (`Ω`), argument of periapsis (`ω`), true anomaly (`ν`)

These elements can be derived from `(r, p)` and are useful for high-level navigation planning. However, the integrator operates on Cartesian coordinates for numerical stability and generality.

### Scale and Precision

Interplanetary positions span 10⁶–10⁹ km, requiring careful numerical handling. The engine uses double-precision floating-point or hierarchical coordinates to maintain accuracy when computing relative positions between distant entities.

## Reference Frame

The Interplanetary dimension operates in the **System Barycentric Inertial Frame**:

- **Origin**: The barycenter (center of mass) of the star system, accounting for the star and all major planets
- **Orientation**: Typically aligned with the ecliptic plane (or the system's invariant plane), with the Z-axis perpendicular to the plane
- **Type**: Inertial (non-rotating, non-accelerating)

### Relationship to Parent and Child Frames

The System Barycentric Frame is nested within the Galactic Inertial Frame (used by the Interstellar dimension):

- **Parent Frame (Galactic)**: The system's barycentric frame moves through the galaxy. Transforming to the Galactic frame requires adding the system's galactic position and velocity.
- **Child Frames (Planetary)**: Each planet has its own inertial frame centered on the planet's center. Transforming to a planetary frame involves subtracting the planet's position and velocity from the entity's state.

### Frame Transformations

When transitioning between Interplanetary and Orbit dimensions:

1. **To Orbit**: Subtract the planet's position and velocity: `r_planet = r_system - r_planet_pos`, `p_planet = p_system - m * v_planet`
2. **From Orbit**: Add the planet's position and velocity back to express the state in the system frame

Because both frames are inertial, no fictitious forces are introduced during these transformations.

## Physics Model / Integrator

The Interplanetary dimension uses a physics model optimized for long-duration orbital mechanics and multi-body gravitational interactions:

### Integrator

- **Type**: N-body gravitational integrator (e.g., Verlet, Runge-Kutta 4, or adaptive symplectic methods)
- **Time-step**: 1–10 seconds of simulation time per tick
- **Tick Rate**: 1–10 Hz (one to ten updates per second)

### Physics Model

The Interplanetary integrator simulates:

- **Point-Mass Gravity**: Gravitational forces from the star, planets, and major moons (treated as point masses or spherical bodies)
- **N-Body Interactions**: Each entity is affected by the gravitational pull of all significant bodies in the system
- **Solar Radiation Pressure**: Light pressure from the star can affect lightweight objects (e.g., solar sails, debris)
- **Simplified Drag**: Minimal atmospheric drag effects near planets (detailed drag is handled in Orbit or Surface dimensions)

### Simplifications

At the interplanetary scale, the following simplifications apply:

- **No Fine-Grained Collisions**: Collision detection is limited to large-scale events (e.g., impact with a planet or major body)
- **Rigid-Body Approximation**: Ships and entities are treated as rigid bodies with no internal deformation
- **No Surface Interactions**: Terrain, atmosphere, and surface physics are handled by child dimensions

### When This Physics Model Applies

The Interplanetary integrator runs when:

- An entity is beyond the **sphere of influence** of any major planet but within the star system
- Long-duration transfer burns or coast phases are in progress
- Multi-body gravitational interactions (e.g., gravity assists) must be accurately simulated

## Handoff Behavior

Entities transition between Interplanetary and other dimensions based on proximity to celestial bodies and system boundaries.

### Transition Into Interplanetary

An entity enters the Interplanetary dimension from:

- **Orbit Dimension**: When it leaves a planet's or moon's sphere of influence (SOI), typically defined as the radius where the planet's gravity no longer dominates over the star's
- **Interstellar Dimension**: When it enters a star system's influence sphere

**Handoff Process (from Orbit)**:

1. Extract the entity's phase state in the planet-centric Orbit chart: `(r_orbit, p_orbit, q, L)`
2. Transform to the system barycentric frame:
   - `r_system = r_orbit + r_planet_pos` (add planet's position in system frame)
   - `p_system = p_orbit + m * v_planet` (add planet's velocity contribution)
3. Spawn the entity in the Interplanetary dimension with the transformed state

### Transition Out of Interplanetary

An entity exits the Interplanetary dimension when:

- **To Orbit**: It enters a planet's or moon's sphere of influence, detected by distance and velocity criteria
- **To Interstellar**: It leaves the star system's influence sphere (e.g., achieves escape velocity and exits the outer boundary)

**Handoff Process (to Orbit)**:

1. Extract the entity's phase state in the system barycentric chart: `(r_system, p_system, q, L)`
2. Transform to the target planet's frame:
   - `r_orbit = r_system - r_planet_pos`
   - `p_orbit = p_system - m * v_planet`
3. Spawn the entity in the target planet's Orbit dimension with the transformed state

### Transition Thresholds

Typical thresholds for Interplanetary ↔ Orbit transitions:

- **Sphere of Influence (SOI)**: Defined using the Hill sphere radius (e.g., for Earth, ~0.93 million km), which approximates the region where a planet's gravity dominates over the star's
- **Velocity Criteria**: An entity approaching a planet at high velocity may be transitioned earlier to ensure accurate capture modeling

## Invariants Preserved

Handoffs to and from the Interplanetary dimension preserve the following physical quantities:

### Momentum Conservation

- **Linear Momentum**: The entity's total momentum in the system barycentric inertial frame is conserved exactly during transformation
- **Angular Momentum**: Spin state (`L`) is preserved, ensuring continuous rotational dynamics across the transition

### Energy Consistency

- **Kinetic Energy**: The entity's kinetic energy relative to the system barycenter remains constant (up to numerical precision)
- **Potential Energy**: Gravitational potential energy from the star and planets is consistently accounted for before and after the transition, ensuring no artificial energy gain or loss

### Mass Conservation

- **Mass Invariance**: The entity's mass (`m`) is unchanged during handoff
- **Internal State**: Fuel reserves, cargo mass, and other internal properties are preserved

### Frame-Invariant Quantities

- **Proper Time**: For entities with custom time scaling (e.g., Fold pockets), proper time is tracked consistently across dimension boundaries
- **Orientation**: The entity's quaternion (`q`) is frame-independent and preserved exactly

### No Artificial Forces

The coordinate transformation between system barycentric and planet-centric frames is purely kinematic. No forces are applied during the handoff, ensuring the entity's trajectory is continuous. Only the coordinate description changes; the underlying phase state remains consistent.

## Summary

The Interplanetary dimension is the backbone of system-scale navigation in the Phase Space engine. It provides a barycentric inertial coordinate chart where ships, asteroids, and stations move under the gravitational influence of the star and major planets. Using an N-body symplectic integrator with coarse time-steps, this dimension efficiently simulates long-duration orbital transfers and multi-body interactions. Transitions to Orbit dimensions are seamless coordinate transformations that preserve momentum, energy, and mass, ensuring continuous trajectories as entities approach or depart planetary spheres of influence. This dimension bridges the galactic scale of Interstellar motion and the fine-grained dynamics of Orbit and Surface simulations.
