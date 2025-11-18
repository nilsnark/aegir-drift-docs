
# **Simulation Time Model**

Aegir Drift uses a layered time model that separates **real-world time**, **engine simulation time**, and **per-dimension local time**. This separation preserves strict determinism while allowing the universe to maintain a coherent, real-time anchored timeline.

## **1. Real Time (UTC Anchor)**

Aegir-core uses **Coordinated Universal Time (UTC)** as the external reference for “what time it is” in the universe. Real-world time continues to advance even when no simulation is running.

Real time is *never* read inside simulation systems. It is only used at engine boundaries:

* when loading a saved world
* when shutting down
* when computing catch-up after downtime
* when presenting time to players (UI, logs, terminals)

## **2. Engine Time (Deterministic Simulation Time)**

Engine Time is the authoritative internal clock of the deterministic simulation:

```text
engine_time = tick_count * dt
```

* `tick_count` is an integer that increments deterministically.
* `dt` is the global fixed timestep (e.g., 1 second per tick).
* All systems run based strictly on `(tick_count, dt)`.

The simulation tick stream is the root of determinism. If two servers start from the same world state and receive the same inputs, they will produce identical simulation histories.

## **3. Dimension Local Time**

Each dimension maintains its own **DimensionClock**, derived from Engine Time but modified by a **time_scale** multiplier:

```text
dt_dimension = dt_engine * time_scale
```

Examples:

* Normal dimension: `time_scale = 1.0`
* Interior pocket dimension in stasis: `time_scale = 0.0`
* Relativistic ship interior: `time_scale = 1 / gamma(v)`
* Fold pocket with accelerated time: `time_scale > 1.0`

Dimensions run their own schedulers, accumulating Engine Time and executing local ticks whenever enough scaled time has accumulated.

This allows:

* ship interiors to advance more slowly at relativistic speeds
* pocket dimensions to freeze or dilate
* planetary surfaces to use different tick frequencies
* stasis to function naturally as a time-scale effect

## **4. Relationship Between UTC and Engine Time**

Aegir Drift never drives the simulation directly from the system clock.
Instead:

* **Engine Time is deterministically advanced by ticks.**
* **UTC acts only as the “external calendar” of the universe.**

When the engine restarts, it determines how much real time has passed and **deterministically catches up** by advancing the tick stream.

This maintains both:

* *physical realism* (“the galaxy ages even if the server was offline”), and
* *simulation determinism* (all advancement is via ticks only).
