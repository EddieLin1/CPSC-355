// CPSC Assignment 1 - A
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 - Kostas Liosis



d_text: 
	.string	 "Current x value: %ld \nCurrent y value: %ld \nCurrent Minimum: %ld \n\n"	 // creates string for x, y, and min values	
	.balign	 4       // used for alignment
	.global	 main    // makes the "main" label visible to the linker
		


main:    //main
	stp	x29, x30, [sp, -16]!	 // pre-increments the SP register by -16
	mov	x29, sp             	 // stores the contents of the pair of registers to the stack
	
	// initializing the constants of the function
	mov	x19,2		// setting the constant 2 to register x19
	mov	x20,-145	// setting the constant -145 to register x20
	mov	x21,-44          // setting the constant -44 to register x21
	mov	x28,-10		 // the counter for the starting point
	mov	x27,9999	 // sets the current min to 9999 so we can capture all values that we get	


loop:	// main loop
	cmp	x28,10		// compares x28 to 10
	b.gt	exit		// if x28 is ever greater, branch to exit

	mul	x18,x28,x28	 // X * X
	mul	x22,x18,x18	 // X^2 * X^2

	mul	x23,x19,x22	 // 2X^4	
	mul	x24,x18,x20	 // -145X^2	
	mul	x25,x21,x28	 // -44X
	add	x25,x25,-14	 // -44X - 14
	add	x26,x23,x24	 // forms 2X^4 + (-145X^2) 	
	add	x2,x26,x25	 // froms 2X^4 + (-145X^2) + (-44X - 14) into register x2
	
	add	x1,x28,0	// puts x  counter into register x1
	add 	x28,x28,1	// increments counter by 1

	// analiyzing the minimum

	cmp	x2,x27	 // compares the integer to the current min
	b.gt	next_p	// if x1 is less than x27 then we go to next_print else
	mov	x27,x2	// moves replaces the min value with current value

next_p:	// prints current values
	add	x3,x27,0	// moving the current min value into 
	adrp	x0, d_text	// address of string
	add	x0,x0,:lo12:d_text	// set 1st argument to pass to printf
	bl	printf	// function call, prints values
	b	loop	// returns back to the loop and runs again


exit:   //exits
	ldp	 x29,x30, [sp], 16 	 // loads the pair of registers from RAM
			       // restores the state of the FP and LR registers
	ret                    // returns control to calling code
	
