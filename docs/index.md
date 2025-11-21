# Phase Space — Design Documentation

Welcome to the living design documentation for **Phase Space**, a simulation-first game world and engine. These docs describe how the universe is structured, how time and space are modeled, and how systems like economy, culture, scripting, networking, and interfaces fit together into a coherent whole.

This site is intended for:

- **Engine and systems developers** who want to understand the architecture, simulation model, and engine constraints well enough to extend or refactor them.
- **Modders and world builders** who plan to define new contexts, dimensions, and systems on top of the core simulation.
- **Tooling and UI/UX developers** who need to integrate terminals, interfaces, and external tools with the engine and game runtime.
- **Contributors and curious readers** who want a high-level mental model of the project’s vision, roadmap, and key concepts.

Use the navigation to explore contexts (like the Fold and its cosmology), engine subsystems (dimensions, scheduling, scripting, multiplayer), and reference material (glossary, open questions, and roadmap). The goal is not just to specify *how* things work, but to capture the design principles and constraints that guide future changes.

## Getting started

If you’re new to Phase Space, a good reading order is:

1. **[Vision](overview/vision.md)** – the high-level goals, design principles, and what makes Phase Space different.
2. **[Architecture](overview/architecture.md)** – how the engine, contexts, and dimensions are structured.
3. **[Glossary](reference/glossary.md)** – canonical definitions of key terms you’ll see throughout the docs.

From there, dive into the contexts, engine subsystems, or reference sections that match the part of the project you’re working on.

> **For contributors**
>
> If you’re exploring how to help shape Phase Space, you may want to start with:
>
> - **[Ideas and open questions](reference/ideas-and-open-questions.md)** – areas that are intentionally under-specified or actively being designed.
> - **[Roadmap](reference/roadmap.md)** – planned directions, milestones, and how the world and engine are expected to evolve.