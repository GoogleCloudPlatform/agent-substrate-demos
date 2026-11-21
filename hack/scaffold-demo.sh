#!/usr/bin/env bash
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

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./hack/scaffold-demo.sh <demo-slug> [--terraform]

Creates a compliant starter <demo-slug>/ directory with:
  - AGENTS.md, README.md, Makefile (8 standard targets), and assets/architecture.svg
  - Either shell lifecycle scripts in hack/ (default)
  - Or split Terraform modules in terraform/{cluster,demo}/ (--terraform)
EOF
}

if (( $# < 1 || $# > 2 )); then
  usage >&2
  exit 1
fi

SLUG="$1"
MODE="shell"
if (( $# == 2 )); then
  if [[ "$2" == "--terraform" ]]; then
    MODE="terraform"
  else
    usage >&2
    exit 1
  fi
fi

if [[ ! "${SLUG}" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "ERROR: demo slug '${SLUG}' must match ^[a-z0-9][a-z0-9-]*$" >&2
  exit 1
fi

case "${SLUG}" in
  docs|hack|.github|.git)
    echo "ERROR: '${SLUG}' is a reserved repository directory name" >&2
    exit 1
    ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${REPO_ROOT}/${SLUG}"

if [[ -e "${TARGET_DIR}" ]]; then
  echo "ERROR: '${TARGET_DIR}' already exists" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}/assets" "${TARGET_DIR}/hack"

HASH_HEADER="# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the \"License\");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an \"AS IS\" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License."

cat > "${TARGET_DIR}/AGENTS.md" <<EOF
# AGENTS.md — ${SLUG}

## Architecture Invariants

- Describe the load-bearing Agent Substrate primitives used by \`${SLUG}\` (\`WorkerPool\`, \`ActorTemplate\`, \`EgressPolicy\`, checkpoint/restore, or Agent Volumes).
- Namespace / atespace: \`${SLUG}\` (override via \`NAMESPACE\`).

## Local Verification Commands

- Repository hygiene: \`../hack/check-hygiene.sh\`
- Live cluster E2E check: \`make verify-live\`

## Gotchas

- Document any demo-specific quota, hardware, or external integration notes here.
EOF

cat > "${TARGET_DIR}/assets/architecture.svg" <<EOF
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
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 220" width="720" height="220">
  <rect width="720" height="220" rx="12" fill="#0f172a"/>
  <rect x="32" y="60" width="180" height="100" rx="8" fill="#1e293b" stroke="#38bdf8" stroke-width="2"/>
  <text x="122" y="106" text-anchor="middle" fill="#f8fafc" font-family="system-ui, sans-serif" font-size="15" font-weight="600">Client / Gateway</text>
  <text x="122" y="128" text-anchor="middle" fill="#94a3b8" font-family="system-ui, sans-serif" font-size="12">GKE Workload</text>
  <line x1="212" y1="110" x2="276" y2="110" stroke="#38bdf8" stroke-width="2"/>
  <rect x="276" y="60" width="180" height="100" rx="8" fill="#1e293b" stroke="#34d399" stroke-width="2"/>
  <text x="366" y="106" text-anchor="middle" fill="#f8fafc" font-family="system-ui, sans-serif" font-size="15" font-weight="600">Agent Substrate</text>
  <text x="366" y="128" text-anchor="middle" fill="#94a3b8" font-family="system-ui, sans-serif" font-size="12">ate.dev/v1 Router</text>
  <line x1="456" y1="110" x2="516" y2="110" stroke="#34d399" stroke-width="2"/>
  <rect x="516" y="60" width="172" height="100" rx="8" fill="#1e293b" stroke="#a78bfa" stroke-width="2"/>
  <text x="602" y="106" text-anchor="middle" fill="#f8fafc" font-family="system-ui, sans-serif" font-size="15" font-weight="600">${SLUG} Actor</text>
  <text x="602" y="128" text-anchor="middle" fill="#94a3b8" font-family="system-ui, sans-serif" font-size="12">Isolated Runtime</text>
</svg>
EOF

cat > "${TARGET_DIR}/README.md" <<EOF
# ${SLUG}

One-sentence summary of what \`${SLUG}\` builds on GKE with Agent Substrate.

| Attribute | Value |
|---|---|
| **Agent Substrate Primitives** | \`gVisor Actors, EgressPolicy\` |
| **Runtime Tier** | \`GA (v1.0+)\` |
| **Cluster Hardware** | \`Standard GKE 1.37+ (gVisor node pool)\` |
| **Time to First Demo** | \`~5 minutes\` *(on an existing cluster)* |
| **External Credentials** | \`None required\` |

[![Watch the ${SLUG} walkthrough](assets/architecture.svg)](https://www.youtube.com/watch?v=REPLACE_WITH_YOUTUBE_ID)
*Replace \`REPLACE_WITH_YOUTUBE_ID\` with your Unlisted or Public YouTube walkthrough link.*

## Why Agent Substrate Here

Explain in one concise paragraph what breaks on stateless Kubernetes Deployments/Jobs and how Agent Substrate solves it here.

## Architecture

![${SLUG} Architecture](assets/architecture.svg)

- **Gateway / Orchestrator**: Routes incoming turns or jobs to isolated actors.
- **Actor Runtime**: Executes stateful work with scoped outbound \`EgressPolicy\`.

## Quickstart

Choose **Option A** if you already have a GKE 1.37+ cluster with Agent Substrate installed, or **Option B** to provision a clean cluster from an empty Google Cloud project.

### Option A: Install on an Existing GKE + Agent Substrate Cluster

\`\`\`bash
make check-prereqs
make deploy
make demo
\`\`\`

**What this does**: Verifies your active \`kubectl\` context and Agent Substrate CRDs, deploys \`${SLUG}\` into its own namespace without modifying \`ate-system\`, and launches the demo entrypoint.

### Option B: Clean Install From Scratch (New GKE Cluster + Agent Substrate)

\`\`\`bash
export PROJECT_ID="\$(gcloud config get-value project)"
make cluster-up
make deploy
make demo
\`\`\`

**What this does**: Provisions a dedicated GKE cluster with Workload Identity Federation and Agent Substrate installed, then deploys and launches \`${SLUG}\`.

## Things to Try

### 1. Run Automated End-to-End Verification

\`\`\`bash
make verify-live
\`\`\`

**What this output means**: Confirms actor creation, execution, and expected policy boundaries against your live GKE cluster.

## Cleanup

If you installed onto an **existing cluster** (Option A), remove only this demo's resources while leaving \`ate-system\` and other workloads untouched:

\`\`\`bash
make teardown
\`\`\`

If you provisioned a **dedicated cluster from scratch** (Option B), delete the cluster and all associated Google Cloud resources:

\`\`\`bash
make cluster-down
\`\`\`
EOF

write_stub_script() {
  local path="$1"
  local msg="$2"
  cat > "${path}" <<EOF
#!/usr/bin/env bash
${HASH_HEADER}

set -euo pipefail

echo "==> [${SLUG}] ${msg}"
EOF
  chmod +x "${path}"
}

write_stub_script "${TARGET_DIR}/hack/check-prereqs.sh" "Checking prerequisites on active kubectl context"
write_stub_script "${TARGET_DIR}/hack/demo.sh" "Launching interactive demo entrypoint"
write_stub_script "${TARGET_DIR}/hack/verify-live.sh" "Running non-interactive live cluster verification"

if [[ "${MODE}" == "shell" ]]; then
  mkdir -p "${TARGET_DIR}/manifests"
  write_stub_script "${TARGET_DIR}/hack/cluster-up.sh" "Provisioning clean GKE cluster \${CLUSTER_NAME:-${SLUG}-cluster} + Agent Substrate"
  cat > "${TARGET_DIR}/hack/cluster-down.sh" <<EOF
#!/usr/bin/env bash
${HASH_HEADER}

set -euo pipefail

: "\${CLUSTER_NAME:?CLUSTER_NAME must be set before deleting a cluster}"
echo "==> [${SLUG}] Deleting dedicated cluster \${CLUSTER_NAME}"
EOF
  chmod +x "${TARGET_DIR}/hack/cluster-down.sh"
  write_stub_script "${TARGET_DIR}/hack/deploy.sh" "Deploying demo workloads into namespace \${NAMESPACE:-${SLUG}}"
  write_stub_script "${TARGET_DIR}/hack/teardown.sh" "Removing only ${SLUG} resources (leaving ate-system intact)"

  cat > "${TARGET_DIR}/Makefile" <<EOF
${HASH_HEADER}

PROJECT_ID   ?= \$(shell gcloud config get-value project 2>/dev/null)
REGION       ?= us-central1
ZONE         ?= us-central1-a
CLUSTER_NAME ?= ${SLUG}-cluster
NAMESPACE    ?= ${SLUG}

.DEFAULT_GOAL := help
.PHONY: help cluster-up cluster-down check-prereqs deploy teardown demo verify-live

help: ## Show available targets and environment overrides
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' \$(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\\n", \$\$1, \$\$2}'

cluster-up: ## Provision a clean GKE cluster + Agent Substrate from scratch
	PROJECT_ID="\$(PROJECT_ID)" REGION="\$(REGION)" ZONE="\$(ZONE)" CLUSTER_NAME="\$(CLUSTER_NAME)" ./hack/cluster-up.sh

cluster-down: ## Delete the dedicated GKE cluster created by cluster-up
	PROJECT_ID="\$(PROJECT_ID)" REGION="\$(REGION)" ZONE="\$(ZONE)" CLUSTER_NAME="\$(CLUSTER_NAME)" ./hack/cluster-down.sh

check-prereqs: ## Verify CLI tools, active kubectl context, Substrate CRDs, and node pools
	PROJECT_ID="\$(PROJECT_ID)" NAMESPACE="\$(NAMESPACE)" ./hack/check-prereqs.sh

deploy: check-prereqs ## Deploy demo resources onto an existing GKE + Agent Substrate cluster
	PROJECT_ID="\$(PROJECT_ID)" REGION="\$(REGION)" NAMESPACE="\$(NAMESPACE)" ./hack/deploy.sh

teardown: ## Surgically remove only this demo's resources (leaves ate-system intact)
	PROJECT_ID="\$(PROJECT_ID)" REGION="\$(REGION)" NAMESPACE="\$(NAMESPACE)" ./hack/teardown.sh

demo: ## Launch port-forwarding or interactive walkthrough
	NAMESPACE="\$(NAMESPACE)" ./hack/demo.sh

verify-live: ## Run non-interactive end-to-end verification against the live deployment
	PROJECT_ID="\$(PROJECT_ID)" NAMESPACE="\$(NAMESPACE)" ./hack/verify-live.sh
EOF
else
  mkdir -p "${TARGET_DIR}/terraform/cluster" "${TARGET_DIR}/terraform/demo"
  for mod in cluster demo; do
    cat > "${TARGET_DIR}/terraform/${mod}/main.tf" <<EOF
${HASH_HEADER}

terraform {
  required_version = ">= 1.5.0"
}
EOF
    cat > "${TARGET_DIR}/terraform/${mod}/variables.tf" <<EOF
${HASH_HEADER}

variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Google Cloud zone."
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "Target GKE cluster name."
  type        = string
  default     = "${SLUG}-cluster"
}
EOF
    cat > "${TARGET_DIR}/terraform/${mod}/outputs.tf" <<EOF
${HASH_HEADER}
EOF
    cat > "${TARGET_DIR}/terraform/${mod}/terraform.tfvars.example" <<EOF
${HASH_HEADER}

project_id   = "your-gcp-project-id"
region       = "us-central1"
zone         = "us-central1-a"
cluster_name = "${SLUG}-cluster"
EOF
  done

  cat > "${TARGET_DIR}/Makefile" <<EOF
${HASH_HEADER}

PROJECT_ID   ?= \$(shell gcloud config get-value project 2>/dev/null)
REGION       ?= us-central1
ZONE         ?= us-central1-a
CLUSTER_NAME ?= ${SLUG}-cluster
TF_CLUSTER   := terraform -chdir=terraform/cluster
TF_DEMO      := terraform -chdir=terraform/demo
TF_VARS      = -var="project_id=\$(PROJECT_ID)" -var="region=\$(REGION)" -var="zone=\$(ZONE)" -var="cluster_name=\$(CLUSTER_NAME)"

.DEFAULT_GOAL := help
.PHONY: help cluster-up cluster-down check-prereqs deploy teardown demo verify-live

help: ## Show available targets and environment overrides
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' \$(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\\n", \$\$1, \$\$2}'

cluster-up: ## Provision a clean GKE cluster + Agent Substrate via terraform/cluster
	\$(TF_CLUSTER) init
	\$(TF_CLUSTER) apply -auto-approve \$(TF_VARS)
	gcloud container clusters get-credentials "\$(CLUSTER_NAME)" --zone "\$(ZONE)" --project "\$(PROJECT_ID)"

cluster-down: ## Destroy the dedicated cluster provisioned by terraform/cluster
	\$(TF_CLUSTER) destroy -auto-approve \$(TF_VARS)

check-prereqs: ## Verify CLI tools, active kubectl context, Substrate CRDs, and node pools
	PROJECT_ID="\$(PROJECT_ID)" ./hack/check-prereqs.sh

deploy: check-prereqs ## Deploy demo workloads & GCP bindings onto the existing cluster
	\$(TF_DEMO) init
	\$(TF_DEMO) apply -auto-approve \$(TF_VARS)

teardown: ## Destroy only demo workloads & GCP bindings (leaves cluster & ate-system intact)
	\$(TF_DEMO) destroy -auto-approve \$(TF_VARS)

demo: ## Launch port-forwarding or interactive walkthrough
	./hack/demo.sh

verify-live: ## Run non-interactive end-to-end verification against the live deployment
	./hack/verify-live.sh
EOF
fi

echo "Scaffolded ${MODE} demo starter at ${TARGET_DIR}"
