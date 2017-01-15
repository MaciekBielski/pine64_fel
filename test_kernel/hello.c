
volatile unsigned int * const UART0DR = (unsigned int *)0x01C28000;
 
void print_uart0(const char *s)
{
    for(; *s!='\0'; s++)
        *UART0DR = (unsigned int)(*s); /* Transmit char */
}
 
void kentry()
{
    print_uart0("Hello world!\n");
}
