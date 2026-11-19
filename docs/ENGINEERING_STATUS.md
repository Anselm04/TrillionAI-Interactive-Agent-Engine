# Engineering qualification register
Source implementation is not equivalent to qualification.
- Foundation PR #1: Node tests and Flutter analysis passed earlier revision; semantics disposal fix pending CI.
- 3D PR #2: procedural CPU renderer and character catalog, unverified.
- Viseme timeline: timestamped ARPAbet mapping, unverified; audio clock and renderer connection outstanding.
- Voice: cancellable turn orchestration with injected adapters, unverified; actual duplex audio transport outstanding.
- Reasoning: provider registry, unverified; model adapters outstanding.
- Memory: local SQLite CRUD with explicit tenant parameter, unverified; authentication boundary, encryption and retrieval outstanding.
- Agents: in-process bounded tool approval and execution, unverified; trusted principal context, sandbox, durable scheduling and orchestration outstanding. Cancellation requires cooperative handlers; timeout does not guarantee side effects stop.
- SDK: Node module entry point; Flutter SDK extraction and versioned network integration outstanding.
No deployment or paid provider calls. Qualify every exact PR head before merge.
