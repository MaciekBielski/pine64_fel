target64	=hbl
start64		=0x4a000000
xcc64		=/opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-elf/bin/aarch64-elf-
_cflags		=-nostdlib -nodefaultlibs
_ldflags	=-Wl,-e$(start64) -Wl,-Ttext=$(start64) -Wl,--build-id=none

$(target64): start.S
	$(xcc64)gcc $(_cflags) -o $@.elf $^ $(_ldflags)
	$(xcc64)objcopy --remove-section .ARM.attributes $@.elf
	$(xcc64)objdump -D $@.elf > $@.lst
	$(xcc64)objcopy -O binary	$@.elf $@.bin
	$(xcc64)objcopy -O srec		$@.elf $@.srec

clean:
	rm -f $(target64).o $(target64).elf $(target64).bin $(target64).lst $(target64).srec
