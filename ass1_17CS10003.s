	.file	"asgn1.c"											# original file name of .c file	
	.text														# section that contains program logic
	.section	.rodata											# ro stands for read only. i.e info here cannot be overwritten
	.align 8													# assigns next variable to a byte which is a multiple of 8
.LC0:															# label for the next string
	.string	"Enter the dimension of a square matrix: "			# prompt for user to enter dimensions of sq. matrix
.LC1:															# label for the next string
	.string	"%d"												
	.align 8													# assign next variable to a byte which is a multiple of 8
.LC2:															# label for next string
	.string	"Enter the first matix (row-major): "				# prompt for user to enter the first first matrix
	.align 8													# assign next variable to a byte which is a multiple of 8
.LC3:															# label for the next string
	.string	"Enter the second matix (row-major): "				# prompt for user to enter the first first matrix
.LC4:															# label for the next string
	.string	"\nThe result matrix:"								# prompt for user to enter the first first matrix
.LC5:															# label for the next string
	.string	"%d "												
	.text														
	.globl	main												# sets main as global so other files can access it
	.type	main, @function										
main:															# label main:
.LFB0:															# Local label, main in our .c file
	.cfi_startproc												
	pushq	%rbp				# push stack base pointer
	.cfi_def_cfa_offset 16										
	.cfi_offset 6, -16											
	movq	%rsp, %rbp			# rbp(base pointer) = rsp(stack pointer)
	.cfi_def_cfa_register 6												
	subq	$4832, %rsp			# allocate 4832 bytes of space on the stack
	movq	%fs:40, %rax								
	movq	%rax, -8(%rbp)										
	xorl	%eax, %eax			# eax= 0
	leaq	.LC0(%rip), %rdi	# rdi= address of string LC0
	movl	$0, %eax			# eax=0
	call	printf@PLT			# call print function
	leaq	-4828(%rbp), %rax	# rax= address of n
	movq	%rax, %rsi			# rsi= address of n
	leaq	.LC1(%rip), %rdi	# rdi= address of string LC1
	movl	$0, %eax			# eax=0
	call	__isoc99_scanf@PLT	# call scanf
	leaq	.LC2(%rip), %rdi	# rdi = adress of string LC2
	movl	$0, %eax			# eax=0
	call	printf@PLT			# call printf
	movl	-4828(%rbp), %eax	# eax= n
	leaq	-4816(%rbp), %rdx	# rdx = adress of matrix A
	movq	%rdx, %rsi			# rsi= adress of matrix A
	movl	%eax, %edi			# edi = n
	call	ReadMat 			# call Readmat function
	leaq	.LC3(%rip), %rdi	# rdi= address of string LC3
	movl	$0, %eax			# eax =0
	call	printf@PLT			# call printf
	movl	-4828(%rbp), %eax	# eax=n
	leaq	-3216(%rbp), %rdx	# rdx = address of string B
	movq	%rdx, %rsi			# rsi= address of string B
	movl	%eax, %edi			# edi=n
	call	ReadMat 			# call Readmat
	movl	-4828(%rbp), %eax	# eax = n
	leaq	-1616(%rbp), %rcx	# rcx = address of matrix C
	leaq	-3216(%rbp), %rdx	# rdx = address of matrix B
	leaq	-4816(%rbp), %rsi	# rax = address of matrix A
	movl	%eax, %edi			# edi = n
	call	MatMult 			# call Matrix multiplication
	leaq	.LC4(%rip), %rdi	# rdi = address of string LC4
	call	puts@PLT			# ...
	movl	$0, -4824(%rbp)		# i=0
	jmp	.L2 					# go to L2
.L5:
	movl	$0, -4820(%rbp)		# j=0
	jmp	.L3 					# jump to L3
