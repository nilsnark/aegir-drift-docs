# Simulation Scheduling

Each dimension has:

- A **dimension type** (interior, local, orbital, etc.).
- A **tick rate** (target Hz).
- A **time scale** (multiplier on real/engine time).
- A **priority** (used when CPU is constrained).

The scheduler in Phase Space Core:

1. Computes how much engine time has elapsed since the last frame.
2. For each dimension:
   - Accumulates time into a local accumulator.
   - Advances that dimension in fixed time steps (e.g., `dt = 1 / tick_rate`) until it has caught up.
3. Ensures deterministic stepping by using fixed dt per dimension, regardless of real-time jitter.

## Scheduler Object Per Dimension

Each dimension is managed by a scheduler object with the following fields:

- **Target Hz**: The desired tick rate for the dimension.
- **Max Work Per Tick (Budget)**: The maximum amount of work the scheduler allows per tick.
- **Paused Flag**: Indicates whether the dimension is currently paused.
- **Priority**: Determines the dimension's scheduling priority when CPU resources are limited.

## Pausing Dimensions

Dimensions can be paused by toggling the `paused` flag in the scheduler. This approach replaces the older method of setting `time_scale = 0` to pause, ensuring clearer and more consistent behavior. When a dimension is paused, its scheduler stops advancing time steps until it is resumed.

## Usage Examples

### Example 1: Pocket Dimensions

Pocket dimensions are typically paused when sealed and only run when a ship or entity is "inside." This behavior is controlled by toggling the `paused` flag in the scheduler.

### Example 2: Debug or Cinematic Mode

In debug or cinematic modes, the Surface dimension can be temporarily paused while the Orbit dimension continues running. This allows for focused debugging or specific visual effects.

## Cross-Reference: Default Dimension Tick Rates

For a detailed table of default tick rates for each dimension type, see the [Default Dimension Tick Rates](../deterministic-simulation.md#default-dimension-tick-rates) section in the Deterministic Simulation documentation.
