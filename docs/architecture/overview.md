# Aegir Architecture Overview

Aegir Drift is structured into three clean layers:

## **1. Aegir-Core (Engine Layer)**

The deterministic simulation substrate.
Responsible for:

* ECS
* physics
* dimensions
* ticking
* determinism
* networking model

Core defines *what is true.*

For the canonical definition of dimension scales, coordinate frames, and tick policies, see the [Aegir-Core Dimension Hierarchy](../architecture/dimensions.md).

## **2. Contexts (Universe Layer)**

Modular universe definitions.
Responsible for:

* custom components and systems
* new physics rules
* technologies
* worldgen
* dimension types
* scripting hooks

Contexts define *what is possible.*

## **3. Aegir-Interface (Perception Layer)**

Clients, UIs, and visualizers.
Responsible for:

* graphical rendering
* input
* HUD
* in-game instruments
* external tools

Interface defines *what is perceived.*

Each layer is independent; new interfaces or new contexts can be added without modifying Aegir-Core.

## Context-Agnostic Core

Aegir-Core does not assume any specific physics or technology beyond classical mechanics and deterministic ECS rules.

Foldstone mechanics, wormholes, NPF, and pocket dimensions exist **only** within the Fold Context.

Other contexts may implement:

* alternate FTL methods
* magic-like systems
* low-tech universes
* hard-science sub-light-only universes
* surreal or anomaly physics

Aegir-Core treats all contexts equally and provides no special-case behavior for Fold.
