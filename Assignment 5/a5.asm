// CPSC 355 Assignment 5
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 - kostas Liosis

MAXVAL = 100		//setting up constants
MAXOP = 20		//varibles = num
NUMBER = 0
TOOBIG = 9
BUFSIZE = 100

.data					//data section
val_m:		.skip	4*MAXVAL	//skip to intialize
buf_m:		.skip	1*BUFSIZE
sp_m:		.word	4		//word as variable
bufp_m:		.word	4



.text			//text section
	
.global		val_m		//.global values
.global		buf_m		//making these values visible new sp			
.global		bufp_m		//val, burf, burfp
.global		sp_m

.global 	push		//making functions visible
.global 	pop		
.global		clear
.global	 	getop
.global		getch		
.global		ungetch


p_push:		.string		"error: stack full\n"		//print formats
p_pop:		.string		"error: stack empty\n"
p_ungetch:	.string		"ungetch: too many characters\n"	


.balign 4				//making sure everything is properly alighed


push:					// push function
	stp	x29, x30, [sp, -32]!	// allocates 32 bytes to amke sure
	mov	x29, sp			// moves sp to fp

	mov	w9, w0			// sp = 0
	
	adrp	x11, sp_m		// address of sp
	add	x11, x11, :lo12:sp_m
	ldr	w13, [x11]		// loads sp

	cmp	w13, MAXVAL		//compares (sp<MAXVAL
	b.ge	push_else		// branches if greater

	adrp	x12, val_m		//address of val
	add	x12, x12, :lo12:val_m
	str	w9, [x12, w13, SXTW 2]	//stores sp in at w13 pointer
	ldr	w0, [x12, w13, SXTW 2]	// val[sp++] = f

	add	w13, w13, 1		// sp++
	str	w13, [x11]		// stores sp++

	b	push_fin		//branch to finish

push_else:				//else
	adrp	x0, p_push		//loads print format
	add	x0, x0, :lo12:p_push	
	bl	printf			// printf("error: stack full")
		
	bl	clear			// clear()
	mov	w0, 0			// return 0

push_fin:				//finish branch
	ldp	x29, x30, [sp], 32	//deallocates memory
	ret				// returns control to calling code

pop:					// pop function
	stp	x29, x30, [sp, -16]	// allocates 16 bytes to fp
	mov	x29, sp			// move sp to fp	

	adrp	x11, sp_m		//address of sp
	add	x11, x11, :lo12:sp_m	// address of sp
	ldr	w13, [x11]		// load sp

	cmp	w13, 0			// compares sp
	b.le	pop_else		// if sp<= 0 branch to else

	adrp	x10, val_m		// address of val
	add	x10, x10, :lo12:val_m	// loads address of va

	sub	w13, w13, 1		//sp--
	str	w0,[x10,w13, SXTW 2]	// return val[sp]
	str	w13, [x11]		// stores new sp
	
	b	 pop_fin		// branches to fin

pop_else:				// pop else function
	adrp	x11, p_pop		// loads pop print fmt
	add	x11, x11, :lo12:p_pop

	bl 	printf			// branch to print
	bl	clear			// branch to clear
	mov	w0, 0	

pop_fin:				// finish function
	ldp	x29, x30, [sp], 16	//deallocates memory
	ret				// returns control to calling code

clear:					// clear function
	stp	x29, x30, [sp, -16]!	// allocates 16 bytes of memory to fp
	mov	x29, sp			// move sp to fp

	adrp	x9, sp_m		// address of sp_m
	add	x9, x9, :lo12:sp_m
	ldr	w9, [x9]		// loads sp

	mov	w9, 0			// sp = 0
	str	w9, [x9]		// stores new value of sp

	ldp	x29, x30, [sp], 16	// deallocates memory
	ret				// returns control to calling code

