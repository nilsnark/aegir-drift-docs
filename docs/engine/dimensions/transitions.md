# Transitions Between Dimensions

Entities can move between dimensions through **handoff protocols**:

- A ship leaving a local surface dimension transitions into an orbital dimension.
- A ship performing a transfer burn transitions from orbital to interplanetary.
- Entering a ship interior transitions a player from orbital/local into an interior dimension.
- Fold contexts can open portals to pocket dimensions and perform similar handoffs.

During a handoff:

1. The engine computes the entity’s state in the source dimension (position, velocity, orientation, etc.).
2. That state is transformed into the coordinate system and scale of the target dimension.
3. The entity is removed from the source dimension and spawned into the target dimension with equivalent state.
4. Any Context-specific hooks (e.g., Fold pocket entry/exit logic) are invoked.

Handoffs are designed to be:

- deterministic
- reversible where appropriate
- context-aware (physics and rules may differ between dimensions)

## Dimension Activation and Streaming

Aegir-Core dynamically activates and deactivates dimensions to optimize simulation cost.

### Activation Rules

A dimension becomes active when:

- a player enters it
- an active entity exists within it
- a context system requires it (e.g., Foldstone regulation)

Active dimensions receive scheduled ticks and generate events.

### Deactivation Rules

A dimension can deactivate when:

- no players are present
- entities inside are inert or sealed
- no context requires ongoing simulation

Deactivated dimensions:

- consume no CPU time  
- remain stored in serialized form  
- can be reactivated deterministically  

### Pocket Optimization

Pocket dimensions may fully deactivate when:

- sealed (time_scale = 0)
- no I/O is active
- no kernel action is required

This allows thousands of pockets without performance cost.
