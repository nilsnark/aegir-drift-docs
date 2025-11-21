# Surface Dimension

## Overview

The **Surface dimension** represents planetary surfaces, including landed ships, ground bases, rovers, and walking players. This dimension handles terrain interaction, atmospheric effects, and full six-degree-of-freedom (6-DOF) rigid-body dynamics for entities in contact with or moving near a planet's surface.

Entities in this dimension include:

- Landed ships and spacecraft
- Ground vehicles (rovers, hoppers)
- Surface bases and structures
- Walking or driving players
- Atmospheric aircraft and drones
- Falling or rolling debris

The Surface dimension uses a rotating reference frame fixed to the planet's body, matching the intuitive "ground perspective" that players expect. It simulates terrain collisions, friction, atmospheric drag and lift, and gravitational effects with high fidelity suitable for player interaction and vehicle control.

## Phase Coordinates

In the Surface dimension, entities are expressed using phase coordinates in the planet's rotating frame:

### Primary Coordinates

- **Position (`r`)**: 3D coordinates relative to a local surface patch or the planet's center, measured in meters or kilometers
- **Linear Momentum (`p`)**: Mass times velocity **in the rotating frame**, encoding translational motion relative to the surface
- **Orientation (`q`)**: Quaternion describing the entity's attitude (critical for vehicle control, landing orientation, and player perspective)
- **Angular Momentum (`L`)**: Rotational momentum in the rotating frame, governing spin dynamics

### Canonical Coordinates

Surface-relative coordinates may also use:

- **Tangent Plane Coordinates**: Position expressed as (North, East, Up) relative to a local tangent plane at a reference point (e.g., a landing site)
- **Spherical Coordinates**: Latitude, longitude, and altitude above the reference ellipsoid (useful for large-scale surface navigation)
- **Terrain-Relative Altitude**: Height above local terrain (critical for landing and collision avoidance)

The integrator typically operates on Cartesian coordinates in the rotating frame, but these alternative representations are used for navigation, user interfaces, and handoff conditions.

### Scale and Precision

Surface positions span 10⁰–10³ km horizontally and 0–100 km vertically (for atmospheric flight). Precision requirements are at the meter or centimeter level for player movement and vehicle control. The engine uses local coordinate patches or hierarchical frames to maintain numerical accuracy over large surface areas.

## Reference Frame

The Surface dimension operates in a **Planet-Surface Rotating Frame**:

- **Origin**: Typically the planet's center of mass, or a local origin for a specific surface patch (e.g., a landing site or base)
- **Orientation**: Rotates with the planet's body, aligned with the planet's rotation axis. The frame rotates at the planet's angular velocity `ω`.
- **Type**: Rotating (non-inertial)

### Relationship to Parent and Child Frames

The Planet-Surface Rotating Frame is nested within the Planet-Centric Inertial Frame (used by the Orbit dimension):

