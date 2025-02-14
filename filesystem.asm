%ifndef FILESYSTEM_ASM
%define FILESYSTEM_ASM

; Constantes do sistema de arquivos
SECTOR_SIZE equ 512
MAX_FILES equ 16

; Estrutura de entrada do diretório
struc DirEntry
    .filename: resb 8    ; Nome do arquivo (8 caracteres)
    .ext:     resb 3    ; Extensão (3 caracteres)
    .attr:    resb 1    ; Atributos
    .reserved: resb 10  ; Bytes reservados
    .time:    resw 1    ; Hora de criação
    .date:    resw 1    ; Data de criação
    .cluster: resw 1    ; Primeiro cluster
    .size:    resd 1    ; Tamanho do arquivo
endstruc

section .data
    root_dir:    times (MAX_FILES * 32) db 0  ; Diretório raiz
    fat_table:   times 512 db 0               ; FAT simplificada

section .text

; Função para inicializar o sistema de arquivos
init_filesystem:
    pusha
    ; Limpar diretório raiz
    mov di, root_dir
    mov cx, MAX_FILES * 32
    xor al, al
    rep stosb
    popa
    ret

; Função para procurar um arquivo
; Entrada: SI = nome do arquivo
; Saída: AX = índice do arquivo (0xFFFF se não encontrado)
find_file:
    pusha
    mov cx, MAX_FILES
    mov di, root_dir
.search_loop:
    push cx
    mov cx, 11          ; 8 + 3 caracteres
    push si
    push di
    repe cmpsb
    pop di
    pop si
    je .found
    add di, 32          ; Próxima entrada
    pop cx
    loop .search_loop
    popa
    mov ax, 0xFFFF      ; Arquivo não encontrado
    ret
.found:
    pop cx
    sub di, root_dir    ; Calcular índice
    shr di, 5           ; Dividir por 32
    popa
    mov ax, di
    ret

%endif