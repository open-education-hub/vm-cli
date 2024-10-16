NASM = nasm

.PHONY: all clean

all: hello.bin

hello.bin: hello.asm
	$(NASM) -o $@ $<

qemu: hello.bin
	qemu-system-x86_64 -display none -nographic $<

clean:
	-rm -f *~
	-rm -f hello.o hello.bin
