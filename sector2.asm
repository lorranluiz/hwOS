%ifndef SECTOR2_ASM
%define SECTOR2_ASM

sector2:
    ; Move string handling functions here
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

    ; Add other auxiliary functions here

%endif