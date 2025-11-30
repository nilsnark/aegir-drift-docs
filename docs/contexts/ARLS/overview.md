# Phase Space – ARLS Context v0

## Autonomous Robotic Logistics & Survey

Terminal‑driven, deterministic, multiplayer orbital logistics and information‑economy simulation

---

## 1. Core Concept

ARLS is a fully robotic interplanetary logistics, survey, and information‑market simulation operating under strict Newtonian physics and deterministic lockstep multiplayer.

Players never pilot directly. They author autonomous programs that:

* Fly robotic survey and cargo vessels
* Perform orbital maneuvers and captures
* Schedule burns and sensor integrations
* Fuse probabilistic observations into knowledge
* Compete in an information‑driven market

The scarce resource is not matter or energy. It is **certainty**.

---

## 2. World & Technology Constraints

* Near‑future interplanetary industry
* No FTL, no artificial gravity
* High‑density reactors or fusion power assumed
* All ships are fully autonomous
* Light‑speed communication delays apply
* No human survivability limits

Only physical limits apply: thrust‑to‑mass ratios, reaction mass, heat dissipation, and structural stress.

---

## 3. Core Gameplay Loop

1. Survey & sensing
2. Probabilistic detection and fusion
3. Orbit fitting and prediction
4. Burn and mission planning
5. Autonomous execution in real simulation time
6. Post‑hoc analysis via logs
7. Iteration through code

The universe never pauses for the player.

---

## 4. Information as the Primary Economy

All distant objects exist as hidden state until detected. Detection produces probabilistic estimates only:

* Position and velocity with covariance
* Mass and composition likelihoods
* Orbital stability and capture windows

Certainty improves only via repeated observation, multi‑sensor fusion, and time.

Tradable commodities include:

* Raw scan data
* Confirmed tracks
* Certified resources
* Verified intercept solutions

Mining is logistics. **Discovery is competition.**

---

## 5. Deterministic Simulation Contract

* Fixed timestep
* Canonical system ordering
* Deterministic PRNG
* Replayable from genesis + input log
* Lockstep multiplayer

Determinism is never compromised for convenience.

---

## 6. Physics Model

* Multi‑body gravitation
* Continuous thrust integration
* Mass changes from propellant burn
* Optional rotational dynamics
* Structural and thermal envelope modeling

Patch‑conic approximation is allowed for early prototypes only.

---

## 7. Sensor & Knowledge Model

### 7.1 Three-Layer Epistemic Model

1. Authoritative physical state (engine only)
2. Signal state (sensor propagation)
3. Belief state (actor knowledge)

Scripts operate exclusively on belief.

### 7.2 Sensors

Each sensor defines band, aperture, FOV, range, noise model, resolution, integration time, power cost, and cooldown. Observations include measurement vectors, covariance, and SNR.

Noise is generated via stateless deterministic PRNG keyed by tick, sensor, and domain.

### 7.3 Belief State

Actors maintain probabilistic tracks with confidence values. Fusion follows deterministic Kalman‑like sequential updates. Confidence decays over time.

Knowledge sharing exchanges belief packets, never truth.

---

## 8. Deterministic PRNG Architecture

Two independent RNG systems exist:

* Engine RNG: stateless, keyed, order‑independent
* Script RNG: per‑brain, stateful

They are mathematically isolated and never influence each other.

---

## 9. Player Scripting Model

### 9.1 Canonical Runtime

* All scripts execute as deterministic Lua bytecode
* Lua is the only engine‑facing runtime
* JS‑like, Lisp, and DSLs transpile to Lua only

### 9.2 Sandbox Constraints

* No file IO
* No network
* No wall‑clock time
* No nondeterministic randomness
* No reflection or dynamic loading
* Bounded execution per tick

### 9.3 Versioning

* Each script has a hash‑stable version
* Edits create new versions
* Existing ships remain bound to prior versions
* No retroactive behavior mutation

---

## 10. Canonical Tick Pipeline

For global tick T:

1. Physics integration
2. Sensor propagation
3. Script execution
4. Intent validation and commit
5. Tick advance

Scripts always observe completed reality and issue future intent.

---

## 11. Script Execution Interface v0

Each script defines:

```
function init(ctx)
function tick(ctx)
```

The context object exposes:

* Time state
* Self physical estimates
* Belief tracks
* Sensor controls
* Communications
* Contracts
* Deterministic RNG
* Logging
* Command queue
* Persistent user data

All properties are read‑only except commands and user data.

---

## 12. Intent & Command Model

Scripts never mutate physics directly. They emit timestamped future intents:

* Thrust burns
* Attitude changes
* Scan scheduling
* Market bids

All intents are validated against:

* Resource availability
* Thermal limits
* Structural envelopes
* Context permissions

---

## 13. Autonomous Actor Model

Each ship is modeled as:

* A physical body
* A sensor platform
* A communications node
* A script brain
* A delayed command receiver

Brains are delayed, fallible controllers operating on stale data.

---

## 14. Market & Contract System

Engine layer provides:

* Commodity abstraction
* Ownership
* Time‑dependent pricing
* Expiring contracts

Context defines:

* Which commodities exist
* Which stations trade
* Which belief products are certifiable

---

## 15. Logging & Replay

All events are logged:

* Burns
* Structural stress
* Sensor observations
* Track promotions
* Contract resolution

Full replayability is a hard invariant.

---

## 16. Multiplayer Model

* Deterministic lockstep
* Shared world state
* No direct player‑to‑player commands
* Competition arises via physics and timing

---

## 17. Terminal-First Interface

The terminal is canonical. All authoritative output is textual:

* Telemetry
* Sensor SNR
* Orbit projections
* Confidence metrics
* Market spreads

Visualization is optional and non‑authoritative.

---

## 18. Explicitly Out of Scope

* Human crews
* First‑person piloting
* EVA
* Weapons or combat systems
* Narrative NPCs

---

## 19. Substrate Requirements Summary

* Deterministic fixed‑step simulation core
* Multi‑body gravity
* Reference frame transforms
* Sensor propagation model
* Hidden‑state knowledge system
* Autonomous actor abstraction
* Deterministic PRNG
* Script VM embedding
* Versioned script registry
* Lockstep synchronization
* Market and contract infrastructure

---

## 20. Non‑Negotiable Design Pillars

1. Physics is never bypassed
2. Information is the economy
3. Automation is authored, not abstracted
4. Failure is physical and permanent
5. Terminal is canonical
6. The universe never pauses
7. Determinism is sacred

---

## 21. ARLS v0 Implementation Scope

* Sensor observation pipeline
* Belief tracking and decay
* Dual PRNG
* Lua runtime integration
* Script API surface
* Post‑physics scripting phase
* Deterministic intent queue

---

## 22. Design Truth

The universe is deterministic.
The player’s knowledge of it is not.

ARLS is a competition in uncertainty collapse under real physics constraints.
