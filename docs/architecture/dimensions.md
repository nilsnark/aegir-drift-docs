# Aegir-Core Dimension Hierarchy

This document is the canonical specification for how Aegir-Core organizes simulation scales. It defines the four Core dimension types, their coordinate frames, tick rules, invariants for cross-scale motion, and the extension hooks contexts use to add new frames. All contexts and engine subsystems must conform to these rules.

## Canonical Dimension Types

Aegir-Core recognizes four Core Context dimension types. Contexts may layer custom physics or features on top, but the underlying guarantees remain unchanged.

| Dimension Type | Summary | Primary Use | Default Physics Fidelity |
| --- | --- | --- | --- |
| **Interstellar** | Galaxy-scale inertial frame anchored to the simulation barycenter. | Star-system navigation, interstellar travel, sector-wide events. | Aggregate forces, simplified gravity wells, low-frequency updates. |
| **Interplanetary** | Solar-system or stellar neighborhood frame, centered on the parent system barycenter. | Planetary transfer, fleet maneuvers, dynamic ephemerides. | Full n-body gravity approximation, medium-frequency updates. |
| **Orbital** | Co-moving orbital frame for a single planet, moon, or artificial body. | Satellite operations, near-planet encounters, re-entry preparation. | Two-body dynamics with perturbations, high-frequency updates. |
| **Surface** | Rotating surface frame, aligned to local gravity vector. | Atmospheric flight, ground combat, naval/land operations. | Full rigid-body physics, atmospheric effects, highest-frequency updates. |

**Interior Dimensions.** Interiors (ships, stations, habitats) are always children of a Surface frame. They inherit Surface tick cadence and time base but may define custom local coordinates. Interiors are not Core canonical types; they exist as Context-defined extensions registered beneath a Surface parent.

## Hierarchy & Relationships

```
Interstellar
  └─ Interplanetary (per star system)
       └─ Orbital (per major body)
            └─ Surface (per landing footprint)
                 └─ Interior (context-defined, optional)
```

* Each dimension has exactly one parent except the root Interstellar frame.
* Children inherit their parent's absolute time base and determinism guarantees but may refine tick rate and coordinate precision.
* A child may override properties only if the override is deterministic and reversible when projected into the parent frame. Overrides must be documented in the Dimension Registry entry.
* Depth cannot be skipped: a Surface frame must be descended from an Orbital frame, which must have an Interplanetary parent, etc.

## Coordinate Systems & Precision Rules

| Dimension | Coordinate Basis | Units | Precision Requirements | Stabilization Rules |
| --- | --- | --- | --- | --- |
| Interstellar | Galactic-centric barycentric inertial frame. | Kilometers, seconds. | 64-bit floating or fixed 48.16 fixed-point. Must preserve 1 m precision within ±10⁹ km. | Only apply reversible Kahan-style summation or pairwise barycentric clamping. No irreversible rounding. |
| Interplanetary | System barycentric inertial frame. | Kilometers, seconds. | 64-bit floating; must retain 1 cm precision within ±10⁷ km. | Allowed: reversible drift correction by re-anchoring to barycenter. Disallowed: quantizing velocities. |
| Orbital | Co-moving orbital frame, origin at parent-body center, axes aligned to instantaneous orbital plane. | Meters, seconds. | 64-bit floating or 32.32 fixed; maintain 1 mm precision within ±10⁶ m. | Allowed: periodic frame recentering relative to parent, provided transforms are reversible and logged. |
| Surface | Local tangent plane aligned to gravity (ENU basis) with rotating reference. | Meters, seconds. | 32-bit floating for positions, 64-bit for velocities/accelerations. Maintain 10 µm precision within ±10⁴ m. | Allowed: origin shift once offset >5 km using double-delta technique. Must keep reversible transform history. |

* Transform pairs (`world_to_frame`, `frame_to_world`) must be reversible to machine precision per dimension's requirements.
* Orientation transforms use normalized quaternions; renormalization is allowed as long as the original orientation can be reconstructed (e.g., by storing normalization factor or re-normalizing deterministically).

## Tick Rate & Time-Scale Rules

| Dimension | Required Tick Range | Default Time-Step | Notes |
| --- | --- | --- | --- |
| Interstellar | 0.05–1 Hz | 1 s | May pause entirely if no interstellar events pending. |
| Interplanetary | 0.5–5 Hz | 0.25 s | Must remain active while any child Orbital is active. |
| Orbital | 5–60 Hz | 0.05 s | May subsample parent ticks but must align every 20 parent ticks. |
| Surface | 30–240 Hz | 0.0083 s (120 Hz) | Always active if any entity present. Interiors inherit Surface cadence. |

Rules:

1. All dimensions share the same monotonically increasing simulation time base. Tick steps are subdivisions of that base; no independent clocks.
2. Determinism requires that a child dimension aligns to a parent tick at deterministic boundaries (LCM tick). When ticks do not divide evenly, the child buffers state until the next parent sync point.
3. A paused parent forces all children to pause after flushing outstanding child ticks to the parent at the next sync boundary.
4. Time dilation mechanics must be implemented via context-defined dimensions, not via the Core canonical types.

## Transition & Handoff Invariants

When an entity transitions between dimensions (e.g., Orbital → Surface) the engine must satisfy these invariants:

