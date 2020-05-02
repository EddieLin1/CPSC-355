// CPSC Assignment 1 - B
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 - Kostas Liosis


// defined macros

define(i, x18)	// defined register x18 as i
define(a, x19)	// defined register x19 as a
define(B, x20)	// defubed reguster x20 as B as it gets confused with branch
define(c, x21)	// defined register x21 as c
define(d, x22)	// defined register x22 as d
define(e, x23)	// defined register x23 as e
define(f, x24)	// defined register x24 as f
define(g, x25)	// defined register x25 as g
define(h, x26)	// defined register x26 as h
define(current_min_counter, x27)	// defined register x27 as i
define(x_counter, x28)	// defined register x28 as counter
define(x_value, x1)	// defined register x1 as x_value
define(y_value, x2)	// defined register x2 as y_value
define(display_min, x3)		// defined register x3 as display_min



words:	//string format
	.string "Current x value: %ld\nCurrent y value: %ld\nCurrent Minimum: %ld\n\n"	// string for the format
	.balign 4	// ensures proper alignment of instructions
	.global main	// makes the main label visible to the linker

main:	//defining the variables in main
	stp	x29, x30, [sp, -16]!	// stores the contents of the pair of register to stack memory
					// saves the state of the register used by calling code, allocates 16 bytes
	mov	x29, sp			// updates FP to current SP

	// initializing the constants of the function
	mov	a, 2		// setting the constant 2 to a
	mov	B, -145		// setting the constant -145 to B
	mov	c, -44		// setting the constant -44 to c
	mov	x_counter, -10	// sets the counter for starting point -10, is also the x value for the function
	mov	current_min_counter, 9999	// sets the current min as 9999 to capture next even if it is postive
	mov	x_value, -9999	// sets the initial so the display isnt too high
	mov	y_value, 9999	// sets the initial so the display isnt too high

	b test			
loop:	
	mul	e,x_counter,x_counter	// X * X
	mul	d,e,e			// X^2 * X^2
	mul	f,e,B			// -145X^2
	mov	e,-14			// moves -14 into e 	

	madd	g,c,x_counter,e		// -44X - 14
	madd	h,a,d,f			// forms 2X^4 + (-145X^2)
	add	y_value,h,g		// forms 2X^4 + (-145X^2) + (-44X - 14) into y_value
	add	x_value,x_counter, 0	// puts the current counter into the x_value
	add	x_counter,x_counter,1	// increments counter by 1
	
	
	

test:	
	cmp	x_counter,10	// sees if the counter is over 10
	b.gt 	exit	// branches to exit if counter is over 10
	
	cmp	y_value, current_min_counter	// compares values, if greater then just goes to print
	b.gt	print				// branches to print, if conditions met
	mov	current_min_counter, y_value	// if this runs then that means the y was smaller than the current min y 
						// it then replaces the min_y with the current y
	
print:	
	add	display_min,current_min_counter,0	// moving the found min into min
	adrp	x0,words		// address of string
	add 	x0,x0, :lo12:words	// set 1st argument to pass to prinf
	bl	printf			// function call, prints values
	b	loop			// returns back to loop and runes

exit: 	// exit label
	ldp	x29, x30, [sp], 16	// loads the pair of registers from RAM
			// restores the state of the FP and LR registers
	ret		// returns control to calling code







