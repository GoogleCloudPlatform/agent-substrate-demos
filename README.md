# Agent Substrate Demos on GKE

Reference architectures, interactive showcases, and end-to-end sample applications demonstrating how to build, checkpoint, govern, and scale stateful AI agents and distributed systems on **Google Kubernetes Engine (GKE)** with [**Agent Substrate**](https://github.com/agent-substrate/substrate) (`ate.dev`), [**Agent Executor (`google/ax`)**](https://github.com/google/ax), and **Gemini platform**.

For the structured, step-by-step hands-on learning curriculum, see the companion [**Agent Substrate Workshop (`GoogleCloudPlatform/agent-substrate-workshop`)**](https://github.com/GoogleCloudPlatform/agent-substrate-workshop).

## How Demos Work in This Repository

Every demo lives in its own self-contained `<demo-slug>/` directory with zero cross-demo dependencies and exposes the same `Makefile` commands (whether implemented with shell scripts or Terraform under the hood), supporting two symmetric workflows:

| Workflow | Install | Run & Verify | Uninstall |
|---|---|---|---|
| **Existing Cluster** *(Agent Substrate pre-installed)* | `make check-prereqs && make deploy` | `make demo` / `make verify-live` | `make teardown` *(removes only the demo; leaves `ate-system` untouched)* |
| **Clean From Scratch** *(Empty Google Cloud project)* | `make cluster-up && make deploy` | `make demo` / `make verify-live` | `make cluster-down` *(deletes the dedicated cluster with zero leaked spend)* |

## Prerequisites

- A Google Cloud project with billing enabled and (for the Existing Cluster track) a **GKE 1.37+** cluster configured with Workload Identity Federation for GKE, gVisor node pools (or Compute Engine C3 nested-virtualization nodes for MicroVM tracks), Cloud Storage, and Artifact Registry.
- Common CLI tools: `gcloud`, `kubectl`, `kubectl-ate`, `go` 1.26+, `jq`, `git`, and `ko` or `terraform` (as noted in each demo's Quick-Facts table).

## Contributing a Demo

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for the demo admission bar, `./hack/scaffold-demo.sh` starter generator, and repository quality checks (`./hack/check-hygiene.sh`).

## License and Disclaimers

This project is licensed under the Apache License, Version 2.0 — see [LICENSE](LICENSE) for details and [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

This project is intended for demonstration purposes only. It is not intended for use in a production environment.

Use of Google Cloud services in these demos is subject to the [Google Cloud Terms of Service](https://cloud.google.com/terms) and the [Google Cloud Service Specific Terms](https://cloud.google.com/terms/service-terms).

Eligibility for the [Google Open Source Software Vulnerability Rewards Program](https://bughunters.google.com/open-source-security) is determined by the [Google Open Source Software Vulnerability Reward Program Rules](https://bughunters.google.com/about/rules/open-source/google-open-source-software-vulnerability-reward-program-rules).
