# C HTTP server on Unikraft

Build and run a simple C HTTP server on Unikraft.
Follow the instructions below to set up, configure, build and run C HTTP.
Make sure you installed the [requirements](../README.md#requirements).

## Run

Run the resulting image using the corresponding platform tool.
Firecracker requires KVM support.
Xen requires a system with Xen installed.

A successful run will show a message such as the one below:

```text
en1: Added
en1: Interface is up
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                Calypso 0.17.0~5d38d108
```

This means that the C HTTP server runs on Unikraft and waiting for connections.

### Run on QEMU/x86_64

To set up networking, use the commands below:

```console
# Remove previously created network interfaces. Ignore missing device errors.
sudo ip link set dev virbr0 down
sudo ip link del dev virbr0
sudo ip link set dev tap0 down
sudo ip link del dev tap0
# Create bridge interface for QEMU networking.
sudo ip link add dev virbr0 type bridge
sudo ip address add 172.44.0.1/24 dev virbr0
sudo ip link set dev virbr0 up
```

Now run the Unikraft image:

```console
sudo qemu-system-x86_64 \
    -nographic \
    -m 8 \
    -cpu max \
    -netdev bridge,id=en0,br=virbr0 -device virtio-net-pci,netdev=en0 \
    -append "c-http netdev.ip=172.44.0.2/24:172.44.0.1::: -- " \
    -kernel out/c-http_qemu-x86_64
```

You need use `sudo` or the `root` account to run QEMU with bridged networking.

### Run on QEMU/ARM64

To set up networking, use the commands below:

```console
# Remove previously created network interfaces. Ignore missing device errors.
sudo ip link set dev virbr0 down
sudo ip link del dev virbr0
sudo ip link set dev tap0 down
sudo ip link del dev tap0
# Create bridge interface for QEMU networking.
sudo ip link add dev virbr0 type bridge
sudo ip address add 172.44.0.1/24 dev virbr0
sudo ip link set dev virbr0 up
```

Now run the Unikraft image:

```console
sudo qemu-system-aarch64 \
    -nographic \
    -machine virt \
    -m 8 \
    -cpu max \
    -netdev bridge,id=en0,br=virbr0 -device virtio-net-pci,netdev=en0 \
    -append "c-http netdev.ip=172.44.0.2/24:172.44.0.1::: -- " \
    -kernel out/c-http_qemu-arm64
```

You need use `sudo` or the `root` account to run QEMU with bridged networking.

## Test

To test C HTTP on Unikraft, use `curl` (or any other HTTP client):

```console
curl 172.44.0.2:8080
```

In case of a successful run, a Hello message is printed:

```console
Hello from Unikraft!
```

## Close

As a server, C HTTP will run forever until you close the Unikraft virtual machine that runs it.
Closing the virtual machine depends on the platform.

### Close QEMU

To close the QEMU virtual machine, use the `Ctrl+a x` keyboard shortcut;
that is press the `Ctrl` and `a` keys at the same time and then, separately, press the `x` key.
