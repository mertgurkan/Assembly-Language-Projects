#ifndef __HPS_TIM
#define __HPS_TIM

	typedef enum {
		TIM0 = 0x00000001,
		TIM1 = 0x00000002,
		TIM2 = 0x00000004,
		TIM3 = 0x00000008
	}	HPS_TIM_t;

	typedef struct {
		HPS_TIM_t tim;
		int timeout; // in usec
		int LD_en;
		int INT_en;
		int enable;
	}	HPS_TIM_config_t;

	//Argument is a struct pointer
	extern void HPS_TIM_config_ASM(HPS_TIM_config_t *param);

	//Reads value of S bit
	//Nature of return depend on whether this function
	//is able to read to read the S-bit of multiple timers in same call
	extern int HPS_TIM_read_INT_ASM(HPS_TIM_t tim);

	//Resets the S-bit and F-bit
	//This funciton support multiple timers in argument
	extern void HPS_TIM_clear_INT_ASM(HPS_TIM_t tim);

#endif