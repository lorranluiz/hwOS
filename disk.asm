%ifndef DISK_ASM
%define DISK_ASM

; Função para ler um setor do disco
; Entrada: AX = número do setor
;         ES:BX = buffer para dados
read_sector:
    pusha
    mov cx, 5           ; Tentativas de leitura
.retry:
    push cx
    mov ah, 0x02       ; Função de leitura
    mov al, 1          ; Número de setores
    mov ch, 0          ; Cilindro 0
    mov cl, al         ; Setor
    mov dh, 0          ; Cabeça 0
    mov dl, 0x80       ; Primeiro disco rígido
    int 0x13
    jnc .success
    xor ah, ah         ; Reset disco
    int 0x13
    pop cx
    loop .retry
    jmp .error
.success:
    pop cx
    popa
    clc
    ret
.error:
    popa
    stc
    ret

; Função para escrever um setor no disco
; Entrada: AX = número do setor
;         ES:BX = buffer com dados
write_sector:
    pusha
    mov cx, 5           ; Tentativas de escrita
.retry:
    push cx
    mov ah, 0x03       ; Função de escrita
    mov al, 1          ; Número de setores
    mov ch, 0          ; Cilindro 0
    mov cl, al         ; Setor
    mov dh, 0          ; Cabeça 0
    mov dl, 0x80       ; Primeiro disco rígido
    int 0x13
    jnc .success
    xor ah, ah         ; Reset disco
    int 0x13
    pop cx
    loop .retry
    jmp .error
.success:
    pop cx
    popa
    clc
    ret
.error:
    popa
    stc
    ret

%endif