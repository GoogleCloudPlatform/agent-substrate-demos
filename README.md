# Agent Substrate Demos on GKE

Reference architectures, interactive showcases, and end-to-end sample applications demonstrating how to build, checkpoint, govern, and scale stateful AI agents and distributed systems on **Google Kubernetes Engine (GKE)** with [**Agent Substrate**](https://github.com/agent-substrate/substrate) (`ate.dev`), [**Agent Executor (`google/ax`)**](https://github.com/google/ax), and **Gemini platform**.

For the structured, step-by-step hands-on learning curriculum, see the companion [**Agent Substrate Workshop (`GoogleCloudPlatform/agent-substrate-workshop`)**](https://github.com/GoogleCloudPlatform/agent-substrate-workshop).

## Prerequisites

- A Google Cloud project with billing enabled and a **GKE 1.37+** cluster configured with Workload Identity Federation for GKE, gVisor node pools (or Compute Engine C3 nested-virtualization nodes for MicroVM tracks), Cloud Storage, and Artifact Registry.
- Local tools: `gcloud`, `kubectl`, `kubectl-ate`, `go` 1.26+, `ko`, `jq`, and `git`.

## License and Disclaimers

This project is licensed under the Apache License, Version 2.0 — see [LICENSE](LICENSE) for details and [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

This project is intended for demonstration purposes only. It is not intended for use in a production environment.

Use of Google Cloud services in these demos is subject to the [Google Cloud Terms of Service](https://cloud.google.com/terms) and the [Google Cloud Service Specific Terms](https://cloud.google.com/terms/service-terms).

Eligibility for the [Google Open Source Software Vulnerability Rewards Program](https://bughunters.google.com/open-source-security) is determined by the [Google Open Source Software Vulnerability Reward Program Rules](https://bughunters.google.com/about/rules/open-source/google-open-source-software-vulnerability-reward-program-rules).
