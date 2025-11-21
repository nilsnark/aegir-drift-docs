# Deterministic Simulation & Phase-State Evolution

## Overview

The Phase Space engine is built on a foundation of **deterministic simulation**: given identical initial conditions and identical inputs, every client must produce exactly the same simulation results at every timestep. This is not merely a nice-to-have property—it is a fundamental architectural requirement that enables the engine's multiplayer model, replay systems, and debugging tools.

This page explains what deterministic simulation means in the context of this engine, why it is necessary, how the phase-space architecture enables it, and what rules the simulation must follow to maintain determinism across multiple physics scales and networked clients.

## Why Deterministic Simulation?

Deterministic simulation is essential for three core engine capabilities:

### Multiplayer Synchronization

Phase Space uses **lockstep synchronization**: instead of transmitting full state data, clients exchange only player inputs and compute identical simulation results locally. This approach:

- Minimizes network bandwidth (inputs are orders of magnitude smaller than full state).
- Eliminates the need for state interpolation or reconciliation.
- Ensures all clients see exactly the same universe at the same logical time.
- Makes cheat detection straightforward (divergent results indicate tampering or bugs).

Without determinism, lockstep multiplayer is impossible.

### Rollback and Re-simulation

When network delays or packet loss occur, clients must be able to **roll back** to a previous state and **re-simulate** forward with corrected inputs. Rollback requires:

- Storing past states at known ticks.
- Re-running the simulation from a saved state with updated inputs.
- Producing results that match what the server or other clients computed.

If simulation is non-deterministic, rollback produces divergent timelines, causing permanent desyncs.

### Deterministic Replay and Debugging

Deterministic simulation enables **replay systems** that can faithfully reproduce any gameplay session:

- Store initial conditions and the sequence of player inputs.
- Re-run the simulation to reproduce the exact sequence of events.
- Debug issues by stepping through the replay frame-by-frame.
- Analyze trajectories, collisions, and transitions with perfect fidelity.

Replay is invaluable for debugging, testing, and post-match analysis. It also enables potential future features like time-lapse visualization, phase-space trajectory plotting, and automated testing of physics correctness.

## The Canonical PhaseState

Every physical entity in the engine—ships, planets, asteroids, interior objects, players—is represented by a **canonical PhaseState** that fully describes its physical configuration at a given moment. The PhaseState is the engine's fundamental unit of simulation state.

### PhaseState Components

A canonical PhaseState includes:

#### Position and Momentum

- **Position** (`r`): 3D spatial coordinates relative to the entity's current reference frame.
- **Linear Momentum** (`p`): Mass times velocity, encoding translational motion.

Using momentum instead of velocity is crucial for numerical stability and determinism. Momentum-based representations:

- Enable symplectic integrators that preserve energy and phase-space structure.
- Simplify collision response via impulse calculations.
- Avoid accumulation of velocity-dependent rounding errors.

#### Orientation and Angular Momentum

- **Orientation** (`q`): A unit quaternion describing the entity's rotational state.
- **Angular Momentum** (`L`): The rotational analog of linear momentum, encoding spin.

Quaternions avoid gimbal lock and singularities, ensuring robust and deterministic orientation updates.

#### Mass Properties

- **Mass** (`m`): Total mass (may evolve due to fuel consumption, cargo transfer, etc.).
- **Inertia Tensor** (`I`): Describes mass distribution, governing rotational dynamics.

Mass properties can change over time, but changes are always computed deterministically from known events (fuel burn, cargo loading, structural damage).

#### Extended State

Contexts and systems may extend the PhaseState with additional degrees of freedom:

- Internal energy (fuel, battery charge, thermal state).
- Structural health (damage, wear, component status).
- Pocket state (Fold aperture configuration, time dilation factor, Kernel state).
- Quantum fields (for anomaly dimensions or exotic physics).

All extended state must obey the same determinism requirements as the canonical state.

### PhaseState as the Simulation Contract

The PhaseState is the **contract** between dimensions, integrators, and systems:

- All physics operates on PhaseState.
- All transitions preserve PhaseState.
- All network synchronization transmits PhaseState (or deltas).
- All replay stores PhaseState snapshots.

By making PhaseState the canonical representation, the engine ensures that every component speaks the same language and computes consistent results.

