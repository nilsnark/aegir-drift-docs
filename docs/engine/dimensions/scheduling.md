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

Pocket dimensions can use `time_scale = 0` to effectively pause when sealed, or a different scale when opened (subject to Context rules).
