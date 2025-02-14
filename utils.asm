; utils.asm

; Verifica se as labels já foram definidas
%ifndef UTILS_ASM
%define UTILS_ASM

; Common utility functions
global print_string

print_string:
    push ax
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    pop ax
    ret

new_line:
    mov si, nl
    call print_string
    ret

nl db 0x0D, 0x0A, 0

%endif ; UTILS_ASM