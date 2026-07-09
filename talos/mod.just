set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[confirm('Create missing OpenEBS ZFS pool? This wipes the selected vdev [y|N] ?')]
[doc('Ensure the OpenEBS ZFS pool exists')]
zfs-ensure node pool="tank":
    safe_node="$(printf '%s' "{{ node }}" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-')"
    zfs_vdev="${ZFS_VDEV:-/dev/disk/by-label/r-zfs-data}"

    run_host() {
        local pod="$1"
        local cmd="$2"

        kubectl delete pod "$pod" --ignore-not-found --wait=false >/dev/null 2>&1 || true
        overrides="$(jq -n \
          --arg node "{{ node }}" \
          --arg cmd "$cmd" \
          --arg vdev "$zfs_vdev" \
          '{apiVersion:"v1",spec:{nodeName:$node,hostNetwork:true,hostPID:true,restartPolicy:"Never",containers:[{name:"zfs",image:"mirror.gcr.io/alpine:latest",securityContext:{privileged:true},env:[{name:"CMD",value:$cmd},{name:"VDEV",value:$vdev}],command:["/bin/sh","-ec","nsenter -t 1 -m -u -i -n -- /bin/sh -ec \"$CMD\""]}]}}')"
        kubectl run "$pod" --restart=Never --image=mirror.gcr.io/alpine:latest --overrides="$overrides" >/dev/null
        for _ in {1..120}; do
            phase="$(kubectl get pod "$pod" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
            case "$phase" in
                Succeeded)
                    kubectl logs "$pod"
                    kubectl delete pod "$pod" --ignore-not-found --wait=false >/dev/null 2>&1 || true
                    return 0
                    ;;
                Failed)
                    kubectl logs "$pod" || true
                    kubectl delete pod "$pod" --ignore-not-found --wait=false >/dev/null 2>&1 || true
                    return 1
                    ;;
            esac
            sleep 1
        done
        kubectl logs "$pod" || true
        kubectl delete pod "$pod" --ignore-not-found --wait=false >/dev/null 2>&1 || true
        return 1
    }

    if run_host "zpool-check-${safe_node}" "/usr/local/sbin/zpool list -H -o name {{ pool }}" >/dev/null; then
        just log info "ZFS pool already exists" node "{{ node }}" pool "{{ pool }}"
    else
        just log info "Creating ZFS pool" node "{{ node }}" pool "{{ pool }}" vdev "$zfs_vdev"
        run_host "zpool-create-${safe_node}" 'set -- $VDEV; /usr/local/sbin/zpool create -f -m none -o ashift=12 -O compression=zstd -O atime=off -O xattr=sa "{{ pool }}" "$@"'
    fi

    just talos zfs-status "{{ node }}" "{{ pool }}"

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
    talosctl -n "{{ node }}" reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --system-labels-to-wipe r-zfs-data --graceful=false {{ args }}

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
