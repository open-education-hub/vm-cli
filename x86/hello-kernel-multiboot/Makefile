kernel := kernel.bin

linker_script := linker.ld
assembly_source_files := $(wildcard *.asm)
assembly_object_files := $(patsubst %.asm, %.o, $(assembly_source_files))

.PHONY: all clean kernel qemu qemu-gdb

all: $(kernel)

$(kernel): $(assembly_object_files) $(linker_script)
	ld -m elf_i386 -n -T $(linker_script) -o $(kernel) $(assembly_object_files)

qemu: $(kernel)
	qemu-system-x86_64 -vga std -kernel $(kernel)

# compile assembly files
%.o: %.asm
	@mkdir -p $(shell dirname $@)
	nasm -felf32 $< -o $@

clean:
	-@rm -fr build *.o $(kernel)
