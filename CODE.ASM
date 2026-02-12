.model tiny
.code

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

	mov ax, 4c00h
	int 21h

	endp
;===============================================================================




;===============================================================================
;	proc print prints rectangles with text
;===============================================================================
print proc

	mov ax, 0b800h		;move VRAM pos to es
	mov es, ax	
	
				;rectangle 1
	mov di, 80h
	mov bl, [di]
	add bl, 5h	

	mov ax, 0ADBh	
	mov bh, 05h
	mov cx, 0A0Ah
	call print_rect

				;rectangle 2
	mov di, 80h
	mov bl, [di]
	inc bl

	mov ax,	33DBh		
	mov bh, 03h
	mov cx, 0C0Bh
	call print_rect


				;text

	mov si, 82h
	mov bx, 80h
	xor cx, cx
	mov cl, byte ptr [bx]
	dec cx
	mov bx, 0D0Ch
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
;====================================================================================
print_rect	proc
	push ax			;store symbol offset in di
	push bx
					
	xor ax, ax
	add al, cl

	mov bx, 160d
	mul bx

	add al, ch
	add al, ch

	mov di, ax
	
	pop bx
	pop ax




	mov bp, 0h		;bp = y shift

.cycle_y:			;y - cycle
	mov si, 0h		;si = x shift

.cycle_x:			;x - cycle
	push bx

	xor bx, bx
	add bx, di
	add bx, bp
	add bx, si

	mov es:[bx], ax

	pop bx

	add si, 2h		;iteration add

	push ax			;comparation

	xor ax, ax
	add al, bl
	add al, bl

	cmp ax, si

	pop ax
ja .cycle_x			;x cycle jump 
	
	add bp, 160d

	push ax			;comparation
	push bx

	xor ax, ax
	add al, bh
	mov bx, 160d
	mul bx

	cmp ax, bp

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
;===============================================================================
print_text 	proc
	
	xor di, di	;store symbol shift in di
	
	push bx
	push cx

	xor ax, ax
	xor cx, cx
	mov al, bl
	mov cx, 160d
	mul cx

	add al, bh
	add al, bh

	mov di, ax

	pop cx
	pop bx

.cycle:			;main cycle

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