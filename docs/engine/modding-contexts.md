# Modding Contexts

Contexts are the engine's mod units — self-contained packages that extend the simulation by declaring data (components), logic (systems), assets, and metadata. Contexts can be versioned, sandboxed, and hot-loaded.

## How contexts act as mods

- A Context is a manifest plus resources. The manifest (`context.yaml`) declares the context id, version, dependencies, and the things it provides (component schemas, systems, assets).
- The engine loads contexts and registers their component schemas and systems into the ECS runtime. Contexts can extend existing types or add entirely new ones.
- Contexts are isolated: they should declare capabilities (e.g., network access, filesystem) and the engine enforces restrictions.

## Defining a context.yaml

Below is a minimal example of a `context.yaml` manifest. It is primarily declarative and used by the engine to register resources at load time.

```yaml
id: fold-pocket
version: 0.1.0
name: Fold Pocket
description: "Adds pocket-dimension mechanics and foldstone entities."
author: Phase Space Team

dependencies:
  - core >= 0.1.0

components:
  - name: Foldstone
    schema:
      radius: float
      capacity: int
    version: 1

systems:
  - module: fold.pocket.systems
    class: PocketSystem
    tick: physics
    depends_on: [PowerSystem]

assets:
  - path: assets/foldstone.png

capabilities:
  - hot_reload
```

Key fields:

- `components`: component schemas the context introduces. Each schema should include a version and typed fields.
- `systems`: fully-qualified module/class pairs loaded by the scripting/runtime loader. Systems can declare `tick` categories and dependencies so the scheduler can order them.
- `dependencies`: other contexts or engine versions this context requires.
- `capabilities`: optional runtime capabilities (hot_reload, persistent_storage, network) that the engine can grant or deny.

## Extending systems and components

Contexts may extend or augment engine behavior in two main ways:

1. Register new component schemas
   - Add new component types that systems (engine-provided or context-provided) can use.
   - Provide migration code if updating an existing component version.

2. Provide systems or system plugins
   - Implement systems that subscribe to entity queries and mutate components.
   - Declare dependencies and read/write component sets so the engine scheduler can safely parallelize execution.

Example extension patterns:

- Non-destructive extension: provide an additional component (e.g., `PocketTag`) and a system that operates when both `PocketTag` and `Transform` exist.
- Schema migration: include a `migrations/` module with functions to migrate persisted data from `v1` to `v2` when a component version changes.

## Hot-loading and safety

- Hot-loading: when enabled, contexts can be reloaded at runtime. The engine will validate new schemas and apply migrations before replacing live components.
- Safety: contexts must not unconditionally replace core component semantics. The engine enforces capability constraints and recommends using adapter components or versioned schemas for compatibility.

## Best practices

- Version your components and contexts from the start.
- Keep contexts focused and small: single-responsibility contexts are easier to test and migrate.
- Prefer additive changes over destructive ones; use migrations when necessary.

## Example: how a system registers

When the engine loads a context, it will import the declared system module and call a known registration function (e.g., `register(engine, manifest)`). The system should then:

1. Register its queries and system-level config
2. Optionally register RPC or scripting hooks
3. Declare shutdown and hot-reload handlers

This registration pattern keeps the engine in control of scheduling and lifecycle while letting contexts provide domain-specific logic.

## See also

`engine/systems.md` — the ECS concepts and roadmap
`contexts/fold/specs/context-manifest.md` — fold context spec and manifest schema
