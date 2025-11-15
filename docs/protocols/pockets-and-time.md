# Pocket Time and Stasis Protocols

This document is intended for **engine implementers and simulation designers**. It defines the
protocol-level rules that Fold Kernels must follow when managing pocket-dimension time scaling
and stasis. The Fold Spacetime Stack page provides the narrative overview; this page specifies
the **actual rules the engine must enforce**.

## Pocket Time States

Pocket dimensions exhibit special time behavior governed by Fold Kernels. There are three main states.

### Sealed stasis

When a pocket dimension has **no open aperture**, its internal time scale becomes:

- `time_scale = 0`

This state is fully stable, consumes **no energy**, and preserves all internal contents indefinitely.

### Open aperture (normal time)

When a pocket is accessible to real-space (inventory open, portal open), the pocket maintains:

- `time_scale = 1`

This requires minimal NPF to regulate the boundary and keep internal physics coherent.

### Time acceleration

Pockets may accelerate internal time at higher energy cost:

- `time_scale = N` (for `N > 1`)

Acceleration is only allowed when:

- the pocket has no players inside;
- the Fold Kernel supervising it is stable;
- the pocket has sufficient NPF reserves.

This rule prevents multiplayer de-sync and avoids temporal paradoxes.
