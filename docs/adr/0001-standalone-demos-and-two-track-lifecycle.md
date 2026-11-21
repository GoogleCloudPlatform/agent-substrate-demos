# Standalone Demo Directories and Two-Track Cluster Lifecycle

Status: accepted

Each demo in `GoogleCloudPlatform/agent-substrate-demos` lives in a flat top-level `<demo-slug>/` directory with 100% self-contained dependencies (`go.mod`, `pyproject.toml`, `package.json`) and zero application-code imports across demos or from a shared root package, and every demo exposes two decoupled operational tracks behind one uniform `Makefile` interface (`cluster-up` / `cluster-down` for clean-project provisioning, and `check-prereqs` / `deploy` / `teardown` for existing clusters with Agent Substrate pre-installed).

## Why

- **Copy-and-fork ergonomics**: Adopters routinely copy or `git sparse-checkout` a single reference architecture into their own repository. Shared Go/Python packages at the monorepo root break single-folder extraction and force lockstep Agent Substrate upgrades across unrelated demos (for example, coupling a GA `gvisor` demo to a preview `microvm` runner demo).
- **Safe coexistence on shared clusters**: Operators evaluating multiple demos on an existing GKE + Agent Substrate cluster need `make deploy` and `make teardown` to install and surgically remove only that demo's resources without touching `ate-system` or sibling workloads, while first-time evaluators starting from an empty GCP project need `make cluster-up` and `make cluster-down` to handle the exact node-pool hardware (`gvisor` vs. `c3` nested-virtualization `microvm`, Filestore, Workload Identity) and leave zero leaked cloud spend afterward.
- **Terraform compatibility without monolithic state**: Demos using Terraform split `terraform/cluster/` (wired to `cluster-up` / `cluster-down`) from `terraform/demo/` (wired to `deploy` / `teardown`) rather than combining cluster creation and app deployment in a single Terraform state, preventing `make teardown` from destroying a shared cluster.