.L4:
	movl	-4820(%rbp), %eax   # eax= j
	movslq	%eax, %rcx			# rcx = j
	movl	-4824(%rbp), %eax	# eax = i
	movslq	%eax, %rdx			# rdx = i
	movq	%rdx, %rax			# rax = i
	salq	$2, %rax			# rax= 4*i
	addq	%rdx, %rax			# rax = 4i + i
	salq	$2, %rax			# rax = 4*5i
	addq	%rcx, %rax			# rax = 20i + j
	movl	-1616(%rbp,%rax,4), %eax	# eax = address of matrix C + 80i + j
	movl	%eax, %esi			# esi = address of matrix C +80i + 4j
	leaq	.LC5(%rip), %rdi	# rdi = address of string LC5
	movl	$0, %eax			# eax =0
	call	printf@PLT			# printing A[i][j]
	addl	$1, -4820(%rbp)		# j++
.L3:
	movl	-4828(%rbp), %eax	# eax= n
	cmpl	%eax, -4820(%rbp)	# compare n and j
	jl	.L4 					# if j<n, jump to L4
	movl	$10, %edi			# edi = 10
	call	putchar@PLT			
	addl	$1, -4824(%rbp)		# i++
.L2:
	movl	-4828(%rbp), %eax	# eax = n 
	cmpl	%eax, -4824(%rbp)	# compare i with n
	jl	.L5 					# if i<n,jump to L5
	movl	$0, %eax			# eax=0
	movq	-8(%rbp), %rcx 		
	xorq	%fs:40, %rcx
	je	.L7 					# jump to .L7
	call	__stack_chk_fail@PLT
.L7:							
	leave						# clear local variables
	.cfi_def_cfa 7, 8
	ret 						# return to caller
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.globl	ReadMat 			# ReadMat is global , can be accessed by other programs
	.type	ReadMat, @function	# set ReadMat as global
ReadMat:
.LFB1:
	.cfi_startproc
	pushq	%rbp				# push base pointer to new loc
	.cfi_def_cfa_offset 16	
	.cfi_offset 6, -16
	movq	%rsp, %rbp			# base pointer= start pointer
	.cfi_def_cfa_register 6
	subq	$32, %rsp			# assign 32 bytes of space in stack
	movl	%edi, -20(%rbp)		# rbp -20 bytes = n 
	movq	%rsi, -32(%rbp)		# rbp- 32 bytes= adress of matrix data
	movl	$0, -8(%rbp)		# i =0
	jmp	.L9 					# jump to L9
.L12:
	movl	$0, -4(%rbp)		# j=0
	jmp	.L10					# jumpt to L10
.L11:
	movl	-8(%rbp), %eax 		#eax = i
	movslq	%eax, %rdx 			# rdx = i
	movq	%rdx, %rax 			# rax = i
	salq	$2, %rax 			# rax = 4i
	addq	%rdx, %rax 			# rax = 5i
	salq	$4, %rax 			# rax = 80i
	movq	%rax, %rdx 			# rdx = 80i
	movq	-32(%rbp), %rax 	# rax = address
	addq	%rax, %rdx  		#rdx = address + 80i 
	movl	-4(%rbp), %eax 		# eax = j
	cltq

	salq	$2, %rax  			# rax = 4j
	addq	%rdx, %rax 			# rax = address + 80i + 4j
	movq	%rax, %rsi 			# rsi = address + 80i + 4j
	leaq	.LC1(%rip), %rdi	# rdi = address of string LC1
	movl	$0, %eax			# eax=0
	call	__isoc99_scanf@PLT	# scan the number
	addl	$1, -4(%rbp)		# j++
.L10:
	movl	-4(%rbp), %eax		# eax = j
	cmpl	-20(%rbp), %eax		# compare j and n
	jl	.L11					# if j<n jump to L11
	addl	$1, -8(%rbp)		# i++
.L9:
	movl	-8(%rbp), %eax 		# eax = i
	cmpl	-20(%rbp), %eax		# compare i and n
	jl	.L12 					# if i<n, jump to L12
	nop							# No operation
	leave						# clear local variable
	.cfi_def_cfa 7, 8
	ret 						# return to caller
	.cfi_endproc
.LFE1:
	.size	ReadMat, .-ReadMat
	.section	.rodata
	.align 8
