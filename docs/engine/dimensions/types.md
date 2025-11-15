# Dimension Types

The baseline engine defines several canonical dimension types. Contexts can extend this set.

## Interior Dimensions

- **Scale:** Ship interiors, small stations, enclosed spaces.
- **Physics:** Full rigid-body physics, collisions, detailed interactions.
- **Use Cases:** Player movement, ship rooms, machinery, local effects.
- **Tick Rate:** High (e.g., 50–200 Hz), prioritized when players are present.

Interior dimensions often sit “inside” a local or orbital dimension; they share overall reference frame but use their own local coordinates.

## Local Dimensions

- **Scale:** Planet surfaces, station exteriors, ground bases.
- **Physics:** Gravity, terrain interaction, atmosphere, local rigid-bodies.
- **Use Cases:** Landed ships, rovers, bases, surface construction.
- **Tick Rate:** Medium–high depending on activity.

Local dimensions may be tiled or streamed internally, but from the engine’s perspective they are a single coherent dimension per surface region.

## Orbital Dimensions

- **Scale:** Low orbit around a planet or station.
- **Physics:** rigid-body motion in a gravity well, simplified atmosphere drag, docking.
- **Use Cases:** Orbital maneuvers, rendezvous, docking, debris fields.
- **Tick Rate:** Medium (e.g., 20–60 Hz), good balance between accuracy and cost.

Orbital dimensions serve as the “KSP layer” for near-body navigation.

## Interplanetary Dimensions

- **Scale:** Space between planets in a star system.
- **Physics:** Coarser orbital mechanics; ships and bodies treated as point masses or simplified rigid-bodies.
- **Use Cases:** Transfer orbits, long burns, convoy movement.
- **Tick Rate:** Lower (e.g., 1–10 Hz), often with larger time-steps.

These dimensions track large-scale motion without simulating fine-grained collisions.

## Interstellar Dimensions

- **Scale:** Motion of stars and star systems within a galaxy, or between systems.
- **Physics:** Approximate orbits around the galactic center, very large time-steps, mostly for positional context.
- **Use Cases:** Strategic view, seedship trajectories, wormhole network layout.
- **Tick Rate:** Very low (seconds to minutes per tick), can be paused when not needed.

Interstellar dimensions provide the big-picture structure the rest of the sim sits inside.

## Custom Dimensions via Contexts

Contexts may define new dimension types with their own:

- physics integrators
- coordinate systems
- time scales
- entry/exit rules
- tick rates
- invariants
- interaction boundaries

Examples:

- **Fold Pocket Dimensions** (Fold Context):
  - Isolated interiors anchored to Foldstones.
  - Custom time scaling rules (e.g., paused when no aperture is open).
  - Unique physics or resource rules.
- **Anomaly Dimensions** (future Context):
  - Non-Euclidean spaces, distorted navigation.
  - Event-specific rules (e.g., scripted encounters).
- Virtual dimensions
- Chrono-layers
- Subsurface strata
- Quantum computational realms

The engine treats all dimensions as first-class peers.

Aegir-Core remains responsible for scheduling and determinism; Contexts provide the rules and content that give each dimension its character.
