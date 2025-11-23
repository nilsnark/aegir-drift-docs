# Phase-Space Architecture

## Overview

The **Phase-Space Architecture** is the foundational conceptual framework for the entire Phase Space simulation engine. It provides a unified mathematical and computational model that governs how all physical entities—from orbiting planets to walking players to rotating machinery—are represented, simulated, and synchronized across multiple scales and reference frames.

This page explains the core ideas behind phase space, how it unifies the engine's multiscale simulation model, and why it is essential for achieving deterministic, multiplayer-safe physics across dimensions.

## What is Phase Space in This Engine?

In classical mechanics, **phase space** is an abstract mathematical space where every possible state of a physical system corresponds to a unique point. For a single particle, this includes its position and momentum; for complex systems, it includes positions, momenta, orientations, angular momenta, and other conserved quantities.

In the Phase Space engine, we adopt this concept as the **unifying abstraction** for all simulation state:

- Every entity (ship, player, planet, asteroid, interior object) has a **phase state** that fully describes its physical configuration.
- All simulation occurs as **evolution through phase space**: physics integrators advance these states forward in time according to forces, torques, and constraints.
- Dimensions, reference frames, and coordinate systems are simply different **charts** (coordinate representations) on this same underlying phase space.

This architecture ensures that:

- Physics is consistent regardless of which dimension or reference frame an entity occupies.
- Transitions between dimensions are **coordinate transformations**, not teleportation or state duplication.
- Determinism is preserved because all state updates follow well-defined mathematical rules.

## The Canonical Phase State

Every entity in the engine carries a **phase state** that encodes its complete physical configuration. The canonical phase state includes:

### Position and Momentum

- **Position** (`r`): 3D spatial coordinates relative to the entity's current reference frame.
- **Linear Momentum** (`p`): Mass times velocity, encoding the entity's translational motion.

Using momentum instead of velocity directly is crucial for:

- **Symplectic integration**: Momentum-based integrators preserve energy and phase-space volume, ensuring long-term numerical stability.
- **Collision response**: Momentum is the natural quantity for impulse-based collision resolution.
- **Relativistic generalization**: Momentum generalizes cleanly to relativistic regimes if needed.

### Orientation and Angular Momentum

- **Orientation** (`q`): A quaternion or rotation matrix describing the entity's rotational state.
- **Angular Momentum** (`L`): Rotational analog of linear momentum, encoding spin.

Together, these capture the full rigid-body dynamics of rotating objects like ships, planets, and machinery.

### Mass Properties

- **Mass** (`m`): Total mass (may change due to fuel consumption, cargo transfer, etc.).
- **Inertia Tensor** (`I`): Describes how mass is distributed, governing rotational behavior.

Mass properties are not constant; they can evolve over time as entities consume fuel, load cargo, or reconfigure internal structure.

### Additional State (Context-Dependent)

Contexts or systems may extend the phase state with additional degrees of freedom:

- **Internal energy**: Fuel, battery charge, thermal state.
- **Structural health**: Damage, wear, component status.
- **Pocket state**: Fold pocket aperture configuration, time dilation factor, Kernel state.
- **Quantum fields**: For anomaly dimensions or exotic physics.

The engine treats the core phase state (position, momentum, orientation, angular momentum, mass) as canonical and universal, while allowing extensions for specialized simulation needs.

## Dimensions as Coordinate Charts

The engine divides the universe into six primary **dimension types**:

1. **Interstellar**: Galactic-scale motion of star systems.
2. **Interplanetary**: Motion within a star system (planets, asteroids, ships in transfer).
3. **Orbit**: Near-body orbits around planets or stations.
4. **Surface**: Planetary surfaces, landed ships, ground bases.
5. **Interior**: Ship interiors, station modules.
6. **Pocket**: Exotic Fold spaces with unique time-dilation properties, serving as non-local interiors.

Each dimension type corresponds to a different **coordinate chart** on the same underlying phase space. Charts differ in:

- **Coordinate origin**: Where (0, 0, 0) is defined.
- **Coordinate scale**: What units represent (meters, kilometers, AU).
- **Time scale**: How large a simulation time-step is.
- **Physics fidelity**: Which forces and interactions are modeled.

