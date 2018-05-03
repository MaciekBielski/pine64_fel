#######################################################################
# Building test kernel
#######################################################################

# xcc32_env =	/opt/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf
# xcc32 = $(xcc32_env)/bin/arm-linux-gnueabihf-
xcc32_env =	/opt/gcc-linaro-6.3.1-2017.02-x86_64_arm-eabi
xcc32 = $(xcc32_env)/bin/arm-eabi-

xcc			=	/opt/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-elf/bin/aarch64-elf-
startup_bin =	startup.bin

cflags = -march=armv8-a -mcpu=cortex-a53

bin_elf		=	hello.elf
bin_img		=	hello.bin

# cflags = -Wall -march=armv8-a -mcpu=cortex-a53 -nostdlib -nostartfiles -ffreestanding -g

#######################################################################
# Old
# $(xcc)gcc -c $(cflags) -s -g hello.c -o hello.o
#######################################################################

startup: startup.s
	$(xcc32)as $(cflags) -o startup.o startup.s
	$(xcc32)ld -T startup.ld startup.o -o startup.elf
	$(xcc32)objdump -D startup.elf > startup.list
	$(xcc32)objcopy -O binary startup.elf $(startup_bin)

clean_startup:
	rm -f startup.o startup.elf startup.list startup.bin

info:
	$(xcc)readelf -a $(bin_elf)
