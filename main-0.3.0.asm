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
    mov bx, di
    mov si, di
    shr si, 2
    mov al, byte [board + si]
    shl si, 2
    sub bx, si
    jz .next
    shl bx, 1
.loop:
    shl al, 1
    dec bx
    jnz .loop
.next:
    shr al, 6
    mov dx, di
    mov cx, di
    shr dx, 4
    mov cx, di
    mov bx, dx
    shl bx, 4
    sub cx, bx
    mul_by_ten dx, bx
    mul_by_ten cx, bx
    call draw_square
    inc di
    cmp di, 256
    jnz render

hang:
    jmp hang

draw_square:
    mov bx, dx
    add bx, 10
    mov [tmp0], bx
    mov bx, cx
    add bx, 10
    mov [tmp1], bx
    add cx, 10
.outer:
    sub cx, 10
.loop:
    mov ah, 0x0c
    mov bh, 0
    int 0x10
    inc cx
    cmp cx, [tmp1]
    jb .loop

    inc dx
    cmp dx, [tmp0]
    jb .outer
    ret

tmp0: dw 0
tmp1: dw 0
tmp2: dw 0

; 2 = green, 4 = red, 0 = black

rows:  equ 16
cols:  equ 16
board:
db 0b10101010, 0b10101010, 0b10101010, 0b10101010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10000000, 0b00000000, 0b00000000, 0b00000010,
db 0b10000000, 0b00000000, 0b00000000, 0b00000010, 0b10101010, 0b10101010, 0b10101010, 0b10101010

    times 510 - ($ - $$) db 0
    dw 0xaa55