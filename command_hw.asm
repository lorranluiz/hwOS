%ifndef COMMAND_HW_ASM
%define COMMAND_HW_ASM

[BITS 16]
section .text
global command_hw

command_hw:
    push bp           ; Save base pointer
    mov bp, sp        ; Set up stack frame
    pusha            ; Save all registers

    mov ax, 0x2000   ; Segmento onde o código C está carregado
    mov es, ax
    call far [es:print_hello_offset]  ; Chamada far para a função C

    popa             ; Restore all registers
    mov sp, bp       ; Restore stack pointer
    pop bp           ; Restore base pointer
    ret              ; Return to caller

section .data
print_hello_offset dw 0x0000  ; Offset da função print_hello no segmento 0x2000

%endif