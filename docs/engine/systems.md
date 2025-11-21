# Systems (Entity–Component–System)

This page describes the core Entity–Component–System (ECS) concepts used by the Phase Space engine, how they map to data and behavior, and the planned ECS roadmap phases.

## Contract (short)

- Inputs: component data tables, entity identifiers, system configuration
- Outputs: component mutations, events, spawn/despawn operations
- Error modes: invalid schema, missing components, version mismatch
- Success: deterministic, cache-friendly iteration and predictable scheduling

## Entities

An Entity is a lightweight identifier (opaque ID). It has no behavior by itself. An entity's meaning is defined by the set of components attached to it.

- Representation: integer or GUID depending on runtime mode
- Lifecycle: created, assigned components, potentially moved across dimensions, destroyed

## Components

Components are data-only structures (no logic). They represent the state needed by systems.

- Examples: Transform, PhysicsBody, Inventory, Reactor, WormholeCarrier
- Shape: strongly-typed schema for fields (name, types, defaults, version)
- Storage: contiguous arrays / tables per component type to enable cache-friendly iteration

Component versioning is supported so contexts and the runtime can evolve schemas safely.

## Systems

Systems are pure logic that query entities by required component sets and operate on component data.

- Execution model: each system iterates over matching entity component rows and produces side-effects by mutating components, emitting events, or scheduling entity operations
- Determinism: systems may declare constraints (read-only vs write sets, dependencies) so the scheduler can produce a deterministic ordering
- Lifecycle hooks: initialize, update (tick), hot-reload, shutdown

Common systems:

- PhysicsSystem — integrates PhysicsBody, resolves collisions
- NavigationSystem — queries Transform + Pathfinding components
- PowerSystem — manages Reactor components and power networks
- PocketSystem — manages pocket-dimension state

## How contexts can extend the ECS

Contexts (mods) may register new component schemas and systems. They should declare component versions and any compatibility metadata. The engine supports hot-loading of component schemas in later roadmap phases; until then, contexts must provide compatibility layers.

## ECS Roadmap (phased)

1. Simple data tables
   - Initial implementation using simple per-component tables and entity-to-component mappings.

2. Archetype ECS
   - Move to archetype-based storage for cache-efficient, fast iteration of common component combinations.

3. Dimension-aware ECS shards
   - Partition ECS state by dimension/shard to scale to millions of entities and isolate simulation domains.

4. Hot-loading component schemas from Contexts
   - Allow Context manifests to introduce and update component schemas at runtime with validation and migration hooks.

5. Deterministic system scheduling
   - Scheduler that enforces declared read/write constraints, supports parallel execution, and ensures deterministic order for multiplayer rollback.

6. Component versioning and migrations
   - Formal versioning, compatibility layers, and automatic data migrations to support rolling upgrades and rollback-safe changes.

7. Plugin-safe extension model
   - Stable plugin APIs so Contexts can provide systems/components without requiring engine rebuilds; includes sandboxing and capability restrictions.

These phases are ordered to minimize risk: start with correct, simple behavior and progressively add performance and extensibility features.

## Edge cases and notes

- Missing components: systems must handle cases where expected components are absent (skip or create defaults)
- Large scale: when running millions of entities, prefer archetype queries and avoid per-entity indirections
- Multiplayer: component version mismatches are a primary source of desync; follow strict versioning and migration procedures

## Further reading

See `engine/dimensions/*` for how ECS state is partitioned across simulation dimensions and `engine/scripting-runtime.md` for scripting hooks that interact with ECS.
