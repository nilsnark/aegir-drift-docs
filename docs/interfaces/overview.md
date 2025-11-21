# Phase Space Interface Layer

Phase Space Interface is the presentation and interaction layer of Phase Space.  
It is responsible for *how the simulation is perceived* but has **no influence** on the rules of the universe.

Interfaces are not part of Phase Space Core and cannot modify simulation state except through Core-approved events.

## Responsibilities

- Rendering (terminal, UI, HUD, 2D/3D, web or native)
- Player input handling
- Instrument dashboards (navigation, ship systems, sensors)
- Visualization of dimensions and transitions
- Diagnostic tooling (profilers, tick inspectors, network monitors)
- Dimension subscription and filtered state streaming

## Multi-Interface Support

Phase Space Core supports multiple simultaneous interfaces, such as:

- **Phase Space Terminal** (text-based debugging)
- **Phase Space Web** (WebGL/WebGPU visualization)
- **Phase Space Inspector** (developer tools)
- **Phase Space VR** or **Phase Space UE** (fully immersive clients)

Interfaces communicate with Core via a stable event protocol, ensuring that rendering tools and gameplay UIs can evolve independently from the simulation engine.
