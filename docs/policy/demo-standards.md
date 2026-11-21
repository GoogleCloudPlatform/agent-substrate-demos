# Demo Engineering & Lifecycle Standards

Reference specification for scaffolding, implementing, and reviewing `<demo-slug>/` directories in `GoogleCloudPlatform/agent-substrate-demos`.

## 1. Directory Layout

Every demo lives at `<demo-slug>/` at the repository root and owns its own dependency manifest (`go.mod`, `pyproject.toml`, or `package.json`). Do not import application code from sibling demos.

### Option A: Shell / `ko` / `kubectl` Layout

```text
<demo-slug>/
├── AGENTS.md               # Demo-specific architecture invariants & test commands
├── Makefile                # 8-target uniform UX wrapper
├── README.md               # Standardized 6-section user guide
├── assets/                 # Apache-2.0 SVGs and screenshots (<= 2 MB each; no video blobs)
├── hack/
│   ├── cluster-up.sh       # Clean GKE + Agent Substrate install
│   ├── cluster-down.sh     # Full cloud teardown (guarded by CLUSTER_NAME)
│   ├── check-prereqs.sh    # Fast existing-cluster preflight
│   ├── deploy.sh           # Idempotent demo install onto existing cluster
│   ├── teardown.sh         # Surgical demo uninstall (leaves ate-system intact)
│   └── verify-live.sh      # Deterministic end-to-end cluster verification
└── manifests/              # Kubernetes & Agent Substrate YAML templates
```

### Option B: Terraform-Backed Layout (Split State)

When Terraform manages both cluster creation and demo resources, split them into **two independent root modules** so `make deploy` / `make teardown` work safely against an existing cluster without touching cluster state:

```text
<demo-slug>/
├── AGENTS.md
├── Makefile                # Wraps terraform -chdir=terraform/cluster and terraform/demo
├── README.md
├── assets/
├── hack/
│   ├── check-prereqs.sh
│   └── verify-live.sh
└── terraform/
    ├── cluster/            # GKE cluster, node pools, VPC/NAT, base ate-system install
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── terraform.tfvars.example
    └── demo/               # Demo-only GCP resources (IAM/WIF, GCS, DBs) & workloads
        ├── main.tf
        ├── variables.tf    # Accepts project_id, cluster_name, location
        ├── outputs.tf
        └── terraform.tfvars.example
```

Demos may also mix approaches (for example, `terraform/cluster/` for GKE + node pools paired with `hack/deploy.sh` + `ko` for fast iterative app deployment). Commit `.terraform.lock.hcl` for reproducible provider versions; never commit `.terraform/`, `*.tfstate*`, or populated `*.tfvars`.

## 2. Starter `Makefile` Templates

### Shell-Backed `Makefile`

```makefile
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PROJECT_ID   ?= $(shell gcloud config get-value project 2>/dev/null)
REGION       ?= us-central1
ZONE         ?= us-central1-a
CLUSTER_NAME ?= <demo-slug>-cluster
NAMESPACE    ?= <demo-namespace>

.DEFAULT_GOAL := help
.PHONY: help cluster-up cluster-down check-prereqs deploy teardown demo verify-live

help: ## Show available targets and environment overrides
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

cluster-up: ## Provision a clean GKE cluster + Agent Substrate from scratch
	PROJECT_ID="$(PROJECT_ID)" REGION="$(REGION)" ZONE="$(ZONE)" CLUSTER_NAME="$(CLUSTER_NAME)" ./hack/cluster-up.sh

cluster-down: ## Delete the dedicated GKE cluster and all cloud resources created by cluster-up
	PROJECT_ID="$(PROJECT_ID)" REGION="$(REGION)" ZONE="$(ZONE)" CLUSTER_NAME="$(CLUSTER_NAME)" ./hack/cluster-down.sh

check-prereqs: ## Verify tools, active kubectl context, Substrate CRDs, and node pools
	PROJECT_ID="$(PROJECT_ID)" NAMESPACE="$(NAMESPACE)" ./hack/check-prereqs.sh

deploy: check-prereqs ## Deploy demo resources onto the active GKE + Agent Substrate cluster
	PROJECT_ID="$(PROJECT_ID)" REGION="$(REGION)" NAMESPACE="$(NAMESPACE)" ./hack/deploy.sh

teardown: ## Surgically remove only this demo's resources (leaves ate-system intact)
	PROJECT_ID="$(PROJECT_ID)" REGION="$(REGION)" NAMESPACE="$(NAMESPACE)" ./hack/teardown.sh

demo: ## Launch port-forwarding or interactive walkthrough
	NAMESPACE="$(NAMESPACE)" ./hack/demo.sh

verify-live: ## Run non-interactive end-to-end verification against the live deployment
	PROJECT_ID="$(PROJECT_ID)" NAMESPACE="$(NAMESPACE)" ./hack/verify-live.sh
```

### Terraform-Backed `Makefile`

