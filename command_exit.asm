; command_exit.asm

%ifndef COMMAND_EXIT_ASM
%define COMMAND_EXIT_ASM

command_exit:
    int 0x19        ; Reboot system
    ret

%endif

; Inclui o arquivo de descrições dos comandos
%include "command_descriptions.asm"