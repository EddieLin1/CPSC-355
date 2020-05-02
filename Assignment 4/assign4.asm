// CPSC 355 Assignment 4
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 - Kostas Liosis


p_int:		.string "Initial Pyramid Values:\n"	// string for initial printing
							
p_final:	.string "New Pyramid Values:\n"		// string for the final pyramid values

p_string:	.string	"Pyramid %s\nCentre = (%d, %d)\nBase Width = %d  Base Length = %d\nHeight = %d\nVolume = %d\n\n" // string for the base calculations

p_name1:	.string "Khafre"			// pyramid name for the base "Khafre"
	
p_name2:	.string "Cheops"			// pyramid name for the base "cheops"

fp .req	x29			// sets x29 as fp
lr .req	x30			// sets x30 as lr

define(p_x, w2)			// defines w2 as p_x
define(p_y, w3)			// defines w3 as p_y
define(p_base_width, w4)	// defines w4 as p_base_width
define(p_base_length, w5)	// defines w5 as p_base_length
define(p_height, w6)		// defines w6 as p_height
define(p_volume, w7)		// defines w7 as p_volume
define(temp_addr, x9)		// defines x9 as a temp_addr
define(temp_r, x10)		// defines x10 as temp_r
define(p_addr, x11)		// defines x11 as p_addr
define(temp_r2, x12)		// defines x12 as temp_r2
define(p_addr2, x13)		// defines x13 as p_addr2
define(expand_factor, w19)	// defines w19 as expand_factor
define(relocate_x, w20)		// defines w20 as relocate_x
define(relocate_y, w21)		// defines w21 as relocate_y

f_r = 16			// frame record size 

p_size = 24			// pyramid size 
p_k_offset = 16			// offset for khafre pyramid
p_c_offset = 40			// offset for cheops pyramid

p_x_offset = 0			// pyramid x coords offset
p_y_offset = 4			// pyramid y coords offset
p_base_width_offset = 8		// pyramid base width offset
p_base_length_offset = 12	// pyramid base length offset
p_height_offset = 16		// pyramid height offset
p_volume_offset = 20		// pyramid volume offset

p_size_alloc = -(p_size + f_r) & -16	// allocation size

.global main			// makes main visible to global linker
.balign 4			// ensures proper alignment

//----------- pyramid structure------------
new_pyramid:			
	stp	fp, lr, [sp, p_size_alloc]!	// allocates enough memory for pyramid
	mov 	fp, sp				// moves stack pointer to frame pointer
	
	add	temp_addr, fp, f_r				// creates a temp address for storing

	str	p_x, [temp_addr, p_x_offset]			// stores p_x in temp address
	str	p_y, [temp_addr, p_y_offset]			// stores p_y in temp address
	str	p_base_width, [temp_addr, p_base_width_offset]	// stores p_base_width in temp address
	str	p_base_length, [temp_addr, p_base_length_offset]// stores p_base_length in temp address
	str	p_height, [temp_addr, p_height_offset]		// stores p_height in temp address
	
	mul	p_volume, p_base_width, p_base_length		// multiplies width x length
	mul	p_volume, p_volume, p_height			// multimplies width x length x height
	mov	w10, 3						// moves 3 into w10
	sdiv	p_volume, p_volume, w10				// (width x length x height)/3

	str	p_volume, [temp_addr, p_volume_offset]		// stores volume in temp address
	
								// uses p_addr from main, sets which pyramid offset
	ldr	temp_r, [temp_addr, p_x_offset]			// loads p_x from temp address
	str	temp_r, [p_addr, p_x_offset]			// stores p_x into actual address
	ldr	temp_r, [temp_addr, p_y_offset]			// loads p_y from temp address
	str	temp_r, [p_addr, p_y_offset]			// stores p_y into actual address
	ldr	temp_r, [temp_addr, p_base_width_offset]	// loads p_base_width from temp address
	str	temp_r, [p_addr, p_base_width_offset]		// stores p_base width into actual address
	ldr	temp_r, [temp_addr, p_base_length_offset]	// loads p_base_length from temp address
	str	temp_r, [p_addr, p_base_length_offset]		// stores p_base_length into actual address
	ldr	temp_r, [temp_addr, p_height_offset]		// loads p_height from temp address
	str	temp_r, [p_addr, p_height_offset]		// stores p_height into actual address
	ldr	temp_r, [temp_addr, p_volume_offset]		// loads p_volume from temp address
	str	temp_r, [p_addr, p_volume_offset]		// stores p_volume into actual address

	ldp	fp, lr, [sp], -p_size_alloc			// deallocates frame record
	ret							// returns to linked address

