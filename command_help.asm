; command_help.asm

%ifndef COMMAND_HELP_ASM
%define COMMAND_HELP_ASM

command_help:
    mov si, help_msg
    call print_string
    ret

help_msg:
    db 'Commands:', 0x0D, 0x0A
    db 'help  - Display available commands', 0x0D, 0x0A
    db 'clear - Clear the screen', 0x0D, 0x0A
    db 'echo  - Print a message', 0x0D, 0x0A
    db 'exit  - Reboot the system', 0x0D, 0x0A, 0

%endif