    [BITS 16]
    [ORG 0x7c00]

    mov ah, 0x00
    mov al, 0x13
    int 10h

    mov dx, word [snaketail]
    movzx cx, dh
    and dx, 0xff
    mov al, SNAKE_COLOR
    call draw_square
input:
    mov ah, 0x01
    int 0x16
    jnz input

    xor ah, ah
    int 0x16

    cmp al, 'w'
    jne check_s
    mov ax, 0x0001
    jmp grow_snake
check_s:
    cmp al, 's'
    jne check_a
    mov ax, 0x00ff
    jmp grow_snake
check_a:
    cmp al, 'a'
    jne check_d
    mov ax, 0xff00
    jmp grow_snake
check_d:
    cmp al, 'd'
    jne input
    mov ax, 0x0100

grow_snake:
    mov di, word [snakelen]
    mov bx, di
    shr bx, 2
    mov si, bx
    shl bx, 2
    sub di, bx
    shl di, 1
    mov bx, 6
    sub bx, di
    jz .next
.shift:
    shl al, 1
    dec bx
    jnz .shift
.next:
    or byte [snakebody + si], al
    inc word [snakelen]

    mov dx, word [snaketail]
    movzx cx, dh
    and dx, 0xff
    mov al, BACKGROUND_COLOR
    call draw_square
    mov bx, snakebody
    xor di, di
get_head:
    test di, 0b00000011
    jnz .next
    movzx si, byte [bx]
    inc bx
.next:
    mov word [tmp0], si
    shr si, 6
    shl si, 1
    add cl, byte [dir + si]
    add dl, byte [dir + si + 1]
    mov si, word [tmp0]
    shl si, 2
    and si, 0xff
    inc di
    cmp di, word [snakelen]
    jnz get_head

    mov al, SNAKE_COLOR
    call draw_square

    mov bx, snakebody
    movzx si, byte [bx]
    shr si, 6
    shl si, 1
    mov dx, word [snaketail]
    movzx cx, dh
    and dx, 0xff
    add cl, byte [dir + si]
    add dl, byte [dir + si + 1]
    mov ch, cl
    mov cl, dl
    mov word [snaketail], cx
    xor di, di
shift:
    mov al, byte[bx]
    shl al, 2
    mov ah, byte[bx + 1]
    shr ah, 6
    or al, ah
    mov byte[bx], ah
    add di, 4
    cmp di, word [snakelen]
    jb shift
    jmp input

; x pos in cx
; y pos in dx
; draws square with top left corner at cx * 5, dx * 5
; returns nothing
draw_square:
    mov word [tmp2], dx
    mov word [tmp3], cx
    shl dx, 2
    add dx, word [tmp2]
    shl cx, 2
    add cx, word [tmp3]
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
    mov dx, word [tmp2]
    mov cx, word [tmp3]
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
DOWN  equ 1
RIGHT equ 2
LEFT  equ 3
;         x,    y
dir db 0x00, 0xff ; up
    db 0x00, 0x01 ; down
    db 0x01, 0x00 ; right
    db 0xff, 0x00 ; left

; x=high byte, y=low byte
snaketail: dw 0x0808
snakelen:  dw 1
snakebody: times 64 db 0

    times 510 - ($ - $$) db 0
    dw 0xaa55