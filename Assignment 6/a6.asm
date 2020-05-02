// CPSC 355 - Assignment 6
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 -  Kostas Liosis

.data				// .data section
lim:	.double	0r1.0e-13	// limit = 1.0e-13
zero:	.double	0r0		// zero

.text				// .text section


print_fmt:	.string "%.2f                  %.10f\n"						//print of x and arctan
print_o:	.string	"Opening file : %s \n"							//print opening command
print_er:	.string	"Error. Number of arguments is incorrect. Usage: ./a6 <filename>"	// error improper usage
print_er2:	.string	"Error opening file. \n"						//error with opening file 
print_end:	.string	"End of file \n"							//end of file text
print_head:	.string	"x value               arctan(x)\n"					//the heading

.balign 4			//ensures proper alignment

define(argc_r, w19)		// argc_r as w19
define(argv_r, x20)		// argv_r as x20
define(fd_r, w21)		// fd_r as w21
define(buf_base_r, x22)		// buf_base_r as x22
define(read_r, x23)		// read_r as x23
define(i_r, w23)		// i_r as w23

buf_size = 8			// buf_size as 8
alloc = -(16 + buf_size) & -16	// memory amount to allocate
dealloc = -alloc		// sets up deallocation
buf_s = 16			// location of buffer

.global main			// makes main visible

main:
	stp	x29, x30, [sp, alloc]!	// allocating memory
	mov	x29, sp			// moves sp into fp	

	mov	argv_r, x1		// moving x1 into argv_r
	mov	argc_r, w0		// moving w0 into argc_r

	mov	i_r, 2			// moves 2 into i_r
	cmp	argc_r, i_r		// if the number of arguments = 2 
	b.eq	good			// then branch

	adrp	x0, print_er		// address of printing error
	add	x0, x0, :lo12:print_er	// adding low order bits
	bl	printf			// call to print f
	b	done			// branches to done

good:
	adrp	x0, print_o		// address of print open
	add	x0, x0, :lo12:print_o	// address of print open
	ldr	x1, [argv_r, 8]		// load input into x1
	bl	printf			//call to printf

	mov	w0, -100		// 1st argument, reads into input file)
	ldr	x1, [argv_r, 8]		// places the input into x1
	mov	w2, 0			// 3rd argument (read- only)
	mov	x8, 56			// i/o request
	svc 	0			// call system function
	mov	fd_r, w0		// move w0 into fd_R

//check error
	cmp	fd_r, 0			// if the file descriptor >= 0
	b.ge	opened			// branch to opened
	
	adrp	x0, print_er2		// address of error 2
	add	x0, x0, :lo12:print_er2	// address
	bl	printf			// branches to printf
	b	done			// branches to done

opened:					
	add	buf_base_r, x29, buf_s	// set memory base of buffer
				
	adrp	x0, print_head		// address of headings
	add	x0, x0, :lo12:print_head// address of headings
	bl	printf			// branches to printf

read:
	mov	w0, fd_r		// moves fd_r into w0
	mov	x1, buf_base_r		// 2nd argument (buffer)
	mov	w2, buf_size		// 3rd argument( buffersize)
	mov	x8, 63			// reads I/O request
	svc	0			// call system function	
	mov	read_r, x0		// move x0 into nread_r

	cmp	read_r, buf_size	// if read is not 8 bytes
	b.ne	close			// branches to close

	ldr	d0, [buf_base_r]	// loads input
	
	bl	arctan			// branches to arctan

	fmov	d1, d0			// moves d0 into d1
	adrp	x0, print_fmt		// address of print fmt
	add	x0, x0, :lo12: print_fmt// address
	bl	printf			// branches to printf

	b	read			// branches to read

close:
	adrp	x0, print_end		// address of close string fmt
	add	x0, x0, :lo12:print_end	// address
	bl 	printf			// branches to printf

	mov	w0, fd_r		// file descriptor as arg
	mov	x8, 57			// close I/O request
	svc	0			// call system function

done:
	ldp	x29, x30, [sp], dealloc	// deallocates memory
	ret				// returns control to calling code

arctan:
	stp	x29, x30, [sp, -16]!	// allocating memory
	mov	x29, sp			// moves sp to fp
	
	mov	w11, 1			// moves 1 into w11 as counter
	fmov	d9, d0			// x

	adrp	x10, lim		// loads address pointer for limit
	add	x10, x10, :lo12:lim
	ldr	d10, [x10]

	adrp	x15, zero		// loads address pointer for zero
	add	x15, x15, :lo12:zero
	ldr	d15, [x15]

arc_loop:
	cmp	w11, 1			// compares if it is the first iteration
	b.gt	arc_next		// branches to arc_next
	
	fmov	d13, d9			// moves x into d13
	b	arc_sum			// branches to arc_sum
	
arc_next:
	fmov	d14, 1.0		// sets 1.0 to d14
	fmov	d16, 2.0		// sets 2.0 to d16

	fmul	d13, d13, d9		// x^2
	fmul	d13, d13, d9		// x^3

	fdiv	d13, d13, d12		// divide by n

	fneg	d13, d13		// negate the term

arc_sum:
	fadd	d15, d15, d13		// add iteration to the current sum
	add	w11, w11, 1		// increase ocunter by 1

	fmov	d1, 2.0			// set d1 as 2.0
	fadd	d12, d12, d1		// adds 2.0 to n

	adrp	x14, lim		// limit address
	add	x14, x14, :lo12:lim	
	ldr	d14, [x14]		// loads the limit pointer

	fcmp	d13, d14		// compares the iteration to 0
	b.gt	arctan_check		// if it is greater then it loops to check

	fneg	d13, d13		// negates amd compares 
	fcmp	d13, d10		// branches to compare
	fneg	d13, d13		// restores original
	
	b.gt	arc_loop		// if it is greater than it branches to arcloop
	b	arctan_done		// branches to done otherwise

arctan_check:
	fcmp	d13, d10		// compares to conversion limit
	b.gt	arc_loop		// if it is greater than limit it loops back

arctan_done:
	fmov	d0, d15			// moves the sum into d0
	ldp	x29, x30, [sp], 16	// deallocate memory from stack
	ret				// return to caller



