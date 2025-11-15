# SLISP — Substrate Lisp

SLISP is the device scripting language for Fold and a candidate scripting runtime for Core-only simulations.

It is designed to run inside the engine's deterministic simulation loop while remaining safe, capability‑limited, and context‑extensible.

## Goals

- Deterministic
- Safe
- Functional-first
- Device-local state
- Capability-restricted

Players use SLISP to automate:

- drones
- factories
- navigation
- sensors
- logistics networks

Engine and context authors can also use SLISP to script systems in a way that remains compatible with multiplayer determinism.

## Execution Model

At the engine level, the scripting runtime executes programs with:

- deterministic evaluation
- bounded CPU cycles per tick
- no implicit global state
- strict capability permissions
- device-local memory
- mostly‑pure functional style with controlled side effects

In Fold specifically, SLISP programs execute inside miniature Foldspace machines within Fold Kernels. Each kernel contains a micro-dimension dedicated to:

- execution isolation
- cycle-accurate determinism
- capability sandboxing
- bounded evaluation
- time dilation control
- state snapshots

SLISP is not interpreted on a conventional CPU — it is *evaluated inside a Fold-dimension computational manifold* that is itself simulated by the engine.

For the formal language definition and tick-level guarantees, see the [SLISP Specification](specs/slisp-spec.md).

## Capability-Based Security Model

SLISP uses a capability-based security model where devices expose controlled APIs to scripts.

Example:

```lisp
(let ((nav (device:get-capability "navigation")))
  (nav:set-target '(1000 250 0))
  (nav:engage-autopilot))
```

### Capability Rules

- A SLISP program cannot access any system unless a device explicitly exports a capability.
- Capabilities are immutable, first-class objects.
- All state changes pass through Core-verified commands.
- Contexts may extend available capabilities.

### Purpose

The capability model and execution rules together ensure:

- determinism
- sandbox safety
- multiplayer consistency
- mod isolation
- predictable simulation behavior

For how this plugs into the broader engine, see:

- [Scripting Runtime](../../engine/scripting-runtime.md)
- [Contexts Overview](../overview.md)