But all charts describe the same physical reality. An entity moving from orbit to surface doesn't change its fundamental phase state—it simply has that state **re-expressed** in a new coordinate system.

### Example: Orbital to Surface Transition

Consider a ship descending from orbit to a planet's surface:

- In the **Orbit dimension**, the ship's position is expressed relative to the planet's center, with coordinates in kilometers.
- In the **Surface dimension**, the ship's position is expressed relative to the local terrain patch, with coordinates in meters.

During the transition:

1. The engine computes the ship's phase state in the Orbit chart: `(r_orbit, p_orbit, q, L)`.
2. It applies a **coordinate transformation** to express the same state in the Surface chart: `(r_surface, p_surface, q, L)`.
3. The ship is removed from the Orbit dimension and spawned into the Surface dimension with the transformed state.

No information is lost; no discontinuity occurs. The transformation is **symplectic** (preserves phase-space structure), ensuring energy and momentum are conserved across the transition.

## Reference Frame Hierarchy

To manage numerical precision and physical intuition, the engine organizes reference frames into a hierarchy:

````markdown
Galactic Frame (inertial, galactic center origin)
  ├─ System Frames (inertial, star barycenter origin)
  │   ├─ Planet Inertial Frames (inertial, planet center origin)
  │   │   ├─ Planet Surface Frames (rotating with planet)
  │   │   │   └─ Interior Frames (attached to ships/stations)
  │   │   └─ Orbital Frames (planet-centric, varying eccentricity)
  │   └─ Interplanetary Frame (barycentric, system-wide)
  └─ Interstellar Frame (galactic, between stars)
````

### Frame Properties

- **Inertial frames**: Do not rotate or accelerate; physics is simplest here.
- **Rotating frames**: Introduce fictitious forces (centrifugal, Coriolis) but match intuitive "ground perspective."
- **Co-moving frames**: Move with an entity (e.g., ship interior); simplify local physics.

The engine handles frame transformations automatically. When a player walks inside a ship that's orbiting a rotating planet, the engine composes multiple frame transformations to compute the player's state in any desired chart.

### Why This Hierarchy Matters

1. **Numerical Precision**: Large distances cause floating-point precision loss. Using local frames keeps coordinates small.
2. **Physical Intuition**: Players think in "ship-relative" or "surface-relative" terms; frames match this intuition.
3. **Determinism**: Frame transformations are exact (or numerically stable), ensuring all clients compute the same results.

## Integrators and Physics Models

Each dimension type uses a physics integrator tuned for its scale and fidelity requirements:

### Interstellar Dimensions

- **Integrator**: Low-order symplectic integrator (e.g., leapfrog) with very large time-steps.
- **Physics**: Approximate galactic dynamics; stars treated as point masses.
- **Time-step**: Seconds to minutes per tick.

Interstellar dimensions provide context but rarely need high-fidelity simulation.

### Interplanetary Dimensions

- **Integrator**: N-body gravitational integrator (e.g., Verlet, RK4, or adaptive methods).
- **Physics**: Point-mass gravity, solar radiation pressure, simplified drag.
- **Time-step**: 1–10 seconds per tick.

Interplanetary dimensions handle transfer orbits, convoy movement, and long-duration burns.

### Orbit Dimensions

- **Integrator**: High-order symplectic or semi-implicit integrator for rigid-body dynamics in gravity wells.
- **Physics**: Gravity, atmospheric drag (altitude-dependent), collision detection, docking forces.
- **Time-step**: 0.05–0.1 seconds per tick (20–50 Hz).

Orbit dimensions are the "KSP layer"—detailed orbital mechanics with docking, rendezvous, and debris simulation.

### Surface Dimensions

- **Integrator**: Rigid-body dynamics with terrain collisions, friction, and atmospheric effects.
- **Physics**: Full 6-DOF (six degrees of freedom) dynamics, terrain interaction, gravity, wind.
- **Time-step**: 0.01–0.05 seconds per tick (20–100 Hz).

Surface dimensions handle landed ships, rovers, walking players, and surface construction.

### Interior Dimensions

- **Integrator**: High-fidelity rigid-body and constraint-based dynamics (e.g., impulse-based collision response).
- **Physics**: Detailed collisions, joint constraints, machinery, player movement, local forces.
- **Time-step**: 0.005–0.02 seconds per tick (50–200 Hz).

