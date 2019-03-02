#include <macros.h>

	.text
	print	0x01C28000, message, completed
completed:	b .
	.data
message:
	.asciz "*** Hello from aarch64! ***"
	.end
