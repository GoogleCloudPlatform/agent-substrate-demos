# Web UI, Diagram & Media Standards

Standards for interactive web interfaces, architecture diagrams, and demo recordings across `GoogleCloudPlatform/agent-substrate-demos`.

## 1. Web UI Design & Security Rules

Apply these rules whenever a demo includes a browser UI:

1. **Clean primary surface + `⌘K` presenter drawer**: Keep the default view realistic and minimal (for chat/agent demos: centered conversation stream + persistent prompt preset bar above the bottom composer). Hide scenario triggers, security/chaos toggles, and presenter shortcuts inside a modal or drawer opened via `⌘K` (and a subtle header icon button).
2. **Vector icons only**: Use crisp inline SVG icons (such as Lucide or FontAwesome SVGs) rather than emoji characters for UI controls, status badges, and navigation.
3. **Zero-layout-shift Projector Light/Dark toggle**: Include an icon-only theme toggle (Moon for dark, Sun for light, zero text label) at the top-right corner. Switching themes must override CSS color tokens only — zero layout shift, reflow, or element resizing.
4. **Path-based routing & visual `/about` view**: Use real URL paths (`/`, `/about`, `/settings`) rather than query-string view toggles (`?view=settings`). When including an `/about` ("How It Works") route, prefer interactive SVG topology graphs, animated signal flows, and state machines over walls of prose, and keep `/about` synchronized whenever architecture changes.
5. **No long-lived browser secrets**: Never prompt for or store Personal Access Tokens (PATs) or API keys in `localStorage`, `sessionStorage`, or persistent databases. Use OAuth 2.0 + PKCE flows storing short-lived tokens strictly in an ephemeral in-memory backend vault with automatic TTL expiry, and surface `LIVE` vs. `FIXTURE` badges on external tool calls.
6. **Table & pill layout guardrails**: Never attach `display: flex` or `display: grid` directly to `<td>` or `<th>` elements (wrap inner chip containers in `<td><div class="chip-row">...</div></td>`), and use `min-height` + `height: auto` on buttons and pills rather than fixed `height`.

## 2. Live Visual Verification (Playwright)

Before opening or merging a PR that adds or modifies web UI files (`*.html`, `*.css`, `*.js`, `*.ts`, `*.tsx`, or inline SVGs), run a headless Playwright audit across:

- **Viewports**: `1280x800` and `1440x900`
- **Themes**: Both **Light** and **Dark** modes (asserting identical bounding-box dimensions across theme switches)
- **States**: Both empty initial state and populated/hydrated state across every route, tab, and `⌘K` modal/drawer

## 3. Architecture Diagrams (`.svg` & Mermaid)

- Place static diagrams in `<demo-slug>/assets/` (`<= 2 MB` per file) or use native GitHub Mermaid blocks in `README.md`.
- **OSS compliance on `.svg` files**: Every `.svg` file must start with the full Google Apache 2.0 XML comment header (`Licensed under the Apache License, Version 2.0`, see [`docs/policy/demo-standards.md`](demo-standards.md#5-license-header-requirement)) and must **not** embed third-party `@font-face` data URIs or `OFL` font license blocks (which Mermaid/Excalidraw exports sometimes inject and open-source license scanners reject). Use standard system/web-safe `font-family` stacks instead.
- Route SVG topology edges cleanly via orthogonal channels with a top-layer label overlay so connectors and labels never pass underneath opaque node boxes.

## 4. Demo Videos (YouTube Links Only)

- **Zero video files in git**: `.mp4`, `.mov`, `.webm`, `.avi`, `.mkv`, and `.m4v` files are blocked by `./hack/check-hygiene.sh` to keep `git clone` fast forever.
- **Upload as Unlisted (or Public) on YouTube**: Host walkthrough videos on YouTube (Unlisted works cleanly for review and sharing before or after public launch) and link them near the top of `<demo-slug>/README.md` via a clickable preview image (`assets/preview.png` or `assets/preview.webp`, `<= 2 MB`):
  ```markdown
  [![Watch the demo walkthrough](assets/preview.png)](https://youtu.be/<VIDEO_ID>)
  ```
- **Recording conventions (always against a live cluster)**:
  - **Web UIs**: Record at `1920x1080` `30fps` inside a clean browser frame, smoothly zooming into active UI regions for readability.
  - **Terminal / CLI demos**: Record against a real GKE + Agent Substrate cluster (never mocked static playback) using high-contrast ANSI colors (e.g., Gruvbox Dark) inside a clean rounded terminal frame.
