.PHONY: all clean

all: hello.bin

hello.bin: hello.o
	$(LD) -o $@ --oformat binary -e init -Ttext 0x7c00 $<

hello.o: hello.s

qemu: hello.bin
	qemu-system-x86_64 -display none -nographic $<

clean:
	-rm -f *~
	-rm -f hello.o hello.bin
