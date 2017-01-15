#######################################################################
# Building test kernel
#######################################################################

xcc_dir		=	gcc-linaro-4.9-2015.05-x86_64_aarch64-elf
xcc			=	/opt/$(xcc_dir)/bin/aarch64-elf-
bin_elf		=	hello.elf
bin_img		=	hello.bin

build_test: hello.c startup.s
	$(xcc)gcc -c -mcpu=cortex-a53 -s -g hello.c -o hello.o
	$(xcc)as -mcpu=cortex-a53 -g startup.s -o startup.o

link_test: hello.o startup.o
	$(xcc)ld -T startup.ld $^ -o hello.elf
	$(xcc)objcopy -O binary hello.elf $(bin_img)

clean:
	rm -f hello.o startup.o hello.elf

info:
	$(xcc)readelf -a $(bin_elf)