```makefile
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PROJECT_ID   ?= $(shell gcloud config get-value project 2>/dev/null)
REGION       ?= us-central1
ZONE         ?= us-central1-a
CLUSTER_NAME ?= <demo-slug>-cluster
TF_CLUSTER   := terraform -chdir=terraform/cluster
TF_DEMO      := terraform -chdir=terraform/demo
TF_VARS      = -var="project_id=$(PROJECT_ID)" -var="region=$(REGION)" -var="zone=$(ZONE)" -var="cluster_name=$(CLUSTER_NAME)"

.DEFAULT_GOAL := help
.PHONY: help cluster-up cluster-down check-prereqs deploy teardown demo verify-live

help: ## Show available targets and environment overrides
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

cluster-up: ## Provision a clean GKE cluster + Agent Substrate via terraform/cluster
	$(TF_CLUSTER) init
	$(TF_CLUSTER) apply -auto-approve $(TF_VARS)
	gcloud container clusters get-credentials "$(CLUSTER_NAME)" --zone "$(ZONE)" --project "$(PROJECT_ID)"

cluster-down: ## Destroy the dedicated cluster provisioned by terraform/cluster
	$(TF_CLUSTER) destroy -auto-approve $(TF_VARS)

check-prereqs: ## Verify tools, active kubectl context, Substrate CRDs, and node pools
	PROJECT_ID="$(PROJECT_ID)" ./hack/check-prereqs.sh

deploy: check-prereqs ## Deploy demo workloads & GCP bindings onto the existing cluster
	$(TF_DEMO) init
	$(TF_DEMO) apply -auto-approve $(TF_VARS)

teardown: ## Destroy only demo workloads & GCP bindings (leaves cluster & ate-system intact)
	$(TF_DEMO) destroy -auto-approve $(TF_VARS)

demo: ## Print live endpoint or start port-forward
	./hack/demo.sh

verify-live: ## Run non-interactive end-to-end verification against the live deployment
	./hack/verify-live.sh
```

## 3. Good Cluster Citizen Rules

1. **Domain-natural namespaces**: Use namespaces and `atespace` names that fit the domain (`aegis-system`, `gha-runners`, or multi-namespace trust boundaries). Never deploy demo workloads into `default` or `kube-system`.
2. **App-scoped shared objects**: Prefix any `ClusterRole`, `ClusterRoleBinding`, custom `SandboxConfig`, or `Role`/`RoleBinding` inside `ate-system` with your demo's identifier (e.g., `aegis-router-cert-reader` instead of `router-cert-reader`) so multiple demos can run side-by-side on one cluster.
3. **Additive `AccessPolicy` management**: Agent Substrate global and per-atespace `AccessPolicy` objects are singletons. Merge your demo's `ServiceAccount` subject into an existing `AccessPolicy` during `deploy` (preserving `uid` and `version` when updating via `kubectl-ate`) and remove only your demo's subject during `teardown` rather than overwriting or deleting shared policies.
4. **Guarded `cluster-down`**: In `hack/cluster-down.sh`, verify `CLUSTER_NAME` is explicitly set (defaulting to `<demo-slug>-cluster`) before calling `gcloud container clusters delete` so an operator never accidentally deletes a shared cluster.

## 4. Per-Demo `<demo-slug>/AGENTS.md` Shape

Keep `<demo-slug>/AGENTS.md` concise (~30–50 lines) and scoped strictly to that demo (do not repeat root `AGENTS.md` rules):

```markdown
# AGENTS.md — <Demo Title>

## Architecture Invariants
- <1-4 bullet summary of load-bearing Agent Substrate primitives, namespaces/atespaces, and security boundaries>

## Local Verification Commands
- Unit & race tests: `<command>`
- Live E2E check: `make verify-live`

## Gotchas
- <Non-obvious runtime, quota, or hardware notes specific to this demo>
```

## 5. License Header Requirement

Include the full Google Apache 2.0 license header at the top of every new source, script, Makefile, YAML, Terraform, and SVG file (short `SPDX-License-Identifier` headers alone emit warnings in open-source license checks):

- Go / TypeScript / JavaScript:
  ```go
  // Copyright 2026 Google LLC
  //
  // Licensed under the Apache License, Version 2.0 (the "License");
  // you may not use this file except in compliance with the License.
  // You may obtain a copy of the License at
  //
  //     http://www.apache.org/licenses/LICENSE-2.0
  //
  // Unless required by applicable law or agreed to in writing, software
  // distributed under the License is distributed on an "AS IS" BASIS,
  // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  // See the License for the specific language governing permissions and
  // limitations under the License.
  ```
- Python / Shell / Makefile / YAML / Terraform:
  ```bash
  # Copyright 2026 Google LLC
  #
  # Licensed under the Apache License, Version 2.0 (the "License");
  # you may not use this file except in compliance with the License.
  # You may obtain a copy of the License at
  #
  #     http://www.apache.org/licenses/LICENSE-2.0
  #
  # Unless required by applicable law or agreed to in writing, software
  # distributed under the License is distributed on an "AS IS" BASIS,
  # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  # See the License for the specific language governing permissions and
  # limitations under the License.
  ```
- SVG diagrams:
  ```xml
  <!--
    Copyright 2026 Google LLC

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
  -->
  ```
