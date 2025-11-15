# Multiplayer Architecture

Aegir Drift multiplayer is deterministic lockstep:

- Each simulation tick produces identical results for all clients.
- Inputs are synchronized, not states.
- Simulation must be pure and context-restricted.
- Player scripting-runtime scripts have strict CPU/time limits.

Networking is thin; simulation consistency is thick.

## Multiplayer Dimension Synchronization

Dimension transitions must remain consistent across all clients and servers.  
Aegir-Core enforces deterministic, authoritative transitions using strict rules.

### Deterministic Transforms

When an entity moves between dimensions, a deterministic transform is applied:

- source → target coordinate conversion
- reference frame reconciliation
- velocity/orientation transformation
- system initialization for the new dimension

All clients receive the same post-transform state.

### Authority Rules

- Aegir-Core (server) is the final authority.
- Clients cannot request or enforce transitions directly.
- Client-side predictions must be reversible.

### Network Events

Transitions generate explicit events:

- `DimensionEnter`
- `DimensionExit`
- `DimensionHandoff`
- `DimensionTransform`

These events ensure that all subscribers update their view of the universe cohesively.

### Context Hooks

Contexts may attach hooks to transitions, but all hooks must be:

- deterministic
- stateless or purely functional
- free of randomness not seeded by Core
