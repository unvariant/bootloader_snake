    [BITS 16]
    [ORG 0x7c00]

    mov ah, 0x00
    mov al, 0x13
    int 10h

    mov dx, word [snakehead]
    movzx cx, dh
    and dx, 0xff
    mov al, SNAKE_COLOR
    call draw_square
start:
    xor ah, ah
    int 0x16
    jmp check_w

input:
    mov ah, 0x01
    int 0x16
    jz base

    xor ah, ah
    int 0x16

check_w:
    cmp al, 'w'
    jne check_s
    mov al, UP
    jmp grow_snake
check_s:
    cmp al, 's'
    jne check_a
    mov al, DOWN
    jmp grow_snake
check_a:
    cmp al, 'a'
    jne check_d
    mov al, LEFT
    jmp grow_snake
check_d:
    cmp al, 'd'
    jne base
    mov al, RIGHT
    jmp grow_snake
base:
    mov al, byte [dir]

grow_snake:
    mov byte [dir], al
    mov ah, al
    shl ah, 6
    mov cx, word [snakelen]
    mov dx, word [snakelen]
    inc word [snakelen]
    shr dx, 2
    mov bx, dx
    shl dx, 2
    sub cx, dx
    shl cl, 1
    sar ah, cl
    or byte [snakebody + bx], ah
    movzx si, al
    shl si, 1
    mov dx, word [snakehead]
    movzx cx, dh
    xor dh, dh

    add cl, byte [moves + si]
    add dl, byte [moves + si + 1]
    cmp cl, 0
    jl hang
    cmp cl, 16
    jz hang
    cmp dl, 0
    jl hang
    cmp dl, 16
    jz hang
    mov word [tmp2], cx
    mov word [tmp3], dx
    mov al, SNAKE_COLOR
    call draw_square
    mov cx, word [tmp2]
    mov dx, word [tmp3]
    mov dh, cl
    mov word [snakehead], dx
    movzx cx, dh
    xor dh, dh

    mov si, snakebody
    xor di, di
    xor bh, bh
get_tail:
    test di, 0b00000011
    jnz .next
    mov bl, byte [si]
    inc si
.next:
    mov al, bl
    shr bl, 6
    shl bl, 1
    sub cl, byte [moves + bx]
    sub dl, byte [moves + bx + 1]
    mov bl, al
    shl bl, 2
    inc di
    cmp di, word [snakelen]
    jnz get_tail

erase_tail:
    mov al, BACKGROUND_COLOR
    call draw_square

    mov si, word [snakelen]
    dec word [snakelen]
    shr si, 2
    inc si
    xor di, di
.shift_body:
    shl byte [snakebody + di], 2
    mov al, byte [snakebody + di + 1]
    shr al, 6
    or byte [snakebody + di], al
    inc di
    cmp di, si
    jnz .shift_body
    mov eax, 0x4ffffff
delay:
    dec eax
    jnz delay
    jmp input

hang:
    hlt
    jmp $

; x pos in cx
; y pos in dx
; draws square with top left corner at cx * 5, dx * 5
; returns nothing
draw_square:
    mov word [tmp0], dx
    shl dx, 2
    add dx, word [tmp0]
    mov word [tmp1], cx
    shl cx, 2
    add cx, word [tmp1]
    mov word [tmp0], dx
    add word [tmp0], 5
    mov word [tmp1], cx
    add word [tmp1], 5
    add cx, 5
.outer:
    sub cx, 5
.loop:
    mov ah, 0x0c
    int 0x10
    inc cx
    cmp cx, [tmp1]
    jb .loop

    inc dx
    cmp dx, [tmp0]
    jb .outer
    ret

tmp0  dw 0
tmp1  dw 0
tmp2  dw 0
tmp3  dw 0

SNAKE_COLOR      equ 0b00000011
BACKGROUND_COLOR equ 0b00000000

ROWS equ 16
COLS equ 16

UP    equ 0
RIGHT equ 1
LEFT  equ 2
DOWN  equ 3
;           x,    y
moves db 0x00, 0xff ; up
      db 0x01, 0x00 ; right
      db 0xff, 0x00 ; left
      db 0x00, 0x01 ; down

dir   db 0

; x=high byte, y=low byte
snakehead: dw 0x0808
snakelen:  dw 0
snakebody: times 64 db 0

    times 510 - ($ - $$) db 0
    dw 0xaa55