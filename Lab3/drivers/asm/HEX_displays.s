.text
		.equ HEX_DISP_1, 0xFF200020 //HEX display address
		.equ HEX_DISP_2, 0xFF200030	
		.global HEX_clear_ASM
		.global HEX_flood_ASM
		.global HEX_write_ASM

HEX_clear_ASM:					//one-hot encoding of HEX display turns off all the LED segments
		PUSH {R1-R8,LR}
		LDR R1, =HEX_DISP_1		//put location of the HEX_DISP_1 into register R1
		MOV R3, #0				//counter initialized at 0 for HEX
		
HEX_clear_LOOP:
		CMP R3, #6				//if we looped all 6 hex displays
		BEQ HEX_clear_CORRECT	//then branch to done, otherwise continue to next line
		AND R4, R0, #1			//check if R0 equals 0x0000 0001 if yes R4=1, if no R4=0
		CMP R4, #1				//check if R4=1
		BEQ HEX_clear_CORRECT	//if R4=1 then branch to HEX_clear_CORRECT (clears the HEX)
							
		ASR R0, R0, #1			//if R4=0, then shift by 1 bit
								// we move to the next bit to check if 
		ADD R3, R3, #1			//increment counter to see the HEX that value of HEX 1 is on R4=1
		B HEX_clear_LOOP		//back to loop 
		
HEX_clear_CORRECT:
		CMP R3, #3				//if counter is bigger than 3, we are either at HEX 4 or 5
		SUBGT R3, R3, #4		//we set our counter back to either 0(if HEx4) or 1(if HEX5) since we are updating the bits
		LDRGT R1, =HEX_DISP_2	//we set R1 to the the other disp HEX
		LDR R2, [R1]			//loads R1 to R2
		MOV R5, #0xFFFFFF00		//give it an initial value
		B HEX_clear_LOOP2		

HEX_clear_LOOP2:
		CMP R3, #0				//checks if counter is back to 0 
		BEQ HEX_clear_DONE		//branch to done if R3=0, continue if R3=1		
		LSL R5, R5, #8			//shift left by 8 bits
		ADD R5, R5, #0xFF		//keep our empty space constant
		SUB R3, R3, #1			//decrement our counter (means R3=0)
		B HEX_clear_LOOP2       //back to loop

HEX_clear_DONE:
		AND R2, R2, R5			//check (R2 and R5) R2 is either 1 or 0
		STR R2, [R1]			//store R2 in R1
		POP {R1-R8, R14}		
		BX LR

HEX_flood_ASM:					//we know that R0 holds a one-hot encoding of which HEX display
		PUSH {R1-R8,R14}
		LDR R1, =HEX_DISP_1		//put location of the HEX3-0 register into R1
		MOV R3, #0				//initialize counter at 0
		
HEX_flood_LOOP:
		CMP R3, #6				//if we looped all 6 hex displays
		BEQ HEX_flood_CORRECT	//if done then branch to HEX_flood_CORRECT

		AND R4, R0, #1			//check if R0 equals 0x0000 0001 if yes R4=1, if no R4=0
		CMP R4, #1				//if equal, this is the desired HEX
		BEQ HEX_flood_CORRECT	//branch to HEX_flood_CORRECT
							
		ASR R0, R0, #1			//if R4=0, then shift by 1 bitt
		ADD R3, R3, #1			//increment counter by 1
		B HEX_flood_LOOP		//back to loop
		
HEX_flood_CORRECT:
		CMP R3, #3				//if counter is bigger than 3, we are either at HEX 4 or 5
		SUBGT R3, R3, #4		//we set our counter back to either 0(if HEx4) or 1(if HEX5) since we are updating the bits
		LDRGT R1, =HEX_DISP_2	//we set R1 to the the other disp HEX
		LDR R2, [R1]			//loads R1 to R2
		MOV R5, #0x000000FF		//give it an initial value
		B HEX_flood_LOOP2		

HEX_flood_LOOP2:
		CMP R3, #0				//check if R3=0 
		BEQ HEX_flood_DONE		//if R3=0 then branch to HEX_flood_DONE	
		LSL R5, R5, #8			//shift left by 8 bits
		SUB R3, R3, #1			//decrement our counter
		B HEX_flood_LOOP2

HEX_flood_DONE:
		ORR R2, R2, R5			// we or R2 and R5 (meaning if R2 and R5 are both 0 R2 is 0 otherwise R2=1)
		STR R2, [R1]			//we store r2 into r1
		POP {R1-R8,LR}
		BX LR