Interior dimensions are the most detailed, simulating individual objects, machinery, and player interactions inside ships and stations.

### Key Insight: Same State, Different Evolution Rules

All integrators operate on the same **phase state representation**. The differences lie in:

- Which forces and constraints are applied.
- How large the time-step is.
- How much computational effort is spent on precision.

When an entity transitions between dimensions, its phase state is preserved exactly—only the evolution rules change.

## The Handoff Protocol

Transitioning an entity between dimensions is called a **handoff**. The handoff protocol ensures that:

- Physical state is preserved (no energy/momentum gain or loss).
- Determinism is maintained (all clients compute the same result).
- Context-specific rules are respected (e.g., Fold pocket entry/exit logic).

### Handoff Steps

1. **State Extraction**: Compute the entity's phase state in the source dimension at the transition moment.
2. **Coordinate Transformation**: Apply a **symplectic transformation** to express the state in the target dimension's chart.
3. **Entity Migration**: Remove the entity from the source dimension's entity set; spawn it in the target dimension.
4. **Context Hooks**: Invoke any Context-specific logic (e.g., aperture state changes, Kernel events).
5. **Synchronization**: Broadcast the handoff event to all clients in multiplayer.

### Symplectic Transformations

A transformation is **symplectic** if it preserves the phase-space volume element (roughly, the "amount of state space"). Symplectic transformations:

- Conserve energy (up to numerical error).
- Preserve momentum and angular momentum.
- Maintain long-term numerical stability.

Handoffs use symplectic transformations to ensure that transitions don't introduce artificial energy or drift. This is critical for determinism: if two clients apply the same transformation to the same state, they get **exactly** the same result.

### Example: Ship Entering Orbit

A ship in an Interplanetary dimension approaches a planet and transitions to an Orbit dimension:

1. **State in Interplanetary chart**: `r_IP = (x, y, z)` relative to star barycenter, `p_IP = m * v`.
2. **Transformation**: Subtract planet's position and velocity to get planet-centric coordinates:
   - `r_Orbit = r_IP - r_planet`
   - `p_Orbit = p_IP - m * v_planet`
3. **Spawn in Orbit dimension**: Ship appears with `(r_Orbit, p_Orbit, q, L)`.

The transformation is exact (no approximation), ensuring the ship's trajectory is continuous across the boundary.

## Why This Architecture Ensures Deterministic Multiplayer

Multiplayer in Phase Space uses **lockstep synchronization**: all clients simulate the same ticks with the same inputs, producing identical results. The phase-space architecture supports this by:

### 1. Unified State Representation

All entities use the same phase state format. There is no ambiguity about what "position" or "momentum" means—it's always defined relative to a known reference frame and chart.

### 2. Deterministic Integrators

Symplectic and fixed time-step integrators produce bit-identical results across platforms (assuming IEEE 754 floating-point compliance and identical initial conditions).

### 3. Deterministic Handoffs

Coordinate transformations are exact mathematical operations. Given the same input state, all clients compute the same output state.

### 4. No Hidden State

All simulation-relevant information is encoded in the phase state. There are no hidden timers, random seeds, or external dependencies that could cause divergence.

### 5. Context Isolation

Contexts extend the phase state but must follow deterministic rules. The engine enforces that all Context hooks are pure functions or explicitly managed by the Core simulation loop.

### 6. Checksum Verification

After each tick (or batch of ticks), clients can compute a checksum of the phase state for all entities. Mismatches indicate a desync, which can be debugged via deterministic replay.

This architecture makes multiplayer debugging tractable: if a desync occurs, developers can replay the exact sequence of inputs and identify which transformation or integrator produced divergent results.

## Unifying Orbital, Surface, Interior, and Transition Logic

Traditional space games often treat orbital mechanics, surface physics, and interior physics as separate systems with ad-hoc transitions. Phase Space unifies them under a single conceptual model:

### Orbital Mechanics

Orbital mechanics is just phase-space evolution under gravitational forces in an inertial or near-inertial frame. The Orbit and Interplanetary dimensions use the same phase state; they differ only in:

- Which gravitational bodies are included (full N-body vs. simplified 2-body).
- Timestep size (finer in Orbit, coarser in Interplanetary).