## The Simulation Loop

The engine's core simulation loop runs at a **fixed timestep** with a **canonical execution order** to ensure deterministic evolution of all entities across all dimensions.

### High-Level Loop Structure

```
1. Process Player Inputs
   - Read and validate inputs from all clients
   - Apply inputs to controllable entities
   - Queue input-triggered events

2. Update Reference Frames
   - Advance frame positions and orientations
   - Update frame hierarchy relationships
   - Compute frame transformation matrices

3. Dimension-Specific Integration Passes
   For each active dimension (in fixed order):
     a. Apply dimension-specific forces and constraints
     b. Run dimension-appropriate integrator
     c. Update PhaseState for all entities in dimension
     d. Check for dimension transition conditions

4. Process Dimension Transitions
   - Execute handoff protocols for transitioning entities
   - Apply symplectic coordinate transformations
   - Migrate entities between dimensions
   - Invoke Context-specific transition hooks

5. Collision Detection and Response
   - Detect collisions within each dimension
   - Compute impulses and apply corrections
   - Update PhaseState for colliding entities
   - Generate collision events

6. Post-Integration Tasks
   - Process physics events (damage, destruction, spawning)
   - Update derived state (energy, temperature, etc.)
   - Run Context system updates
   - Compute state checksums for multiplayer verification

7. Advance Simulation Time
   - Increment global tick counter
   - Store state snapshot if needed (for rollback)
   - Prepare for next tick
```

### Fixed Timestep

The engine uses a **fixed timestep** for all simulation:

- Each dimension has a defined `dt` (timestep duration).
- Dimensions may run at different frequencies, but each uses a fixed, consistent `dt`.
- No variable or adaptive timesteps are used in core physics (though some integrators may use internal sub-steps with fixed ratios).

Fixed timesteps ensure that:

- All clients advance time in lockstep.
- Integrators produce identical results regardless of frame rate or CPU speed.
- Replay is exact (same inputs + same timestep = same results).

### Canonical System Order

All systems execute in a **fixed, canonical order**:

- Dimensions are processed in a defined sequence (e.g., Interior → Surface → Orbit → Interplanetary → Interstellar).
- Within each dimension, entities are processed in a deterministic order (e.g., sorted by entity ID).
- Events are processed in the order they were queued, with ties broken by a stable rule.

Execution order matters because:

- Concurrent updates with dependencies can produce different results if order varies.
- Floating-point operations are not associative; summing forces in different orders can yield different results.
- Determinism requires that all clients execute systems in exactly the same sequence.

The engine never uses:

- Unordered iteration over hash sets or maps.
- Parallel processing with unsynchronized side effects.
- Time-based or load-based scheduling that could vary between clients.

## Deterministic Integrators

Each dimension uses a physics integrator to evolve PhaseState forward in time. All integrators must be **pure functions** of `(state, dt, forces)` with no process-level nondeterminism.

### Integrator Requirements

To maintain determinism, integrators must:

1. **Produce bit-identical results**: Given the same inputs, produce exactly the same output on all platforms (subject to IEEE 754 floating-point semantics).
2. **Be stateless**: Integrators cannot depend on internal state that persists across ticks (except explicitly managed state in PhaseState itself).
3. **Use fixed timesteps**: No adaptive timestepping or variable substeps based on error estimates.
4. **Avoid nondeterministic operations**: No random number generation without a shared, seeded RNG; no timing measurements; no platform-specific optimizations that change results.

### Symplectic vs. Non-Symplectic Integrators

The engine prefers **symplectic integrators** (e.g., leapfrog, Verlet, Störmer-Verlet) for long-term stability:

- Symplectic integrators preserve phase-space structure (energy, momentum, angular momentum).
- They do not accumulate drift over long simulations.
- They are inherently reversible, which aids debugging and rollback.

Non-symplectic integrators (e.g., Runge-Kutta methods) are used when:

- Higher-order accuracy is needed over short timescales.
- The system is dissipative (drag, friction) and does not conserve energy anyway.
- Stability is less critical than precision (e.g., interior physics with active damping).

### Integrator Selection by Dimension

