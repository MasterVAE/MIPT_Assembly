.model tiny
.code

VRAMSEG EQU 0b800h
EXITCODE EQU 4c00h

WIDTH EQU 80d

SYMB1 EQU 06DBh
SYMB2 EQU 03DBh

RECT_POS_X EQU 01h
RECT_POS_Y EQU 01h

org 100h

;===============================================================================

start:
		push 0
		pop es

		mov bx, 09h * 4

		mov dx, es:[bx]			;saving old interuptor
		mov old_inter, dx
		mov dx, es:[bx + 2]
		mov old_inter_seg, dx


		mov es:[bx], offset inter

		mov ax, cs
		mov es:[bx + 2], ax

		mov ax, 3100h
		mov dx, offset prog_end

		shr dx, 4
		inc dx
		int 21h

;===============================================================================



;===============================================================================
;	proc restore restores old interuption commander
;===============================================================================
restore proc
		push es
		push bx
		push ax

		push 0
		pop es

		mov bx, 09h * 4

		mov ax, old_inter
		mov es:[bx], ax
		mov ax, old_inter_seg
		mov es:[bx + 2], ax

		pop ax
		pop bx
		pop es

		ret
endp
;===============================================================================







;===============================================================================
;	proc inter resolve keyboard interuption
;===============================================================================
inter proc
	push ax bx es

	push 0b800h
	pop es

	mov bx, (5*80d + 40d) * 2
	mov ah, 4eh

	in al, 61h
	or al, 80h
	out 61h, al
	and al, not 80h
	out 61h, al

	mov al, 20h
	out 20h, al

	in al, 60h
	mov es:[bx], ax

cmp al, 1h
jne .skip
	call print
	call restore



.skip:
	pop es bx ax
	iret

	endp

;===============================================================================




;===============================================================================
;	proc print prints rectangles with text
;===============================================================================
print proc

	mov ax, VRAMSEG		;move VRAM pos to es
	mov es, ax	
	

				;rectangle 1

	mov bl, 5d		;scale x
	mov bh, 10d		;scale y

	mov ax, SYMB1	;symb

	mov ch, RECT_POS_X		;pos x
	mov cl, RECT_POS_Y		;pos y


	call print_rect

				;rectangle 2

	mov bl, 5d - 2d		;scale x
	mov bh, 10d - 2d		;scale y

	mov ax, SYMB2	;symb

	mov ch, RECT_POS_X + 1h		;pos x
	mov cl, RECT_POS_Y + 1h		;pos y

	call print_rect


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
;destroy
;====================================================================================
print_rect	proc
	push si
	push cx
	push ax			
	push bx
					
	xor ax, ax		;store symbol offset in di
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

	pop cx
	pop si

	ret 
	
	endp
;===============================================================================



;====================================================================================
;proc print_symbol
;enter		al - char
;		ah - color argument
;		cl - pos_y
;		ch - pos_x
;destroy
;====================================================================================
print_symbol	proc
	push dx
	push bx
	push ax			
					
	xor ax, ax
	xor bx, bx
	add al, cl

	add bx, WIDTH * 2
	mul bx

	xor dx, dx
	add dl, ch
	add ax, dx
	add ax, dx

	mov bx, ax

	pop ax

	mov es:[bx], ax 

	pop bx
	pop dx

	ret
	endp

	
;===============================================================================


;================================================================================
.data
old_inter	dw 'jj'
old_inter_seg	dw 'ww'
open	db 0


;================================================================================
prog_end:
end 	start
