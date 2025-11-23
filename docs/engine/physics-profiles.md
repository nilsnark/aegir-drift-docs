# Physics Profiles in the Engine

## What is a PhysicsProfile?

A `PhysicsProfile` is a conceptual bundle that combines the following elements:

- **Integrator**: The numerical method used to solve equations of motion.
- **Gravity Model**: The model defining gravitational interactions.
- **Numeric Tuning**: Parameters that adjust the behavior of the integrator and gravity model.

PhysicsProfiles are used to define the physical behavior of entities within different dimensions of the engine.

## Built-in Physics Profiles

The engine provides several built-in PhysicsProfiles, each tailored to specific dimension types:

| Dimension Type   | Default PhysicsProfile       | Description                                      |
|------------------|------------------------------|--------------------------------------------------|
| Orbit            | SemiImplicit                 | Rigid-body integrator for orbital mechanics.    |
| Interplanetary   | PatchedConics                | Simplified model for interplanetary transfers.  |
| Interstellar     | OnRails                      | Basic on-rails model for large-scale motion.    |

## Extending Physics Profiles

Contexts can register custom PhysicsProfiles via a registry. This allows modders and developers to:

- Define new integrators or gravity models.
- Adjust numeric tuning for specific gameplay scenarios.

> **Note:** This section provides a high-level overview. Detailed API documentation is available in the engine's developer guide.