1. **Momentum Preservation:** Total linear and angular momentum expressed in the parent frame must match the child's entry state within numerical precision.
2. **Orientation Continuity:** The quaternion representing orientation must be continuous; re-normalization is allowed but no discontinuous jumps or gimbal resets.
3. **Position & Velocity Transformation:** `world_to_frame` and `frame_to_world` transforms must be applied sequentially without lossy rounding. Transform history must be available for debugging.
4. **Entity Snapshot:** The entity's full component set is snapshotted at handoff start and restored in the destination frame before tick processing resumes.
5. **Multi-Step Handoff:** Complex transfers (Interstellar → Surface) occur via sequential parent-child transitions. Each stage must complete before the next begins, ensuring the entity never exists in two frames simultaneously.
6. **Deterministic Replay:** Applying the same transition inputs in replay mode must yield identical entity states.

## Scheduler Constraints

* **Multi-Rate Scheduling:** The scheduler iterates from slowest (Interstellar) to fastest (Surface) each global tick, allowing children to run multiple steps inside a parent tick.
* **Priority:** Parent frames always resolve their tick before allowing children to advance. Within the same depth, frames are processed deterministically by canonical ID order.
* **Wake/Pause Conditions:** A frame wakes if it has active entities or pending handoffs. A frame may pause only when it and all descendants are idle.
* **Deterministic Ordering:** No mid-tick dimension switching. Transitions are queued and executed at the next synchronization boundary.
* **Disallowed Behaviors:** Skipping parent ticks while children run, changing tick rate without completing a sync boundary, or invoking non-deterministic scheduling (e.g., thread-race based ordering).

## Dimension Registry & IDs

Aegir-Core maintains a registry of dimension types and specific frame instances.

* **Canonical IDs:** Interstellar = `core.dim.interstellar`, Interplanetary = `core.dim.interplanetary`, Orbital = `core.dim.orbital`, Surface = `core.dim.surface`.
* IDs are stable, lowercase, dot-delimited strings. Once assigned they cannot be reused for different semantics.
* Serialization stores both the dimension instance ID and its canonical type ID. Instance IDs must be globally unique (UUIDv7 or context-provided deterministic hash).
* Contexts register custom dimension types (e.g., `fold.dim.interior.habitat`) by providing metadata: parent canonical type, tick policy, coordinate basis, allowed precision, and reference frame implementation.
* Collisions are prevented by namespace ownership: `core.` is reserved for Aegir-Core, `ctx.<name>.` for contexts.
* Registry entries include: `id`, `canonical_type`, `parent_type`, `tick_policy`, `reference_frame_class`, `handoff_rules`, `metadata` (JSON object), and `version` for migrations.

## Entity Residency Rules

* An entity resides in exactly one dimension at any time. Multi-frame residency is disallowed.
* Transition steps:
  1. Entity requests transfer to child or parent frame.
  2. Scheduler queues transfer until synchronization boundary.
  3. Entity components are serialized; the ReferenceFrame transform is applied; entity is instantiated in destination frame; source frame deletes the original instance.
* Deleting an entity removes it from its dimension and cascades clean-up in any child contexts (e.g., passengers inside a ship interior).
* When a dimension collapses (e.g., destroyed habitat), all resident entities are recursively moved to the parent Surface frame using emergency handoff rules that preserve center-of-mass momentum.

## ReferenceFrame API Contract

Every dimension type exposes a `ReferenceFrame` implementation registered with the Dimension Registry. The contract is:

```python
class ReferenceFrame:
    def world_to_frame(self, pos_world, vel_world):
        """Converts parent-frame position/velocity into this frame."""

    def frame_to_world(self, pos_frame, vel_frame):
        """Converts local position/velocity back into the parent frame."""

    def compose_velocity(self, local_velocity, frame_velocity):
        """Deterministically composes velocities (Galilean or relativistic)."""

    def update_orientation(self, orientation, angular_velocity, dt):
        """Advances orientation using deterministic quaternion integration."""
```

Requirements:

* Methods must be deterministic, pure functions with no external state mutation.
* Velocity composition rules must be declared (Galilean for canonical types); contexts may override but must remain invertible.
* Orientation integration must conserve angular momentum per frame's physics fidelity.
* Reference frames must expose metadata describing numerical tolerances so the scheduler can validate transitions.

## Extension Hooks & Context Responsibilities

* Contexts can add new dimension types by registering them as children of an existing canonical type, supplying their ReferenceFrame class, tick policy, and transition rules.
* Context-defined dimensions inherit parent invariants and must not weaken determinism guarantees.
* When adding custom physics fidelity, contexts must document additional invariants or restrictions inside the registry metadata.

## Example Transition Flow

1. **Ship departing planet:** Surface frame notifies scheduler of ascent. At the next sync boundary, entity state is transformed via the Surface ReferenceFrame into Orbital coordinates. Momentum, orientation, and angular state are preserved.
2. **Orbital insertion:** When apoapsis exits the planet's SOI, the entity transitions to the Interplanetary frame via Orbital → Interplanetary handoff, again ensuring reversible transforms.
3. **Docking with station interior:** A vessel in Surface hover mode spawns an Interior dimension registered by the context. Entities boarding the vessel transition Surface → Interior while inheriting Surface tick cadence.

This specification supersedes any previous dimension descriptions and serves as the single source of truth for Aegir-Core simulation scales.
