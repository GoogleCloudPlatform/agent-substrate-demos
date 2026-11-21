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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

MAX_FILE_BYTES=$((2 * 1024 * 1024)) # 2 MiB
REQUIRED_MAKE_TARGETS=(help cluster-up cluster-down check-prereqs deploy teardown demo verify-live)

failures=0
fail() {
  echo "ERROR: $*" >&2
  failures=$((failures + 1))
}

echo "==> Running repository hygiene checks in ${REPO_ROOT}"

# Collect tracked + unignored files (excluding deleted files in working tree)
mapfile -t ALL_FILES < <(
  {
    git ls-files
    git ls-files --others --exclude-standard
  } | sort -u
)

for f in "${ALL_FILES[@]}"; do
  [[ -e "${f}" ]] || continue
  [[ -L "${f}" ]] && continue

  # 1. Block committed video files (must be hosted on YouTube)
  case "${f,,}" in
    *.mp4|*.mov|*.webm|*.avi|*.mkv|*.m4v)
      fail "${f}: video files must not be committed to git; upload to YouTube (Unlisted or Public) and link in README.md"
      ;;
  esac

  # 2. Enforce <= 2 MiB per-file budget
  size_bytes="$(wc -c < "${f}")"
  if (( size_bytes > MAX_FILE_BYTES )); then
    fail "${f}: file size (${size_bytes} bytes) exceeds 2 MiB limit (${MAX_FILE_BYTES} bytes)"
  fi

  # 3. Block Terraform state, non-example tfvars/env files, and private keys
  base="$(basename "${f}")"
  case "${base}" in
    *.tfstate|*.tfstate.*)
      fail "${f}: Terraform state files must never be committed"
      ;;
    *.tfvars|*.tfvars.json)
      if [[ "${base}" != *.tfvars.example && "${base}" != *.tfvars.json.example ]]; then
        fail "${f}: commit *.tfvars.example instead of live *.tfvars"
      fi
      ;;
    .env|.env.*)
      if [[ "${base}" != ".env.example" && "${base}" != *.env.example ]]; then
        fail "${f}: commit .env.example instead of live .env files"
      fi
      ;;
    *.pem|*.key|*.p12)
      fail "${f}: private key/certificate material must not be committed"
      ;;
  esac

  # 4. Require full Google Apache 2.0 header on source, script, Makefile, Terraform, and SVG files
  case "${base}" in
    *.go|*.py|*.ts|*.tsx|*.js|*.mjs|*.cjs|*.sh|*.tf|*.svg|Makefile)
      head_lines="$(head -n 25 "${f}")"
      if ! grep -qi "Copyright" <<<"${head_lines}" || ! grep -qi "Licensed under the Apache License, Version 2.0" <<<"${head_lines}"; then
        fail "${f}: missing full Google Apache 2.0 license header ('Copyright ...' + 'Licensed under the Apache License, Version 2.0') in first 25 lines"
      fi
      ;;
  esac

  # 5. SVG cleanliness (no embedded @font-face or OFL font licenses)
  if [[ "${f,,}" == *.svg ]]; then
    if grep -qiE "@font-face|OFL-1\.1|SIL Open Font License" "${f}"; then
      fail "${f}: SVG contains embedded @font-face or OFL font block; use standard web/system font-family stacks"
    fi
  fi

  # 6. Registry, terminology & OSS Cross dictionary checks on text files
  case "${base}" in
    *.md|*.go|*.py|*.ts|*.tsx|*.js|*.sh|*.tf|*.yaml|*.yml|*.json|*.toml|*.lock|Makefile)
      if grep -qE "a[i]rlock-proxy|u[p]link\.goog" "${f}"; then
        fail "${f}: contains internal Airlock mirror URL; regenerate lockfiles against pypi.org or registry.npmjs.org"
      fi
      if grep -qiE "V[e]rtex AI|G[e]mini Enterprise Agent Platform|G[e]mini Agent Platform|G[e]mini on Agent Platform" "${f}"; then
        fail "${f}: uses retired branding; use canonical 'Gemini platform'"
      fi
      if grep -qiE "fl[u]id compute" "${f}"; then
        fail "${f}: uses internal terminology; use 'compute obtainability' or 'designing for obtainability'"
      fi
      if grep -qE "s[a]ndbox\.[a-zA-Z]" "${f}"; then
        fail "${f}: contains 'sandbox' followed immediately by a dot and word, which triggers open-source domain-leak false positives"
      fi
      ;;
  esac
done

# 7. Validate every top-level <demo-slug>/ directory against the repository contract
mapfile -t DEMO_DIRS < <(
  find . -mindepth 1 -maxdepth 1 -type d \
    ! -name '.git' \
    ! -name '.github' \
    ! -name 'docs' \
    ! -name 'hack' \
    -printf '%f\n' | sort
)

if (( ${#DEMO_DIRS[@]} > 0 )); then
  echo "==> Validating ${#DEMO_DIRS[@]} demo director(ies): ${DEMO_DIRS[*]}"
fi

for demo in "${DEMO_DIRS[@]}"; do
  for req_file in README.md AGENTS.md Makefile; do
    if [[ ! -f "${demo}/${req_file}" ]]; then
      fail "${demo}/${req_file}: required file missing"
    fi
  done

  if [[ -f "${demo}/Makefile" ]]; then
    for target in "${REQUIRED_MAKE_TARGETS[@]}"; do
      if ! grep -qE "^${target}:" "${demo}/Makefile"; then
        fail "${demo}/Makefile: missing required target '${target}'"
      fi
    done
  fi

  # Zero cross-demo Go module replace directives
  if [[ -f "${demo}/go.mod" ]]; then
    if grep -qE "replace[[:space:]].*=>[[:space:]]*\.\./" "${demo}/go.mod"; then
      fail "${demo}/go.mod: cross-directory 'replace ../' directive breaks standalone demo isolation"
    fi
  fi

  # Split Terraform state check when Terraform manages both cluster-up and deploy
  if [[ -d "${demo}/terraform" && -f "${demo}/Makefile" ]]; then
    if grep -A3 -E "^cluster-up:" "${demo}/Makefile" | grep -q "terraform" && \
       grep -A3 -E "^deploy:" "${demo}/Makefile" | grep -q "terraform"; then
      if [[ ! -d "${demo}/terraform/cluster" || ! -d "${demo}/terraform/demo" ]]; then
        fail "${demo}/terraform: demos using Terraform for both cluster-up and deploy must split state into terraform/cluster/ and terraform/demo/"
      fi
    fi
  fi
done

if (( failures > 0 )); then
  echo "FAILED: ${failures} hygiene check(s) failed." >&2
  exit 1
fi

echo "PASSED: All repository hygiene checks succeeded."
