; command_clear.asm

%ifndef COMMAND_CLEAR_ASM
%define COMMAND_CLEAR_ASM

command_clear:
    mov ax, 0x0003  ; Text mode 80x25
    int 0x10
    ret

%endif

; Inclui o arquivo de descrições dos comandos
%include "command_descriptions.asm"