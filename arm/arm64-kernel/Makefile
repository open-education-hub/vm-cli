AS = aarch64-linux-gnu-as
CC = aarch64-linux-gnu-gcc
LD = aarch64-linux-gnu-ld

.PHONY: all clean

all: hello_world.elf

hello_world.elf: linker.ld startup.o hello_world.o
	# Link the two object files to an elf file
	$(LD) -T linker.ld startup.o hello_world.o -o hello_world.elf

startup.o: startup.s
	$(AS) -o startup.o startup.s

hello_world.o: hello_world.c
	$(CC) -c -o hello_world.o hello_world.c

qemu: hello_world.elf
	qemu-system-aarch64 -M virt -cpu max -display none -nographic -kernel $<

clean:
	-rm -f *~
	-rm -f hello_world.o startup.o hello_world.elf
