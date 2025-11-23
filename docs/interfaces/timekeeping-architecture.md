# **Galactic Calendar: Mapping Engine Time to In-Universe Time**

Aegir Drift represents all internal simulation time in **real-world seconds**, derived directly from Engine Time (`ticks × dt`). Any in-universe or lore-facing calendar is a **presentation layer** that maps from these real seconds into a format meaningful to players or contexts.

The simulation itself does *not* depend on the Galactic Calendar.

---

## **1. Engine Time as the Universal Reference**

Given:

```text
engine_dt_seconds   // seconds per simulation tick
engine_tick_count   // deterministic tick index
```

Engine Time in seconds is:

```text
engine_seconds = engine_tick_count * engine_dt_seconds
```

This value represents the current “universe time” from the perspective of the simulation.

The Galactic Calendar—if enabled—is a transformation of `engine_seconds`.

---

## **2. Converting Engine Time to Galactic Calendar Time**

A context or UI layer may define a galactic calendar for flavor or world-building. For example:

* 1 Galactic Day = 86,400 seconds
* 1 Galactic Year = 400 Galactic Days
* Epoch starting point = arbitrary reference value in seconds

The mapping becomes:

```text
galactic_seconds = engine_seconds - epoch_offset_seconds

galactic_day      = galactic_seconds / seconds_per_galactic_day
galactic_year     = galactic_day / days_per_galactic_year
```

And the final representation might be:

```text
GY 3124, Day 183
```

or an ISO-like version:

```text
3124-183-GT
```

This entire layer is optional and strictly cosmetic.
Different contexts may define different calendars.

---

## **3. Cross-Dimensional Time Presentation**

Each dimension has its own local time due to `time_scale`:

```text
local_seconds = Σ (engine_dt_seconds * time_scale)
```

This supports:

* **relativistic proper time** inside high-velocity seedships
* **frozen time** in stasis or sealed pockets
* **accelerated time** for certain Fold or simulation contexts

Thus the UI can display:

* **Galactic Time** — anchored to engine_seconds
* **Local Time** — anchored to a dimension’s local_seconds

Example UI:

```text
Galactic Time: GY 4021, Day 112
Local Time (Ship Interior): 17y 141d 03:22
```

Even if the ship experiences heavy time dilation or stasis, Galactic Time continues to advance normally.
