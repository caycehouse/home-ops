<div align="center">

### My Home Operations Repository

</div>

<div align="center">

[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dtalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://www.talos.dev/)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/caycehouse/home-ops/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/caycehouse/home-ops/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Home-Internet](https://img.shields.io/uptimerobot/status/m797044251-175b66fd080347cba92eab7d?color=brightgreeen&label=Home%20Internet&style=for-the-badge&logo=v&logoColor=white)](https://status.housefam.casa)&nbsp;&nbsp;
[![Status-Page](https://img.shields.io/uptimerobot/status/m797044253-d5e05cfb7efa9b098b99d258?color=brightgreeen&label=Status%20Page&style=for-the-badge&logo=statuspage&logoColor=white)](https://status.housefam.casa)&nbsp;&nbsp;
[![Alertmanager](https://img.shields.io/endpoint?url=https%3A%2F%2Fhealthchecks.io%2Fb%2F2%2F03387ff3-d245-4a6f-89b7-c20f9b494bd0.shields&color=brightgreeen&label=Alertmanager&style=for-the-badge&logo=prometheus&logoColor=white)](https://status.housefam.casa)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.housefam.casa%2Fquery%3Fformat%3Dendpoint%26metric%3Dcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo/)&nbsp;&nbsp;

</div>

---

## Instructions

### To Recover cluster:

1. `task talos:bootstrap`
2. be patient...
3. `task flux:bootstrap`
4. ???
5. success

### To Upgrade Talos:

`task talos:upgrade-talos node=<node> image=<factory_image_url>`

The factory image url can be generated at [factory.talos.dev](factory.talos.dev).

### To Upgrade k8s:

`task talos:upgrade-k8s node=<node> to=<k8s_version>`

---

## 🔧 Hardware

| Device           | CPU          | OS Disk Size         | Data Disk Size                         | Ram   | Operating System    | Purpose             |
|------------------|--------------|----------------------|----------------------------------------|-------|---------------------|---------------------|
| PowerEdge r630   | 2xE5-2695 v4 | 2x1TB SSD (mirrored) | 3x960GB NVMe (rook-ceph)               | 384GB | Proxmox 8           | VM Server           |
| PowerEdge r730xd | 2xE5-2620 v3 | 2x1TB SSD (mirrored) | 10x3TB and 2x10TB ZFS (mirrored vdevs) | 64GB  | TrueNAS Scale 24.04 | NFS + Backup Server |
| UniFi UDMP       | -            | -                    | 1x2TB HDD                              | -     | -                   | Router & NVR        |
| UniFi USW-48-PoE | -            | -                    | -                                      | -     | -                   | SFP+ PoE Switch     |
