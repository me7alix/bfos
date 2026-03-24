bits 16
org 0x7c00

%define INST_LEN (1 << 14)
%define MEM_LEN  (1 << 14)

; SI is the instruction pointer
; DI is the memory pointer

section .bss
	inst resb INST_LEN
	mem  resb MEM_LEN

section .text
start:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov si, ax
    mov di, ax

	; zero mem
	xor ax, ax
	mov es, ax
	mov di, mem
	mov cx, MEM_LEN
	rep stosb

	; clear screen
	mov ah, 0x00
	mov al, 0x03
	int 0x10

; Reading {
.lread:
	; read char
	mov ah, 0x00
	int 0x16

	; print char
	mov ah, 0x0E
	int 0x10

	; handle backspace
	cmp al, 8
	jne .sbackspace
	
	cmp si, 0
	je .lread

	dec si

	mov al, 32
	mov ah, 0x0E
	int 0x10

	mov ah, 0Eh
	mov al, 08h
	mov bh, 0
	int 0x10

	jmp .lread
.sbackspace:

	; write to inst
	mov [inst+si], al
	inc si

	; break if ENTER
	cmp al, 13
	jne .lread
; Reading }

	; clear screen
	mov ah, 0x00
	mov al, 0x03
	int 0x10	

; Interpreting {
	xor si, si
.lit:
	mov al, [inst+si]

	cmp al, '>'
	jne .snext
	inc di	
	jmp .pit
.snext:

	cmp al, '<'
	jne .sprev
	dec di	
	jmp .pit
.sprev:

	cmp al, '+'
	jne .splus
	inc [mem+di]
	jmp .pit
.splus:

	cmp al, '-'
	jne .smin
	dec [mem+di]
	jmp .pit
.smin:

	cmp al, '.'
	jne .sdot

	mov al, [mem+di]
	mov ah, 0x0E

	cmp al, 10
	jne .sdot_cr
	mov al, 13
	int 0x10
	mov al, 10
.sdot_cr:

	int 0x10
	jmp .pit
.sdot:

	cmp al, ','
	jne .scom
	mov ah, 0x00
	int 0x16
	mov [mem+di], al
	jmp .pit
.scom:

; OBRA {
	cmp al, '['
	jne .sob

	mov al, [mem+di]
	cmp al, 0
	jne .pit

	; CX = bra_cnt
	mov cx, 1
.lob:
	inc si
	mov al, [inst+si]

	cmp al, '['
	jne .lob_sob
	inc cx
.lob_sob:

	cmp al, ']'
	jne .lob_scb
	dec cx

	cmp cx, 0
	jne .lob_scb
	jmp .pit
.lob_scb:

	jmp .lob	
.sob:
; OBRA }

; CBRA {
	cmp al, ']'
	jne .scb

	mov al, [mem+di]
	cmp al, 0
	je .pit

	; CX = bra_cnt
	mov cx, 1
.lcb:
	dec si
	mov al, [inst+si]

	cmp al, ']'
	jne .lcb_scb
	inc cx
.lcb_scb:

	cmp al, '['
	jne .lcb_sob
	dec cx

	cmp cx, 0
	jne .lcb_sob
	; dec si
	jmp .pit
.lcb_sob:
	
	jmp .lcb
.scb:
; CBRA }

	cmp al, 13
	je .eit

.pit:
	inc si
	jmp .lit
.eit:
; Interpreting }

.lwait:
	mov ah, 0x00
	int 0x16
	cmp al, 13
	jne .lwait
	jmp start

times 510 - ($ - $$) db 0
dw 0xaa55
