#######################################################################
# 1. Download the image
#######################################################################

im_name =	simpleimage-pine64-latest.img.xz
im_path	=	https://www.stdin.xyz/downloads/people/longsleep/pine64-images/${im_name}

im_dld:
	wget $(im_path)

#######################################################################
# 2. Flash the image to SDcard
#######################################################################

sd_path	=	/dev/mmcblk0

im_flash:
	xzcat $(im_name) | pv | sudo dd of=$(sd_path) bs=1M oflag=sync

#######################################################################
# 3. Building test kernel
#######################################################################

test_dir	=	test_kernel
kern_im		=	$(test_dir)/hello.bin

build_objects:
	$(MAKE) -C $(test_dir) build_test

link_objects:
	$(MAKE) -C $(test_dir) link_test

clean_objects:
	$(MAKE) -C $(test_dir) clean


#######################################################################
# ---------------- BUILDING YOUR OWN IMAGE ---------------------------
#######################################################################

#######################################################################
# 4. Get boot0
#
# I have cut the boot0 blob and removed android image since it takes 4GB
#######################################################################
android_img = android-7.0-pine-a64-v1.11.0-r67.img
android_link = http://files.pine64.org/os/android/$(android_img).gz
blobs		= blobs
boot0_img	= $(blobs)/boot0.bin

android_dld:
	wget $(android_link)

android_extract:
	gunzip $(android_img).gz

boot0_cut:
	test -e $(android_img) && \
	test -d $(blobs) || mkdir $(blobs) && \
	dd if=$(android_img) bs=1k skip=8 count=32 of=$(boot0_img)

#######################################################################
# 5. Get scp firmware
#######################################################################
scp_bin = $(blobs)/scp.bin

scp_dld:
	wget https://github.com/longsleep/build-pine64-image/raw/master/blobs/scp.bin && \
	mv scp.bin $(scp_bin)

#######################################################################
# 6. Build u-boot
#
# BSP u-boot runs in 32bit mode
#######################################################################
xcc32_env =	/opt/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf
xcc32 = $(xcc32_env)/bin/arm-linux-gnueabihf-

uboot_dir	= u-boot
uboot_bin	= $(uboot_dir)/u-boot-sun50iw1p1.bin


define UBOOTENV
\t\t"if load mmc 0:1 $${load_addr} uEnv.txt; then " \
\\\n\t\t\t"run import_bootenv; " \
\\\n\t\t"fi" \
\\
endef
export UBOOTENV


uboot_dld:
	git clone --depth 1 --branch pine64-hacks --single-branch \
	https://github.com/longsleep/u-boot-pine64.git $(uboot_dir) && \
	sed -i.bkp '/\"mmcbootcmd=\" /a\'"$$UBOOTENV" $(uboot_dir)/include/configs/sun50iw1p1.h


uboot_build:
	$(MAKE) ARCH=arm CROSS_COMPILE=$(xcc32) -C $(uboot_dir) sun50iw1p1_config && \
	$(MAKE) ARCH=arm CROSS_COMPILE=$(xcc32) -C $(uboot_dir)


#######################################################################
# 7. Build ATF
#
# The ATF has to be compatible with BSP u-boot
#######################################################################
xcc64_env = /opt/gcc-linaro-5.3.1-2016.05-x86_64_aarch64-linux-gnu
xcc64	= $(xcc64_env)/bin/aarch64-linux-gnu-

atf_dir	=	atf_a64
atf_bin	=	$(atf_dir)/build/sun50iw1p1/release/bl31.bin

atf_dld:
	git clone --branch allwinner-a64-bsp --single-branch \
	https://github.com/longsleep/arm-trusted-firmware.git $(atf_dir)

atf_build:
	$(MAKE) -C $(atf_dir) clean && \
	$(MAKE) ARCH=arm CROSS_COMPILE=$(xcc64) PLAT=sun50iw1p1 -C $(atf_dir) bl31


#######################################################################
# 8. Sunxi packing tools
#
# This runs on host machine
#######################################################################

packer_dir = sunxi_pack_tools
packer_tools = $(packer_dir)/bin

packer_dld:
	git clone https://github.com/longsleep/sunxi-pack-tools.git $(packer_dir)

packer_build:
	$(MAKE) -C $(packer_dir)


#######################################################################
# 9. Sysconfig fex
#
# Dummy but required
#######################################################################

sysconf_src	= $(blobs)/sys_config.fex
sysconf_bin = $(patsubst %.fex,%.bin,$(sysconf_src))

define SYSFEX
[product]
version = "100"
endef
export SYSFEX
 
sysconf_create:
	echo "$$SYSFEX" | unix2dos > $(sysconf_src)


#######################################################################
# 10. Download devicetree
# 
# If dtc would not work try the one from kernel repo
#######################################################################

dts_path = $(blobs)/pine64.dts
dtb_path = $(blobs)/pine64.dtb

