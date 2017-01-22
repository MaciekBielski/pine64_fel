
volatile unsigned int * const UART0_DR = (unsigned int *)0x01C28000;
volatile unsigned int * const UART_LSR = (unsigned int *)0x01C28014;
 
void print_uart0(const char c)
{
	while(!((*UART_LSR) & 0x20))
		continue;
	*UART0_DR = c;
}
 
void kentry()
{
	print_uart0('D');
	print_uart0('U');
	print_uart0('P');
	print_uart0('A');
}