HEX_write_ASM:					//we know that R0 holds a one-hot encoding of which HEX display, R1 holds the character value
		MOV R10, R0  			// R10=R0
		MOV R9, R1				// R9=R1, store copy of R1 into R9 which is char value
		PUSH {R1-R8,LR}			
		BL HEX_clear_ASM		//branch to HEX_CLEAR _ASM clear HEX display before writing
		POP {R1-R8,R14}
		MOV R0, R10				//Rresore initial value of r0 before the clear command
		
		PUSH {R1-R8,LR}
		LDR R1, =HEX_DISP_1		//put location of the HEX3-0 register into R1
		MOV R3, #0				//counter initialized at 0
		B HEX_write_0			//branch to HEX_write_0	

HEX_write_0:
		CMP R9, #48 	// ascii value
		BNE HEX_write_1
		MOV R5, #0x3F //hex value for 0
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_1:	
		CMP R9, #49
		BNE HEX_write_2
		MOV R5, #0x06
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_2:	
		CMP R9, #50
		BNE HEX_write_3
		MOV R5, #0x5B
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_3:	
		CMP R9, #51
		BNE HEX_write_4
		MOV R5, #0x4F
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_4:	
		CMP R9, #52
		BNE HEX_write_5
		MOV R5, #0x66
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_5:	
		CMP R9, #53
		BNE HEX_write_6
		MOV R5, #0x6D
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_6:	
		CMP R9, #54
		BNE HEX_write_7
		MOV R5, #0x7D
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_7:	
		CMP R9, #55
		BNE HEX_write_8
		MOV R5, #0x07
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_8:	
		CMP R9, #56
		BNE HEX_write_9
		MOV R5, #0x7F
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_9:	
		CMP R9, #57
		BNE HEX_write_A
		MOV R5, #0x6F
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_A:	
		CMP R9, #58
		BNE HEX_write_B
		MOV R5, #0x77
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_B:	
		CMP R9, #59
		BNE HEX_write_C
		MOV R5, #0x7C
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_C:	
		CMP R9, #60
		BNE HEX_write_D
		MOV R5, #0x39
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_D:	
		CMP R9, #61
		BNE HEX_write_E
		MOV R5, #0x5E
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_E:	
		CMP R9, #62
		BNE HEX_write_F
		MOV R5, #0x79
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_F:	
		CMP R9, #63
		BNE HEX_write_OFF
		MOV R5, #0x71
		MOV R8, R5
		B HEX_write_LOOP

HEX_write_OFF:
		MOV R5, #0
		MOV R8, R5
		B HEX_write_LOOP
		
HEX_write_LOOP:
		CMP R3, #6				//if we looped all of them
		BEQ HEX_write_CORRECT	//branch to done if error

		AND R4, R0, #1			//AND 0x0000 0000 is equal to 0x0000 00001, shift if not equal
		CMP R4, #1				//if equal, this is the desired HEX
		BEQ HEX_write_CORRECT	//branch to the part that does something
							
		ASR R0, R0, #1			//if not equal, then shift by 1 bit, move on to check if the value of HEX is 1
		ADD R3, R3, #1			//also increment our counter which will tell us which one is our HEX
		B HEX_write_LOOP		//loop again if not correct
		
HEX_write_CORRECT:
		CMP R3, #3				//if counter is bigger than 3, we are at HEX 4 or 5
		SUBGT R3, R3, #4		//we set our counter back to either 0 or 1 since we are updating the bits
		LDRGT R1, =HEX_DISP_2	//we set it to the the other disp HEX
		LDR R2, [R1]			// Set R2 to the value of R1 to get the value of the hex at that time
		MOV R5, R8				//give R8 an initial value, which is from our switch case
		B HEX_write_LOOP2		//to push stuff back

HEX_write_LOOP2:
		CMP R3, #0				//if not equal to 0, we update it
		BEQ HEX_write_DONE		//branch to done		
		LSL R5, R5, #8			//shift left by 8 bits, 
		SUB R3, R3, #1			//decrement our counter
		B HEX_write_LOOP2

HEX_write_DONE:
		ORR R2, R2, R5			// OR the current HEX values of the board with R7 to write the HEX value onto that HEX address
		STR R2, [R1]			//Store the new HEX values to the address. This effectively changes the HEX on the board
		POP {R1-R8,LR}
		BX LR
		.end
