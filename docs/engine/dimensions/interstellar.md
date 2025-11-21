# Interstellar Dimension

## Overview

The **Interstellar dimension** represents the largest scale in the Phase Space simulation engine. It models the motion of star systems within a galaxy and provides the cosmic context for all other simulation layers. This dimension handles galactic-scale dynamics where distances are measured in light-years and time scales extend to years or centuries.

Entities in this dimension include:

- Star systems as whole units
- Seedship trajectories between stars
- Wormhole network anchor points
- Large-scale cosmic structures (future: nebulae, clusters)

The Interstellar dimension is typically dormant during active gameplay, updating only when strategic-scale navigation is relevant. It serves as the foundational coordinate chart from which all smaller-scale dimensions derive their absolute galactic position.

## Phase Coordinates

In the Interstellar dimension, entities are expressed using simplified phase coordinates suited for galactic-scale motion:

### Primary Coordinates

- **Position (`r`)**: 3D coordinates relative to the galactic center, measured in light-years or parsecs
- **Linear Momentum (`p`)**: Mass times velocity, encoding large-scale drift through the galaxy
- **Orientation (`q`)**: Quaternion describing the star system's rotational orientation (relevant for wormhole anchor alignment)
- **Angular Momentum (`L`)**: Rotational state of the system as a whole (typically negligible at this scale)

### Canonical Coordinates

At the interstellar scale, orbital elements around the galactic center can be used as canonical coordinates when precision is needed:

- Semi-major axis and eccentricity of the galactic orbit
- Inclination relative to the galactic plane
- Longitude of ascending node and argument of periapsis

However, for most purposes, Cartesian coordinates in the galactic frame are sufficient, as interstellar integrators use coarse time-steps and approximate dynamics.

### Scale and Precision

Position coordinates at this scale are large (10³–10⁵ light-years), requiring careful numerical handling. The engine uses appropriate floating-point precision or hierarchical coordinate systems to prevent loss of accuracy when computing local offsets.

## Reference Frame

The Interstellar dimension operates in the **Galactic Inertial Frame**:

- **Origin**: The center of mass of the galaxy (or an appropriate reference point if multiple galaxies are simulated)
- **Orientation**: Aligned with the galactic plane, with the Z-axis perpendicular to the disk
- **Type**: Inertial (non-rotating, non-accelerating at galactic scales)

### Relationship to Child Frames

The Galactic Inertial Frame is the root of the reference frame hierarchy. All smaller-scale frames derive their absolute position from this frame:

- **System Frames**: Each star system has an inertial frame centered on its barycenter. Transforming from Galactic to System frame involves a translation (subtracting the system's galactic position) and potentially a rotation if the system frame is oriented differently.

### Frame Transformations

When an entity transitions between Interstellar and Interplanetary dimensions, the transformation is straightforward:

1. Subtract the star system's galactic position from the entity's position: `r_system = r_galactic - r_star_system`
2. Adjust momentum to be relative to the system's motion: `p_system = p_galactic - m * v_star_system`

Because both frames are inertial (or nearly so), no fictitious forces are introduced during this transformation.

## Physics Model / Integrator

The Interstellar dimension uses a minimal physics model optimized for long-term, low-fidelity simulation:

### Integrator

- **Type**: Low-order symplectic integrator (e.g., leapfrog or basic Verlet)
- **Time-step**: Very large, ranging from seconds to minutes of simulation time per tick
- **Tick Rate**: 0.01–1 Hz (one update per second to once per minute)

### Physics Simplifications

At the interstellar scale, detailed dynamics are unnecessary. The physics model includes:

- **Galactic Gravity**: Stars orbit the galactic center under a simplified gravitational potential (e.g., a logarithmic or isothermal halo model)
- **Point-Mass Approximation**: Star systems are treated as single point masses with no internal structure
- **No Collisions**: Interstellar collisions are astronomically rare and not simulated
- **No Drag or Radiation**: Interstellar space is treated as a perfect vacuum

### When This Physics Model Applies

The Interstellar integrator runs when:

- Strategic navigation between star systems is active (e.g., plotting seedship routes)
- Wormhole network topology needs updating
- Long-term galactic motion simulation is required

Most of the time, this dimension is effectively paused or updated infrequently, as gameplay focuses on smaller scales.

## Handoff Behavior

Entities transition between the Interstellar and Interplanetary dimensions based on proximity to star systems.

### Transition Into Interstellar

An entity enters the Interstellar dimension when:

- It leaves a star system's **sphere of influence** (typically defined as a radius where the system's gravity dominates, e.g., 1–10 light-years depending on stellar mass and galactic context)
- It completes a wormhole traversal and emerges in interstellar space

**Handoff Process**:

1. Extract the entity's phase state in the Interplanetary chart: `(r_system, p_system, q, L)`
2. Transform to the Galactic frame by adding the star system's position and velocity:
   - `r_galactic = r_system + r_star_system`
   - `p_galactic = p_system + m * v_star_system`
3. Spawn the entity in the Interstellar dimension with the transformed state

### Transition Out of Interstellar

An entity exits the Interstellar dimension when:

- It enters a star system's sphere of influence (detected by distance threshold or velocity-dependent criteria)
- It initiates a wormhole traversal to a system-bound destination

**Handoff Process**:

1. Extract the entity's phase state in the Galactic chart: `(r_galactic, p_galactic, q, L)`
2. Transform to the target system's frame:
   - `r_system = r_galactic - r_target_system`
   - `p_system = p_galactic - m * v_target_system`
3. Spawn the entity in the target system's Interplanetary dimension with the transformed state

### Transition Thresholds

Typical thresholds for Interstellar ↔ Interplanetary transitions:

- **Distance-based**: Exit Interstellar when within 1–5 light-years of a star system barycenter
- **Velocity-based**: Enter Interstellar when escape velocity from the system is exceeded and the entity is beyond the system's gravitational dominance radius

## Invariants Preserved

Handoffs to and from the Interstellar dimension preserve the following physical quantities:

### Momentum Conservation

- **Linear Momentum**: The entity's total momentum in the galactic inertial frame is conserved exactly during transformation
- **Angular Momentum**: Spin state (`L`) is preserved across the transition (though rotational dynamics are minimal at this scale)

### Energy Consistency

- **Kinetic Energy**: The entity's kinetic energy relative to the galactic frame remains constant (up to numerical precision)
- **Potential Energy**: Gravitational potential energy in the galactic field is consistently accounted for before and after the transition

### Mass Conservation

- **Mass Invariance**: The entity's mass (`m`) is unchanged during handoff
- **Fuel or Cargo**: Any internal state (fuel reserves, cargo mass) is preserved

### Frame-Invariant Quantities

- **Proper Time**: For relativistic or time-dilated entities (e.g., Fold pockets), proper time is tracked consistently across dimension boundaries
- **Orientation**: The entity's quaternion (`q`) is frame-independent and preserved exactly

### No Artificial Forces

The coordinate transformation between Galactic and System frames is purely kinematic—no forces are applied during the handoff. The entity's trajectory is continuous across the boundary; only the description (chart) changes.

## Summary

The Interstellar dimension serves as the cosmic foundation of the Phase Space engine's multiscale architecture. It provides a galactic-scale coordinate chart where star systems, seedships, and wormhole anchors exist as point masses drifting through the galaxy. Using a coarse symplectic integrator and inertial galactic frame, this dimension anchors all smaller-scale simulations in a consistent absolute reference. Transitions to and from Interplanetary dimensions are simple coordinate translations that preserve momentum, energy, and mass, ensuring seamless continuity as entities move between the largest and next-smaller scales of simulation.
