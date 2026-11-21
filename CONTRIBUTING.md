# How to Contribute

We'd love to accept your patches and reference-architecture demos!

## Before You Begin

### Sign our Contributor License Agreement

Contributions to this project must be accompanied by a
[Contributor License Agreement](https://cla.developers.google.com/about) (CLA).
You (or your employer) retain the copyright to your contribution; this simply
gives us permission to use and redistribute your contributions as part of the
project.

If you or your current employer have already signed the Google CLA (even if it
was for a different project), you probably don't need to do it again.

Visit <https://cla.developers.google.com/> to see your current agreements or to
sign a new one.

### Review our Community Guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google/conduct/).

## Contributing a New Demo

Every top-level `<demo-slug>/` directory in this repository is a **self-contained, standalone reference architecture or interactive showcase** where Agent Substrate primitives (gVisor/MicroVM sandboxes, checkpoint/restore, copy-on-write snapshot forks, zero-slot request parking, `EgressPolicy` / `atenet` credential injection, or Agent Volumes) do load-bearing architectural work on GKE. *(Step-by-step introductory tutorials belong in [`GoogleCloudPlatform/agent-substrate-workshop`](https://github.com/GoogleCloudPlatform/agent-substrate-workshop).)*

### 1. Bootstrap Your Demo Folder

Generate a compliant starter directory (with either Shell scripts or split Terraform modules):

```bash
# Shell / ko / kubectl starter:
./hack/scaffold-demo.sh my-demo

# Or Terraform-backed starter (split terraform/cluster and terraform/demo modules):
./hack/scaffold-demo.sh my-demo --terraform
```

### 2. Follow the Repository Standards

- **[AGENTS.md](AGENTS.md)**: Core scope, security, portability, and completion criteria (compatible with Gemini CLI, Claude Code, Cursor, Codex, and Jetski).
- **[Demo Engineering & Lifecycle Standards](docs/policy/demo-standards.md)**: The mandatory 8-target `Makefile` UX (`cluster-up`, `cluster-down`, `check-prereqs`, `deploy`, `teardown`, `demo`, `verify-live`, `help`), split Terraform state rules, and Good Cluster Citizen coexistence rules.
- **[Demo `README.md` Template](docs/policy/readme-template.md)**: Required 6-section user guide structure.
- **[Web UI, Diagram & Media Standards](docs/policy/ui-and-media.md)**: UI patterns, Playwright visual checks, clean Apache-2.0 SVGs, and **YouTube-only** video hosting (upload walkthrough videos as Unlisted or Public on YouTube; do not commit video files to git).

### 3. Verify Locally Before Opening a Pull Request

1. Run the repository hygiene gate:
   ```bash
   ./hack/check-hygiene.sh
   ```
2. Run your demo's unit tests, linters, and (for UI demos) headless Playwright visual checks.
3. Verify **both** install/uninstall tracks against a real GKE + Agent Substrate cluster — specifically proving `make deploy && make verify-live && make teardown` leaves `ate-system` and sibling workloads untouched — and include the `make verify-live` output in your Pull Request description.

## Code Reviews

All submissions, including submissions by project members, require review via
GitHub Pull Requests. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.