- **Interstellar**: Low-order symplectic (leapfrog), very large timesteps (seconds to minutes).
- **Interplanetary**: Symplectic N-body integrator (Verlet or higher-order), moderate timesteps (1–10 seconds).
- **Orbit**: High-order symplectic integrator for rigid-body dynamics, fine timesteps (0.05–0.1 seconds).
- **Surface**: Rigid-body integrator with constraint resolution, fine timesteps (0.01–0.05 seconds).
- **Interior**: High-fidelity constraint-based integrator (impulse-based collision response), very fine timesteps (0.005–0.02 seconds).

Each integrator is chosen to balance accuracy, stability, and performance for its scale, but all must satisfy the determinism requirements.

## Reference-Frame Graph and Coordinate Conversions

The engine organizes reference frames into a **hierarchical graph** spanning multiple scales:

```
Galactic Frame (inertial, galactic center origin)
  ├─ System Frames (inertial, star barycenter origin)
  │   ├─ Planet Inertial Frames (inertial, planet center origin)
  │   │   ├─ Planet Surface Frames (rotating with planet)
  │   │   │   └─ Interior Frames (attached to ships/stations)
  │   │   └─ Orbital Frames (planet-centric, inertial or Keplerian)
  │   └─ Interplanetary Frame (barycentric, system-wide)
  └─ Interstellar Frame (galactic, between stars)
```

### Deterministic Coordinate Conversions

Converting PhaseState between frames is a **deterministic coordinate transformation**:

1. **Compute the transformation matrix** from the source frame to the target frame at the current tick.
2. **Transform position**: `r_target = R * (r_source - r_frame_origin)`, where `R` is a rotation matrix.
3. **Transform momentum**: `p_target = R * (p_source - m * v_frame)`, accounting for the frame's velocity.
4. **Transform orientation**: `q_target = q_frame^(-1) * q_source` (quaternion multiplication).
5. **Transform angular momentum**: `L_target = R * L_source`.

These transformations are exact (up to floating-point precision) and produce identical results on all clients. The reference-frame graph ensures that:

- Every entity's PhaseState is always expressed relative to a known, well-defined frame.
- Conversions between frames are well-defined and unambiguous.
- Clients can independently compute transformations and arrive at the same results.

### Numerical Precision and Frame Hierarchy

Using a frame hierarchy improves numerical precision:

- Large absolute coordinates (e.g., light-years from galactic center) cause floating-point precision loss.
- By expressing positions relative to local frames, coordinates remain small and precise.
- Frame transformations compose: `r_global = T_A * T_B * r_local`, where each `T` is a local transformation.

This design ensures that:

- Precision is maintained even over interstellar distances.
- Determinism is preserved because transformations are exact and associative (up to rounding).

## Dimension Transitions as Coordinate Transforms

Transitioning an entity between dimensions (e.g., from Orbit to Surface) is a **coordinate transformation** plus a **constraint set change**. Transitions must preserve physical invariants and maintain determinism.

### Handoff Protocol

When an entity transitions from dimension A to dimension B:

1. **State Extraction**: Compute the entity's PhaseState in dimension A's chart at the transition moment.
2. **Coordinate Transformation**: Apply a symplectic transformation to express the PhaseState in dimension B's chart.
3. **Entity Migration**: Remove the entity from dimension A's entity set; spawn it in dimension B.
4. **Context Hooks**: Invoke any Context-specific logic (e.g., Fold pocket entry/exit, aperture state changes).
5. **Synchronization**: Broadcast the handoff event to all clients in multiplayer.

### Symplectic Transformations

A transformation is **symplectic** if it preserves the phase-space volume element (the "amount of state space"). Symplectic transformations:

- Conserve energy (up to numerical error).
- Preserve momentum and angular momentum.
- Maintain long-term numerical stability.

Transitions use symplectic transformations to ensure that:

- No artificial energy is injected or removed.
- Trajectories are continuous across dimension boundaries.
- All clients compute the same post-transition PhaseState.

### Invariants Preserved Across Transitions

The handoff protocol enforces conservation of:

- **Total Energy**: Kinetic + potential energy is preserved (modulo frame-dependent potential changes).
- **Linear Momentum**: Momentum in the global inertial frame is conserved.
- **Angular Momentum**: Angular momentum about the global origin is conserved.
- **Mass**: Mass is unchanged by the transition (unless explicitly consumed by a Context event).

These invariants ensure that transitions do not introduce drift or desynchronization.

