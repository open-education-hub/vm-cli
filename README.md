# Virtualization using the Command Line

Most of time, for common chores, we use virtual machines with a graphical user interface (GUI).
This is easier, but it's difficult to automate and to scale to many virtual machines.

In this workshop we use the [QEMU](https://www.qemu.org/) command line options

## Requirements

Make sure you have the `qemu-system-x86` and `qemu-system-arm` or equivalent packages install on your system.

The GNU toolchain (GCC, Make) is also required.
On a Debian/Ubuntu system, installing the `build-essential` package should be enough.

## Short Intro

QEMU is an emulator that can make use the [KVM support](https://linux-kvm.org/page/Main_Page) in the Linux kernel to provide virtualization.
In essence, QEMU is a VMM (*Virtual Machine Monitor*) and KVM is the hypervisor, providing CPU and memory-level virtualization.

We use the `qemu-systemx-x86_64` or the `qemu-system-arm` commands to start virtual machines (emulated or virtualized).
In order to enable KVM support, you pass the `-enable-kvm` option:

```console
qemu-system-x86_64 ...
qemu-system-x86_64 -enable-kvm ...
```

There are two main ways to run a virtual machine:

1. Pass the kernel image to run.
   Use a QEMU boot protocol to load the kernel image and pass actions to it.

1. Pass an virtual hard disk image containing the filesystem and the kernel image and boot from that.
   The virtual disk image must be a bootable image and host the bootloader required.

## Minimalistic / Baremetal Hello World

Our goal is go boot a baremetal disk image that prints a "Hello, World!" message.
Since this is a very early on message, we will make use of early boot code instructions.

For that we follow the three tutorials here to build and run image files:

* x86_64: https://medium.com/@g33konaut/writing-an-x86-hello-world-boot-loader-with-assembly-3e4c5bdd96cf
* x86_64: https://blog.ghaiklor.com/2017/10/21/how-to-implement-your-own-hello-world-boot-loader/
* ARM: https://jasonblog.github.io/note/arm_emulation/hello_world_for_bare_metal_arm_using_qemu.html

## Run Full-Fledged OSes

Follow these instructions to run full-fledged OSes:

* Alpine x86: https://wiki.alpinelinux.org/wiki/QEMU
* Debian ARM: https://translatedcode.wordpress.com/2017/07/24/installing-debian-on-qemus-64-bit-arm-virt-board/

First, download the `x86_64` and `aarch64` Alpine images from [here](https://alpinelinux.org/downloads/).

We can try to boot the iso image by running:

```console
qemu-system-x86_64 -enable-kvm -cdrom alpine-standard-3.20.3-x86_64.iso
```

This however will lead to a lot of errors, caused by the fact that `qemu` uses `128M` of memory by default, which is not enough.
We can try to give the machine more memory:

```console
qemu-system-x86_64 -enable-kvm -m 512 -cdrom alpine-standard-3.20.3-x86_64.iso
```

This works, and reaches the login screen:

```console
Welcome to Alpine Linux 3.20
Kernel 6.6.49-0-lts on an x86_64 (/dev/ttyS0)

localhost login:
```

We can login using `root`, with no password required.
This will start a shell.
We can even run `setup-alpine` to install the operating system.
Let's create a new file and reboot the machine:

```console
# echo "you shall not pass" > file.txt
# ls -la
total 8
drwx------    2 root     root            80 Oct 17 07:06 .
drwxr-xr-x   20 root     root           400 Oct 17 07:06 ..
-rw-------    1 root     root            44 Oct 17 07:06 .ash_history
-rw-r--r--    1 root     root            19 Oct 17 07:06 file.txt
```

After that, let's power off the machine using `poweroff` and boot again.
After the reboot, you can see that our file does not longer exists.
This is expected, since we did not attach a disk to out machine, and everything booted from the `cdrom` `iso` image.

To attach a disk and install the operating system, we first need to create the disk.

```console
qemu-img create -f qcow2 alpine.qcow2 8G
```

This will create a `qcow2` formated file, which will be used as our disk, with a maximum size of 8G.
To attach it to our virtual machine, we can use the `-hda` option:

```console
qemu-system-x86_64 -enable-kvm -m 512 -cdrom alpine-standard-3.20.3-x86_64.iso -hda alpine.qcow2
```

After the machine boots, we install the operating system by running `setup-alpine`.
Just press enter to select the default settings, until we reach the disk selection:

```console
Which disk(s) would you like to use? (or '?' for help or 'none') [none]
```

If we press `?`, we should see our attached disk:

```text
The disk you select can be used for a traditional disk install or for a
data-only install.

The disk will be erased.

Enter 'none' if you want to run diskless.

Available disks are:
  fd0  (0.0 GB  )
  sda  (8.6 GB ATA      QEMU HARDDISK   )
```

We then select `sda`, which is our 8G disk, and select `sys` at the next `How would you like to use it?` question.
After all this, the operating system will get installed on our disk, and next time we power on the VM, we can remove the `cdrom` `iso` image.
We will see an `Installation is complete. Please reboot.` message.
Let's power off the machine, remove the `cdrom` and run again:

```console
qemu-system-x86_64 -enable-kvm -m 512 -hda alpile.qcow2
```

After it boots, we can connect using `root` with no password again, and create a new file like we did before:

```console
# echo "you shall not pass" > file.txt
# ls -la
total 8
drwx------    2 root     root            80 Oct 17 07:06 .
drwxr-xr-x   20 root     root           400 Oct 17 07:06 ..
-rw-------    1 root     root            44 Oct 17 07:06 .ash_history
-rw-r--r--    1 root     root            19 Oct 17 07:06 file.txt
```

This time, after we poweroff the VM and boot again, the file is still there:

```console
# ls
file.txt
# cat file.txt
you shall not pass
```

We can go further and attach a network interface to our machine, following the instructions [here](https://wiki.alpinelinux.org/wiki/QEMU#Advanced_network_configuration).
