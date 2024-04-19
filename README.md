<div align="center">

### My Home Operations Repository

</div>

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