### No Teleport Accumulation

Traditional game engines often implement dimension transitions as "teleports" that reposition entities by setting new coordinates. This approach accumulates errors:

- Floating-point rounding in position conversion.
- Loss of momentum information due to imprecise velocity conversion.
- Temporal desync if transitions occur at slightly different times on different clients.

Phase Space avoids this by treating transitions as **exact coordinate transformations**:

- The transformation is computed from well-defined frame relationships.
- No "guessing" or interpolation is involved.
- The result is mathematically correct and deterministic.

## Floating-Point Determinism

Floating-point arithmetic is not perfectly deterministic across all platforms, but the engine employs strategies to minimize divergence:

### Fixed Precision

- All simulation uses IEEE 754 double-precision (64-bit) floating-point.
- No single-precision (32-bit) is used in core physics (though rendering may use it).
- No extended precision (80-bit x87) or compiler-specific optimizations that change precision.

This ensures that:

- All platforms compute with the same bit precision.
- Rounding modes are consistent (IEEE 754 default round-to-nearest).

### Controlled Accumulation

Floating-point errors accumulate over long simulations. The engine mitigates this via:

- **Symplectic integrators**: Preserve structure; errors do not grow unboundedly.
- **Periodic normalization**: Quaternions are re-normalized every tick to prevent drift.
- **Compensated summation**: Kahan summation or similar techniques for large force accumulations.
- **Conservative timesteps**: Smaller `dt` reduces per-tick error, preventing exponential growth.

### Platform Consistency

The engine requires that:

- All clients use the same compiler optimizations (`-O2` or equivalent, with strict IEEE 754 compliance).
- No "fast math" flags that violate IEEE 754 semantics (e.g., `-ffast-math` is disallowed).
- No platform-specific intrinsics that produce different results (e.g., x86 SSE vs. ARM NEON must yield identical results when compiled correctly).

Cross-platform testing ensures that:

- Windows, Linux, and macOS clients produce identical results.
- Different CPU architectures (x86-64, ARM64) remain in sync.

### Integrator Selection and Stability

Some integrators are more sensitive to floating-point error than others:

- **Symplectic integrators**: Relatively robust to rounding error; energy oscillates but does not drift.
- **Runge-Kutta methods**: More sensitive; accumulated errors can cause divergence over long runs.
- **Constraint-based methods**: May diverge if constraint resolution is not deterministic (order of constraints matters).

The engine uses symplectic methods wherever possible and carefully validates other integrators for determinism across platforms.

## Deterministic Network Model

Phase Space multiplayer relies on **lockstep synchronization** with **rollback and re-simulation** for handling network delays and packet loss.

### Lockstep Evolution

In lockstep mode:

- All clients advance the simulation in sync, tick-by-tick.
- Each tick, clients exchange player inputs.
- Clients simulate the same tick with the same inputs, producing identical results.
- No client advances until all inputs for the current tick are received (or predicted).

Lockstep ensures:

- All clients see the same universe state at the same logical time.
- Desyncs are immediately detectable (state checksums diverge).
- Bandwidth is minimal (only inputs are transmitted, not full state).

### Rollback and Re-simulation

When a client receives delayed inputs or detects a misprediction:

1. **Rollback**: Restore the simulation state to a previous tick (before the misprediction).
2. **Re-simulate**: Replay ticks forward with corrected inputs.
3. **Verify**: Compute state checksum and confirm synchronization.

Rollback requires:

- **State snapshots**: Store PhaseState for all entities at regular intervals.
- **Input log**: Record all inputs received, including timing.
- **Deterministic replay**: Re-running the simulation produces exactly the same results.

If the simulation is deterministic, rollback is seamless. If not, rollback creates divergent timelines and permanent desyncs.

### Deterministic State Digests

After each tick (or batch of ticks), clients compute a **deterministic digest** (checksum or hash) of the PhaseState for all entities:

- The digest is computed in a fixed, canonical order (e.g., sorted by entity ID).
- All PhaseState fields are included (position, momentum, orientation, etc.).
- The digest is transmitted to the server or other clients for verification.

If digests match, clients are synchronized. If they diverge, a desync is detected and rollback is triggered.

### Strict Ordering of Player Input

Player inputs must be processed in a **strict, canonical order**:

