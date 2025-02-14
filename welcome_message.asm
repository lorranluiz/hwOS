%ifndef WELCOME_MESSAGE_ASM
%define WELCOME_MESSAGE_ASM

display_welcome:
    mov ax, 0x0003  ; Clear screen
    int 0x10
    mov si, msg
    call print_string
    ret

msg db 'Welcome to hwOS 0.1', 0x0D, 0x0A, 0x0D, 0x0A, 0

%endif