.LC6:
	.string	"\nThe transpose of the second matrix:"
	.text
	.globl	TransMat
	.type	TransMat, @function
TransMat:						# label for transpose
.LFB2:
	.cfi_startproc
	pushq	%rbp				# push base pointer
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp			# base pointer = stack pointer
	.cfi_def_cfa_register 6
	subq	$32, %rsp			# add 32 bytes of space to stack
	movl	%edi, -20(%rbp)		# rbp - 20 bytes = n
	movq	%rsi, -32(%rbp)		# rbp - 32 bytes = address of matrix data
	movl	$0, -12(%rbp)		# i=0
	jmp	.L14					# jump to .L14
.L17:
	movl	$0, -8(%rbp)		# j = 0
	jmp	.L15					# jump to .L15
.L16:
	movl	-12(%rbp), %eax		# eax = i
	movslq	%eax, %rdx			# rdx = i
	movq	%rdx, %rax			# rax = i
	salq	$2, %rax			# rax = 4i
	addq	%rdx, %rax			# rdx = 5i
	salq	$4, %rax			# rax = 80i
	movq	%rax, %rdx			# rdx = 80i
	movq	-32(%rbp), %rax		# rax = address of matrix data
	addq	%rax, %rdx			# rdx = data[i][0]
	movl	-8(%rbp), %eax		# eax = j
	cltq
	movl	(%rdx,%rax,4), %eax	# eax = data[i][j]
	movl	%eax, -4(%rbp)		# t = data[i][j]
	movl	-8(%rbp), %eax		# eax = j
	movslq	%eax, %rdx			# rdx = j
	movq	%rdx, %rax			# rax = j
	salq	$2, %rax			# rax = 4j
	addq	%rdx, %rax			# rax = 5j
	salq	$4, %rax			# rax = 80j
	movq	%rax, %rdx			# rdx = 80j
	movq	-32(%rbp), %rax		# rax = address of matrix data
	leaq	(%rdx,%rax), %rsi	# rsi = data[j][0]
	movl	-12(%rbp), %eax		# eax = i
	movslq	%eax, %rdx			# rdx = i
	movq	%rdx, %rax			# rax = i
	salq	$2, %rax			# rax = 4i
	addq	%rdx, %rax			# rax = 5i
	salq	$4, %rax			# rax =80i
	movq	%rax, %rdx			# rdx = 80i
	movq	-32(%rbp), %rax		# rax = address of matrix data
	leaq	(%rdx,%rax), %rcx	# rcx = data[i][0]
	movl	-12(%rbp), %eax		# eax = i
	cltq
	movl	(%rsi,%rax,4), %edx	# edx = data[j][i]
	movl	-8(%rbp), %eax		# eax = j
	cltq
	movl	%edx, (%rcx,%rax,4)	# data[i][j]= data[j][i]
	movl	-8(%rbp), %eax		# eax = j
	movslq	%eax, %rdx			# rdx = j
	movq	%rdx, %rax			# rax = j
	salq	$2, %rax			# rax = 4j
	addq	%rdx, %rax			# rax = 5j
	salq	$4, %rax			# rax = 80j
	movq	%rax, %rdx			# rdx = 80j
	movq	-32(%rbp), %rax		# rax = address of matrix data
	leaq	(%rdx,%rax), %rcx	# rcx = data[j][0]
	movl	-12(%rbp), %eax		# eax = i
	cltq
	movl	-4(%rbp), %edx		# edx = t
	movl	%edx, (%rcx,%rax,4)	# data[i][j] = t
	addl	$1, -8(%rbp)		# i ++
.L15:
	movl	-8(%rbp), %eax		# eax = j
	cmpl	-12(%rbp), %eax		# compare j with I
	jl	.L16					# if j<i, Jump to .L16
	addl	$1, -12(%rbp)		# i++
.L14:
	movl	-12(%rbp), %eax		# eax = i
	cmpl	-20(%rbp), %eax		# compare i to n
	jl	.L17					# if i<n, jump to .L17
	leaq	.LC6(%rip), %rdi	# rdi = address of string .LC6
	call	puts@PLT			# Print the string
	movl	$0, -12(%rbp)		# i = 0
	jmp	.L18					# jump to .L18