- Inputs are timestamped with the tick they apply to.
- Inputs are sorted by player ID (or a globally unique input ID) to break ties.
- Clients process inputs in the same order, ensuring deterministic outcomes.

Unordered processing (e.g., based on network arrival time) causes nondeterminism:

- Player A's input arrives before Player B's on Client 1.
- Player B's input arrives before Player A's on Client 2.
- Clients apply inputs in different orders → divergent results.

Canonical ordering eliminates this issue.

## Rules for Maintaining Determinism

To ensure deterministic simulation, developers must avoid the following in core simulation code:

### Unordered Iteration

- **Never** iterate over hash maps, hash sets, or other unordered containers without sorting.
- Always use ordered containers (e.g., sorted vectors, B-trees) or explicitly sort before iteration.
- Iteration order affects force accumulation, collision detection, and constraint resolution.

### Parallel Side Effects

- **Never** use unsynchronized parallel processing in core physics.
- Read-only parallelism is acceptable, but writes must be synchronized.
- If parallelism is used, results must be combined in a fixed, deterministic order.

### OS Clock and Timing

- **Never** query the system clock (`std::chrono::system_clock`, `gettimeofday`, etc.) in core simulation.
- Use only the simulation's logical tick counter for timing.
- Real-world time is nondeterministic (clients have different clocks, latency, etc.).

### Nondeterministic RNG

- **Never** use unseeded or system-seeded random number generators (e.g., `rand()`, `std::random_device`).
- Always use a deterministic RNG seeded by the simulation state or a shared seed.
- RNG state must be part of PhaseState (or managed by the server and broadcast to clients).

### Physics Depending on Load

- **Never** make physics depend on frame rate, CPU load, or time between frames.
- Use fixed timesteps; ignore wall-clock time.
- Physics must be independent of performance characteristics.

### External Dependencies

- **Never** depend on external state (file timestamps, network responses, user input outside the canonical input system).
- All simulation-relevant information must flow through the deterministic input pipeline.

### Floating-Point Nondeterminism

- **Avoid** fast-math optimizations or non-IEEE 754 arithmetic.
- **Avoid** order-dependent summation without careful control (e.g., use Kahan summation for large force sums).
- **Avoid** platform-specific intrinsics unless verified to produce identical results.

## Debugging and Verification Tools

Deterministic simulation enables powerful debugging tools:

### Deterministic Replay

- Record initial state and input sequence.
- Replay simulation to reproduce any issue.
- Step through frame-by-frame to identify divergence.

### Phase-Space Trajectory Plots

- Visualize entity trajectories in phase space (position vs. momentum).
- Detect unphysical behavior (energy drift, constraint violations).
- Compare replays to identify divergence points.

### State Checksum Comparison

- Compute checksums at every tick.
- Compare checksums across clients to detect desyncs.
- Binary-search the tick range to identify when divergence started.

### Automated Regression Tests

- Create test scenarios with known outcomes.
- Run simulations and verify checksums match expected results.
- Ensure integrators, transitions, and systems remain deterministic after code changes.

These tools are only possible because the engine is deterministic. Nondeterministic engines cannot reliably replay or compare states.

## Summary

Deterministic simulation is the foundation of the Phase Space engine's multiplayer model, replay system, and debugging infrastructure. By representing all entities as canonical PhaseState, using fixed timesteps, enforcing canonical execution order, and applying symplectic coordinate transformations across dimensions, the engine ensures that:

- All clients compute identical results given identical inputs.
- Rollback and re-simulation are seamless and exact.
- Replay faithfully reproduces any gameplay session.
- Dimension transitions preserve energy, momentum, and angular momentum.
- Floating-point behavior is controlled and consistent across platforms.
- Desyncs are detectable, debuggable, and preventable.

Deterministic evolution of PhaseState across multiple charts (dimensions) is not just a technical detail—it is the unifying principle that makes Phase Space's multiscale, multiplayer-safe simulation possible. Without it, the engine's ambitious scope (interstellar to interior, thousands of active dimensions, lockstep multiplayer, deterministic replay) would be intractable.

By adhering to the determinism rules and leveraging the phase-space architecture, developers can build systems, Contexts, and gameplay features with confidence that the simulation will remain consistent, stable, and multiplayer-safe across all scales and scenarios.
