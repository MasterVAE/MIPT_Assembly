.model tiny
.code

VRAMSEG EQU 0b800h
EXITCODE EQU 4c00h

WIDTH EQU 80d

SYMB1 EQU 00DBh
SYMB2 EQU 03DBh

RECT_POS_Y EQU 0Ah

STRING_LENGHT_POS EQU 80h
STRING_START EQU 82h

org 100h

;===============================================================================

start:
    	call print

    	jmp exit

;===============================================================================





;===============================================================================
;	proc exit leave programm
;===============================================================================
exit proc

	mov ax, EXITCODE
	int 21h

	endp
;===============================================================================




;===============================================================================
;	proc print prints rectangles with text
;===============================================================================
print proc

	mov ax, VRAMSEG		;move VRAM pos to es
	mov es, ax	
	
	mov di, STRING_LENGHT_POS
	xor cx, cx		;changed scale
	mov cl, [di]
	add di, cx			
	mov dl, [di]
	sub dl, '0'
	mov scale, dl

				;rectangle 1

	mov di, STRING_LENGHT_POS
	mov bl, [di]
	add bl, 1h		;scale x
	mov bh, scale		;scale y

	mov ax, SYMB1	;symb

	xor cx, cx		;changed color
	mov cl, [di]
	add di, cx			
	mov dl, [di - 2]
	sub dl, '0'
	mov ah, dl

	push ax
	push bx


	xor ax, ax
	mov al, bl
	shr ax, 1h

	mov ch, WIDTH 		;pos x
	shr ch, 1h
	sub ch, al

	mov cl, RECT_POS_Y		;pos y

	pop bx
	pop ax
	call print_rect

				;rectangle 2

	mov di, STRING_LENGHT_POS
	mov bl, [di]
	sub bl, 3			;scale x

	mov ax, SYMB2	;symb
	mov bh, scale
	sub bh, 2		;scale y

	push ax
	push bx

	xor ax, ax
	mov al, bl
	shr ax, 1h

	mov ch, WIDTH 		;pos x
	shr ch, 1h
	sub ch, al

	mov cl, RECT_POS_Y + 1		;pos y

	pop bx
	pop ax
	call print_rect


				;text

	mov si, STRING_START	;color
	mov bx, STRING_LENGHT_POS
	xor cx, cx
	mov cl, byte ptr [bx]
	sub cx, 5
	

	xor ax, ax
	mov al, cl
	shr al, 1h

	mov bh, WIDTH 		;pos x
	shr bh, 1h
	sub bh, al

	xor bl, bl		;pos y
	mov bl, scale
	shr bl, 1h
	add bl, RECT_POS_Y	

	call print_text

	ret

	endp
;====================================================================================





;====================================================================================
;proc print_rect
;enter		al - char
;		ah - color argument
;		bl - scale_y
;		bh - scale_x
;		cl - pos_y
;		ch - pos_x
;destroy	si
;====================================================================================
print_rect	proc
	push ax			;store symbol offset in di
	push bx
					
	xor ax, ax
	xor bx, bx
	add al, cl

	add bx, WIDTH * 2
	mul bx

	xor bx, bx
	add bl, ch
	add ax, bx
	add ax, bx

	mov di, ax
	
	pop bx
	pop ax

	xor cx, cx		;cx = y shift

.cycle_y:			;y - cycle
	xor si, si		;si = x shift

.cycle_x:			;x - cycle

	push bx

	xor bx, bx
	add bx, cx
	add bx, si
	mov es:[di + bx], ax

	pop bx

	add si, 2h		;iteration add

	push ax			;comparation

	xor ax, ax
	add al, bl
	add al, bl

	cmp ax, si

	pop ax
ja .cycle_x			;x cycle jump 
	
	add cx, WIDTH * 2

	push ax			;comparation
	push bx

	xor ax, ax
	add al, bh
	mov bx, WIDTH * 2
	mul bx

	cmp ax, cx

	pop bx
	pop ax
ja .cycle_y
	ret 
	
	endp
;===============================================================================






;===============================================================================
;proc print_text
;enter 		si - start of text
;		bl - text pos y
;		bh - text pos x
;		cx - text lenght
;destroy	di dx
;===============================================================================
print_text 	proc
	
	xor di, di		;store symbol shift in di
	
	push cx

	xor ax, ax
	xor cx, cx

	mov al, bl
	mov cx, WIDTH * 2
	mul cx
		
	xor dx, dx
	add dl, bh

	add ax, dx
	add ax, dx

	mov di, ax

	pop cx

.cycle:				;main cycle

	mov bl, [si]
	mov bh, 3Fh
	mov es:[di], bx

	inc di
	inc di
	inc si
	dec cx
	cmp cx, 0h
ja .cycle
	ret
		endp
;================================================================================
.data
scale	db 7h

end 	start