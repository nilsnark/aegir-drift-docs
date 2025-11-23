# **World Persistence and Save/Load Logic**

When the simulation shuts down, Aegir-core persists:

## **Simulation Clocks**

```text
engine_tick
engine_dt
last_utc_anchor
```

## **All Dimension Clocks**

For each active dimension:

```text
dimension_id
dimension_tick
dimension_time_scale
dimension_accumulator
```

## **World State**

* full ECS state (components, systems, entity graphs)
* dimension list and hierarchy
* context-specific data
* pending events (timestamped by engine_tick)

## **On Load**

1. Read `last_utc_anchor`.
2. Read the current real-world UTC time.
3. Compute elapsed real time:

    ```text
    delta_real = now_utc - last_utc_anchor
    ```

4. Apply one of the deterministic **catch-up policies** (below).
5. Advance:

   * the global engine tick counter
   * each dimension’s clock
   * the ECS systems
     using standard fixed-time-step advancement.
6. Once engine time has reached the correct UTC-correlated value, the server transitions to real-time ticking.

**No systems ever read UTC directly.**
All systems operate purely on tick-based Engine Time.
