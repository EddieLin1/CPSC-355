//File:	Assignment 6
//Author: Za Warudo
//UCID: ########
//Date: 2020-04-13


// ----------------------------- Initialized Variables ------------------------------------------------------------ 

// Macro variables
define(count, d13)	// define our macro d13 as count.
define(limit, d10)	// define our macro d10 as limit.
define(value_r, d16)	// define our macro d16 as value_r
define(result_r, x17)	// define our macro d17 as result_r

//Global Variables										
float_0:			.double 0r0.0						// Float constant 0.0.
deg_upper:			.double	0r90.0						// Upper bound for degree allowance.
deg_lower:			.double 0r-0.0						// Lower bound for degree allowance.
convergence_limit:		.double	0r1.0e-13					// Limit for when to stop Taylor series. 

.text	
buf_size = 8				// Create buffer for reading 8-byte inputs.
buf_s = 16
alloc = -(16 + buf_size)&-16		// Memory allocation
dealloc = -alloc			// De-allocation amount			
	
// ------------------------------------------------- Strings ---------------------------------------------------------------- 

str_header:	.string "x:                arctan(x):    \n"					// String for header
str_line:	.string "--------------------------------\n"					// String for line (decoration)
str1:		.string "Opening file: %s\n"							// String output.
str2:		.string "%.10f     "								// Output of number.
str3:		.string "End of file has been reached.\n"					// Print "done of file reached".
str_arctan:	.string "%.10f  \n"								// Print statement for Arctan.

str_error1:	.string "Error: incorrect number of arguments. Usage: ./a6 <filename.bin>\n"									
str_error2:	.string "Error: Filename %s not found.\n"		
str_error3:	.string "Input %f out of range.\n"							


//Subroutine
.balign 4				//Ensures instructions are properly aligned



// ----------------------------------------------- Arctan -------------------------------------------------------//



arctan:		stp 	x29, x30, [sp, -16]!			// Allocate subroutine memory
		mov 	x29, sp					// Update fp with sp

			
		//Load our temporary Registers
		fmov	d9, d0					// Move d0 into temporary register d9

		adrp	x10, convergence_limit			// Move the limit to register 10	
		add	x10, x10, :lo12:convergence_limit	// Get address of convergence limit and add to register 10
		ldr	d10, [x10]				// Load values of x10 in to the temporary register d10		
		mov	w11, 1					// Set internal register 11 to 1						

		adrp	x15, float_0				// Get address of float_0	
		add	x15, x15, :lo12:float_0			// Add address of float_o with x15 on to x15
		ldr	d15, [x15]				// Load values of float_0


		// Begin the loop to calculate Arctan.	
		
		fmov	d12, 1.0				// Set n to 1.0 (x^n / n!). Increases by 2 each iteration.

// ---------------------------------------------------------- Arctan2 ------------------------------------------------------------------
		
arctan2:		// Check if current term is the first term.
			
			cmp	w11, 1					// We set w11 to 1 as this will be our first count
			b.gt	arctan3					// If it is, set first term value = 1. Otherwise branch.
			
			fmov	count, d9				// Set first term to equal x
			b	arctan4					// Continue - increment values and move to next term.

// ---------------------------------------------------------- Arctan3 -------------------------------------------------------------------		
arctan3:		fmov	d14, 1.0
			fmov 	d16, 2.0

			fmul	count, count, d9				// Multiply current term by x	
			fmul	count, count, d9				// Multiply by x so we have x^3

			fdiv	count, count, d12				// Divide by n
		
			fneg	count, count					// Negate the current term.

			
// ---------------------------------------------------------- Arctan4 ---------------------------------------------------------------------------

			//This will increment our values.
arctan4:		fadd	d15, d15, count					// Add the current term to the ongoing sum
			add	w11, w11, 1					// Add 1 to the term number
		
			// Add 2 to the equation 
			fmov	d1, 2.0						// Set d1 to 2.0				
			fadd	d12, d12, d1					// Add 2.0 to n
			
			// Check if current term is smaller than convergence limit

			adrp	x14, float_0					// Set a temporary register d14 = 0.0 for comparison
			add	x14, x14, :lo12:float_0				// Get address of float_0
			ldr	d14, [x14]					// Load values of register 14

			fcmp	count, d14					// Compare temporary registers d13 and d14
			b.gt	arctan_check					// If d13 AKA our term is larger than d14 our float_0 or limit, then go to arctan_check
									
							
			fneg	count, count
			fcmp	count, d10					// Check if value is greater than convergence limit,
			fneg	count, count					// Return value to what it was before.

			b.gt	arctan2						// If current value was greater, then branch back to top of loop.
			b	arctan_done					// Otherwise, branch to arctan_done.	
			
