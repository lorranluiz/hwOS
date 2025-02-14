; command_echo.asm

%ifndef COMMAND_ECHO_ASM
%define COMMAND_ECHO_ASM

command_echo:
    ; Get the pointer to the first argument
    mov si, input_buffer
    call skip_command

    ; Print the argument
    call print_string
    call new_line
    ret

; Subroutine to skip the "echo" command
skip_command:
    mov cx, 5  ; Length of the "echo " command (including space)
.skip_loop:
    lodsb
    loop .skip_loop
    ret

; Inclui o arquivo de utilitários
%include "utils.asm"

%endif ; COMMAND_ECHO_ASM

; Inclui o arquivo de descrições dos comandos
%include "command_descriptions.asm"