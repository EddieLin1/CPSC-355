// CPSC Assignment 3
// Name: Edrick Lin
// UCID: 30073844
// Tutorial 04 - Kostas Liosis


// initializing variables\

index_offset = 16				// offset value for index
jndex_offset = 20				// offset value for jndex
gap_offset = 24					// offset value for gap
array_start = 28				// offset value for start of array

index_size = 4					// element size in array (word)
a_size = 100					// array size = 100
alloc_array_size = a_size * index_size		// allocate 100 * 4 bytes in memory for array
mem_alloc = -(16 + 16 + alloc_array_size) & -16	// pre - increment value for updating stack pointer
dealloc = -mem_alloc				// post-incrementing value for return

// defining macros

fp	.req x29	// fp as x29
lr	.req x30	// lr as x30

define(a_base_adr, x19)	// register holding base address for array
define(temp_r, w20)	// temp register
define(index_r, w21)	// w20 as index_r
define(jndex_r, w22)	// w21 as jndex_r
define(temp_r2, w23)	// w23 as temp_r2
define(gap, w24)	// w23 as gap
define(count, w25)	// w25 as count

// printing formats

p_array:
	.string "v[%d]: %d\n"			// array string format

sorted_fmt:
	.string "\nSorted Array:\n"		// Sorted array string format

unsorted_fmt:
	.string "\nUnsorted Array:\n"		// Unsorted array string format
	


	.balign 4
	.global main

main:
	stp	fp, lr, [sp, mem_alloc]!		// stores contents of pair registers lp,fp to stack memory
							// allocating "mem_alloc" of memory
	mov 	fp, sp					// updates fp to sp

	mov	a_base_adr, fp 				// sets base address to fp
	add	a_base_adr, a_base_adr, array_start 	// fp add 28 offset gets first array position
	
	adrp	x0, unsorted_fmt			// formats unsorted string
	add 	w0, w0, :lo12:unsorted_fmt		// loads unsorted string
	bl	printf					// functioncall
 
	mov	index_r, 0 				// places 0 into index_r
	str	index_r, [fp, index_offset]		// stores index into first memory slot after fp

	b	test_1					// branches to loop_1


loop_1_place:
	
	bl	rand					// random function call
	and	w0,w0,0x1FF				// AND value of random with 0x1FF,so numbers between
							// 0 and 511
	str	w0, [a_base_adr, index_r, SXTW 2]     	// stores w0 into base address at v[index_r]
	ldr 	temp_r, [a_base_adr, index_r, SXTW 2]	// loads value into temp

	mov	w1, index_r				// loads index_r into w1
	mov	w2, temp_r				// loads temp_r into w2
	adrp 	x0, p_array				// uses printing array format
	add 	w0, w0, :lo12:p_array			// loads array printing format
	bl	printf					// function call to printf

	ldr	index_r, [fp, index_offset]		// loads index into index in memory
	add	index_r, index_r, 1			// i++
	str	index_r, [fp, index_offset]		// stores i in memory

test_1:
	cmp	index_r, a_size			// compares index_r to a_size
	b.lt	loop_1_place			// if index_r<a_size
	
	mov index_r, 0				// places 0 into index_r
	str index_r, [fp, index_offset]		// stores index into first memory slot after fp

	adrp	x0, sorted_fmt			// loads sorted fmt
	add	w0, w0, :lo12:sorted_fmt	// loads sorted fmt
	bl	printf				// function call to printf
 		
	mov	gap, a_size			// move value a_size into gap
	str	gap, [fp, gap_offset]		// stores gap value in memory




loop_2:
	ldr	gap, [fp, gap_offset]		// loads gap from the memory
	lsr	gap, gap, 1			// gap/2
	mov 	count, 1			// count++
	cmp	gap, 0				// compares the gap to 0
	b.le	print_sorted			// branches if gap is less than 0

	str	gap, [fp, gap_offset]		// stores the new gap to the offset address
	str	gap, [fp, index_offset]		// stores gap as index_offset in memory

loop_3:
	ldr	index_r, [fp, index_offset]	// loads index from memory address to index register
	cmp	index_r, a_size			// compares if index is larger than a_size
	b.ge	loop_2				// if it is it branches

	add	index_r, index_r, 1		// increments index by 1
	str	index_r, [fp, index_offset]	// stores the new index
	
	ldr	index_r, [fp, index_offset]	// loads index_offset value in memory
	sub	jndex_r, index_r, gap		// j = i - gap
	str	jndex_r, [fp, jndex_offset]	// stores new jndex value

loop_4:	
	ldr	jndex_r, [fp, jndex_offset]		// loads jndex_r from memory	
	ldr	temp_r, [a_base_adr, jndex_r, SXTW 2]	// loads v[j] onto temp_r
	ldr	gap, [fp,gap_offset]			// loads gap to gap

	add	temp_r2, jndex_r, gap			// creates j + gap
	ldr	temp_r2, [a_base_adr, temp_r2, SXTW 2]	// loads v[j+gap] to temp_r2	
	cmp	temp_r, temp_r2				// compares temp_r and temp_r2
	b.gt	loop_3					// if temp_r is greater than branch to loop
	
	ldr	jndex_r, [fp, jndex_offset]	// loads jndex register from memory
	cmp	jndex_r,0			// compares jndex to 0
	b.lt	loop_3				// branches if jndex_r is less than 0

	str	temp_r2, [a_base_adr, jndex_r, SXTW 2]	// stores temp_r2 to v[j]
	str	temp_r, [a_base_adr, temp_r2, SXTW 2]	// stores temp_r to v[j+gap]
	
	sub	jndex_r, jndex_r, gap			// j-= gap
	str	jndex_r, [fp, jndex_offset]		// stores new gap value
	
	b	loop_4					// branch to loop

print_sorted:
	cmp	count, 100				// compares index to 100
	b.ge	exit					// if its greater then it exits
	
	mov	w1, count				//loads index to w1
	ldr	temp_r, [a_base_adr, count, SXTW 2]	// loads the v[i] into temp_r
	mov	w2, temp_r				// moves the temp_r into w2
	adrp 	x0, p_array				// address of the string
	add	w0, w0, :lo12:p_array			// address of the string
	bl	printf 					// printf function call
	
	add	count, count, 1		 		// index++
	b	print_sorted				// loops back up with new index

exit:
	mov 	w0, 0			// return 0 to OS as required 
	ldp	fp, lr, [sp], dealloc	// loads pair of registers, deallocates memory used
	ret				// returns control



