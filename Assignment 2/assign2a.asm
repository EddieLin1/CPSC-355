// CPSC 355 Assignemnt 2 - A
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 - Kostas Liosis 

// defining macros

define(orig_r, w19)	// sets w19 as original_register  
define(rev_r, w20)	// sets w20 as reverse_register
define(t1_r, w21)	// sets w21 as t1_register
define(t2_r, w22)	// sets w22 as t2_register 
define(t3_r, w23)	// sets w23 as t3_register
define(t4_r, w24)	// sets w24 as t4_register
define(temp_r, w26)	// sets w26 as a temporary register

// format string setup
fmt:
	.string "original: 0x%08x (%d) reverse: 0x%08x (%d) \n"	// string for the result
	
	.balign 4	// ensures proper alignment
	.global main	// makes main label visible to linker

// main label
main:
	stp 	x29, x30, [sp, -16]!	// stores the contents of the pair of registers to stack memory
	mov 	x29, sp			// updates FP to current SP

//setting up initial variable
	
	mov	orig_r, 0x07FC07FC	// setting up the original X value into orig_r

// step 1 label
step_1:
	and	temp_r, orig_r, 0x55555555 	// manipulates bits comparing to bitmask 0x55555555 stores in temp
	lsl	t1_r, temp_r, 1			// logical shift left multiply by 2^(1) stored in t1_r

	lsr	temp_r, orig_r, 1		// logical shift right divide by 2^(1) stores in t2_r
	and	t2_r, temp_r, 0x55555555
	
	orr	rev_r, t1_r, t2_r		// manipulates bits comparing between t1_r and t2_r stores in rev_r

// step 2 label
step_2:
	and 	temp_r, rev_r, 0x33333333	// manipulates bits comparing to bitmask 0x33333333 stores in temp
	lsl	t1_r, temp_r, 2			// logical shift left on temp_r multiply by 2^(2) stores in t1_r

	lsr	temp_r, rev_r,2			// logical shift right on rev_r multiply by 2^(2) stores in temp_r
	and	t2_r, temp_r, 0x33333333	// manipulates bits comparing to bitmask 0x33333333 stores in t2_r

	orr	rev_r, t1_r, t2_r		// manipulates bits comparing between t1_r and t2_r stores in rev_r

// step 3 label
step_3:
	and	temp_r, rev_r, 0x0F0F0F0F	// manipulates bits comparing to bitmask 0x0F0F0F0F stores in temp_r
	lsl	t1_r, temp_r, 4			// logical shift left on temp_r multiply by 2^(4) stores in t1_r

	lsr	temp_r, rev_r, 4		// logical shift right on rev_r divide by 2^(4) stores in temp_r
	and	t2_r, temp_r, 0x0F0F0F0F	// manipulates bits comparing to bitmask 0x0F0F0F0F stores in t2_r
	
	orr	rev_r, t1_r, t2_r		// manipulates bits ocmparing between t2_r and t1_r stores om rev_r

// step 4 label
step_4:
	lsl	t1_r, rev_r, 24			// logical shift left on rev_r multiply by 2^(24) stores in t1_r

	and	temp_r, rev_r, 0xFF00		// manipulates bits comparing rev_r to bitmask 0xFF00 stores in temp_r
	lsl	t2_r, temp_r, 8			// logical shift left temp_r multiply by 2^(8) stores in t2_r

	lsr	temp_r, rev_r, 8		// logcail shift right on rev_r multiply by 2^(8) stores in temp_r
	and 	t3_r, temp_r, 0xFF00		// manipulates bits comparing temp_r to bitmask 0xFF00 stores in t3_r
	
	lsr	t4_r, rev_r, 24			// logical shift right on rev_r divides by 2^(24) stores to t4_r
	
	orr	temp_r, t1_r, t2_r		// manipulates bits comparing between t2_r and t1_r stores to temp_r
	orr	temp_r, temp_r, t3_r		// manipulates bits comparing between temp_r and t3_r stores to temp_r
	orr	rev_r, temp_r, t4_r  		// manipulates bits comparing between temp_r and t3_r stores to rev_r

// print label
print:	
	mov	 w1, orig_r	// moves orig_r into w1
	mov	 w2, orig_r	// moves orig_r into w2
	mov	 w3, rev_r	// moves rev_r into w3
	mov	 w4, rev_r	// moves rev_r into w4
	adrp	 x0, fmt	// address of string fmt
	add	 x0, x0, :lo12:fmt	// address of string fmt
	bl	 printf		// print function call

// exit label
exit:
	ldp x29, x30, [sp], 16	// loads the pair of registers from RAM, restores the state of FP and LR
				// registers, and deaallocated 16 bytes of stack memory by post-increenting SP
				// by +16
	ret			// returns control to calling code