### Surface Physics

Surface physics uses the same rigid-body phase state, but:

- The coordinate frame rotates with the planet (introducing fictitious forces).
- Terrain collision constraints are active.
- Atmospheric drag and gravity are altitude-dependent.

A ship on the surface is not "in a different physics mode"—it's in the same phase space, viewed from a rotating frame with different constraints active.

### Interior Physics

Interior physics operates on phase states of objects inside a ship or station. The reference frame is **attached to the container entity**, moving and rotating with it. Interior entities experience:

- Accelerations from the container's motion (artificial gravity from thrust, centrifugal effects from spin).
- Collisions with interior walls and objects.
- Local forces from machinery (airlocks, elevators, etc.).

Again, the phase state is identical; the frame and constraints differ.

### Transitions

Transitions are coordinate transformations plus constraint set changes:

- **Orbit to Surface**: Change from inertial to rotating frame; activate terrain constraints.
- **Surface to Interior**: Change from planet-surface frame to ship-local frame; activate interior collision geometry.
- **Orbit to Interplanetary**: Change from planet-centric to barycentric frame; simplify gravitational model.

All transitions preserve energy and momentum because they are symplectic transformations on the same phase space.

## Summary: Why Phase-Space Architecture Simplifies Engine Development

The phase-space architecture provides several key benefits:

### Conceptual Unity

Developers reason about one state model, not five separate physics modes. Orbital, surface, and interior physics are all instances of the same underlying framework.

### Numerical Stability

Symplectic integrators and coordinate transformations preserve energy and phase-space structure, reducing drift and numerical artifacts over long simulations.

### Determinism by Design

Fixed time-steps, deterministic integrators, and exact transformations ensure that all clients compute identical results, making lockstep multiplayer tractable.

### Extensibility

Contexts can extend the phase state with new degrees of freedom (e.g., Foldstone charge, wormhole anchors) without breaking the core architecture. The engine handles bookkeeping; Contexts provide the physics.

### Debugging and Verification

Because all state is explicit and all updates are deterministic, desyncs can be reproduced, diagnosed, and fixed systematically. Deterministic replay and checksum verification are built into the model.

### Multiscale Flexibility

By treating dimensions as charts on the same phase space, the engine can seamlessly simulate interactions spanning 10+ orders of magnitude in scale (from millimeter-level interior physics to light-year-scale interstellar motion).

## Looking Forward

The phase-space architecture is the conceptual backbone of Phase Space. All other engine systems—dimensions, scheduling, multiplayer, scripting, Contexts—are built on top of this foundation. Understanding phase space is essential for:

- **Implementing new dimension types** (e.g., anomaly dimensions, subsurface strata).
- **Designing Context-specific physics** (e.g., Fold pocket time dilation, wormhole traversal).
- **Debugging multiplayer desyncs** (tracking state divergence through phase-space evolution).
- **Optimizing simulation performance** (choosing appropriate integrators and time-steps per dimension).

As the engine evolves, this conceptual model will remain stable, even as specific integrators, dimension types, and Contexts change. The phase-space architecture is not just a design decision—it's the **unifying principle** that makes Phase Space's multiscale, deterministic, multiplayer-safe simulation possible.

## Gravity Models

### Gravity Model Overview

The engine uses the `GravityModel` abstraction to define how gravity behaves in different dimensions. This modular approach allows dimensions to select the most appropriate gravity model for their needs, balancing accuracy and performance.

### Built-in Gravity Models

The following gravity models are available out of the box:

- **Constant Field**: A uniform gravitational field, useful for simple simulations or interiors.
- **Point-Mass N-Body**: Models gravitational interactions between multiple bodies, suitable for interplanetary and orbital dynamics.
- **Patched Conics**: Simplifies N-body problems into a series of two-body problems, commonly used for on-rails orbits in interplanetary transfers.

### Extending Gravity

Contexts can register custom gravity models to tailor gravitational behavior for specific dimensions. While the engine does not yet expose a detailed API, the conceptual pipeline involves:

1. Defining a new `GravityModel` implementation.
2. Registering the model with the engine's gravity registry.
3. Assigning the custom model to a dimension during its initialization.

This extensibility ensures that modders and advanced users can adapt gravity to unique gameplay or simulation requirements.
