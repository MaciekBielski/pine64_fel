#######################################################################
# Building test kernel
#######################################################################

xcc32_env =	/opt/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf
xcc32 = $(xcc32_env)/bin/arm-linux-gnueabihf-

xcc			=	/opt/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-elf/bin/aarch64-elf-
bin_elf		=	hello.elf
bin_img		=	hello.bin

# cflags = -Wall -march=armv8-a -mcpu=cortex-a53 -nostdlib -nostartfiles -ffreestanding -g
cflags = -Wall -march=armv8-a -mcpu=cortex-a53


#######################################################################
# Old
# $(xcc)gcc -c $(cflags) -s -g hello.c -o hello.o
#######################################################################

build_test: startup.s
	$(xcc32)as $(cflags) -o startup.o startup.s

link_test: startup.o
	$(xcc32)ld -T startup.ld $^ -o hello.elf
	$(xcc32)objdump -D hello.elf > hello.list
	$(xcc32)objcopy -O binary hello.elf $(bin_img)

clean:
	rm -f hello.o startup.o hello.elf hello.list hello.bin

info:
	$(xcc)readelf -a $(bin_elf)
