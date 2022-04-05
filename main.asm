    [BITS 16]
    [ORG 0x7c00]

; ax - free use
; bx - free use
; cx - free use
; dh - snakehead x (SAVE)
; dl - snakehead y (SAVE)
; si - snakelen
; di - free use
    mov ax, 0x0013
    int 0x10

    mov dx, 0x5000
    mov al, BORDER_COLOR
    mov bx, 0x0550
    call draw_rect

    mov dx, 0x0050
    mov bx, 0x5505
    call draw_rect

    rdtsc
    mov word [rand], ax
    call draw_apple

    mov dx, 0x3232
    mov al, SNAKE_COLOR
    call draw_square
    xor si, si
start:
    xor ah, ah
    int 0x16
    jmp check_a

input:
    mov ecx, 0x6ffffff
delay:
    dec ecx
    jnz delay

    mov ah, 0x01
    int 0x16
    jz base

    xor ah, ah
    int 0x16

check_a:
    cmp al, 'a'
    jne check_s
    jmp valid_input
check_s:
    cmp al, 's'
    jne check_d
    jmp valid_input
check_d:
    cmp al, 'd'
    jne check_w
    jmp valid_input
check_w:
    cmp al, 'w'
    jne base
valid_input:
    and al, 0x07
    shr al, 1
    movzx bx, al
    mov ah, byte [invalid + bx]
    cmp ah, byte [dir]
    je base
    jmp grow_snake
base:
    mov al, byte [dir]

grow_snake:
    mov byte [dir], al
    mov ah, al
    shl ah, 6
    mov cx, si
    mov di, si
    inc si
    shr di, 2
    mov bx, di
    shl di, 2
    sub cx, di
    shl cl, 1
    shr ah, cl
    or byte [snakebody + bx], ah
    shl al, 1
    movzx di, al

    add dh, byte [moves + di]      ; if the result of the add underflows the sign bit is set in eflags
    js hang                        ; an underflow indicates that the snakehead is past the border
    add dl, byte [moves + di + 1]  ; same here
    js hang
    cmp dh, 80
    jz hang
    cmp dl, 80
    jz hang

    cmp dx, word [apple]
    jne .next
    call draw_apple
    jmp draw_head
.next:
    push dx
    mov di, snakebody
    xor cx, cx
    xor bh, bh
get_tail:
    test cx, 0x03
    jnz .next
    mov bl, byte [di]
    inc di
.next:
    mov al, bl
    shr bl, 6
    shl bl, 1
    sub dh, byte [moves + bx]
    sub dl, byte [moves + bx + 1]
    mov bl, al
    shl bl, 2
    inc cx
    cmp cx, si
    jnz get_tail

erase_tail:
    mov al, BACKGROUND_COLOR
    call draw_square
    pop dx

    mov cx, si
    dec si
    shr cx, 2
    inc cx
    xor bx, bx
.shift_body:
    shl byte [snakebody + bx], 2
    mov al, byte [snakebody + bx + 1]
    shr al, 6
    or byte [snakebody + bx], al
    inc bl
    cmp bl, cl
    jnz .shift_body

    push dx
    movzx cx, dh
    xor dh, dh
    mov ah, 0x0d
    int 0x10
    cmp al, SNAKE_COLOR
    jz hang
    pop dx

draw_head:
    mov al, SNAKE_COLOR
    call draw_square
    cmp si, 255
    jz hang
    jmp input

hang:
    jmp $

draw_square:
    mov bx, 0x0505
    call draw_rect
    ret

; x pos in dh
; y pos in dl
; draws square with top left corner at dh, dl
; returns nothing
draw_rect:
    push dx
    movzx cx, dh
    mov di, cx
    add bx, dx
    xor dh, dh
    mov ah, 0x0c
.loop:
    int 0x10
    inc cl
    cmp cl, bh
    jb .loop

    mov cx, di
    inc dl
    cmp dl, bl
    jb .loop
    pop dx
    ret

draw_apple:
    push dx
    call next_rand
    movzx cx, ah
    movzx dx, al
    and cl, COLS - 1
    and dl, ROWS - 1
    lea ecx, [ecx * 4 + ecx]
    lea edx, [edx * 4 + edx]
    mov ah, 0x0d
    jmp .next
.check:
    add cl, 5
    cmp cl, 80
    jne .next
    xor cl, cl
    add dl, 5
    cmp dl, 80
    jne .next
    xor dl, dl
.next:
    int 0x10
    cmp al, SNAKE_COLOR
    jz .check
    mov dh, cl
    mov word [apple], dx
    mov al, APPLE_COLOR
    call draw_square
.end:
    pop dx
    ret

next_rand:
    mov ecx, 75
    mov ax, word [rand]
    mul ecx
    add ax, 74
    mov word [rand], ax
    ret

SNAKE_COLOR      equ 0b00000010
BACKGROUND_COLOR equ 0b00000000
APPLE_COLOR      equ 0b00000100
BORDER_COLOR     equ 0b00001111

ROWS equ 16
COLS equ 16

UP    equ (moves.up    - moves) / 2
RIGHT equ (moves.right - moves) / 2
LEFT  equ (moves.left  - moves) / 2
DOWN  equ (moves.down  - moves) / 2
;              x,    y
moves:
.left    db 0xfb, 0x00 ; left  (a)
.down    db 0x00, 0x05 ; down  (s)
.right   db 0x05, 0x00 ; right (d)
.up      db 0x00, 0xfb ; up    (w)

invalid  db RIGHT, UP, LEFT, DOWN

dir   db 0
snakebody: times (ROWS * COLS) / 4 db 0
rand  dw 0
apple dw 0

    times 510 - ($ - $$) db 0
    dw 0xaa55