dts_dld:
	wget -O $(dts_path) https://raw.githubusercontent.com/longsleep/build-pine64-image/master/blobs/pine64.dts

dts_build:
	dtc -Odtb -Idts -o $(dtb_path) $(dts_path)


#######################################################################
# 11. Merge u-boot and other components
#
#######################################################################

build_dir	= build
uboot_mgd1	= $(build_dir)/uboot_merged1.bin
uboot_mgd2	= $(build_dir)/uboot_merged2.bin
uboot_dtb	= $(build_dir)/uboot_dtb.bin

# from u-boot-postprocess.sh
pack_build:
	test -d $(build_dir) || mkdir $(build_dir) && \
	$(packer_tools)/script $(sysconf_src)
	$(packer_tools)/merge_uboot \
		$(uboot_bin) $(atf_bin) $(uboot_mgd1) \
		secmonitor && \
	$(packer_tools)/merge_uboot \
		$(uboot_mgd1) $(scp_bin) $(uboot_mgd2) scp
	$(packer_tools)/update_uboot_fdt \
		$(uboot_mgd2) $(dtb_path) $(uboot_dtb)
	$(packer_tools)/update_uboot \
		$(uboot_dtb) $(sysconf_bin)

pack_clean:
	rm $(uboot_mgd1) $(uboot_mgd2) $(uboot_dtb)


#######################################################################
# 5. Creating custom simpleimage
# * Contains no rootfs and spawns a shell on UART tty
#
# fdisk -l $(im_name)
# This gives a block size and offset of kernel in blocks. One can either
# overwrite it with dd or mount and edit. Specific partition can be mounted and
# accessed:
# 	mount {-t TYPE} -o loop,offset=65536 src.img /mnt/path
#######################################################################

im_out		=	szyszka.img
im_part		=	szyszka.part
im_part		=	szyszka.part
u_env		=	uEnv.txt
boot0_pos	=	8		#KB  =
# this hole seems to be fixed by boot0
uboot_pos	=	19096	#KB  =
part_pos	=	20		#MB  = [0x1400000
part_pos_kb	=	20480	# same in KB
boot_sz		=	10		#MB, I assume not more will be needed

image_boot:
	dd if=/dev/zero bs=1M count=$(part_pos) of=$(im_out)
	dd if=$(boot0_img) conv=notrunc bs=1K seek=$(boot0_pos) of=$(im_out)
	dd if=$(uboot_dtb) conv=notrunc bs=1K seek=$(uboot_pos) of=$(im_out)

define PARTTAB
cat <<@ | sudo fdisk $(im_out)
o
n
p
1
$$(($(part_pos_kb)*2))

t
83
p
w
@
endef
export PARTTAB

image_kernel:
	dd if=/dev/zero bs=1M count=$(boot_sz) of=$(im_part)
	sudo mkfs.vfat -n BOOT $(im_part) && \
	mcopy -smnv -i $(im_part)  $(kern_im) :: && \
	mcopy -smnv -i $(im_part) $(u_env) ::
	dd if=$(im_part) conv=notrunc bs=1M seek=$(part_pos) of=$(im_out) && \
	rm -f $(im_part)
	sh -c "$$PARTTAB"

# HOW To run my binary form uboot??
#
# [0x2000,0xa000)			: boot0
# ...
# [0x12a6000, 138e000)		: u-boot
# ------ BOOT vfat ------
# [0x1400000, 0x14000c0)	: mkfs.fat FAT16
# [0x1405200, 1405280)		: BOOT
# [0x1409200, 14092b0)		: kernel.bin
# [0x1409a00, 1409a60)		: uEnv.txt
#
# pre-build kernel was flashed with im_flash
#
# application error:
# sunxi#go 0x41000000
# ## Starting application at 0x41000000 ...
# data abort
# pc : [<41000028>]          lr : [<7ff1d054>]
# sp : 76eb8e00  ip : 00000030     fp : 7ff1d00c
# r10: 00000002  r9 : 76ed0ea0     r8 : 7ffb5340
# r7 : 77f1b0b8  r6 : 41000000     r5 : 00000002  r4 : 77f1b0bc
# r3 : 41000000  r2 : 77f1b0bc     r1 : 77f1b0bc  r0 : 00000001
# Flags: nZCv  IRQs on  FIQs off  Mode SVC_32
# Resetting CPU ...
#

image_flash:
	sudo dd if=$(im_out) bs=1M oflag=sync of=$(sd_path) && sync

flash_kernel:
	rm $(im_out)
	$(MAKE) image_boot
	$(MAKE) image_kernel
	$(MAKE) image_flash

# xcc64
image_test:
	$(xcc32)objdump -fF $(im_out)

#Environment size: 1619/131067 bytes
#	sunxi#set load_kernel 'fatload mmc ${boot_part} ${load_addr} ${kernel_filename}'
#	sunxi#set kernel_filename 'hello.bin'
#	sunxi#
#	sunxi#
#	sunxi#set mmcboot 'run load_kernel go ${load_addr}'
#	s


