# Dimension System

A **dimension** in Phase Space Core is a self-contained simulation space with its own:

- coordinate system
- physics fidelity
- simulation rate
- entity set

Dimensions are hierarchical and can be nested (e.g., ship interiors inside orbital dimensions, pockets inside ships). They let the engine run different parts of the universe at different levels of detail while preserving a single coherent timeline.

## Dimensions as Reference Frames

Each dimension operates in its own coordinate frame.
Transitioning between dimensions involves coordinate transforms rather than teleportation.

- Ship interior frame moves with the ship
- Local surface frame rotates with the planet
- Orbital frame uses a co-moving elliptical reference
- Interplanetary frame is barycentric
- Interstellar frame is galactic-centric

Dimensions form a hierarchy of nested frames used for stability and numerical precision.

## Dimension Instance Lifecycle

Dimensions in the Phase Space engine are not static layers but dynamic instances managed by a central **DimensionInstanceRegistry**. This section explains their lifecycle:

### Creation

- New dimension instances are created when the engine or a context requires a distinct simulation space.

- Examples include spawning a ship interior or generating a pocket dimension.

### Active vs Paused States

- Dimensions can be active (simulating) or paused (frozen in time).

- The **DimensionInstanceRegistry** tracks the state of each dimension.

### Removal/Destruction

- Dimensions are removed when no longer needed, such as when a ship is destroyed or a pocket collapses.

- The registry ensures proper cleanup of associated entities and resources.

### DimensionInstanceRegistry

The **DimensionInstanceRegistry** is the central manager for dimension instances. It:

- Registers new dimensions and assigns unique identifiers.

- Provides APIs to find and list dimensions.

- Supports multiplayer and contexts by ensuring entities are mapped to the correct dimension.

> **Note:** Multiplayer relies on the registry to synchronize dimension states across clients.

For more details, see the ECS partitioning section in `docs/engine/systems.md`.