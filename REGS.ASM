.model tiny
.code

VRAMSEG EQU 0b800h

WIDTH EQU 80d

SYMB1 EQU 06DBh
SYMB2 EQU 03DBh

RECT_POS_X EQU 01h
RECT_POS_Y EQU 01h

RECT_SCALE_X EQU 7d
RECT_SCALE_Y EQU 11d

KEYBOARD_INTERRUPTION EQU 09h * 4
TIMER_INTERRUPTION EQU 08h * 4

LSHIFT_SCANCODE EQU 42d

KEYBOARD_SCANCODE_PORT EQU 60h
KEYBOARD_INFO_PORT EQU 61h

org 100h

;===============================================================================

start:
	push 0
	pop es

	mov bx, KEYBOARD_INTERRUPTION		;keyboard interruption

	mov dx, es:[bx]			
	mov old_inter, dx
	mov dx, es:[bx + 2]
	mov old_inter_seg, dx


	mov es:[bx], offset inter

	mov ax, cs
	mov es:[bx + 2], ax




	mov bx, TIMER_INTERRUPTION		;timer interruption

	mov dx, es:[bx]			
	mov old_timer, dx
	mov dx, es:[bx + 2]
	mov old_timer_seg, dx


	mov es:[bx], offset timer

	mov ax, cs
	mov es:[bx + 2], ax




	mov ax, 3100h		;resident mode
	mov dx, offset prog_end

	shr dx, 4
	inc dx
	int 21h

;===============================================================================






;===============================================================================
;	proc inter resolve keyboard interuption
;===============================================================================
inter proc
	push ax bx es

	in al, KEYBOARD_INFO_PORT
	or al, 80h
	out KEYBOARD_INFO_PORT, al
	and al, not 80h
	out KEYBOARD_INFO_PORT, al

	mov al, 20h
	out 20h, al

	in al, KEYBOARD_SCANCODE_PORT
cmp al, LSHIFT_SCANCODE
jne .skip
	call change
	

.skip:

	pushf
    call dword ptr cs:[old_inter]

	pop es bx ax
	iret

change:
	cmp open, 1
	je .set_zero
	jmp .set_one

.set_zero:
	mov open, 0

	mov ax, 0600h      ;set empty rect on plase of rect
	mov bh, 07h       
	mov cx, 0000h      
	mov dx, 184Fh      
	int 10h     

	jmp .end
.set_one:
	mov open, 1

.end:

ret

endp


;===============================================================================






;===============================================================================
;	proc timer resolve timer interuption
;===============================================================================
timer proc
	push ax bx cx dx es si di
	pushf

	cmp open, 1
	jne .skip_timer

	call print

.skip_timer:
	
    call dword ptr cs:[old_inter]

	pop di si es dx cx bx ax
	iret

endp

;===============================================================================




;===============================================================================
;	proc print prints rectangles with text
;===============================================================================
print proc
	push dx
	push cx
	push bx
	push ax


	push VRAMSEG		;move VRAM pos to es
	pop es	
	

				;rectangle 1

	mov bl, RECT_SCALE_X		;scale x
	mov bh, RECT_SCALE_Y		;scale y

	mov ax, SYMB1	;symb

	mov ch, RECT_POS_X		;pos x
	mov cl, RECT_POS_Y		;pos y


	call print_rect

				;rectangle 2

	mov bl, RECT_SCALE_X - 4d		;scale x
	mov bh, RECT_SCALE_Y - 2d		;scale y

	mov ax, SYMB2	;symb

	mov ch, RECT_POS_X + 2h		;pos x
	mov cl, RECT_POS_Y + 1h		;pos y

	call print_rect

				;register printing
	
	mov ch, RECT_POS_X + 3h


	mov cl, RECT_POS_Y + 2h
	pop ax
	call print_symbol

	mov cl, RECT_POS_Y + 4h
	pop ax
	call print_symbol

	mov cl, RECT_POS_Y + 6h
	pop ax
	call print_symbol

	mov cl, RECT_POS_Y + 8h
	pop ax
	call print_symbol


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
old_inter_seg	dw 'jj'
old_timer	dw 'ww'
old_timer_seg	dw 'ww'
open	db 0


;================================================================================
prog_end:
end 	start