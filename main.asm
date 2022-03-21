    [BITS 16]
    [ORG 0x7c00]

%macro mul_by_ten 2
    mov %2, %1
    shl %1, 2
    add %1, %2
    shl %1, 1
%endmacro
    

    mov ah, 0x00
    mov al, 0x13
    int 10h

    xor di, di
render:
    mov word[tmp0], di
    mov si, di
    mov bx, di
    shr bx, 3
    mov al, byte[board + bx]
    shl bx, 3
    sub si, bx
    shl si, 1
    cmp si, 0
    jz next
shift:
    shl al, 1
    dec si
    jnz shift
next:
    shr al, 6
    mov si, di
    shr di, 4
    mov bx, di
    shl di, 4
    sub si, di
    mov di, bx
    lea esi, [esi * 4 + esi]
    shl si, 1
    lea edi, [edi * 4 + edi]
    shl di, 1
    call draw_square

    mov di, word[tmp0]
    inc di
    cmp di, 256
    jb render

hang:
    jmp hang

draw_square:
    mov dx, di
    mov cx, si
    add di, 10
    add si, 10
.outer:
    xor cx, cx
.loop:
    mov ah, 0x0c
    mov bh, 0
    int 0x10
    inc cx
    cmp cx, si
    jb .loop

    inc dx
    cmp dx, di
    jb .outer
    ret

tmp0: dw 0
tmp1: dw 0
tmp2: dw 0

; 2 = green, 4 = red, 0 = black

rows:  equ 16
cols:  equ 16
board:
db 0b11111111, 0b11111111, 0b11111111, 0b11111111, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11000000, 0b00000000, 0b00000000, 0b00000011,
db 0b11000000, 0b00000000, 0b00000000, 0b00000011, 0b11111111, 0b11111111, 0b11111111, 0b11111111

    times 510 - ($ - $$) db 0
    dw 0xaa55