UART wiring
--------------------------------------------------------------------------------
UART0, symbols of FDTI connected to EXP:

	[_][_][_][TX][_]
	[_][_][_][RX][GND]


Boot sequence
--------------------------------------------------------------------------------

1. Comes out of RESET in 32-bit mode and executes BROM code (mapped at 0x0)
  * BROM code can be found at 0x2c00 (32KB long)
2. Power without SD card enters the FEL mode
3. Firmware loads u-boot at sector 38192 (19.096 KByte)
4. Firmware loads ATF into DRAM
5. Firmware loads code for the arisc management into SRAM
6. Firmware does RMR write for warm-reset into AArch64 execution state and
   jumps into ATF entry point by putting its address into RVBAR
7. ATF initializes the boot core for non-secure execution
8. ATF jumps to non-secure AArch32 EL1 to run u-boot
9. u-boot runs in 32-bit and uses hacked ATF to hand over kernel entry point
10. ATF returns into AArch64 non-secure EL1 to run kernel this time


U-boot info
--------------------------------------------------------------------------------
* u-boot is loaded in the image at 19096 (if one wants to overwrite it)
* compiled with `arm-linux-gnueabihf-gcc`
* UART0 is at 0x01C28000

	fdt_addr=45000000
	fdt_filename_prefix=pine64/sun50i-a64-
	fdt_filename_suffix=.dtb
	initrd_addr=45300000
	initrd_filename=initrd.img
	kernel_addr=41080000
	kernel_filename=pine64/Image
	load_addr=41000000


TODO: create an image with your own binary
