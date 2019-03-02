###############################################################################
# 1. Download components
###############################################################################
sunxid			= sunxi-tools
apritzel_link	= https://github.com/apritzel/pine64/raw/master/binaries
spl				= sunxi-a64-spl32-ddr3.bin
atf				= bl31.bin
blobsd			= blobs

fel_clone:
	git submodule add -- \
		git@github.com:linux-sunxi/sunxi-tools.git $(sunxid)
	git -C $(sunxid) ckt v1.4.2
	git submodule init -- $(sunxid)

fel_build:
	make -C $(sunxid) tools

blobs:
	mkdir -p $(blobsd)
	test -e $(blobsd)/$(spl) || \
		(cd $(blobsd) && wget $(apritzel_link)/$(spl))
	test -e $(blobsd)/$(atf) || \
		(cd $(blobsd) && wget $(apritzel_link)/$(atf))

###############################################################################
# 2. Build the 32-bit startup binary and 64-bit app binary
###############################################################################

xcc64	=/opt/gcc-linaro-7.2.1-2017.11-x86_64_aarch64-elf/bin/aarch64-elf-
xcc32	=/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-eabi/bin/arm-eabi-
start64	=0x4a000000
start32	=0x40000000

# NOTE: -e $(start64) is not needed for hello32 program
# target	= hello32
target32= rmr32

# The entry point is set to start64, by default it is called '_start'
# -Ttext defines .text section start as if in a script
$(target32): $(target32).s
	$(xcc32)as --defsym AARCH64_START=$(start64) -o $@.o $^
	$(xcc32)ld -e $(start32) -Ttext=$(start32) -o $@.elf $@.o
	$(xcc32)objcopy --remove-section .ARM.attributes $@.elf
	$(xcc32)objdump -D $@.elf > $@.lst
	$(xcc32)objcopy -O binary	$@.elf $@.bin
	$(xcc32)objcopy -O srec		$@.elf $@.srec

clean32:
	rm -f $(target32).o $(target32).elf $(target32).bin $(target32).lst $(target32).srec

run32:
	./$(sunxid)/sunxi-fel spl $(blobsd)/$(spl)
	./$(sunxid)/sunxi-fel write $(start32) $(target32).bin
	./$(sunxid)/sunxi-fel exe $(start32)

###############################################################################
target64	=	hello64
_cflags=-nostdlib -nodefaultlibs
_ldflags =-Wl,-e$(start64) -Wl,-Ttext=$(start64) -Wl,--build-id=none

$(target64): $(target64).S
	$(xcc64)gcc $(_cflags) -o $@.elf $^ $(_ldflags)
	$(xcc64)objcopy --remove-section .ARM.attributes $@.elf
	$(xcc64)objdump -D $@.elf > $@.lst
	$(xcc64)objcopy -O binary	$@.elf $@.bin
	$(xcc64)objcopy -O srec		$@.elf $@.srec

clean64:
	rm -f $(target64).o $(target64).elf $(target64).bin $(target64).lst $(target64).srec

run64:
	./$(sunxid)/sunxi-fel spl $(blobsd)/$(spl)
	./$(sunxid)/sunxi-fel write $(start64) $(target64).bin
	./$(sunxid)/sunxi-fel reset64 $(start64)

# the same as above but with custom restarting binary
# run64:
# 	./$(sunxid)/sunxi-fel spl $(blobsd)/$(spl)
# 	./$(sunxid)/sunxi-fel write $(start32) $(target32).bin
# 	./$(sunxid)/sunxi-fel write $(start64) $(target64).bin
# 	./$(sunxid)/sunxi-fel exe $(start32)


###############################################################################
# 2) U-boot
###############################################################################
ubconfig	= pine64_plus_defconfig
ub_dir		= u-boot
ub_bin		= $(ub_dir)/u-boot.bin
ub_branch	= master


ubclone:
	git submodule add -- \
		git@github.com:MaciekBielski/u-boot.git $(ub_dir)
	git -C $(ub_dir) ckt $(ub_branch)
	git submodule init -- $(ub_dir)

ubdefconf:
	$(MAKE) -C $(ub_dir) \
		BL31=$(blobsd)/$(atf) ARCH=arm CROSS_COMPILE=$(xcc64) $(ubconfig)

ubmenuconf:
	$(MAKE) -C $(ub_dir) \
		BL31=$(blobsd)/$(atf) ARCH=arm CROSS_COMPILE=$(xcc64) menuconfig

ubbuild:
	$(MAKE) -C $(ub_dir) \
		BL31=$(blobsd)/$(atf) ARCH=arm CROSS_COMPILE=$(xcc64) -j3

ubclean:
	$(MAKE) -C $(ub_dir) mrproper


boot:
	./$(sunxid)/sunxi-fel spl $(blobsd)/$(spl)
	./$(sunxid)/sunxi-fel write $(start64) $(ub_bin)
	./$(sunxid)/sunxi-fel reset64 $(start64)


.PHONY: fel_clone, blobs hello32, clean32, run32

