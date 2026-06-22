# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A GitOps mono-repo for a home Kubernetes cluster running on [Talos](https://talos.dev), reconciled by [Flux](https://fluxcd.io) and kept up to date by Renovate. There is no application source code here — everything is declarative YAML (Kubernetes manifests, Helm values, Talos machine config). Changes take effect by being merged to `main` and reconciled by Flux, not by running a build.

## Tooling & commands

Tasks are run through [`just`](https://github.com/casey/just) with [`mise`](https://mise.jdx.dev) managing the toolchain and environment. `mise` exports `KUBECONFIG`, `TALOSCONFIG`, and `FLATE_PATH` (see `.mise/config.toml`), so always run commands through `mise`/`just` rather than invoking `kubectl`/`talosctl`/`flate` with ad-hoc env. Recipes live in `*/mod.just` modules wired up from the root `.justfile`.

```sh
just --list                      # all recipe groups (kube, talos, bootstrap)
just kube --list                 # cluster operational recipes
just talos --list                # node lifecycle recipes
```

Common cluster operations (`just kube …`):

- `sync hr|ks|gitrepo|ocirepo|es` — force-reconcile all resources of a Flux kind
- `apply-ks <ns> <ks>` / `delete-ks <ns> <ks>` — render a Flux Kustomization locally (via `flate build ks`) and apply/delete it
- `restore <ns> <app>` — restore a PVC from VolSync (Kopia) backups
- `snapshot` / `volsync suspend|resume` — trigger or pause VolSync backups
- `browse-pvc <ns> <claim>`, `view-secret <ns> <secret>`, `debug-node <node>`, `prune-pods`

Talos / bootstrap (destructive recipes prompt for confirmation):

- `just talos apply-node <node>`, `upgrade-node <node>`, `upgrade-k8s <version>`, `reboot-node`, `reset-node`
- `just bootstrap cluster` — full Talos + Kubernetes bring-up from scratch

### Validation

There is no test suite. Validation = "does Flux render and accept it." Pre-commit hooks come from a remote `lefthook` config (`.lefthook.toml` → home-operations/.github). To check a change locally, render the affected Flux Kustomization with `flate build ks <path>` (what `just kube render-local-ks` does) and confirm it produces clean YAML before pushing. For Helm chart changes, `helm template` against the pinned chart version is the fastest sanity check.

## Architecture

### Flux reconciliation flow

`kubernetes/flux/cluster/ks.yaml` is the root Kustomization. It points Flux at `./kubernetes/apps` and recursively applies the top-level `kustomization.yaml` in each directory. It also injects cluster-wide defaults via a `patches` block (HelmRelease install/upgrade/rollback behavior, remediation/retries) — individual apps do **not** repeat these.

The directory hierarchy is a strict three-level pattern:

```
kubernetes/apps/<namespace>/
├── kustomization.yaml          # namespace + list of ./app/ks.yaml entries + shared components
├── namespace.yaml
└── <app>/
    ├── ks.yaml                 # Flux Kustomization: path, dependsOn, components, postBuild.substitute
    └── app/
        ├── kustomization.yaml  # plain kustomize: lists the resources below
        ├── helmrelease.yaml    # HelmRelease (values inline)
        ├── ocirepository.yaml  # OCIRepository the HelmRelease's chartRef points at
        └── externalsecret.yaml # optional, pulls from 1Password Connect
```

- The per-namespace `kustomization.yaml` sets the `namespace:` and lists each app's `./<app>/ks.yaml`. Adding an app = create the `<app>/` tree **and** register `./<app>/ks.yaml` here.
- Each app's `ks.yaml` is a Flux `Kustomization` (not a kustomize one). It declares `dependsOn` (most stateful apps depend on `rook-ceph-cluster` in `rook-ceph`), `targetNamespace`, optional `components`, and `postBuild.substitute` (commonly `APP: <name>`, consumed by shared components).

### Charts & images

Most apps use the bjw-s [`app-template`](https://github.com/bjw-s-labs/helm-charts) chart, referenced as an `OCIRepository` whose `chartRef` the `HelmRelease` consumes. Image and chart versions are pinned (tag + digest) and bumped by Renovate (`.renovaterc.json5`) — auto-merge is configured for trusted/home-operations OCI digests and GitHub Actions.

### Reusable components (`kubernetes/components/`)

Kustomize Components included by apps via `components:` in their `ks.yaml` (or the namespace `kustomization.yaml`):

- **volsync** — PVC + VolSync replication source/destination for backups; parameterized by the `${APP}` substitution from the app's `ks.yaml`.
- **alerts** — Alertmanager + GitHub-status providers, included namespace-wide.
- **zeroscaler** — HPA-based scale-to-zero.

### Secrets

Secrets are never in-repo. `ExternalSecret` resources pull from **1Password Connect** via the `onepassword-connect` ClusterSecretStore. The generated Secret name is referenced from the HelmRelease (e.g. `{{ .Release.Name }}-secret`).

## Conventions

- YAML files start with a `# yaml-language-server: $schema=…` line; keep it and use the home-operations schema host for Flux/CRD kinds.
- When renaming or moving an app, rename **every** resource (`ks.yaml` name, HelmRelease, OCIRepository, ExternalSecret target, generated ConfigMap, PrometheusRule) and update the namespace `kustomization.yaml` reference — names cascade because release name drives resource names.
- Prefer `git mv` for renames to preserve history.
- Reloader: pod-roll-on-config-change is opt-in via the workload annotation `reloader.stakater.com/auto: "true"`.
- Talos node config is templated: `talos/machineconfig.yaml.j2` + `talos/nodes/<node>.yaml.j2`, rendered through `minijinja-cli | vals eval` (the root `just template` recipe).
