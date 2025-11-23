# Simulation Overview

Phase Space simulates the universe at multiple nested scales:

1. Ship Interiors  
2. Planetary Surfaces  
3. Low Orbit  
4. High Orbit  
5. Interplanetary Space  
6. Interstellar Space  
7. **Pocket Dimensions**  

Each layer is represented as a **dimension** with its own simulation time-step and spatial resolution. Objects transition between layers seamlessly.

Physics is strictly Newtonian unless extended by a Context. Relativistic effects are modeled at high velocities or deep gravity wells.

All simulation runs deterministically, enabling lockstep multiplayer.

**Pocket Dimensions**: These are exotic Fold spaces with unique time-dilation properties. They serve as non-local interiors and are distinct from physical ship/station spaces.

## Cross-Reference: Default Dimension Tick Rates

For a detailed table of default tick rates for each dimension type, see the [Default Dimension Tick Rates](deterministic-simulation.md#default-dimension-tick-rates) section in the Deterministic Simulation documentation.
