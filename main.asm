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
    mov cx, 18
    mov dx, 0
    mov es, dx
    mov bp, border1
    int 10h

    mov di, 16
    add bp, 18
.loop:
    inc dh
    int 10h
    dec di
    jnz .loop

    inc dh
    sub bp, 18
    int 10h

    add bp, 36
    mov di, bp
    inc di
horizontal:
    mov dh, byte[di]
    mov ch, byte[di + 1]
    mov dl, dh
    mov cl, ch
    and dh, 0x0f
    and ch, 0x0f
    shr dl, 4
    shr cl, 4
    mov ah, 0x02
    int 10h
    mov ah, 0x0a
    cmp dh, ch
    jnz vertical

    cmp dl, cl
    jl .next

    xchg dl, cl
.next:
    sub cl, dl
    mov ch, 0
    int 10h

    jmp next
vertical:
    cmp dh, ch
    jl .next

    xchg dh, ch
.next:
    movzx si, ch
.loop:
    mov ah, 0x0a
    mov cx, 1
    int 10h
    inc dh
    mov ah, 0x02
    int 10h
    mov cx, si
    cmp dh, cl
    jnz .loop

next:
    inc di
    cmp word[di + 1], 0
    jnz horizontal

    jmp $
check_input:
    mov ah, 0x01
    int 13h
    ; je ; figure out something




border1:  db "@@@@@@@@@@@@@@@@@@"
border2:  db "@                @"
body_sym: db "o"
snake:    db 0x00, 0x05
          times 160 db 0            ; max amount of points that could make up the snake is 160 + 2 for the terminator

; dh contains byte to search for
; assumes ptr to 0 word (2 bytes) terminated array
contains:
    mov al, 1            ; set al to true
.loop:
    cmp byte[bx], dh     ; compare dh to byte at addr bx
    jz .end              ; return if equal
    inc bx               ; increment ptr
    cmp word[bx + 1], 0      ; end at word 0 terminator
    jnz .loop
    mov al, 0            ; set al to zero if element was not found
.end:
    ret


    times 510 - ($ - $$) db 0
    dw 0xaa55                   ; no idea why this is necessary
