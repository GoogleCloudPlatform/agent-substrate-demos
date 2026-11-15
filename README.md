# Agent Substrate Demos on GKE

Reference architectures, interactive showcases, and end-to-end sample applications demonstrating how to build, checkpoint, govern, and scale stateful AI agents and distributed systems on **Google Kubernetes Engine (GKE)** with [**Agent Substrate**](https://github.com/agent-substrate/substrate) (`ate.dev`), [**Agent Executor (`google/ax`)**](https://github.com/google/ax), and **Gemini platform**.

For the structured, step-by-step hands-on learning curriculum, see the companion [**Agent Substrate Workshop (`GoogleCloudPlatform/agent-substrate-workshop`)**](https://github.com/GoogleCloudPlatform/agent-substrate-workshop).

## Demo Tracks

Each directory in this repository provides a self-contained reference architecture with GKE deployment manifests, Go/Python source code, architectural decision records (ADRs), and automated verification scripts:

| Track | Directory | What It Demonstrates |
|---|---|---|
| **Interactive Conference Agent Swarm** | `agent-swarm/` | High-density stateful agent fleet (`swarm`, `megaswarm`, and `hyperswarm` profiles) multiplexing thousands of gVisor actors across warm `WorkerPool` pods with **Gemini platform**, request parking, human-in-the-loop code execution approvals, and Cloud Filestore Agent Volumes (`/workspace`). |
| **Zero-Trust Enterprise Agent Security (AegisSRE)** | `agent-security/` | Reference implementation of the 6 enterprise agent security boundaries on GKE using ADK Go v2, **Gemini platform** (Agent Registry, Agent Identity, Agent Gateway, Model Armor, and Cloud SDP), MCP, A2A, A2UI, and zero-secret Agent Substrate gVisor actors. |
| **Multi-Harness Coding Agent Portal** | `agentscope/` | Multi-harness coding portal and control room built on **Agent Executor (`google/ax`)** and Agent Substrate on GKE featuring per-session model budget gates, WebSocket PTY terminals, live preview routing, and idle Cloud Storage checkpointing. |
| **3D Spatial Multi-Agent Orchestrator** | `cortex/` | Multimodal 3D spatial orchestrator, real-time bidirectional voice coordinator, and Cloud Firestore Shared Brain coordinating polyglot coding and research agents on GKE. |
| **Self-Spawning Bug Bash Tree** | `ax-bug-bash/` | Recursive multi-agent bug-finding and patch-verification workflow built on `google/ax`, `agent-substrate/env`, and copy-on-write Agent Substrate actor snapshots. |
| **High-Density CI/CD & GitOps Workflow Actors** | `workflows/` | Turn-based CI/CD and multi-tenant GitOps pipelines (`argo-actors`, `tekton-actors`, and `flux-substrate`) running Argo Workflows, Tekton v1 Pipelines, and FluxCD reconcilers inside gVisor actors with instant snapshot fork/revert and zero-slot parked approvals. |
| **Stateful Distributed Systems on Actors** | `anything-but-agents/` | Nine stateful non-AI workloads (multiplayer 2D roguelike, in-memory search cold-start race, per-tenant embedded databases, deception honeypot, Raft split-brain lab, SLSA L3 airgapped buildbox, sleeping subscription billing engine, and OpenFGA collaborative canvas) illustrating core Agent Substrate primitives. |
| **Interactive Browser Learning Environment** | `learn-substrate/` | Browser-based interactive lab environment on GKE combining WebSocket PTY actors with agent-native codelab skills so developers learn Agent Substrate from inside a live actor. |

## Prerequisites

- A Google Cloud project with billing enabled and a **GKE 1.37+** cluster configured with Workload Identity Federation for GKE, gVisor node pools (or Compute Engine C3 nested-virtualization nodes for MicroVM tracks), Cloud Storage, and Artifact Registry.
- Local tools: `gcloud`, `kubectl`, `kubectl-ate`, `go` 1.26+, `ko`, `jq`, and `git`.

## License and Disclaimers

This project is licensed under the Apache License, Version 2.0 — see [LICENSE](LICENSE) for details and [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

This project is intended for demonstration purposes only. It is not intended for use in a production environment.

Use of Google Cloud services in these demos is subject to the [Google Cloud Terms of Service](https://cloud.google.com/terms) and the [Google Cloud Service Specific Terms](https://cloud.google.com/terms/service-terms).

Eligibility for the [Google Open Source Software Vulnerability Rewards Program](https://bughunters.google.com/open-source-security) is determined by the [Google Open Source Software Vulnerability Reward Program Rules](https://bughunters.google.com/about/rules/open-source/google-open-source-software-vulnerability-reward-program-rules).