// ----------------------------------------------------------------- Arctan Check --------------------------------------------------------------------

arctan_check:		fcmp	count, d10				// Compare our count to convergent limit.
			b.gt	arctan2					// If greater than the limit we loop back to arctan2
									

// ----------------------------------------------------------------- Done ----------------------------------------------------------------------------


arctan_done:		fmov	d0, d15					// Move return value cos(input) into d0.
			ldp 	x29, x30, [sp], 16			// Deallocating memory from stack.
			ret						// Return to caller.


// ---------------------------------------------------------- Main -------------------------------------------------------------------------- 

			.global main

main:			stp	x29, x30, [sp, alloc]!				// Allocate memory for main.
			mov	x29, sp

			mov	w20,	w0
			mov	x21,	x1

			// Check number of arguments input. Should equal 2 to work.
			cmp	w20, 2						// Compare number of arguments.
			b.eq	main2						// If equal to 2, continue.

			adrp	x0, str_error1					// Otherwise, print error message.
			add	x0, x0, :lo12:str_error1
			bl	printf
			b	done						// And branch to done.

//--------------------------------------------------------------- Main2 --------------------------------------------------------------------------
			
			// Print out "reading input from file". 
main2:			adrp	x0, str1					// Set up str1 argument.		
			add	x0, x0, :lo12:str1				
			ldr	x1, [x21, 8]					// Load input string into x1.
			bl	printf						// Branch link to printf.
	
			mov	w0, -100					// Reading input from file.
			ldr	x1, [x21, 8]					// Place input string into x1
			mov	w2, 0					
			mov	w3, 0					

			mov	x8, 56						// Openat I/O request
			svc	0						// Call system function
			mov	w22, w0					// Move result into file descriptor.

			// Do error checking for openat()
			cmp	w22, 0						// Error check: branch over.
			b.ge main3						// If fd_r > 0, open successful.

			adrp	x0, str_error2					// Otherwise, set up error message "file not found".
			add	x0, x0, :lo12:str_error2
			ldr	x1, [x21, 8]					// Move input string into x1.
			bl	printf						// Branch link to printf.
			b	done						// Branch to done.


//------------------------------------------------------------ Main3 ------------------------------------------------------------

			// Print out our header
main3:			adrp	x0, str_header				// Print the header
			add	x0, x0, :lo12:str_header

			bl printf

			adrp	x0, str_line				// Print the line
			add	x0, x0, :lo12:str_line

			bl printf

			add	x23, x29, buf_s				

//------------------------------------------------------------------- open --------------------------------------------------------

open:			mov	w0, w22					
			mov	x1, x23					
			mov	w2, buf_size					
			mov	x8, 63						
			svc	0						
			mov	result_r, x0					

			cmp	result_r, buf_size				
			b.ne	exit						

			// Print out the value of the input.
			
			adrp	x0, str2					
			add	x0, x0, :lo12:str2				 
			ldr	d0, [x23]				
			bl	printf						

			// Perform Arctan(x)

			ldr	d0, [x23]				
			bl	arctan						// Branch to arctan(x)
			
			adrp	x0, str_arctan					
			add	x0, x0, :lo12:str_arctan
			bl	printf						// Print the function

			b open							// Branch to open

//------------------------------------------------------- Exit ---------------------------------------------------------------------
			
exit:		mov	w0, w22					
		mov	x8, 57								
		svc	0							
		mov 	w0, 0

//------------------------------------------------------- Done ----------------------------------------------------------------------

done:		adrp	x0, str_line
		add	x0, x0, :lo12:str_line	
		bl printf	

		adrp 	x0, str3
		add 	x0, x0, :lo12:str3
		bl printf

		ldp	x29, x30, [sp], dealloc				// Deallocate memory from stack
		ret							// Return to caller




