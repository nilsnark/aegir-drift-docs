# Contexts Overview

Contexts are self-contained universes built on top of the Phase Space engine. Each Context defines its own fiction, rules, and content, while relying on the shared simulation, ECS, and networking foundations provided by the engine.

Where the **Engine** pages describe the generic building blocks (dimensions, entities/components/systems, lockstep multiplayer, scripting runtime), Contexts describe concrete *worlds* that plug those blocks together in different ways. The Fold Context is one such world; this page explains the generic model that Fold (and other Contexts) follow.

## What is a Context?

A Context is a mod package that:

- Declares a **Context manifest** describing its ID, name, version, and dependencies.
- Registers one or more **dimensions** into the engine's dimension graph.
- Defines **components** and **systems** that extend the ECS.
- Provides **world generation** pipelines and content packs.
- Optionally exposes **scripting APIs** (for example via the scripting runtime) and data-driven configuration.

At runtime, the engine loads one or more Contexts and composes them into a running simulation. Each Context can be developed, shipped, and versioned independently, as long as it respects the engine contracts.

## How Contexts extend the engine

From the engine's point of view, a Context is just another module that registers things into well-known extension points. Typical extension points include:

- **Dimensions** – new simulation layers (e.g., a ship interior layer, a hyperspace transit layer, an underworld layer) with their own spatial scale and tick rate.
- **Components** – ECS data types attached to entities (e.g., `Foldstone`, `WarpDrive`, `Population`, `Atmosphere`), often tagged with which dimensions they are valid in.
- **Systems** – deterministic update logic that runs each tick in one or more dimensions (e.g., FTL navigation, economy simulation, biology, AI).
- **Worldgen** – pipelines that construct initial worlds, sectors, ships, factions, and other content when a new save is created.

The engine owns the scheduling, networking, and deterministic tick model, but it does not know what a "Foldstone" or "Seedship" is. Those concepts live entirely inside the Context.

## Context manifests and registration

Each Context ships with a manifest (see `contexts/fold/specs/context-manifest.md` for a concrete schema) that tells the engine what to load. In high-level terms the manifest answers questions like:

- What is the Context's ID and display name?
- Which engine version and other Contexts does it depend on?
- Which modules should be loaded for dimensions, components, systems, and worldgen?

When the engine boots with a given set of Contexts enabled, it:

1. Parses each Context's manifest.
2. Resolves dependencies and load order.
3. Invokes registration hooks provided by the Context code.

Those hooks call into engine APIs to register dimensions, components, worldgen steps, and systems.

## Registering dimensions

Dimensions are described in detail in `engine/dimensions/overview.md`; Contexts use those concepts to add their own layers to the simulation graph. A dimension registration typically includes:

- A **dimension ID** and human-readable name.
- A **scale** and **topology** (e.g., 2D grid, 3D space, tile-based interior).
- A **tick rate** and scheduling policy.
- **Transition rules** to other dimensions (see `engine/dimensions/transitions.md`).

For example, the Fold Context introduces dimensions for interstellar space, local systems, planetary surfaces, and pocket dimensions. Other Contexts might define mythic realms, cyberspace layers, or abstract strategy layers.

## Registering components

Components are the data that describe entities. Contexts typically:

- Define new component types (e.g., `Foldstone`, `NPFReactor`, `Faction`, `CargoHold`).
- Extend or specialize shared, engine-level components (e.g., physics, transforms, ownership).
- Declare which systems and dimensions read or write each component.

Because the engine enforces deterministic systems and stable execution order, components defined by a Context must be designed with deterministic updates in mind.

## Registering worldgen

World generation bridges static content and the running simulation. A Context can register worldgen modules that:

- Build initial dimension graphs (e.g., which star systems or realms exist).
- Populate those dimensions with entities (stars, planets, stations, ships, factions, dungeons, etc.).
- Apply procedural rules and noise functions to create variety.
- Seed deterministic RNG streams so that the same seed always produces the same world.

Worldgen modules are usually driven via data (JSON, DSLs, or scripts) plus a small amount of deterministic glue code.

## Registering systems

Systems are where a Context's rules actually run. Per `engine/systems.md` and `engine/simulation-overview.md`, systems:

- Run in a fixed order in each dimension on each tick.
- Read and write components deterministically.
- Must avoid I/O and other nondeterministic side effects.

A Context registers systems such as:

- Movement and navigation (including FTL or teleportation rules).
- Resource production and consumption (economy, life support, fuel).
- AI behavior and decision-making.
- Narrative or progression systems.

The engine's scheduler decides *when* to run systems; the Context provides *what* they do.

## Relationship to the engine docs

If you're designing a new Context, you will typically:

1. Start with the **Engine** docs:
   - `engine/simulation-overview.md` – how the deterministic tick model works.
   - `engine/dimensions/*` – how to structure your dimensions and transitions.
   - `engine/systems.md` – how to write deterministic systems.
   - `engine/modding-contexts.md` – contracts and APIs available to mods.
2. Sketch the fiction and high-level structure of your Context (what dimensions, what factions, what core components).
3. Define a Context manifest, then implement registration code for dimensions, components, worldgen, and systems.

Once those pieces are in place, you have a new universe that the engine can run.

## How Fold fits into this model

The Fold Context (see `contexts/fold/index.md`) is the flagship example of the Context model:

- It uses the engine's dimension system to model everything from planetary surfaces up to interstellar space and pocket dimensions.
- It defines components for Foldstones, Fold Kernels, NPF reactors, seedships, and more.
- It registers worldgen to create a far-future setting with ancient megastructures, wormhole networks, and long-running civilizations.
- Its systems implement causality-safe FTL travel, Foldstone energy budgets, SLISP scripting hooks, and a rich economy.

When reading the docs, you can think of this page as the **bridge** between the abstract engine concepts and the concrete Fold example:

- Use the **Engine** section to understand the core mechanics the engine guarantees.
- Use this **Contexts Overview** to see how mods are expected to plug into those mechanics.
- Use the **Fold** docs as a deep, concrete case study of a complex Context built on top of the model described here.
