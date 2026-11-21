# Demo `README.md` Template

Every `<demo-slug>/README.md` must follow this 6-section structure so readers can understand what the demo does in 10 seconds, deploy it onto either an existing cluster or a clean GCP project in minutes, and tear it down cleanly.

## Writing Rules

1. **Command first, explanation after**: In Quickstart and Guided Scenarios, show the runnable command and expected output first, followed immediately by a brief *"What this output means"* explanation.
2. **YouTube-only video embeds**: GitHub Markdown strips `<iframe>` embeds and rejects large video blobs in git. Upload walkthrough videos to **YouTube (Unlisted or Public)** and link them with a clickable preview image (`assets/preview.png` `<= 2 MB`) as shown below.
3. **Zero personal identifiers**: Use generic placeholders or `gcloud config` / `kubectl config current-context` defaults in prose and output snippets.

---

## Copy-Paste Template

````markdown
# <Demo Title>

<One-sentence summary of what this reference architecture builds on GKE with Agent Substrate.>

| Attribute | Value |
|---|---|
| **Agent Substrate Primitives** | `<e.g., gVisor Actors, Checkpoint/Restore, EgressPolicy + atenet MITM>` |
| **Runtime Tier** | `GA (v1.0+)` *(or `Preview (--preview=<FlagName>)`)* |
| **Cluster Hardware** | `Standard GKE 1.37+ (gVisor node pool)` *(or `C3 Nested-Virt MicroVM` / `Cloud Filestore`)* |
| **Time to First Demo** | `~5 minutes` *(on an existing cluster)* |
| **External Credentials** | `None required` *(or `Optional — defaults to FIXTURE mode; supports LIVE OAuth`)* |

[![Watch the <Demo Title> walkthrough](assets/preview.png)](https://youtu.be/<YOUTUBE_VIDEO_ID>)
*Click above to watch the walkthrough on YouTube.*

## Why Agent Substrate Here

<One concise paragraph explaining what breaks or requires complex workarounds on stateless Kubernetes Deployments/Jobs, and which Agent Substrate primitive solves that exact architectural problem.>

## Architecture

![<Demo Title> Architecture](assets/architecture.svg)

<3–5 short bullets walking through the request path, actor lifecycle boundary, and network/credential boundary.>

## Quickstart

Choose **Option A** if you already have a GKE 1.37+ cluster with Agent Substrate installed, or **Option B** to provision a clean cluster from an empty Google Cloud project.

### Option A: Install on an Existing GKE + Agent Substrate Cluster

```bash
make check-prereqs
make deploy
make demo
```

**What this does**: Verifies your active `kubectl` context and Agent Substrate CRDs, deploys the demo into its own namespace without modifying `ate-system`, and opens the interactive demo endpoint.

### Option B: Clean Install From Scratch (New GKE Cluster + Agent Substrate)

```bash
export PROJECT_ID="$(gcloud config get-value project)"
make cluster-up
make deploy
make demo
```

**What this does**: Provisions a dedicated GKE cluster with the required node pools, Workload Identity Federation, and Agent Substrate installation, then deploys and launches the demo.

## Things to Try

### 1. <Scenario 1 Title — e.g., Trigger Actor Checkpoint & Instant Restore>

```bash
<runnable command or UI action>
```

```text
<expected output>
```

**What this output means**: <1–2 sentences connecting the observable output back to the Agent Substrate primitive.>

### 2. <Scenario 2 Title — e.g., Verify Default-Deny Egress Enforcement>

```bash
<runnable command or automated check>
```

```text
<expected output>
```

**What this output means**: <1–2 sentences explaining the boundary proved here.>

### Automated End-to-End Verification

```bash
make verify-live
```

## Cleanup

If you installed onto an **existing cluster** (Option A), remove only this demo's resources while leaving `ate-system` and all other workloads untouched:

```bash
make teardown
```

If you provisioned a **dedicated cluster from scratch** (Option B), delete the cluster and all associated Google Cloud resources so zero spend leaks:

```bash
make cluster-down
```
````
