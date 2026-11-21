# AGENTS.md

Guidance for AI coding agents working in `GoogleCloudPlatform/agent-substrate-demos` — self-contained reference architectures and interactive showcases for **Agent Substrate** (`ate.dev`) on **Google Kubernetes Engine (GKE)**.

## Scope & Admission Bar

- **Load-bearing actors**: Every top-level `<demo-slug>/` directory must solve a concrete architectural problem where an Agent Substrate primitive — gVisor or MicroVM sandboxing, checkpoint/restore, copy-on-write snapshot fork, zero-slot request parking, `EgressPolicy` / `atenet` credential injection, or Agent Volumes — does load-bearing work that stateless Kubernetes pods cannot cleanly do. Both AI agent systems and stateful infrastructure/workflow systems belong here.
- **Keep step-by-step tutorials in the workshop repo**: Single-primitive exercises and progressive codelabs belong in `GoogleCloudPlatform/agent-substrate-workshop`.
- **Standalone directories (zero cross-demo imports)**: Place each demo in `<demo-slug>/` at the repository root with its own dependency manifest (`go.mod`, `pyproject.toml`, `package.json`). Demos must be 100% standalone-copyable and must never import application code from sibling demos or a shared root package.

## Runtime, Security & Portability Invariants

1. **Real Agent Substrate execution**: Target live `ate.dev/v1` (`WorkerPool`, `ActorTemplate`, `Actor`, `EgressPolicy`) on GKE 1.37+ (and `kind` where supported). In-memory fakes are allowed only inside unit tests.
2. **Explicit `LIVE` vs. `FIXTURE` provenance for external SaaS**: Demos integrating optional third-party SaaS (GitHub OAuth, Jira, Slack, Gmail) must run out-of-the-box on GKE + **Gemini platform** via deterministic `FIXTURE` fallbacks while supporting real `LIVE` credentials, surfacing visible `LIVE` / `FIXTURE` badges.
3. **Zero-secret sandboxes**: Keep API keys, OAuth tokens, and cloud credentials out of actor `env`, actor filesystems, and browser `localStorage`/`sessionStorage`. Enforce explicit `EgressPolicy` allowlists, Workload Identity Federation for GKE, OAuth 2.0 + PKCE (ephemeral backend vault), or `atenet` Egress MITM.
4. **Environment-derived configuration**: Derive project, cluster, and region defaults from `gcloud config` and `kubectl config current-context` with environment-variable overrides (`PROJECT_ID`, `CLUSTER_NAME`, `REGION`/`ZONE`). Never commit personal project IDs, cluster names, or node hostnames.
5. **Public registries & canonical naming**: Resolve Python and Node lockfiles strictly against `https://pypi.org/simple` (`uv lock --no-config`) and `https://registry.npmjs.org/`. Use Google Cloud's canonical **Gemini platform** branding and public **compute obtainability** terminology.

## Two-Track Lifecycle & `Makefile` Contract

Every `<demo-slug>/Makefile` must expose these 8 targets (`help` as default), backed by either shell scripts (`hack/*.sh`) or split Terraform modules (`terraform/cluster/` and `terraform/demo/`):

| Target | Responsibility |
|---|---|
| `make help` | Print available targets and key environment overrides. |
| `make cluster-up` | **Clean Track**: Provision a dedicated GKE cluster, required node pools/APIs, and Agent Substrate (`ate-system`) from an empty GCP project. |
| `make cluster-down` | **Clean Track**: Delete every cloud resource created by `cluster-up` (guarded so it only deletes matching `CLUSTER_NAME`) with zero leaked spend. |
| `make check-prereqs` | **Existing-Cluster Track**: Fast preflight checking CLI tools, active `kubectl` context, Agent Substrate CRDs, required sandbox node pool (`gvisor` or `microvm`), and GCP APIs. |
| `make deploy` | **Existing-Cluster Track**: Idempotently deploy demo cloud/K8s resources onto an existing cluster where Agent Substrate is pre-installed. |
| `make teardown` | **Existing-Cluster Track**: Surgically remove only the demo's resources (removing merged `AccessPolicy` subjects cleanly) without touching `ate-system` or other workloads. |
| `make demo` | Start port-forwarding / print the live URL or run the guided interactive CLI flow. |
| `make verify-live` | Non-interactive end-to-end verification against the deployed cluster (exits `0` on pass, non-zero on failure). |

**Good Cluster Citizen rules**: Deploy into domain-natural namespaces (avoid `default` and `kube-system`), prefix any `ClusterRole` or `ate-system` `RoleBinding` with the demo's app name, and merge subjects into singleton Agent Substrate `AccessPolicy` objects rather than overwriting them. When using Terraform for both tracks, keep `terraform/cluster/` state separate from `terraform/demo/` state so `make teardown` never destroys the cluster.

## Context Pointers

Read the matching reference before starting work in any of these branches:

- **Scaffold or review a demo** → [`docs/policy/demo-standards.md`](docs/policy/demo-standards.md) for Shell and Terraform `Makefile` templates, split `terraform/{cluster,demo}` layout, `AccessPolicy` merge helpers, and per-demo `<demo-slug>/AGENTS.md` structure. Use `./hack/scaffold-demo.sh <demo-slug> [--terraform]` to bootstrap a compliant folder.
- **Write or edit a demo `README.md`** → [`docs/policy/readme-template.md`](docs/policy/readme-template.md) for the required 6-section layout, Quick-Facts header table, YouTube clickable thumbnail snippet, and command-first quickstart rules.
- **Build a web UI, author SVG diagrams, or record a video** → [`docs/policy/ui-and-media.md`](docs/policy/ui-and-media.md) for the `⌘K` controls pattern, zero-layout-shift Light/Dark projector toggle, Apache-2.0 SVG rules, Playwright `1280x800` & `1440x900` visual audit, and YouTube-only video hosting (`<= 2 MB` git image cap).
- **Modify repo layout or shared tooling** → [`docs/adr/0001-standalone-demos-and-two-track-lifecycle.md`](docs/adr/0001-standalone-demos-and-two-track-lifecycle.md) for architectural constraints across demos.

When working inside `<demo-slug>/`, also read `<demo-slug>/AGENTS.md` (and `<demo-slug>/docs/adr/` if present) before editing code.

## Completion Criteria (Required Before Opening or Updating a PR)

1. `./hack/check-hygiene.sh` exits `0` (verifies Apache 2.0 headers, SVG cleanliness, zero committed video blobs, `<= 2 MB` asset cap, lockfile URLs, naming, and the 8-target `Makefile` contract).
2. All unit/integration tests, linters, `terraform fmt -check` / `terraform validate` (when `*.tf` is present), and headless Playwright audits (when a web UI is present) pass.
3. For new demos or runtime upgrades, both `make deploy && make verify-live && make teardown` on a live GKE + Agent Substrate cluster succeed, with captured output included in the PR body.
