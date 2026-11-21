## Summary

<!-- Briefly describe what this PR adds or changes, and which Agent Substrate primitives are load-bearing here. -->

## Demo & Policy Checklist

- [ ] `./hack/check-hygiene.sh` passes locally (`0` errors)
- [ ] Demo lives in a standalone `<demo-slug>/` folder with zero cross-demo code imports
- [ ] Exposes all 8 standard `Makefile` targets (`help`, `cluster-up`, `cluster-down`, `check-prereqs`, `deploy`, `teardown`, `demo`, `verify-live`)
- [ ] If using Terraform for both tracks, state is split into `terraform/cluster/` and `terraform/demo/`
- [ ] Zero secrets in actor `env`/disk or browser storage; explicit `EgressPolicy` allowlists; zero hardcoded project/cluster names
- [ ] `<demo-slug>/README.md` follows [`docs/policy/readme-template.md`](docs/policy/readme-template.md) and links any walkthrough video via **YouTube** (no video files committed to git)
- [ ]*(Web UI demos only)* Headless Playwright visual check passes across Light & Dark modes at `1280x800` and `1440x900`

## Live Cluster Verification Evidence

<!-- Required when adding a new demo or upgrading Agent Substrate / GKE versions. Paste output from `make deploy && make verify-live && make teardown` proving end-to-end execution and surgical teardown. -->

```text
Paste `make verify-live` and `make teardown` output here (or write "N/A — docs/repo-tooling change only").
```