.L21:
	movl	$0, -8(%rbp)		# j = 0
	jmp	.L19					# jump to label 19
.L20:
	movl	-12(%rbp), %eax		# eax = i
	movslq	%eax, %rdx			# rdx =i
	movq	%rdx, %rax			# rax = i
	salq	$2, %rax			# rax = 4i
	addq	%rdx, %rax			# rax = 5i
	salq	$4, %rax			# rax = 80i
	movq	%rax, %rdx			# rdx = 80i
	movq	-32(%rbp), %rax		# rax = address of matrix data
	addq	%rax, %rdx			# rdx = data[i]
	movl	-8(%rbp), %eax		# eax = j
	cltq
	movl	(%rdx,%rax,4), %eax	# eax = data[i][j]
	movl	%eax, %esi			# esi = data[i][j]
	leaq	.LC5(%rip), %rdi	# edi = address of string .LC5
	movl	$0, %eax			# eax = 0
	call	printf@PLT			# call printf
	addl	$1, -8(%rbp)		# j++
.L19:
	movl	-8(%rbp), %eax		# eax = j
	cmpl	-20(%rbp), %eax		# compare j with n
	jl	.L20					# if j<n, jump to .L20
	movl	$10, %edi			# edi = 10
	call	putchar@PLT			# print \n
	addl	$1, -12(%rbp)		# i++
.L18:
	movl	-12(%rbp), %eax		# eax = i
	cmpl	-20(%rbp), %eax		# compare i with n
	jl	.L21 					# if i<n,jump to label 21
	nop							# no operation
	leave						# empty local variables 
	.cfi_def_cfa 7, 8
	ret 						# return to caller
	.cfi_endproc
.LFE2:
	.size	TransMat, .-TransMat
	.globl	VectMult
	.type	VectMult, @function
VectMult:						# label for vect multiplication
.LFB3:
	.cfi_startproc
	pushq	%rbp				# push base pointer
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp			# base pointer= stack pointer
	.cfi_def_cfa_register 6
	movl	%edi, -20(%rbp)		# rbp - 20 bytes= n
	movq	%rsi, -32(%rbp)		# rbp- 32 bytes = address of matrix firstMat
	movq	%rdx, -40(%rbp)		# rbp- 40 bytes = address of matrix secondMat
	movl	$0, -4(%rbp)		# result = 0
	movl	$0, -8(%rbp)		# i = 0
	jmp	.L23
.L24:
	movl	-8(%rbp), %eax		# eax = i
	cltq
	leaq	0(,%rax,4), %rdx	# rdx = 4i
	movq	-32(%rbp), %rax		# rax = address of firstMat
	addq	%rdx, %rax			# rax = address of firstMat + 4i
	movl	(%rax), %edx		# edx = firstMat[i]
	movl	-8(%rbp), %eax		# eax = i
	cltq
	leaq	0(,%rax,4), %rcx	# rcx = 4i
	movq	-40(%rbp), %rax		# rax = address of secondMat
	addq	%rcx, %rax			# rax = address of secondMat +4i
	movl	(%rax), %eax		# eax = secondMat[i]
	imull	%edx, %eax			# eax = firstMat[i]*secondMat[i]
	addl	%eax, -4(%rbp)		# result += firstMat[i]*secondMat[i] 
	addl	$1, -8(%rbp)		# i++
.L23:
	movl	-8(%rbp), %eax		# eax = i
	cmpl	-20(%rbp), %eax		# compare i and n
	jl	.L24					# if i<n, jump to L24
	movl	-4(%rbp), %eax		# eax = result 
	popq	%rbp				# pop base
	.cfi_def_cfa 7, 8
	ret 						# return to caller
	.cfi_endproc
.LFE3:
	.size	VectMult, .-VectMult
	.globl	MatMult 			# Matmult can be used by other programs
	.type	MatMult, @function	# Matmult is a function
