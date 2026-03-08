.model tiny
.code

EXITCODE EQU 4c00h

org 100h

;===============================================================================

start:
		
		xor ax, ax
		mov bx, 80h
		mov al, [bx]
		dec al
		
		mov si, 82h
		mov di, offset password
    	call strncmp
		mov bx, 1
		cmp ax, bx
		jne .failure

		mov ah, 9 		 
		mov dx, offset success    
		int 21h    

    	jmp exit

.failure:
		mov ah, 9 		 
		mov dx, offset failure
		int 21h    

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





;====================================================================================
;proc strncmp
;enter		ax - lenght
;		si - first string start
;		di - second string start
;		
;return		ax - 1/0 yes/no
;detroy		
;====================================================================================
strncmp	proc
	push cx
	push bx
	push dx

	xor cx, cx
.cycle:
	
	mov bx, si
	add bx, cx
	mov dl, [bx]

	mov bx, di
	add bx, cx
	mov dh, [bx]

	cmp dh, dl
	je .skip

	mov ax, 0
	pop dx
	pop bx
	pop cx
	ret
.skip:
	inc cx
	cmp cx, ax
jne .cycle
	
	mov ax, 1
	pop dx
	pop bx
	pop cx
	ret
	
	
	endp
;===============================================================================






;================================================================================
.data
password db '3N!TY$'
success db 'success$'
failure db 'failure$'

end 	start