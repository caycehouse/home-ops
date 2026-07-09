set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[doc('Print manual command to create the OpenEBS ZFS pool')]
zfs-create-command node *vdev:
    test -n "{{ vdev }}"
    cat <<'EOF'
    # Review the vdev before running this. It wipes: {{ vdev }}
    # Prefer a stable /dev/disk/by-id/... path over /dev/sdX or /dev/nvmeXnY.

    pod="zpool-create-{{ node }}"
    cleanup() {
      kubectl delete pod "$pod" --ignore-not-found --wait=false >/dev/null 2>&1 || true
    }
    trap cleanup EXIT
    cleanup
    overrides="$(jq -n --arg node "{{ node }}" --arg pool "tank" --arg vdev "{{ vdev }}" \
      '{apiVersion:"v1",spec:{nodeName:$node,hostNetwork:true,hostPID:true,restartPolicy:"Never",containers:[{name:"zpool",image:"mirror.gcr.io/alpine:latest",securityContext:{privileged:true},env:[{name:"POOL",value:$pool},{name:"VDEV",value:$vdev}],command:["/bin/sh","-ec","set -- $VDEV; nsenter -t 1 -m -u -i -n -- /usr/local/sbin/zpool create -f -m none -o ashift=12 -O compression=zstd -O atime=off -O xattr=sa \"$POOL\" \"$@\""]}]}}')"
    kubectl run "$pod" --restart=Never --image=mirror.gcr.io/alpine:latest --overrides="$overrides"
    kubectl wait --for=jsonpath='{.status.phase}'=Succeeded "pod/$pod" --timeout=120s
    kubectl logs "$pod"
    EOF

[doc('List candidate disks before creating the OpenEBS ZFS pool')]
zfs-disks node:
    talosctl -n "{{ node }}" get disks
    talosctl -n "{{ node }}" list /dev/disk/by-id || true

[doc('Run non-destructive ZFS/Talos preflight checks')]
zfs-preflight node:
    just talos zfs-disks "{{ node }}"
    echo
    talosctl -n "{{ node }}" list /usr/local/sbin | rg '(^|[[:space:]/])(zfs|zpool)([[:space:]]|$)'
    echo
    talosctl -n "{{ node }}" mounts | rg '/var/openebs/local|/var/lib/kubelet' || true

[doc('Show OpenEBS ZFS pool status from a privileged debug pod')]
zfs-status node pool="tank":
    pod="zfs-status-{{ node }}"
    cleanup() {
        kubectl delete pod "$pod" --ignore-not-found --wait=false >/dev/null 2>&1 || true
    }
    trap cleanup EXIT
    cleanup
    overrides="$(jq -n --arg node "{{ node }}" --arg pool "{{ pool }}" \
      '{apiVersion:"v1",spec:{nodeName:$node,hostNetwork:true,hostPID:true,restartPolicy:"Never",containers:[{name:"zfs",image:"mirror.gcr.io/alpine:latest",securityContext:{privileged:true},env:[{name:"POOL",value:$pool}],command:["/bin/sh","-ec","nsenter -t 1 -m -u -i -n -- /usr/local/sbin/zpool status \"$POOL\" && nsenter -t 1 -m -u -i -n -- /usr/local/sbin/zpool list -o name,size,allocated,free,capacity,health,readonly \"$POOL\" && nsenter -t 1 -m -u -i -n -- /usr/local/sbin/zfs get -r -o name,property,value,source compression,atime,xattr \"$POOL\""]}]}}')"
    kubectl run "$pod" --restart=Never --image=mirror.gcr.io/alpine:latest --overrides="$overrides"
    kubectl wait --for=jsonpath='{.status.phase}'=Succeeded "pod/$pod" --timeout=120s
    kubectl logs "$pod"

[doc('Verify ZFS/OpenEBS/Kopiur storage wiring after bootstrap')]
zfs-verify node pool="tank":
    just talos zfs-status "{{ node }}" "{{ pool }}"

    default_class="$(kubectl get storageclass openebs-zfspv -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')"
    test "$default_class" = "true"

    hostpath_default="$(kubectl get storageclass openebs-hostpath -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' 2>/dev/null || true)"
    test "$hostpath_default" != "true"

    snapshot_driver="$(kubectl get volumesnapshotclass zfspv-snapshot -o jsonpath='{.driver}')"
    test "$snapshot_driver" = "zfs.csi.openebs.io"

    kubectl get snapshotpolicies.kopiur.home-operations.com -A -o json | jq -e '
      [
        .items[]
        | select(.spec.mover.cache.mode == "Persistent")
        | select(.spec.mover.cache.storageClassName != "openebs-zfspv")
        | "\(.metadata.namespace)/\(.metadata.name)"
      ] as $bad
      | if ($bad | length) == 0 then true
        else error("Persistent Kopiur cache must use openebs-zfspv: " + ($bad | join(", ")))
        end
    '

    just log info "Verified ZFS storage wiring" node "{{ node }}" pool "{{ pool }}"

[confirm('Apply Talos config to ' + node + ' [y|N] ?')]
[doc('Apply Talos config to a node')]
apply-node node *args:
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Download Talos machine image')]
download-image version:
    export SCHEMATIC="$(just talos schematic-id)"
    curl -fL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors --progress-bar \
        -o "{{ source_directory() }}/talos-{{ version }}-${SCHEMATIC:0:8}.iso" \
        "https://factory.talos.dev/image/${SCHEMATIC}/{{ version }}/metal-amd64.iso"
    just log info "Downloaded Talos" version "{{ version }}" schematic "${SCHEMATIC}"

[confirm('Reboot node ' + node + ' [y|N] ?')]
[doc('Reboot a node')]
reboot-node node:
    talosctl -n {{ node }} reboot -m powercycle

[doc('Render Talos config for a node')]
render-config node:
    export CONTROLPLANE="$(just talos machine-controller {{ node }})"
    export SCHEMATIC="$(just talos schematic-id)"
    talosctl machineconfig patch <(just template "{{ source_directory() }}/machineconfig.yaml.j2") \
        -p @<(just template "{{ source_directory() }}/nodes/{{ node }}.yaml.j2")

[confirm('Reset node ' + node + ' [y|N] ?')]
[doc('Reset a node')]
reset-node node *args:
    talosctl -n "{{ node }}" reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --graceful=false {{ args }}

[confirm('Shutdown node ' + node + ' [y|N] ?')]
[doc('Shutdown a node')]
shutdown-node node *args:
    talosctl -n "{{ node }}" shutdown --force {{ args }}

[confirm('Upgrade Kubernetes to ' + version + ' [y|N] ?')]
[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s version:
    talosctl -n "$(talosctl config info -o yaml | yq -r -e '.endpoints[0]')" upgrade-k8s --to {{ version }}

[confirm('Upgrade node ' + node + ' [y|N] ?')]
[doc('Upgrade Talos version on a node')]
upgrade-node node *args:
    talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image)" -m powercycle --timeout=10m {{ args }}

[private]
schematic-id:
    curl -sX POST --data-binary @<(just template "{{ source_directory() }}/schematic.yaml.j2") "https://factory.talos.dev/schematics" | jq -r '.id'

[private]
machine-controller node:
    just template "{{ source_directory() }}/nodes/{{ node }}.yaml.j2" | yq -r -e 'select(.machine) | (.machine.type == "controlplane") // ""'

[private]
machine-image:
    export SCHEMATIC="$(just talos schematic-id)"
    just template "{{ source_directory() }}/machineconfig.yaml.j2" | yq -r -e 'select(.machine) | .machine.install.image'
