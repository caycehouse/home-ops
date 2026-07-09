# OpenEBS ZFS Setup

This cluster keeps ZFS pool creation manual and makes the repeatable checks automated.
`zpool create` is destructive and hardware-specific, so it should stay outside Flux and
outside the normal bootstrap path.

## Pool Contract

- Pool name: `tank`
- OpenEBS durable StorageClass: `openebs-zfspv`
- Kopiur snapshot class: `zfspv-snapshot`
- Kopiur persistent mover cache: `openebs-zfspv`
- Talos ZFS binary path: `/usr/local/sbin/zfs`
- Hostpath base path: `/var/openebs/local`

The pool creation command uses:

```sh
zpool create -f -m none -o ashift=12 -O compression=zstd -O atime=off -O xattr=sa tank <vdev>
```

Volume-level policy stays in Kubernetes. The `openebs-zfspv` StorageClass sets
`recordsize: 16k` and `shared: "yes"`.

The backup component follows onedr0p's persistent Kopia cache pattern, but uses
`openebs-zfspv` as this cluster's durable storage class. Do not set a
`SnapshotPolicy` cache to `mode: Persistent` on `openebs-hostpath`; that turns
transient mover storage into a long-lived hostpath PVC. `openebs-hostpath` remains
available as a non-default class for explicitly transient scratch/cache needs only.

## Reset Flow

1. Reset and bootstrap Talos/Kubernetes.
2. As soon as `kubectl` works against the new cluster, inspect the available disks:

    ```sh
    just talos zfs-preflight k8s-0
    ```

3. Choose a stable `/dev/disk/by-id/...` path. Avoid `/dev/sdX` and `/dev/nvmeXnY`
   because those names can move across boots.
4. Print the manual pool creation command.

    Single data disk:

    ```sh
    just talos zfs-create-command k8s-0 /dev/disk/by-id/<disk-id>
    ```

    Future mirror example:

    ```sh
    just talos zfs-create-command k8s-0 mirror /dev/disk/by-id/<disk-a> /dev/disk/by-id/<disk-b>
    ```

5. Review and run the printed command. It creates the `tank` pool from a privileged
   debug pod by entering the Talos host namespaces and invoking `/usr/local/sbin/zpool`.
6. Verify the pool and storage wiring:

    ```sh
    just talos zfs-verify k8s-0
    ```

7. If Flux already tried to reconcile stateful apps before the pool existed, force a
   reconciliation after verification:

    ```sh
    just kube sync ks
    just kube sync hr
    ```

## Non-Goals

- No Flux-managed `zpool create`.
- No automated `zpool destroy`.
- No durable application PVCs on `openebs-hostpath`.
