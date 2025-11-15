# Fold Spacetime Stack

Foldspace engineering is built from a small set of interoperating constructs:

- **Foldstones** – microscopic anchors that hold pocket dimensions.
- **Capacity law** – a limit on how much spacetime structure a Foldstone can safely support.
- **Fold Kernels** – supervisory cores that regulate geometry, time, and NPF.
- **NPF energy** – the exotic substrate that fuels all Fold operations.
- **Pocket dimensions** – internal spaces used for storage, industry, and habitats.
- **Seedships** – ultralight Foldstones used as interstellar probes.
- **Wormholes** – causality‑safe shortcuts between distant anchors.

This page consolidates the core physical model so you can reason about Fold as a coherent spacetime stack.

## Foldstones and Capacity

Foldstones are microscopic spacetime anchors capable of supporting enormous internal volumes called pocket dimensions.

### Properties

- Smaller external size → larger internal capacity.
- Inverse density relationship between real-space and pocket.
- Require Fold Kernels for stability.
- Pocket time defaults to 1:1 with real-space.
- Can store matter, energy, or entire structures.

Used for:

- Ship storage
- Inventory compression
- Industrial spaces
- Megastructures inside stones

### Capacity Law

Each Foldstone has a finite capacity budget that constrains how much structure it can safely host. In formal specs this is captured by the **Foldstone Capacity Model**, but at a high level it relates:

- total mass stored
- spatial complexity (volume, topology, number of regions)
- time dilation factor
- NPF reserves

A simple illustrative form of the constraint is:

$$C_\text{used} = f(m, V, \tau, E_\text{NPF}) \le C_\text{max}(\text{stone tier})$$

where $C_\text{max}$ depends on the stone's mass tier and manufacturing quality. The exact function is specified in the [Foldstone Capacity Model](specs/foldstone-capacity.md), but the design intent is clear:

- pushing **any** dimension (mass, complexity, time dilation) too far will saturate the capacity budget;
- NPF can offset some load but cannot violate hard physical limits;

After a choke event, a safe reopening protocol is summarized as:

- bigger stones do not linearly scale capacity – engineering matters.

### Stability and Failure Modes

Foldstones are stable under normal conditions but can destabilize under extreme misuse.

Each Foldstone has:

For the full protocol specification, see [Wormhole Protocols](specs/wormhole-protocol.md).

- maximum spatial complexity
- allowable time dilation bounds
- NPF budget

Exceeding these limits introduces turbulence within the pocket.

Possible failure outcomes include:

- **Turbulence** – pocket geometry oscillates; items may suffer damage.
- **Mass Shear** – pocket attempts to eject excess mass back into real-space.
- **Kernel Stall** – Fold Kernel loses τ-sync and collapses the pocket to stasis.
- **Catastrophic Collapse** – extreme misuse collapses the pocket, vaporizing or ejecting contents.

Fold Kernels issue warnings before failure when possible.

See also: [Foldstone Capacity Model](specs/foldstone-capacity.md).

## Fold Kernels

Fold Kernels are specialized Foldstones containing vast computational structures that regulate Foldspace.

They are responsible for:

- maintaining pocket geometry
- controlling pocket-time acceleration
- managing NPF distribution
- regulating wormhole throats
- running SLISP scripts safely
- enforcing causality and safety interlocks

Every Kernel inherits logic from the ancient ["Common Lisp Fragment"](lore/common-lisp-fragment.md).

Kernels are also the execution environment for [SLISP](slisp.md) programs; see the [SLISP Specification](specs/slisp-spec.md) for language details.

## NPF Energy

**Negative Potential Flux (NPF)** is the exotic energy substrate enabling all Foldspace engineering.

Applications include:

- pocket expansion and compression
- wormhole throat inflation
- τ-lattice synchronization
- kernel computation
- high-density reactors

NPF is the top-tier resource in the [Fold economy](economy-and-culture.md#resource-tiers) and the limiting factor for large-scale Foldspace projects.

## Pocket Dimensions

Pocket dimensions are internal spaces inside Foldstones.

### Basic Rules

- Size ∝ 1 / real-space Foldstone size.
- Time runs at real-space rate unless accelerated.
- Acceleration requires substantial NPF and Fold Kernel supervision.
- Acceleration is forbidden while a player is inside to prevent multiplayer de-synchronization and paradoxical item production.
- Pocket physics is defined by the Fold context.

Typical uses include:

- storage
- industry
- habitats
- research spaces

### Pocket Time and Stasis

Pocket dimensions exhibit special time behavior governed by Fold Kernels.

For full protocol-level rules, see [Pocket Time and Stasis Protocols](../../protocols/pockets-and-time.md).

## Seedships

Seedships are micro-Foldstone probes accelerated to relativistic velocities.

### Purpose

Seedships:

- carry pocket factories;
- deploy wormhole anchors;
- sync proper-time with a home anchor;
- operate autonomously for centuries.

They are the backbone of interstellar expansion.

### Flight Model

Seedships are picogram-scale Foldstones capable of extreme acceleration. Their tiny mass allows them to reach relativistic velocities without catastrophic heating or structural stress.

Typical parameters:

- launch acceleration: ~0.1c to 0.9c over months;
- navigation: Fold Kernel micro-thrusters;
- communication: τ-beacons;
- deceleration: folded NPF brakes;
- operational lifetime: centuries.

Seedships use pure real-space travel — no early wormholes — to avoid causality violations, then deploy anchors for later wormhole connections.

## Wormholes

Fold-engineered wormholes allow instantaneous local travel without violating causality.

### Constraints

- Anchors are fixed in their inertial frames.
- τ-synchronization is required between endpoints.
- Gravitational potential mismatch triggers a choke.
- NPF is continuously consumed to maintain the throat.

If relative velocity exceeds limits or potentials diverge too far, the wormhole chokes to prevent causal paradoxes. This is regulated by the Fold Kernel's τ-lattice.

### Construction

A typical construction sequence:

1. A seedship deploys a remote anchor.
2. The local anchor matches the remote anchor's inertial frame.
3. τ-lattices align.
4. NPF reservoirs are charged.
5. Filaments extend into Foldspace.
6. The throat inflates.

### Wormhole Reopening Protocol

After a choke event, a safe reopening protocol is:

1. **Freeze both anchors** in their inertial frames.
2. **Re-synchronize τ-lattice epochs** to resolve proper-time divergence.
3. **Equalize gravitational potential** via pocket-buffered NPF discharge.
4. **Perform an energy parity check** across both anchors.
5. **Reinflate the throat** using controlled Foldspace filaments.

If any step fails, the wormhole remains locked until manual intervention.

For protocol-level details, see the [Wormhole Protocol](specs/wormhole-protocol.md).
