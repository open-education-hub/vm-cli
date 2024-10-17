# C Hello on Unikraft

Build and run a C Hello program on Unikraft.
Follow the instructions below to set up, configure, build and run C Hello.
Make sure you installed the [requirements](../README.md#requirements).

## Run

Run the resulting image using the corresponding platform tool.
Firecracker requires KVM support.
Xen requires a system with Xen installed.

A successful run will show a message such as the one below:

```text
Booting from ROM..Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                Calypso 0.17.0~5d38d108
Hello from Unikraft!
```

### Run on QEMU/x86_64

```console
qemu-system-x86_64 -nographic -m 8 -cpu max -kernel out/c-hello_qemu-x86_64
```

### Run on QEMU/ARM64

```console
qemu-system-aarch64 -nographic -machine virt -m 8 -cpu max -kernel out/c-hello_qemu-arm64
```
