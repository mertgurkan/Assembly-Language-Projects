.text
			.global _start

_start:
			LDR R1, =NUMBER			// R1 points to first NUMBER
			LDR R0, [R1]			// R0 holds N
			BL FACTORIAL			// subroutine call
			LDR R2, =RESULT			// R2 points to RESULT
			STR R0, [R2]			// R0 stored to result location
			B END

FACTORIAL:	PUSH {R1, LR}			// Remembers the state of R1 and LR
			MOV R1, R0				// Store first number R0 holds into R1
			CMP R0, #0				// If R0 equals 0
			BNE NOT_ZERO			// If not equal then go to NOT_ZERO
			MOV R0, #1				// Load value 1 to R0
			B FINAL

NOT_ZERO:	SUB R0, R0, #1			// R0 = R0-1
			BL FACTORIAL			// calls factorial recursive (n-1)
			MUL R0, R0, R1			// R0 stores factorial R0= (n-1) * n

FINAL:		POP {R1, LR}			// Restore previous version of R1 and LR
			BX LR					// Exit factorial call

END:		B END

NUMBER:		.word 5
RESULT:		.word 0