//--------------Structure to print_pyramid----------------

print_pyramid:
	stp	fp, lr, [sp, -f_r]!				// allocates for structure
	mov	fp, sp						// moves sp to fp
	
	mov	p_addr,x0					// for base address, in main it will be offset + fp
	
	ldr	w0, =p_string					// sets base string argument
	ldr 	p_x, [p_addr, p_x_offset]			// loads p_x from address
	ldr	p_y, [p_addr, p_y_offset]			// loads p_y from address
	ldr	p_base_width, [p_addr, p_base_width_offset]	// loads p_base_width from address
	ldr	p_base_length, [p_addr, p_base_length_offset]	// loads p_base_length from address
	ldr	p_height, [p_addr, p_height_offset]		// loads p_height from address
	ldr	p_volume, [p_addr, p_volume_offset]		// loads p_volume from address
	
	bl	printf						// branches to printf

	ldp	fp, lr, [sp], f_r				// deallocates frame record
	ret							// returns to linked address

//--------------Check equality subroutine--------------
check_eq:	
	stp	fp, lr, [sp, -f_r]!				// allocates memory
	mov	fp, sp						// moves sp to fp
	
	mov	p_addr, x20					// moves first address from x20 into p_addr
	mov	p_addr2, x21					// moves second address from x21 to p_addr2

	ldr	temp_r, [p_addr, p_base_width_offset]		// loads width from first address
	ldr	temp_r2, [p_addr2, p_base_width_offset]		// loads width from second address
	cmp	temp_r, temp_r2					// compares, if equal branches
	b.eq	true_eq						// branch instruction 


	ldr	temp_r, [p_addr, p_base_length_offset]		// loads length from first address
	ldr	temp_r2, [p_addr2, p_base_length_offset]	// loads length from second address
	cmp	temp_r, temp_r2					// compares, if equal branches
	b.eq 	true_eq						// branch instruction

	ldr	temp_r, [p_addr, p_height_offset]		// loads height from first address
	ldr	temp_r2, [p_addr2, p_height_offset]		// loads height from second address
	cmp	temp_r,temp_r2					// compares, if equal branches
	b.eq	true_eq						// branch instruction
	

	b	done_eq						// branches to done_eq when done

true_eq:							// true checker
	mov	x19, 1						// moves 1 into x19, symbolizing true 
		
done_eq:							// done branch
	ldp	fp, lr, [sp], f_r				// deallocates
	ret							// returns to linked address

//----------------Expand subroutine-------------------------------
expand:	
	stp	x29, x30, [sp, -f_r]!				// allocates memory for subroutine
	mov	fp, sp						// moves sp to frame pointer

	mov	p_addr, temp_r					// moves temp_r to p_addr from main

	ldr	p_base_width, [p_addr, p_base_width_offset]	// loads width from p_addr
	mul	p_base_width, p_base_width, expand_factor	// multiplies by expand_factor
	str	p_base_width, [p_addr, p_base_width_offset]	// stores back into p_addr

	ldr	p_base_length,	[p_addr, p_base_length_offset]	// loads length from p_addr
	mul	p_base_length,	p_base_length, expand_factor	// multiplies by expand_factor
	str	p_base_length, 	[p_addr, p_base_length_offset]	// stores back into p_addr

	ldr	p_height, [p_addr, p_height_offset]		// loads height from p_addr
	mul	p_height, p_height, expand_factor		// multiplies by expand_factor
	str	p_height, [p_addr, p_height_offset]		// stores height back to p_addr

	mul	p_volume, p_base_width, p_base_length		// length * width
	mul	p_volume, p_volume, p_height			// height * length * width
	mov	w10, 3						// moves 3 to w10
	sdiv	p_volume, p_volume, w10				// (length * width * height)/3

	str	p_volume, [p_addr, p_volume_offset]		// stores volume to p_addr
	
	ldp	fp, lr, [sp], f_r				// deallocates
	ret							// returns to linked address

