# Simulation Overview

Phase Space simulates the universe at multiple nested scales:

1. Ship Interiors  
2. Planetary Surfaces  
3. Low Orbit  
4. High Orbit  
5. Interplanetary Space  
6. Interstellar Space

Each layer is represented as a **dimension** with its own simulation time-step and spatial resolution. Objects transition between layers seamlessly.

Physics is strictly Newtonian unless extended by a Context. Relativistic effects are modeled at high velocities or deep gravity wells.

All simulation runs deterministically, enabling lockstep multiplayer.
