.text
.global _start
_start:
			
PUSH_:	
			MOV R0, #2		// Load 2 in R0
			PUSH {R0}		// Push 2 to Stack
			MOV R0, #3		// Load 3 in R0
			PUSH {R0}		// Push 3 to Stack
			MOV R0, #4		// Load 4 in R0
			PUSH {R0}		// Push 4 to Stack

POP_:
			POP {R1-R3}		// Pop values from stack in R1, R2, R3

END:			B END           	// infinite loop!