//----------------Relocate subroutine---------------------------
relocate:

	stp	fp, lr, [sp, -f_r]!			// allocates memory for subroutine
	mov	fp, sp					// moves sp to fp
	
	mov	p_addr, x0				// moves x0 to p_addr, x0 from main

	ldr	p_x, [p_addr, p_x_offset]		// loads the p_x coord values
	mov	p_x,  relocate_x			// relocates by relocation amount in relocate_x
	str	p_x, [p_addr, p_x_offset]		// stores back into p_addr address

	ldr	p_y, [p_addr, p_y_offset]		// loads the p_y coord values
	mov	p_y, relocate_y				// relocates by relocation amount in relocate_y
	str	p_y, [p_addr, p_y_offset]		// stores back into p_addr address

	ldp	fp, lr, [sp], f_r			// deallocates
	ret						// returns to linked address

//-------------Main-----------------------------------------------------
main:
	stp	x29, x30, [sp, -f_r]!			// allocates memory for main
	mov 	x29, sp					// moves sp to fp

	add	p_addr, fp, p_k_offset			// sets up address for khafre pyramid 
	mov	p_x, 0					// sets p_x value
	mov	p_y, 0					// sets p_y value
	mov	p_base_width, 10			// sets width value
	mov	p_base_length, 10			// sets length value
	mov	p_height, 9				// sets height value
	bl	new_pyramid				// branches to create pyramid khafre at address

	add	p_addr, fp, p_c_offset			// sets up addres for cheops pyramid
	mov	p_x, 0					// sets p_x value
	mov	p_y, 0					// sets p_y value
	mov	p_base_width, 15			// sets width value
	mov	p_base_length, 15			// sets length value
	mov	p_height, 18				// sets height value
	bl	new_pyramid				// branches to create pyramid cheops at address

	ldr	w0, =p_int				// loads the initial print statement
	bl	printf					// prints

	add	x0, fp, p_k_offset			// loads the pyramid khafre address
	ldr	w1, =p_name1				// adds khafre string to base argument in print_pyramid
	bl	print_pyramid				// branches to print pyramid

	add	x0, fp, p_c_offset			// loads the pyramid cheops address
	ldr	w1, =p_name2				// adds cheops string to base argument in print_pyramid
	bl	print_pyramid				// branches to print pyramid
	
		
	mov	x19, 0					// moves 0 to x19 as "false"
	add	x20, fp, p_k_offset			// moves address of pyramid khafre to x20
	add	x21, fp, p_c_offset			// moves address of pyramid cheops to x21
	bl	check_eq				// check equality branch
		
	cmp	x19,1					// compares if x19 is still false
	b.eq	exit					// if not false just exits

	mov	temp_r, x21				// moves the address of cheops into temp_R
	mov	expand_factor, 9			// adds 9 into expand_factor
	bl	expand					// branches to expand
	
	add	x0, fp, p_c_offset			// sets up address of cheops into x0
	mov	relocate_x, 27 				// relocation coords on x
	mov	relocate_y, -10				// relocation coords on y
	bl	relocate				// branch to relocate

	add	x0, fp, p_k_offset			// sets up address of khafre into x0
	mov	relocate_x, -23				// relcation coords on x
	mov	relocate_y, 17				// relocation coords on y
	bl	relocate				// branch to relocate

	ldr	w0, =p_final				// loads the new pyramid values string into w0
	bl	printf					// branch to printf to print

	add	x0, fp, p_k_offset			// loads address of pyramid khafre into x0
	ldr	w1, =p_name1				// loads string khafre into w1
	bl	print_pyramid				// branches to print_pyramid

	add	x0, fp, p_c_offset			// loads address of pyramid cheops into x0
	ldr	w1, =p_name2				// loads string cheops into w1
	bl	print_pyramid				// branches to print_pyramid

	b 	exit					// branch to exit
exit:
	ldp	x29, x30, [sp], f_r			// deallocation of stack frame
	ret						// returns control
