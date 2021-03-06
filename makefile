# @desc		Makefile for compiling and running the entire operating system
# @author	Davide Della Giustina
# @date		14/11/2019

ASM_LIBS = $(wildcard src/boot/lib/16bit/*.asm src/boot/lib/32bit/*.asm)
C_SOURCES = $(wildcard src/kernel/*.c src/drivers/*.c src/cpu/*.c src/libc/*.c src/data_structures/*.c src/programs/*.c)
C_HEADERS = $(wildcard src/kernel/*.h src/drivers/*.h src/cpu/*.h src/libc/*.h src/data_structures/*.h)
OBJ = $(C_SOURCES:.c=.o src/cpu/interrupt.o) # Extension replacement

KERNEL_SIZE = $$(wc -c < 'src/kernel/kernel.bin') # Compute kernel size (in bytes)
KERNEL_SECTORS_SIZE = $$((($(KERNEL_SIZE)+511)/512)) # Compute kernel size (in sectors)

SECOND_STAGE_BL_SIZE = $$(wc -c < 'src/boot/second_stage.bin') # Compute second-stage bootloader size (in bytes)
SECOND_STAGE_BL_SECTORS_SIZE = $$((($(SECOND_STAGE_BL_SIZE)+511)/512)) # Compute second-stage bootloader size (in sectors)

SH = bash
SFLAGS = -i
CC = i386-elf-gcc
CFLAGS = -m32 -fno-builtin -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -Werror
LD = i386-elf-ld

RAM_SIZE = 128 # RAM size in MB

.PHONY: all
.PHONY: run
.PHONY: vbox
.PHNOY: clean

all: out/os-image.bin # Default target

%.bin: %.asm src/boot/second_stage.bin src/kernel/kernel.bin $(ASM_LIBS) src/boot/gdt.asm
	$(SH) $(FLAGS) -c "echo Second-stage bootloader takes $(SECOND_STAGE_BL_SECTORS_SIZE) sectors"
	$(SH) $(FLAGS) -c "echo Kernel takes $(KERNEL_SECTORS_SIZE) sectors"
	$(SH) $(SFLAGS) -c "nasm -fbin -dKERNEL_SECTORS_SIZE=$(KERNEL_SECTORS_SIZE) -dSECOND_STAGE_BL_SECTORS_SIZE=$(SECOND_STAGE_BL_SECTORS_SIZE) $< -o $@"

%.o: %.asm
	$(SH) $(SFLAGS) -c "nasm -felf $< -o $@"

%.o: %.c $(C_HEADERS)
	$(SH) $(SFLAGS) -c "$(CC) $(CFLAGS) -DTOTAL_RAM_SIZE=$(RAM_SIZE) -ffreestanding -c $< -o $@"

src/boot/second_stage.bin: src/boot/second_stage.o
	$(SH) $(SFLAGS) -c "$(LD) -e second_stage_bootloader -Ttext 0x1000 $^ -o $@ --oformat binary"

src/kernel/kernel.bin: src/kernel/kernel_entry.o $(OBJ)
	$(SH) $(SFLAGS) -c "$(LD) -e kmain -T link.ld $^ -o $@ --oformat binary"

out/os-image.bin: src/boot/bootsect.bin src/boot/second_stage.bin src/kernel/kernel.bin
	$(SH) $(SFLAGS) -c "cat $^ > $@"

run: all
	qemu -m $(RAM_SIZE) out/os-image.bin

vbox: all
	$(SH) $(SFLAGS) -c "dd if=/dev/zero of=out/floppy.img ibs=1k count=1440"
	$(SH) $(SFLAGS) -c "dd if=out/os-image.bin of=out/floppy.img conv=notrunc"

clean:
	rm -rf src/boot/*.o src/boot/*.bin src/kernel/*.o src/kernel/*.bin src/drivers/*.o src/cpu/*.o src/libc/*.o src/data_structures/*.o
	rm -rf src/programs/*.o
	rm -rf out/os-image.bin out/floppy.img