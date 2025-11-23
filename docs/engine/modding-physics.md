# Extending Physics and Gravity from a Context

Contexts in the Phase Space engine provide a powerful way to customize and extend the behavior of physics and gravity. This guide offers a high-level overview for modders to understand how to hook into and modify these systems.

## Selecting and Overriding Dimension Physics Profiles

Each dimension in the engine is associated with a `PhysicsProfile`, which defines the integrator, gravity model, and numeric tuning for that dimension. To override or customize a dimension's physics profile:

1. **Identify the Dimension**: Determine which dimension (e.g., Orbit, Surface, Pocket) you want to modify.
2. **Select a Built-in Profile**: Use one of the predefined profiles (e.g., `SemiImplicit`, `PatchedConics`, `OnRails`) as a starting point.
3. **Override the Profile**: Register a custom `PhysicsProfile` for the dimension using the context's configuration pipeline.

## Plugging in a Custom GravityModel

The `GravityModel` abstraction allows you to define how gravity behaves in a dimension. Built-in models include constant gravity, N-body simulations, and patched conics. To create and use a custom gravity model:

1. **Implement the GravityModel Interface**: Define your custom gravity behavior by implementing the required methods.
2. **Register the Model**: Add your custom `GravityModel` to the context's registry.
3. **Assign the Model to a Dimension**: Update the dimension's configuration to use your custom gravity model.

## Tuning Tick Rates and Schedulers for Custom Dimensions

Tick rates and scheduling determine how often a dimension updates and how much computational time it is allocated. To customize these settings:

1. **Adjust Tick Rates**: Modify the default tick rate for the dimension to balance performance and accuracy.
2. **Configure the Scheduler**: Use the `SchedulerTuning` structure to set parameters like maximum work per tick, priority, and whether the dimension is paused.
3. **Test Determinism**: Ensure that your changes maintain deterministic behavior, especially in multiplayer or replay scenarios.

## Linking and Cross-referencing

To ensure modders can easily find this information, this page is linked from:

- [Modding Contexts](modding-contexts.md)
- [Physics Profiles](physics-profiles.md)
- Relevant dimension pages under `docs/engine/dimensions/`

By following this guide, modders can extend and replace physics and gravity in a structured and predictable way, enabling rich and diverse gameplay experiences.