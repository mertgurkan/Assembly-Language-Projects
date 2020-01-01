.text
			.global _start

_start:
			// Initialize registers
			MOV R0, #0
			LDR R1, = RESULT
			MOV R2, #2
			MOV R3, #3
			MOV R4, #4
							
			BL findMin // caller subroutine
			B DONE

findMin:

			LDR R1, = RESULT	// R4 points to the result location
			LDR R2, [R1, #4]	// R2 holds the number of elements in the list (N)
			ADD R3, R1, #8		// R3 points to the first number

			LDR R0, [R3]		// R0 holds the first number in the list

LOOP:		
			SUBS R2, R2, #1		// decrement the loop count (counter)
			BEQ EXIT            // if counter is =0 exit the loop
			ADD R3, R3, #4		// R3 points to next number in the list
			LDR R5, [R3]		// R5 holds the next number in the list

			CMP R0, R5			// check if it is smaller than the minimum
			BLE LOOP			// if no, branch back to the loop
			MOV R0, R5		// if yes, update the current min
			B LOOP				// branch back to the loop
EXIT:	
			LDR R1, = RESULT
			STR R0, [R1]		// store the result to the memory location
			BX LR				// return to calling code (findmin)

DONE:		
			 
END:			B END				// infinite loop!

RESULT:			.word	0			// memory assigned for result location
N: 			.word	3			// number of entries in the list			
NUMBERS:		.word	10, 2, 1			// the list data
