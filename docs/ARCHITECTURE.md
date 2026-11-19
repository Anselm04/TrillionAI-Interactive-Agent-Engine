# Architecture
## Components
- Flutter client SDK: session lifecycle, streaming audio, captions, avatar rendering and accessible fallback.
- Node.js/TypeScript control plane: authenticated session API, agent routing, tool policy, event streaming and usage budgets.
- Provider adapters: speech recognition, synthesis, language models and vision behind replaceable interfaces.
- Memory service: PostgreSQL tenant-scoped records, retrieval, retention, consent and deletion.
- Avatar runtime: original assets, animation state machine, phoneme/viseme timing, expression events and platform-specific rendering adapters.
- Integration SDK: versioned events and capability contracts; integrations remain opt-in.
## Trust boundaries
Client never owns privileged credentials. Server derives tenant and identity from verified authentication, not request bodies. Tool execution uses scoped credentials, explicit approval for consequential operations, timeouts and idempotency. Audit records omit raw secrets. Treat model output and retrieved content as untrusted.
## Realtime contract
Session events carry version, session ID, sequence, timestamp and type. Support reconnect, cancellation, interruption and backpressure. Separate media transport from control messages. Measure latency rather than promise an unverified target.
## Storage
PostgreSQL for durable state; optional ephemeral cache when justified. No external infrastructure required for the initial local development phase.
## Proposed layout
apps/demo_flutter, services/engine, packages/contracts, packages/flutter_sdk, packages/provider_adapters, assets/avatars, docs. Runtime packages are not yet implemented.
