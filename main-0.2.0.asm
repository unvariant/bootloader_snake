; really dont want to write code with a table
; next to me with the length of all the instructions...
; will try avoid doing that for as long as I can

    [BITS 16]
    org 0x7c00

setup:
    mov ax, 0x0001       ; think moving one value into 16 bit reg is less bytes then two moves into 8 bit registers
    int 10h

    ; mov ah, 01h        ; turns off cursor blinking
    ; mov cx, 0x2000     ; uncomment this code if there is still space
    ; int 10h

draw_board:
    mov ax, 0x1301
    mov bx, 0x000f
    mov cx, 17
    xor dx, dx
    mov es, dx
    mov bp, border1
    mov di, 16
.loop:
    int 10h
    inc dh
    dec di
    jnz .loop

    add bp, rowlen
    int 10h

    add bp, rowlen
    lea di, [bp + 16]
horizontal:
    mov dh, byte[di]
    mov ch, byte[di + 1]
    mov dl, dh
    mov cl, ch
    and dh, 0x0f
    and ch, 0x0f
    shr dl, 4
    shr cl, 4
    cmp dh, ch
    jnz vertical

    cmp dl, cl
    jl .next

    xchg dl, cl
.next:
    sub cl, dl
    xor ch, ch
    inc cl
    int 10h

    jmp next
vertical:
    cmp dh, ch
    jg .next

    xchg dh, ch
.next:
    movzx si, ch
    dec si
.loop:
    mov cx, 1
    int 10h
    dec dh
    mov cx, si
    cmp dh, cl
    ja .loop

next:
    inc di
    cmp word[di + 1], 0
    jnz horizontal

check_input:
    mov ah, 0x01
    int 16h
    je check_input

    xor ah, ah
    int 16h

    mov bx, direction
    sub al, 0x31
    js check_input
    cmp al, 3
    ja check_input

    movzx si, al
    mov al, byte[bx + 5 + si]

    mov ah, byte[bx + 1 + si]
    cmp ah, byte[bx]
    jz check_input
    ;jnz move_snake

    ;mov al, byte[bx]

move_snake:                ; al holds next direction
    push ax
    lea di, [bx - 162]
    cmp al, byte[bx]
    jz move_head

    mov bp, snake_end
    inc word[bp]
    mov bp, word[bp]
    dec bp
    lea cx, [di - 1]
shift:
    shl word[bp], 8
    dec bp
    cmp bp, cx
    jnz shift

    mov cl, byte[di + 1]
    mov byte[di], cl

move_head:
    mov byte[bx], al
    mov ch, byte[di]
    mov cl, al
    mov dh, ch
    mov dl, ch
    shr cl, 4               ; cl contains x increment
    shr dh, 4               ; dh contains current x pos
    add dh, cl
    and dh, 0x0f

    and dl, 0x0f            ; dl contains current y pos
    and al, 0x0f            ; al contains y increment
    add dl, al
    and dl, 0x0f

    shl dh, 4
    or dh, dl
    mov byte[di], dh
    jmp draw_board

border1:   db "                @"
rowlen     equ $ - border1
border2:   db "@@@@@@@@@@@@@@@@@"
body_sym:  db "oooooooooooooooo"
snake:     db 0x77, 0x77
           times 160 db 0            ; max amount of points that could make up the snake is 160 + 2 for the terminator
direction: db 0xf0
; '1' = left, '2' = down, '3' = up, '4' = right
map:       db 0x10, 0x0f, 0x01, 0xf0
dir:       db 0xf0, 0x01, 0x0f, 0x10
           db 0xe0, 0x02, 0x0e, 0x20
snake_end: dw snake + 1

; dh contains byte to search for
; assumes ptr to 0 word (2 bytes) terminated array
contains:
    mov al, 1            ; set al to true
.loop:
    cmp byte[bx], dh     ; compare dh to byte at addr bx
    jz .end              ; return if equal
    inc bx               ; increment ptr
    cmp word[bx + 1], 0  ; end at word 0 terminator
    jnz .loop
    mov al, 0            ; set al to zero if element was not found
.end:
    ret

    times 510 - ($ - $$) db 0
    dw 0xaa55                   ; no idea why this is necessary
