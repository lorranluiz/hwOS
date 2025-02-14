// Simple output functions using BIOS interrupts

void print_char(char c) {
    __asm__ volatile (
        "mov $0x0e, %%ah\n"
        "mov %0, %%al\n"
        "int $0x10"
        : 
        : "r" (c)
        : "ax"
    );
}

void print_hello(void) {
    const char *message = "Hello from C!\r\n";
    const char *ptr = message;
    
    while (*ptr) {
        print_char(*ptr);
        ptr++;
    }
}

void _start(void) {
    print_hello();
    __asm__ volatile ("ret");
}