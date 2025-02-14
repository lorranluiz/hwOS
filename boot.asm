; boot.asm
org 0x7C00  ; O código de boot é carregado na memória em 0x7C00
[bits 16]

start:
    xor ax, ax      ; Clear AX
    mov ds, ax      ; Set DS to 0
    mov es, ax      ; Set ES to 0
    mov ss, ax      ; Set SS to 0
    mov sp, 0x7C00  ; Set stack pointer

    ; Load additional sectors
    mov ah, 0x02    ; BIOS read sector function
    mov al, 4       ; Number of sectors to read
    mov ch, 0       ; Cylinder number
    mov cl, 2       ; Sector number (1-based, sector 2)
    mov dh, 0       ; Head number
    mov dl, 0x80    ; Drive number (change to 0x80 for hard disk)
    mov bx, second_sector  ; Load sectors after bootloader
    int 0x13
    jc error        ; If carry flag set, there was an error

    ; Verify if sectors were read correctly
    cmp al, 4       ; AL returns number of sectors actually read
    jne error       ; If not all sectors were read, show error

    ; After successful load, continue with execution
    call display_welcome
    call init_filesystem    ; Initialize filesystem first
    call command_prompt    ; Then start command prompt
    jmp $           ; Infinite loop

error:
    mov si, error_msg
    call print_string
    jmp $

error_msg db 'Error loading sector', 0x0D, 0x0A, 0

times 510-($-$$) db 0  ; Pad first sector
dw 0xAA55             ; Boot signature

second_sector:
; Include utility functions
%include "utils.asm"
; Include welcome message
%include "welcome_message.asm"
; Include command prompt
%include "command_prompt.asm"
; Include filesystem
%include "filesystem.asm"
%include "command_hw.asm"