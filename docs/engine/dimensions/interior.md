# Interior Dimension

## Overview

The **Interior dimension** represents enclosed spaces inside ships, stations, structures, and pocket dimensions. This is the most detailed simulation layer, handling player movement, machinery operation, object interactions, and all physics at human scale. Interior dimensions provide the immediate, tangible gameplay experience where players walk, interact with controls, manipulate objects, and experience the effects of the containing entity's motion.

Entities in this dimension include:

- Walking or floating players
- Interior objects (crates, furniture, equipment)
- Machinery and interactive systems (doors, lifts, conveyors)
- Debris and loose items
- NPCs and creatures
- Fold pocket contents (in Fold Context)

The Interior dimension uses the highest fidelity physics, with fine time-steps and detailed collision detection. It operates in a **co-moving reference frame** attached to the containing entity (ship, station, or pocket), so interior physics appear stable from the player's perspective even as the container rotates or accelerates through space.

## Phase Coordinates

In the Interior dimension, entities are expressed using phase coordinates in the container's local frame:

### Primary Coordinates

- **Position (`r`)**: 3D coordinates relative to the container's origin (e.g., ship center of mass or a defined interior origin), measured in meters or centimeters
- **Linear Momentum (`p`)**: Mass times velocity **in the container's co-moving frame**, encoding translational motion relative to the interior
- **Orientation (`q`)**: Quaternion describing the entity's attitude (important for player perspective, object orientation, and equipment alignment)
- **Angular Momentum (`L`)**: Rotational momentum in the co-moving frame, governing spin dynamics

### Canonical Coordinates

Interior-specific coordinate systems may include:

- **Room-Relative Coordinates**: Position expressed relative to a specific room or compartment origin
- **Grid Coordinates**: Snapped to a construction grid for modular ship/station building
- **Surface-Relative Coordinates**: Position and orientation relative to a nearby surface (floor, wall, ceiling) for gravity-aligned gameplay

The integrator operates on Cartesian coordinates in the container's frame, but alternative representations are used for gameplay logic, UI, and procedural placement.

### Scale and Precision

Interior positions span 10⁻²–10² meters (centimeters to tens of meters). Precision requirements are at the centimeter or millimeter level for accurate collision detection, player movement, and object manipulation. The engine uses double-precision floating-point within the local frame, avoiding the precision loss that would occur if positions were expressed in planet-scale or system-scale coordinates.

## Reference Frame

The Interior dimension operates in a **Container-Attached Co-Moving Frame**:

- **Origin**: The container entity's center of mass or a defined interior origin point
- **Orientation**: Rotates and translates with the container entity as it moves through space
- **Type**: Non-inertial (accelerating and rotating with the container)

### Relationship to Parent Frames

The Container-Attached Frame is nested within the parent dimension's frame (Orbit, Surface, or even another Interior if nested):

- **Parent Frame (Orbit/Surface)**: The container's frame moves through the parent dimension. Transforming to the parent frame requires applying the container's position, velocity, and rotational state.
- **Child Frames (Nested Interiors)**: Interior dimensions can nest (e.g., a small vehicle inside a ship interior). Each nested level has its own co-moving frame.

### Fictitious Forces

Because the Interior frame is non-inertial, fictitious forces appear:

- **Acceleration Forces**: If the container accelerates (thrust, braking, maneuvering), interior entities experience a force `F_acc = -m * a_container` (e.g., artificial gravity from ship thrust)
- **Centrifugal Force**: If the container rotates (spin gravity, tumbling), interior entities experience `F_cf = -m * ω × (ω × r)` (outward force, used for spin gravity)
- **Coriolis Force**: Moving entities in a rotating container experience `F_cor = -2m * ω × v` (deflection perpendicular to velocity)
- **Euler Force**: If the container's rotation rate changes, entities experience `F_euler = -m * α × r` (tangential force due to angular acceleration)

These fictitious forces create the experience of "artificial gravity" and other dynamic effects that players feel inside ships and stations.

## Physics Model / Integrator

The Interior dimension uses the highest-fidelity physics model in the engine:

### Integrator

- **Type**: High-fidelity rigid-body and constraint-based dynamics integrator (e.g., impulse-based collision response, iterative constraint solver)
- **Time-step**: 0.005–0.02 seconds of simulation time per tick (50–200 steps per second)
- **Tick Rate**: 50–200 Hz (fifty to two hundred updates per second)

### Physics Model

The Interior integrator simulates:

- **Gravity**: Gravitational forces from the container's location (planet, moon) plus artificial gravity from container acceleration/rotation
- **Collisions**: Detailed collision detection between entities and interior geometry (walls, floors, ceilings, objects)
- **Friction**: Static and kinetic friction for realistic sliding, rolling, and stopping behavior
- **Joint Constraints**: Hinges, sliders, springs, and other mechanical joints for doors, lifts, machinery
- **Contact Forces**: Forces from player interactions (pushing, pulling, grabbing)
- **Atmospheric Effects**: Air drag for moving objects (if the interior is pressurized), buoyancy in fluid-filled compartments
- **Damage and Breakage**: Structural damage, component failure (system-dependent)

### Simplifications

At the interior scale, the following simplifications may apply:

- **Rigid-Body Approximation**: Most objects are rigid bodies; soft-body or cloth simulation is limited to specific cases
- **No Terrain**: Collision geometry is based on interior structure meshes, not large-scale terrain
- **Local Scope**: Long-range forces (gravitational attraction between interior objects) are negligible and ignored