MatMult:						# label for MatMult
.LFB4:
	.cfi_startproc
	pushq	%rbp				# push base pointer
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp			# base pointer = stack pointer
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$56, %rsp			# add 56 bytes of space to stack
	.cfi_offset 3, -24
	movl	%edi, -36(%rbp)		# rbp - 36 bytes = n
	movq	%rsi, -48(%rbp)		# rbp - 48 bytes = address of firstMat
	movq	%rdx, -56(%rbp)		# rbp - 56 bytes = address of secondMat
	movq	%rcx, -64(%rbp)		# rbp - 64 bytes = address of M
	movq	-56(%rbp), %rdx		# rdx = address of secondMat
	movl	-36(%rbp), %eax		# eax = n
	movq	%rdx, %rsi			# rsi = address of secondMat
	movl	%eax, %edi			# edi = n
	call	TransMat 			# call Transmat
	movl	$0, -24(%rbp)		# i =0
	jmp	.L27					# jump to  .L27
.L30:
	movl	$0, -20(%rbp)		# j = 0
	jmp	.L28					# jump to .L28
.L29:
	movl	-20(%rbp), %eax		# eax = j
	movslq	%eax, %rdx			# rdx = j
	movq	%rdx, %rax			# rax = j
	salq	$2, %rax			# rax = 4j
	addq	%rdx, %rax			# rax = 4j + j
	salq	$4, %rax			# rax = 16*5j
	movq	%rax, %rdx			# rdx = 80j
	movq	-56(%rbp), %rax		# rax = adsress of secondMat
	addq	%rdx, %rax			# rax = secondMat[j][0]
	movq	%rax, %rsi			# rsi = secondMat[j][0]
	movl	-24(%rbp), %eax		# eax = i
	movslq	%eax, %rdx			# rdx = i
	movq	%rdx, %rax			# rax = i
	salq	$2, %rax			# rax = 4i
	addq	%rdx, %rax			# rax = 4i + i
	salq	$4, %rax			# rax = 16*5i
	movq	%rax, %rdx			# rdx = 80i
	movq	-48(%rbp), %rax		# rax = address of firstMat
	addq	%rdx, %rax			# rax = firstMat[i][0]
	movq	%rax, %rcx			# rcx = firstMat[i][0]
	movl	-24(%rbp), %eax		# eax = i
	movslq	%eax, %rdx			# rdx = i
	movq	%rdx, %rax			# rax =i
	salq	$2, %rax			# rax = 4i
	addq	%rdx, %rax			# rax = 4i + i
	salq	$4, %rax			# rax = 16 * 5i
	movq	%rax, %rdx			# rdx = 80i
	movq	-64(%rbp), %rax		# rax = address of matrix M
	leaq	(%rdx,%rax), %rbx
	movl	-36(%rbp), %eax		# eax = n
	movq	%rsi, %rdx			# rdx = secondMat[j][0]
	movq	%rcx, %rsi			# rsi = firstMat[i][0]
	movl	%eax, %edi			# edi = n
	call	VectMult 			# call VectMult
	movl	%eax, %edx			# edx = result of VectMult
	movl	-20(%rbp), %eax		# eax = j
	cltq
	movl	%edx, (%rbx,%rax,4)	# M[i][j] =  result of VectMult
	addl	$1, -20(%rbp)		# j++
.L28:
	movl	-20(%rbp), %eax		# eax = j
	cmpl	-36(%rbp), %eax		# compare j and n
	jl	.L29					# if j<n, jump to .L29
	addl	$1, -24(%rbp)		# i++
.L27:
	movl	-24(%rbp), %eax		# eax = i
	cmpl	-36(%rbp), %eax		# compare i and n
	jl	.L30					# if i< n , jump to .L30
	nop							# no operation
	addq	$56, %rsp
	popq	%rbx				
	popq	%rbp				# pop base pointer
	.cfi_def_cfa 7, 8
	ret 						# return to caller
	.cfi_endproc
.LFE4:
	.size	MatMult, .-MatMult
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