getop:					// get top function
	stp	x29, x30, [sp, -48]!	// deallocating memory
	mov 	x29, sp			// moves sp to fp
	
	i_size = 4			// size of i
	j_size = 4			// size of j
	sp_m_size = 8			// size of sp_m
	lim_size = 4			// size of lim

	i_adr = 16			// base addresses of i
	j_adr = 20			// base address of j
	limit_size = 32			// base address of limit
	sp_m_adr = 24			// base address of sp_m

	alloc = -(16 + j_size + i_size + sp_m_size + lim_size) & -16	// allocates the memory
	dealloc = -alloc		// dealloc
		
	stp	x29, x30, [sp, alloc]!	//allocating memory to fp
	mov	x29, sp			// moving sp to fp

	add	x9, x29, i_size		// setting up temp registers
	add	x10, x29, j_size	// with sizes + frame pointer
	add	x11, x29, sp_m_size
	add	x12, x29, lim_size

	mov	x13, x0			// moves x0 into x13
	str	x13, [x11]		// stores x13 

	mov	w12, w1			// moves w1 into w12
	str	w12, [x12]		// stores w12

getop_loop:
	bl	getch			// branches to getch
	mov	w14, w0			// moves w0 into w14
	str	w14, [x10]		// stores value

	cmp	w14, ' '		// compare c to ' '
	b.eq	getop_loop		// if equal, branch to loop

	cmp	w14, '\t'		// compare c to '\t'
	b.eq	getop_loop		// if equal branch to loop

	cmp	w14, '\n'		// compare c to '\n'
	b.eq	getop_loop		// if equal branch

	cmp	w14, 0			// if c < '0'
	b.lt	getop_n			// branch to getop_n

	cmp	w14, 9			// if c > '9'
	b.gt	getop_n			// branch to getop_n

	b 	getop_loop2		// branches to getop_loop2

getop_n:				//getop_next 
	add	x11, x29, sp_m_adr	// loads base address of sp_m into x11
	ldr	x13, [x11]		// loads address into x13
	str	w11, [x13]		// stores j into w11
	
	add	x9, x29, i_size		//moves address of i into x9
	mov	w10, 1			// movs 1 into w10
	str	w10, [x9]		// stores w10 into x9

getop_loop2:				//getop loop
	bl	getchar			// branch to getchar
	mov	w9, w0			// moves w0 into w9
	add	x10, x29, j_size	// makes x10 into j_Size
	str	w13, [x10]		// stores x10 into w13

	cmp	w13,9			// compares w13 to 9


getop_end:				// gettop end
	ldp	x29, x30, [sp], dealloc	// deallocates memory
	ret				// returns control to calling code

getch:					//getch function
	stp	x29, x30, [sp, -16]!	// allocates memory 16 bytes
	mov	x29, sp			// moves sp to fp

	adrp	x9, bufp_m		// loads address of burp_m
	add	x9, x9, :lo12:bufp_m	// loads address of burp_m
	ldr	w11, [x9]		// load burp

	adrp	x10, buf_m		// address of buf_m
	add	x10, x10, :lo12:buf_m	//adress of bur_m

	cmp	w11, 0			// compares bufp to 0
	b.le	getch_next		// if bufp <= 0 branch to done

	sub	w11, w11,1		// --bufp
	ldr	w0, [x10, w11, SXTW 2]	// loads into w0

	b	getch_done		// branches to getch done

getch_next:				// getch next branches to getchar
	bl	getchar

getch_done:				// getch done 
	ldp	x29, x30, [sp], 16	// deallocates memory
	ret				// returns to calling code

ungetch:				//ungetch
	stp	x29, x30, [sp, -16]!	// allocates memory
	mov	x29, sp			// moves sp to fp

	adrp	x9, bufp_m		// loads address of bufp_m
	add	x9, x9, :lo12:bufp_m	// loads address of bufp_m
	ldr	w10, [x9]		// loads bufp_m

	cmp	w10, BUFSIZE		// compares bufp and BUFSIZE
	b.le	ungetch_n		// if bufp <= BUFSIZE branch

	adrp	x11, p_ungetch			//address of print fmt
	add	x11, x11, :lo12: p_ungetch		
	bl 	printf				// prints

	b	ungetch_done		// branhces to ungetchdone

ungetch_n:				// ungetch_next function
	adrp	x12, buf_m		// loads address
	add	x12, x12, :lo12:buf_m	
	
	str	w0, [x12, w10, SXTW 2]	// stores value into w0
	
	add	w10, w10, 1		// bufp++
	str	w10, [x9]		// store value of bufp

ungetch_done:
	ldp	x29, x30, [sp], 16	// deallocates memory
	ret				// returns to calling code



