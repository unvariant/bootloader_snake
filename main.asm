	org 0x7c00

	mov ah, 5h
	mov al, 1
	int 10h

draw	mov ah, 13h
	mov al, 1
	mov bh, 1
	mov bl, 0000_1111b
	mov cx, 16
	mov dx, 0
	mov bp, border1
	push cs
	pop es
	int 10h

	mov bp, border2
	mov si, 14
border  inc dh
	int 10h
	dec si
	jne border

	inc dh
	mov bp, border1
	int 10h

	mov ah, 13h
	mov al, 1
	mov cx, 1
	mov di, snake
	mov bp, body
render	mov dh, byte[di]
	mov dl, byte[di]
	and dh, 0fh
	shr dl, 4
	int 10h

	inc di
	cmp byte[di], 0xff
	jne render

input   mov ah, 1
	int 16h
	je input

	mov ah, 0
	int 16h

	mov di, dir
	cmp al, "h"
	je left
	cmp al, "j"
	je down
	cmp al, "k"
	je up
	cmp al, "l"
	je right
	jmp draw

left    cmp word[di], 0100h
	je draw
	mov word[di], 0f00h
	jmp next
down	cmp word[di], 0001h
	je draw
	mov word[di], 000fh
	jmp next
up	cmp word[di], 000fh
	je draw
	mov word[di], 0001h
	jmp next
right	cmp word[di], 0f00h
	je draw
	mov word[di], 0100h

next    mov di, snake - 1
findend	inc di
	cmp byte[di + 1], 0xff
	jne findend

	mov bp, word[di]
	mov word[di + 1], bp
	dec di

	cmp byte[apple], 0
	jne grow

	mov byte[di + 1], 0xff

grow	cmp di, snake - 1
	je head

shift   mov bp, word[di]
	mov word[di + 1], bp
	dec di
	cmp di, snake - 1
	jne shift

head	mov dx, word[dir]
	mov al, byte[snake + 1]
	add al, dl
	and al, 0x0f
	mov cl, al

	shr dx, 8
	mov al, byte[snake + 1]
	shr al, 4
	add al, dl
	and al, 0x0f
	shl al, 4
	or  cl, al
	mov byte[snake], cl
	jmp draw
	
snake   db 0x77
	db 0xff
	times 196 db 0

border1 db "@@@@@@@@@@@@@@@@"
border2 db "@              @"
body    db "o"
dir     dw 000fh
apple   db 0
	times 510 - ($ - $$) db 0
	dw 0xaa55


; get keyboard status
mov ah, 1
int 16h

; read from keyboard buffer
mov ah, 0
int 16h
