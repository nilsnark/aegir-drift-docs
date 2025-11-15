# Dimension System

A **dimension** in Aegir-Core is a self-contained simulation space with its own:

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