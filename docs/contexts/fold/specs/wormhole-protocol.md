# Wormhole Protocols

Fold-engineered wormholes allow instantaneous local travel without violating causality.

This document is intended for **engine implementers and simulation designers**. It captures the
"hard" procedural rules that Fold Kernels must enforce when constructing, maintaining, and
reopening wormholes. Lore and high-level concept explanations live in the Fold context docs; this
page is about **what the engine must actually do**.

## τ-Synchronization

Anchors maintain the same proper-time epoch via Fold Kernel telemetry.

## Parity Check

Wormholes only remain open if:

- relative velocity < threshold
- gravitational potential within tolerance
- pocket stability intact
- NPF reserves balanced

## Choke Conditions

Triggered by:

- anchor drift
- τ desync
- mass shock
- insufficient NPF

## Construction Sequence

A typical construction sequence:

1. A seedship deploys a remote anchor.
2. The local anchor matches the remote anchor's inertial frame.
3. τ-lattices align.
4. NPF reservoirs are charged.
5. Filaments extend into Foldspace.
6. The throat inflates.

## Reopening Protocol

After a choke event, a safe reopening protocol is:

1. **Freeze both anchors** in their inertial frames.
2. **Re-synchronize τ-lattice epochs** to resolve proper-time divergence.
3. **Equalize gravitational potential** via pocket-buffered NPF discharge.
4. **Perform an energy parity check** across both anchors.
5. **Reinflate the throat** using controlled Foldspace filaments.

If any step fails, the wormhole remains locked until manual intervention.
