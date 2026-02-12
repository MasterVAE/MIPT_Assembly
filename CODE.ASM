.model tiny
.code

VRAMSEG EQU 0b800h
EXITCODE EQU 4c00h

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
	
				;rectangle 1

	mov di, STRING_LENGHT_POS
	mov bl, [di]
	add bl, 5h		;scale x

	mov ax, 0ADBh	;symb
	mov bh, 05h		;scale y

	push ax
	push bx

	xor ax, ax
	mov al, bl
	mov bl, 2h
	div bl

	mov ch, 40d 		;pos x
	sub ch, al

	mov cl, 0Ah		;pos y

	pop bx
	pop ax
	call print_rect

				;rectangle 2

	mov di, STRING_LENGHT_POS
	mov bl, [di]
	inc bl			;scale x

	mov ax, 03DBh	;symb
	mov bh, 03h		;scale y

	push ax
	push bx

	xor ax, ax
	mov al, bl
	mov bl, 2h
	div bl

	mov ch, 40d 		;pos x
	sub ch, al

	mov cl, 0Bh		;pos y

	pop bx
	pop ax
	call print_rect


				;text

	mov si, STRING_START
	mov bx, STRING_LENGHT_POS
	xor cx, cx
	mov cl, byte ptr [bx]
	dec cx
	

	xor ax, ax
	mov al, cl
	mov bl, 2h
	div bl

	mov bh, 40d 		;pos x
	sub bh, al

	mov bl, 0Ch		;pos y

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

	add bx, 160d
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
	
	add cx, 160d

	push ax			;comparation
	push bx

	xor ax, ax
	add al, bh
	mov bx, 160d
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
	mov cx, 160d
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

	

end 	start