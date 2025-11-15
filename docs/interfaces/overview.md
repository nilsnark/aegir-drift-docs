# Aegir-Interface Layer

Aegir-Interface is the presentation and interaction layer of Aegir Drift.  
It is responsible for *how the simulation is perceived* but has **no influence** on the rules of the universe.

Interfaces are not part of Aegir-Core and cannot modify simulation state except through Core-approved events.

## Responsibilities

- Rendering (terminal, UI, HUD, 2D/3D, web or native)
- Player input handling
- Instrument dashboards (navigation, ship systems, sensors)
- Visualization of dimensions and transitions
- Diagnostic tooling (profilers, tick inspectors, network monitors)
- Dimension subscription and filtered state streaming

## Multi-Interface Support

Aegir-Core supports multiple simultaneous interfaces, such as:

- **Aegir-Terminal** (text-based debugging)
- **Aegir-Web** (WebGL/WebGPU visualization)
- **Aegir-Inspector** (developer tools)
- **Aegir-VR** or **Aegir-UE** (fully immersive clients)

Interfaces communicate with Core via a stable event protocol, ensuring that rendering tools and gameplay UIs can evolve independently from the simulation engine.