### When This Physics Model Applies

The Interior integrator runs when:

- Entities (players, objects) are inside the container's interior volume
- The container is active (not deactivated or paused)
- Player or NPC interaction is occurring

## Handoff Behavior

Entities transition between Interior and adjacent dimensions based on entry/exit points and containment logic.

### Transition Into Interior

An entity enters the Interior dimension from:

- **Orbit or Surface Dimension**: When it passes through an entry point (airlock, door, cargo bay) into the container
- **Another Interior Dimension**: When it moves from one container to another (e.g., docking two ships and transitioning between their interiors)

**Handoff Process (from Orbit/Surface)**:

1. Extract the entity's phase state in the parent dimension's frame: `(r_parent, p_parent, q, L)`
2. Compute the container's phase state in the parent frame: `(r_container, p_container, q_container, L_container)`
3. Transform to the container's co-moving frame:
   - `r_interior = R_container^T * (r_parent - r_container)` (rotate from parent to container frame, translate to container origin)
   - `v_interior = R_container^T * (v_parent - v_container - ω_container × (r_parent - r_container))`
   - `p_interior = m * v_interior`
   - `q_interior = q_container^T * q` (relative orientation)
4. Spawn the entity in the Interior dimension with the transformed state

**Handoff Process (from Another Interior)**:

1. Extract the entity's phase state in the source interior frame
2. Transform to the parent frame, then to the target interior frame using the same procedure
3. Spawn the entity in the target Interior dimension

### Transition Out of Interior

An entity exits the Interior dimension when:

- **To Orbit/Surface**: It passes through an exit point (airlock, door) to the parent dimension
- **To Another Interior**: It moves from one container's interior to another

**Handoff Process (to Orbit/Surface)**:

1. Extract the entity's phase state in the interior frame: `(r_interior, p_interior, q_interior, L)`
2. Compute the container's phase state in the parent frame: `(r_container, p_container, q_container, L_container)`
3. Transform to the parent frame:
   - `r_parent = r_container + R_container * r_interior` (rotate and translate from interior to parent)
   - `v_parent = v_container + ω_container × (R_container * r_interior) + R_container * v_interior`
   - `p_parent = m * v_parent`
   - `q_parent = q_container * q_interior` (compose orientations)
4. Spawn the entity in the parent dimension (Orbit/Surface) with the transformed state

### Transition Thresholds

Typical thresholds for Interior dimension transitions:

- **Entry**: Crossing an entry point (airlock, door) from outside to inside
- **Exit**: Crossing an exit point from inside to outside
- **Proximity**: Some systems may use proximity-based transitions (e.g., teleportation pads, Fold portals)

## Invariants Preserved

Handoffs to and from the Interior dimension preserve the following physical quantities:

### Momentum Conservation

- **Linear Momentum**: When transforming between the parent frame and the container's co-moving frame, the entity's absolute momentum (in the parent inertial frame) is conserved. The momentum in the interior frame accounts for the container's motion.
- **Angular Momentum**: Spin state (`L`) is preserved in the absolute sense. When expressed in the interior frame, it accounts for the container's rotation.

### Energy Consistency

- **Kinetic Energy**: The entity's total kinetic energy (translational + rotational) is conserved in the parent inertial frame. In the interior frame, energy appears to change due to the container's acceleration/rotation, but this is accounted for by fictitious force work.
- **Potential Energy**: Gravitational and other potential energies are consistently tracked. The effective gravity in the interior frame (real gravity + fictitious forces) is accounted for.

### Mass Conservation

- **Mass Invariance**: The entity's mass (`m`) is unchanged during handoff
- **Internal State**: All internal properties (health, equipment, inventory, etc.) are preserved

### Frame-Invariant Quantities

- **Proper Time**: For entities with custom time scaling (e.g., players inside Fold pockets with time dilation), proper time is tracked consistently across dimension boundaries
- **Orientation**: The entity's absolute orientation (in the parent frame) is preserved. The relative orientation in the interior frame is computed correctly.

### No Artificial Forces

Coordinate transformations between the parent frame and the container's co-moving frame are purely kinematic. The fictitious forces (centrifugal, Coriolis, Euler, acceleration) that appear in the interior frame are mathematically consistent and derived from the container's motion. No arbitrary forces are introduced during the handoff. The entity's absolute trajectory (in the parent frame) is continuous across the boundary; only the coordinate description changes.

## Summary

The Interior dimension is the most detailed and immersive layer of the Phase Space engine's multiscale architecture. It provides human-scale physics in a co-moving reference frame attached to ships, stations, or pocket dimensions, allowing players to walk, interact, and experience the effects of their container's motion as artificial gravity and dynamic forces. Using a high-fidelity rigid-body integrator with fine time-steps, this dimension simulates collisions, friction, constraints, and machinery with precision suitable for direct player interaction. Transitions from Orbit or Surface dimensions involve complex frame transformations that account for the container's position, velocity, orientation, and rotation, introducing fictitious forces that create the sensation of acceleration and spin gravity. All handoffs preserve momentum, energy, and mass through symplectic transformations, ensuring that entering or exiting a ship's interior is seamless and deterministic. The Interior dimension completes the engine's multiscale framework, connecting the cosmic scales of interstellar motion to the tangible, walkable spaces where gameplay happens.
