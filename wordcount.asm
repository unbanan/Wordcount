SYS_EXIT: 	equ 	60
SYS_READ: 	equ 	0
SYS_WRITE: 	equ 	1
STDIN:		equ	0
STDOUT:		equ	1
STDERR:		equ	2

	section 	.text
	global 	_start


_start:
	xor 	r10, r10
	mov 	r12, 1
	;r12 show, if there was a whitespace before char to understand that it's a beginning of a word
	;at first we should put 1 in it because it's not true, that string begins with whitespaces
read_start:
	mov 	rax, SYS_READ
	mov 	rdi, STDIN
	mov 	rsi, buff
	mov 	rdx, buff_size
	syscall
	test 	rax, rax
	js 	read_error
	jz 	print_ans
	xor 	rbx, rbx

char_loop:
	mov	cl, byte[rsi + rbx]
	inc	rbx
	cmp	cl, 0x20
	je 	whitespace_symbol
	cmp	cl, 0x09
	jl 	char
	cmp	cl, 0x0d
	jg 	char
	; 9 - 13, 32 - whitespaces
	jmp 	whitespace_symbol

whitespace_symbol:
	mov	r12, 1
	cmp	rbx, rax
	je	read_start
	jmp	char_loop
char:
	add	r10, r12
	xor 	r12, r12
	cmp	rbx, rax
	je	read_start
	jmp 	char_loop

read_error:
	mov 	rax, SYS_WRITE
	mov 	rdi, STDERR
	mov 	rsi, error_msg
	mov 	rdx, error_msg_size
	syscall
	mov 	rax, SYS_EXIT
	mov 	rdi, 1
	syscall

print_ans:
	; r10 = ans
	mov 	rax, r10
	mov 	rbx, 10
	mov 	r8, rsp
	mov 	r9, r8
	sub 	rsp, 32
	dec	r8	
	mov	byte[r8], 0x0a	
	dec	r8

next_digit:
	xor 	rdx, rdx
	div 	rbx
	add 	dl, '0'
	mov 	[r8], dl
	dec	r8
	cmp 	rax, 0
	jne 	next_digit

	inc	r8
	sub 	r9, r8
	mov 	rax, SYS_WRITE
	mov 	rdi, STDOUT
	mov 	rsi, r8
	mov 	rdx, r9
	syscall

	mov 	rax, SYS_EXIT
	mov 	rdi, 0
	syscall

	section 	.bss
buff:	resb	 4096

buff_size:	equ 	 $ - buff
	section 	.rodata

error_msg: 	db 	"Read error ocured!",0x0a
error_msg_size:	equ  	$ - error_msg

