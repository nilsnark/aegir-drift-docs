# Simulation overview & deterministic tick model

## Lockstep multiplayer guarantee

- Scope: Phase Space simulates the universe at multiple nested scales (Ship Interiors → Planetary Surfaces → Low Orbit → High Orbit → Interplanetary Space → Interstellar Space). Each scale is modeled as a separate "dimension" with its own spatial resolution and simulation time-step.
- Physics: By default, physics are Newtonian; Contexts can extend or replace the model. Relativistic effects are modeled where relevant (very high velocity or deep gravity wells).
- Determinism / Tick model: the engine runs deterministically so each dimension advances in fixed ticks. Key implications:
  - Simulation state advances in fixed ticks per-dimension (a fixed timestep per dimension).
  - Systems update state at tick boundaries in a repeatable, stable order.
  - Transitions between dimensions are deterministic (objects move between layers without non-deterministic side effects).
  - Determinism enables lockstep multiplayer.

> Note: `simulation-overview.md` contains the canonical brief description; this page summarizes the behavioral guarantees and practical constraints needed for multiplayer.

## Core constraints required for reliable lockstep

### Deterministic updates

- Stable system execution order each tick.

- No timing-dependent or race-prone logic inside a tick.

### Deterministic numeric behavior

- Use a deterministic math model across platforms (fixed-point arithmetic or carefully controlled floating-point rules).

- Deterministic RNG seeded per-tick; avoid global nondeterministic RNG usage.

### Fixed, synchronized tick schedule

- Tick durations are fixed and agreed on per-dimension.

- Inputs are associated with specific tick indices; clients must not advance past tick N without inputs for N (or must use prediction + rollback).

### No nondeterministic side-effects during simulation ticks

- Avoid reading system time, performing I/O, or invoking OS-dependent behavior that affects simulation state.

### Version and code parity

- All clients must run identical simulation code and deterministic data formats.

### Bounded per-tick execution

- Per-tick computation should be bounded to prevent desyncs from slow clients. Multiplayer policy should define handling for slow or offline clients.

### Input delivery and recovery

- Reliable delivery of per-tick inputs, with buffering, prediction, and authoritative correction strategies for dropped/late inputs.

### Debugging & verification

- Per-tick checksums/hashes of world state for divergence detection and deterministic replays to reproduce desyncs.

## Related engine pages

- Systems (ECS / systems): `ecs.md`
- Dimensions: `dimensions.md`
- Multiplayer (networking & lockstep details): `multiplayer.md`
