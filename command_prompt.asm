; command_prompt.asm
%ifndef COMMAND_PROMPT_ASM
%define COMMAND_PROMPT_ASM

%include "utils.asm"        ; Include utils first
%include "command_clear.asm"
%include "command_exit.asm"
%include "command_help.asm"  ; Add this include

command_prompt:
    mov si, prompt
    call print_string
    mov di, input_buffer
    call read_string
    call new_line

    ; Check if command is help
    mov si, input_buffer
    mov di, help_command
    call compare_strings
    je .do_help

    ; Check if command is echo
    mov si, input_buffer
    mov di, echo_command
    call compare_strings_partial
    je .do_echo

    ; Check clear command
    mov si, input_buffer
    mov di, clear_command
    call compare_strings
    je .do_clear

    ; Check exit command
    mov si, input_buffer
    mov di, exit_command
    call compare_strings
    je .do_exit

    mov si, err_msg
    call print_string
    jmp command_prompt

.do_help:
    call command_help
    jmp command_prompt

.do_echo:
    mov si, input_buffer
    add si, 5          ; Skip "echo " command
    call print_string
    call new_line
    jmp command_prompt

.do_clear:
    call command_clear
    jmp command_prompt

.do_exit:
    call command_exit
    ret

; Data section
prompt db '> ', 0
exit_command db 'exit', 0
clear_command db 'clear', 0
echo_command db 'echo', 0
help_command db 'help', 0    ; Add this line
err_msg db 'Unknown command', 0x0D, 0x0A, 0  ; Improved error message
input_buffer times 24 db 0        ; Reduced from 32 to 24 bytes

; String handling functions
read_string:
    xor cx, cx
.loop:
    mov ah, 0
    int 0x16
    cmp al, 0x0D
    je .done
    stosb
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    xor al, al
    stosb
    ret

; String comparison functions
compare_strings:
.loop:
    lodsb
    scasb
    jne .not_equal
    test al, al
    jz .equal
    jmp .loop
.equal:
    xor ax, ax
    ret
.not_equal:
    or ax, 1
    ret

compare_strings_partial:
.loop:
    lodsb
    scasb
    jne .not_equal
    cmp byte [di], 0
    je .equal
    jmp .loop
.equal:
    xor ax, ax
    ret
.not_equal:
    or ax, 1
    ret

%endif