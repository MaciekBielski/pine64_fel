#######################################################################
# 1. Download the image
#######################################################################

im_name =	simpleimage-pine64-latest.img.xz
im_path	=	https://www.stdin.xyz/downloads/people/longsleep/pine64-images/${im_name}

im_dload:
	wget $(im_path)

#######################################################################
# 2. Flash the image to SDcard
#######################################################################

sd_path	=	/dev/mmcblk0

im_flash:
	xzcat $(im_name) | pv | sudo dd of=$(sd_path) bs=1M oflag=sync

#######################################################################
# 3. Building test kernel
# TODO: merge this kernel with loadable image that is written to SDcard
#######################################################################

test_dir	=	test_kernel

build_objects:
	$(MAKE) -C $(test_dir) build_test

link_objects:
	$(MAKE) -C $(test_dir) link_test

clean_objects:
	$(MAKE) -C $(test_dir) clean



#######################################################################
# 3. Overwrite the image with own kernel
#
# fdisk -l $(im_name)
# This gives a block size and offset of kernel in blocks. One can either
# overwrite it with dd or mount and edit. Specific partition can be mounted and
# accessed:
# 	mount {-t TYPE} -o loop,offset=65536 src.img /mnt/path
#######################################################################