- **Parent Frame (Planet-Centric Inertial)**: The surface frame rotates relative to the inertial frame. Transforming to the inertial frame requires accounting for the frame's angular velocity and introducing velocity corrections.
- **Child Frames (Interior)**: Entities on the surface may contain interior spaces (e.g., a landed ship's interior). The interior frame is attached to the entity and moves/rotates with it.

### Fictitious Forces

Because the Surface frame is rotating, fictitious forces appear:

- **Centrifugal Force**: `F_cf = -m * ω × (ω × r)` (points radially outward, slightly reduces effective gravity)
- **Coriolis Force**: `F_cor = -2m * ω × v` (deflects moving objects perpendicular to their velocity and the rotation axis)

These forces are included in the physics model to correctly simulate motion in the rotating frame. For slowly moving objects (e.g., walking players), Coriolis effects are negligible; for high-speed aircraft or projectiles, they can be significant.

### Frame Transformations

When transitioning between Surface and Orbit dimensions:

1. **To Orbit**: Transform from the rotating surface frame to the inertial orbit frame:
   - `v_orbit = v_surface + ω × r_surface` (add rotational velocity contribution)
   - `p_orbit = m * v_orbit`
2. **From Orbit**: Transform from the inertial orbit frame to the rotating surface frame:
   - `v_surface = v_orbit - ω × r_orbit` (subtract rotational velocity contribution)
   - `p_surface = m * v_surface`

These transformations are symplectic and preserve energy when the rotational kinetic energy is properly accounted for.

## Physics Model / Integrator

The Surface dimension uses a physics model optimized for terrain interaction and atmospheric effects:

### Integrator

- **Type**: Rigid-body dynamics integrator with collision response and constraint solving (e.g., impulse-based or penalty-based methods)
- **Time-step**: 0.01–0.05 seconds of simulation time per tick (20–100 steps per second)
- **Tick Rate**: 20–100 Hz (twenty to one hundred updates per second)

### Physics Model

The Surface integrator simulates:

- **Gravity**: Gravitational acceleration corrected for centrifugal effect (`g_eff = g - ω² * R` at the equator)
- **Terrain Collision**: Detection and response for collisions with the planet's surface, including friction, restitution (bounce), and contact forces
- **Atmospheric Drag and Lift**: Forces on moving entities due to air resistance and aerodynamic surfaces (e.g., wings, control surfaces)
- **Wind**: Atmospheric wind velocity field affecting entity motion
- **Friction**: Static and kinetic friction between entities and the terrain or other entities
- **Buoyancy**: For entities in fluid (water, thick atmospheres)
- **Joint Constraints**: For articulated vehicles (e.g., rovers with suspension, landing gear)

### Simplifications

At the surface scale, the following simplifications may apply:

- **Simplified Terrain**: Terrain may use a heightmap or mesh representation rather than a fully volumetric model
- **Rigid-Body Approximation**: Entities are treated as rigid bodies; structural deformation is not simulated unless required by specific systems
- **Local Flat-Earth Approximation**: For small surface patches, the curvature of the planet may be ignored, treating the surface as locally flat

### When This Physics Model Applies

The Surface integrator runs when:

- An entity is within the **transition altitude** (typically 30–100 km) and below orbital velocity
- The entity is in contact with or near the planet's surface (including atmospheric flight)
- Terrain collision or atmospheric effects are significant

## Handoff Behavior

Entities transition between Surface and adjacent dimensions based on altitude, velocity, and operational state.

### Transition Into Surface

An entity enters the Surface dimension from:

- **Orbit Dimension**: When it descends below the transition altitude (e.g., 30–100 km) and enters the atmospheric or surface physics regime
- **Interior Dimension**: When it exits a landed ship's or base's interior and steps onto the surface

**Handoff Process (from Orbit)**:

1. Extract the entity's phase state in the planet-centric inertial chart: `(r_orbit, p_orbit, q, L)`
2. Transform to the rotating surface frame:
   - `r_surface = r_orbit` (position is the same, re-expressed in rotating frame)
   - `v_surface = v_orbit - ω × r_orbit` (subtract rotational velocity contribution)
   - `p_surface = m * v_surface`
3. Spawn the entity in the Surface dimension with the transformed state

**Handoff Process (from Interior)**:

1. Extract the entity's phase state in the interior's co-moving frame: `(r_interior, p_interior, q, L)`
2. Transform to the surface frame by accounting for the container entity's (ship/base) position, velocity, and orientation:
   - `r_surface = r_container + R_container * r_interior` (rotate and translate from interior to surface)
   - `v_surface = v_container + ω_container × (R_container * r_interior) + R_container * v_interior`
   - `p_surface = m * v_surface`
3. Spawn the entity in the Surface dimension with the transformed state

### Transition Out of Surface

An entity exits the Surface dimension when:

- **To Orbit**: It ascends above the transition altitude (e.g., 30–100 km) and achieves orbital or suborbital velocity
- **To Interior**: It enters a ship's or base's interior (e.g., through an airlock or door)

**Handoff Process (to Orbit)**:

1. Extract the entity's phase state in the rotating surface frame: `(r_surface, p_surface, q, L)`
2. Transform to the planet-centric inertial frame:
   - `r_orbit = r_surface`
   - `v_orbit = v_surface + ω × r_surface` (add rotational velocity contribution)
   - `p_orbit = m * v_orbit`
3. Spawn the entity in the Orbit dimension with the transformed state

### Transition Thresholds

Typical thresholds for Surface dimension transitions:

- **To Orbit**: Altitude > 30–100 km (or when atmospheric effects become negligible and orbital mechanics dominate)
- **To Interior**: Proximity to an interior entry point (airlock, door) and velocity conditions for safe entry are met

## Invariants Preserved

Handoffs to and from the Surface dimension preserve the following physical quantities:

### Momentum Conservation

- **Linear Momentum**: When transforming between inertial and rotating frames, the entity's absolute momentum (in the inertial frame) is conserved. The momentum in the rotating frame accounts for the frame's motion.
- **Angular Momentum**: Spin state (`L`) is preserved, ensuring continuous rotational dynamics across transitions

### Energy Consistency

- **Kinetic Energy**: The entity's total kinetic energy (translational + rotational) is conserved in the inertial frame. When expressed in the rotating frame, the kinetic energy includes contributions from the frame's rotation, which are correctly accounted for.
- **Potential Energy**: Gravitational potential energy is consistently tracked before and after the transition. The effective gravity in the rotating frame (including centrifugal reduction) is accounted for.

### Mass Conservation

- **Mass Invariance**: The entity's mass (`m`) is unchanged during handoff
- **Internal State**: Fuel reserves, cargo mass, structural integrity, and other internal properties are preserved

### Frame-Invariant Quantities

- **Proper Time**: For entities with custom time scaling (e.g., Fold pockets within surface bases), proper time is tracked consistently across dimension boundaries
- **Orientation**: The entity's quaternion (`q`) is frame-independent and preserved exactly

### No Artificial Forces

Coordinate transformations between inertial and rotating frames are purely kinematic. The Coriolis and centrifugal forces that appear in the rotating frame are mathematically consistent fictitious forces, not artificial errors. No arbitrary forces are introduced during the handoff. The entity's trajectory is continuous across the boundary; only the coordinate description changes.

## Summary

The Surface dimension provides the ground-level perspective in the Phase Space engine's multiscale architecture. It uses a rotating reference frame fixed to the planet's body, simulating terrain collisions, atmospheric effects, and rigid-body dynamics with fidelity suitable for player interaction and vehicle control. Transitions from Orbit require accounting for the planet's rotation, introducing Coriolis and centrifugal forces in the rotating frame. Transitions to Interior dimensions involve additional coordinate shifts to the entity's local frame. All handoffs preserve momentum, energy, and mass through symplectic transformations, ensuring that landings, takeoffs, and surface exploration are seamless and deterministic. This dimension bridges the orbital mechanics of space and the detailed physics of interior environments, completing the chain from interstellar scales down to human-scale gameplay.
