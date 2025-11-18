# **Catch-Up Policies**

Aegir Drift supports multiple deterministic catch-up modes. These are server configuration options or context-driven policies.

## **1. Full Catch-Up (Default for Accuracy)**

The engine simulates every required tick from the saved state to the present UTC-derived engine time.

Good for:

* interstellar travel
* long-duration orbital mechanics
* aging and crop cycles
* research/production queues

Downside: could be expensive after long downtime with many active dimensions.

## **2. Hybrid Catch-Up (Recommended for Large Worlds)**

Aegir-core categories systems into:

* **micro-tick systems** (require per-tick detail: physics, trajectories, life support)
* **macro-tick systems** (can advance in larger steps: economic simulation, AI planning)
* **analytic systems** (can compute results without stepping through each tick)

Hybrid mode:

1. Run analytic systems directly using closed-form solutions.
2. Advance macro systems with coarse increments (e.g., 1 hour or 1 day per step).
3. Use full tick-by-tick simulation only for micro-tick systems near active areas.

This allows extremely large downtime gaps to be simulated deterministically and efficiently.

## **3. Capped Catch-Up (Pragmatic Mode)**

If downtime exceeds a configured threshold (e.g., 7 days):

* The engine advances only N hours/days forward.
* Beyond that, the universe is assumed “inactive” and is clamped at the cap.

This is useful for modded servers or small private sessions.
