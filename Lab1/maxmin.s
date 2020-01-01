.text
		.global _start

_start:	LDR R0, =MAX		// R0 points to result max location 
		LDR R1, =MIN		// R1 points to result min location
		LDR R2, [R1, #4]	// R2 holds the value of n
		LDR R3, [R1, #8]	// R3 holds the value of m
		ADD R4, R1, #12		// R4 points to the first number
		ADD R5, R1, #16 	// R5 points to the next number

		ADD R6, R2, R3		// R6 holds the elements in the list as counter n + m
		SUB R10, R10, R10		// Initialize sum to 0

FINDSUM:			 
		LDR R8, [R4]		// Get the value of R4 (pointer)
		ADD R10, R10, R8		// Add the value of R4 (pointer) to sum
		ADD R4, R4, #4		// Update R4 to point to the next number
		SUBS R6, R6, #1		// Decrement Counter by 1
		BEQ RESET			// Exit loop
		B FINDSUM

RESET:
		ADD R4, R1, #12		// R4 points to the first number
		SUB R6, R6, R6		// Reset R6
		ADD R6, R2, R3		// R6 holds the elements in the list as counter n + m
		LDR R9, [R4]		// Get the value from R4 (first number in the list)

		LDR R3, [R0]		// Obtain Value of Max
		LDR R4, [R1]		// Obtain Value of Min

LOOP:
		SUBS R6, R6, #1		// Decrement counter
		BEQ DONE		// Exit if counter = 0
		LDR R7, [R5]		// Get the value from R5
		ADD R5, R5, #4		// Move R5 forward to point to next number
			
			// Computation
			ADD R11, R9, R7 	// X1 + X2 = Xsum (R11=R9+R7)
			SUB R12, R10, R11 	//  Sum - Xsum = Ysum (R12=R10-R11)
			MUL R2, R11, R12	// Result (R2) = (Xsum * Ysum) (R2=R11*R12)
			
			// Comparison
			CMP R3, R2		// Compare Result & Max	
			BLE UPDATEMAX		// If Result > Max, Update Max
			B CHECKMIN		// Else Check Min

UPDATEMAX:	MOV R3, R2

CHECKMIN: 	CMP R4, R2		// Compare Result & Min
			BGE UPDATEMIN		// If Result < min, Update Min
			B LOOP			// Else Back to loop

UPDATEMIN:	MOV R4, R2
			B LOOP			
			
DONE:	 STR R3, [R0]		// copy content of the register R3 to R0
		 STR R4, [R1]		// copy content of the register R4 to R1
		 
END:		B END			// infinite loop!

MAX:		.word	0		// memory assigned for max location 
MIN:		.word	2147483647	// memory assigned for min location 
N: 			.word	2			
M:			.word	2			
NUMBERS:	.word	-1	, 0, 3, 2	// the list data
