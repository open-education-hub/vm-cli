# Virtualization using the Command Line

Most of time, for common chores, we use virtual machines with a graphical user interface (GUI).
This is easier, but it's difficult to automate and to scale to many virtual machines.

In this workshop we use the [QEMU](https://www.qemu.org/) command line options

## Requirements

Make sure you have the `qemu-system-x86` and `qemu-system-arm` or equivalent packages install on your system.

The GNU toolchain (GCC, Make) is also required.
On a Debian/Ubuntu system, installing the `build-essential` package should be enough.

On a Debian-based system, run the commands below to install required packages:

```console
sudo apt install -y --no-install-recommends \
  build-essential \
  sudo \
  gcc-aarch64-linux-gnu \
  libncurses-dev \
  libyaml-dev \
  flex \
  bison \
  git \
  wget \
  uuid-runtime \
  qemu-kvm \
  qemu-system-x86 \
  qemu-system-arm \
  sgabios \
  mtools \
  grub-common \
  nasm
```

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

### Hello World as a Bootloader

The simplest way is to have the program running as a bootloader.
This is easy, but severely limited since it can only use the first sector of the image.

Go to the `x86/hello-bootloader/` directory.
There are two subdirectories, depending on the assembler used: `as/` and `nasm/`.

Enter each directory (`as/` and `nasm/).
In each of them:

1. Build the bootloader image:

   ```console
   make
   ```

1. Run the resulting image with QEMU:

   ```console
   make qemu
   ```

Look at the source code files (`hello.s` and `hello.asm`) to see how the bootloader program is created.
Also check the `Makefile` in each directory to see how the bootloader is being built (with `as` or `nasm`) and run (with `qemu-system-x86_64`).

#### Do It Yourself

Update the programs to print "Bye, World!" instead of "Hello, World!".

### Hello World as a Kernel Using Multiboot

Getting past the bootloader limitations, we can build an actual kernel and boot it with QEMU.
This requires a boot protocol, where QEMU knows how to locate and where to load the kernel.
The default one is [Multiboot](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html);
we will use this.

Go to the `x86/hello-kernel-multiboot/` directory.
Similar to the above:

1. Build the kernel image:

   ```console
   make
   ```

1. Run the resulting kernel with QEMU:

   ```console
   make qemu
   ```

Look at the source code files (`boot.asm` and `multiboot_header.asm`) to see how the kernel image is created.
Check the linker script (`linker.ld`) as well.
Also check the `Makefile` in each directory to see how the kernel is being built (with `nasm` and `ld`) and run (with `qemu-system-x86_64`).

**Note**: If you don't have a GUI for QEMU, you can replace `-vga std` with `-curses` for a text user interface.

#### Do It Yourself

Update the program to print "Bye, World!" instead of "Hello, World!".

You will have to update the `boot.asm` file.
Careful about the screen buffer addresses.

### Hello World as a Bootable Image

Multiboot is limited to 32 bits.
If you want to go for 64 bits, we need to create an image that stores a 64 bit kernel.
The image also requires a bootloader configured (GRUB).

Go to the `x86/hello-os-grub/` directory.
Similar to the above:

1. Build the kernel image:

   ```console
   make
   ```

1. Build the ISO image to boot, incorporating the kernel and the bootloader configuration:

   ```console
   make iso
   ```

1. Run the resulting ISO with QEMU:

   ```console
   make qemu
   ```

Look at the source code files (`boot.asm` and `multiboot_header.asm`) to see how the kernel image is created.
They are quite similar to the ones above.
Check the linker script (`linker.ld`) as well.
And check the GRUB configuration file (`grub.cfg`).
Also check the `Makefile` in each directory to see how the kernel is being built (with `nasm` and `ld`), how the ISO image is being built (with `grub-mkrescue`) and how the ISO image is being run (with `qemu-system-x86_64`).

**Note**: If you don't have a GUI for QEMU, you can replace `-vga std` with `-curses` for a text user interface.

#### Do It Yourself

Update the program to print "Bye, World!" instead of "Hello, World!".

You will have to update the `boot.asm` file.
Careful about the screen buffer addresses.

## Hello World in a Unikernel

If you do not want to deal with assembly code, we have prepared a minimal setup in `./c-hello/`.
There, we have a `hello.c` file that just prints a `Hello world` message.

To biuld it and run it as a virtual machine, we have provided some scripts.
They will pack the application as an [`unikernel`](https://en.wikipedia.org/wiki/Unikernel), using [`Unikraft`](https://unikraft.org/) and create a minimal virtual machine.
The details of this are not that relevant, we will focus on the way the virtual machine is started using `qemu`.

To build the application, run the `build.qemu.x86_64` script.
To run it, use the `run.qemu.x86_64` script.
This will use the followin `qemu` command:

```console
qemu-system-x86_64 \
    -nographic \
    -m 8 \
    -cpu max \
    -kernel out/c-hello_qemu-x86_64
```

What it does is: give the VM 8M of memory, tell it to not open a graphical window, to just print the output to the terminal instead, use the cpu with maximal features and then point to the kernel image.
You can try to run the command by hand.

After that, you can also use the `aarch64` scripts to build and run for the `aarch64` architecture.

Modify the source code to print `Bye, world!` instead of the original message, build and run again and see if the changes take place correctly.

After that, also try out the `c-http/` application, using the same scripts.
Look in the `run.qemu` scripts and try to figure out what they do extra.
Look in the `README` file of the application to see how to test it.

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
