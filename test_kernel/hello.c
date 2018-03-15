
volatile unsigned int * const UART0_DR = (unsigned int *)0x01C28000;
volatile unsigned int * const UART_LSR = (unsigned int *)0x01C28014;

static void print_uart0(const char c)
{
	while(!((*UART_LSR) & 0x20))
		continue;
	*UART0_DR = c;
}

void kentry()
{
	print_uart0('H');
	print_uart0('E');
	print_uart0('L');
	print_uart0('L');
	print_uart0('O');
}
