.text
	
	.global A9_PRIV_TIM_ISR
	.global HPS_GPIO1_ISR
	.global HPS_TIM0_ISR
	.global HPS_TIM1_ISR
	.global HPS_TIM2_ISR
	.global HPS_TIM3_ISR
	.global FPGA_INTERVAL_TIM_ISR
	.global FPGA_PB_KEYS_ISR
	.global FPGA_Audio_ISR
	.global FPGA_PS2_ISR
	.global FPGA_JTAG_ISR
	.global FPGA_IrDA_ISR
	.global FPGA_JP1_ISR
	.global FPGA_JP2_ISR
	.global FPGA_PS2_DUAL_ISR
	
	.global hps_tim0_int_flag
	.global hps_tim1_int_flag

hps_tim0_int_flag:
	.word 0x0

hps_tim1_int_flag:
	.word 0x0

A9_PRIV_TIM_ISR:
	BX LR
	
HPS_GPIO1_ISR:
	BX LR
	
HPS_TIM0_ISR:
	PUSH {LR}
	
	MOV R0, #0x1 				//moves the one-hot encoded value of the timer interrupt to clear
	BL HPS_TIM_clear_INT_ASM 	//clears tim0's interrupt request bit

	LDR R0, =hps_tim0_int_flag //loads the address of tim0's interrupt flag into R0
	MOV R1, #1 					//moves 1 into R1 to store at the address in R0
	STR R1, [R0] 				//sets hps_tim0_int_flag to 1

	POP {LR}
	BX LR
	
HPS_TIM1_ISR:
	PUSH {LR}
	
	MOV R0, #0x2 				//moves the one-hot encoded value of the timer interrupt to clear
	BL HPS_TIM_clear_INT_ASM 	//clears tim1's interrupt request bit

	LDR R0, =hps_tim1_int_flag 	//loads the address of tim1's interrupt flag into R1
	MOV R1, #1 					//moves 1 into R1 to store at the address in R0
	STR R1, [R0] 				//sets hps_tim1_int_flag to 1

	POP {LR}
	BX LR
	
HPS_TIM2_ISR:
	BX LR
	
HPS_TIM3_ISR:
	BX LR
	
FPGA_INTERVAL_TIM_ISR:
	BX LR
	
FPGA_PB_KEYS_ISR:
	BX LR
	
FPGA_Audio_ISR:
	BX LR
	
FPGA_PS2_ISR:
	BX LR
	
FPGA_JTAG_ISR:
	BX LR
	
FPGA_IrDA_ISR:
	BX LR
	
FPGA_JP1_ISR:
	BX LR
	
FPGA_JP2_ISR:
	BX LR
	
FPGA_PS2_DUAL_ISR:
	BX LR
	
	.end
