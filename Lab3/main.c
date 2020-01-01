#include <stdio.h>

#include "./drivers/inc/LEDs.h"
#include "./drivers/inc/slider_switches.h"
#include "./drivers/inc/HEX_displays.h"
#include "./drivers/inc/pushbuttons.h"
#include "./drivers/inc/HPS_TIM.h"
#include "./drivers/inc/ISRs.h"
#include "./drivers/inc/address_map_arm.h"
#include "./drivers/inc/int_setup.h"





int main(){
	// PART 1 


	while(1){
		write_LEDs_ASM(read_slider_switches_ASM());
	}






	/*
	PART 2
	Infinite loop with while loop with writeLEDs constantly running
	Check if the last switch is turned on (0x200 == 1000 0000 0000) and clear all HEX if it's on
	Else, always flood HEX4-5 and read the slider value of the first 4 sliders (0xF == 0000 0000 1111)
	then read the pushbutton value to check which HEX we want to write on.
	*/


	while(1){
		write_LEDs_ASM(read_slider_switches_ASM());
		if(read_slider_switches_ASM() & 0x200){
			HEX_clear_ASM(HEX0); //should clear all
			HEX_clear_ASM(HEX1);
			HEX_clear_ASM(HEX2);
			HEX_clear_ASM(HEX3);
			HEX_clear_ASM(HEX4);
			HEX_clear_ASM(HEX5);
		}
		else{
			HEX_flood_ASM(HEX4);
			HEX_flood_ASM(HEX5);
			char hex_val = (0xF & read_slider_switches_ASM());
			int pushbutton = (0xF & read_PB_data_ASM());
			hex_val = hex_val + 48; //for ascii usage
			HEX_write_ASM(pushbutton, hex_val);//write the value on display
		}
	}


	// SAMPLE CODE 
SAMPLE
	int count0 = 0, count1 = 0, count2 = 0, count3 = 0;
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0|TIM1|TIM2|TIM3;
	hps_tim.timeout = 1000000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);
	while (1) {
		write_LEDs_ASM(read_slider_switches_ASM());
		if (HPS_TIM_read_INT_ASM(TIM0)) {
			HPS_TIM_clear_INT_ASM(TIM0);
			if (++count0 == 16)
				count0 = 0;
		HEX_write_ASM(HEX0, (count0+48));
		}
		if (HPS_TIM_read_INT_ASM(TIM1)) {
			HPS_TIM_clear_INT_ASM(TIM1);
			if (++count1 == 16)
				count1 = 0;
			HEX_write_ASM(HEX1, (count1+48));
		}
		if (HPS_TIM_read_INT_ASM(TIM2)) {
			HPS_TIM_clear_INT_ASM(TIM2);
			if (++count2 == 16)
				count2 = 0;
		HEX_write_ASM(HEX2, (count2+48));
		}
		if (HPS_TIM_read_INT_ASM(TIM3)) {
			HPS_TIM_clear_INT_ASM(TIM3);
			if (++count3 == 16)
				count3 = 0;
			HEX_write_ASM(HEX3, (count3+48));
		}
	}








/*
	PART 3, STOPWATCH
	First, config both timers (TIM0 for the timer, TIM1 for pushbutton polling)
	Then enter infinite loop where we constantly check if the timer was started which increments in 10 milliseconds and
	increments seconds and minutes accordingly
	It also write the values of the time units to the corresponding HEX
	It also checks if the pushbuttons are pressed and either Starts, Stops or Resets the timer
	*/


	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0;
	hps_tim.timeout = 10000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim); //Config timer 1



	//This timer is for the pushbutton polling
	HPS_TIM_config_t hps_tim_pb;
	hps_tim_pb.tim = TIM1;
	hps_tim_pb.timeout = 5000;
	hps_tim_pb.LD_en = 1;
	hps_tim_pb.INT_en = 1;
	hps_tim_pb.enable = 1;
	HPS_TIM_config_ASM(&hps_tim_pb); //config timer 2



	//Declare our init
	int milli = 0;
	int seconds = 0;
	int minutes = 0;
	int timerstart = 0;
	while (1) {
		//check if timer was started
		if (HPS_TIM_read_INT_ASM(TIM0) && timerstart) {
			HPS_TIM_clear_INT_ASM(TIM0);
			milli += 10; //Timer is for 10 milliseconds
			//When microseconds reach 1000, we increment seconds, then microsseocnds reset
			if (milli >= 1000) {
				milli -= 1000;
				seconds++;
				//when seconds reach 60, we reset and increment minutes
				if (seconds >= 60) {
					seconds -= 60;
					minutes++;
					//reset after 60 minutes
					if (minutes >= 60) {
						minutes = 0;
					}
				}
			}
			//Display every value and convert the count to ascii values
			HEX_write_ASM(HEX0, ((milli % 100) / 10) + 48); // Milli increments in 10 microseconds so we must modulo and divide by 10 to get the digit at 0.01 s
			HEX_write_ASM(HEX1, (milli / 100) + 48);		//Divide Milli by 100 to get 0.1s digit
			HEX_write_ASM(HEX2, (seconds % 10) + 48);		// modulo seconds to get 1s digit
			HEX_write_ASM(HEX3, (seconds / 10) + 48);		// divide by 10 to get 10s digit
			HEX_write_ASM(HEX4, (minutes % 10) + 48);		// modulo minutes to get 1s digit
			HEX_write_ASM(HEX5, (minutes / 10) + 48);		// divide minutes by 10 to get 10s digit
		}
		//for the pushbuttons polling
		if (HPS_TIM_read_INT_ASM(TIM1)) {
			HPS_TIM_clear_INT_ASM(TIM1); //reset
			int pushbutton = 0xF & read_PB_data_ASM(); // read_PB_edgecap_ASM()
			//Start timer check if button 1 is pressed
			if ((pushbutton & 1) && (!timerstart)) {
				timerstart = 1;
			}
			//Stop timer when button 2 is pressed
			else if ((pushbutton & 2) && (timerstart)) {
				timerstart = 0;
			}
			//Reset timer when button 4 is pressed
			else if (pushbutton & 4) {
				milli = 0;
				seconds = 0;
				minutes = 0;
				timerstart = 0;
				//set everything to 0
				HEX_write_ASM(HEX0, 48);
				HEX_write_ASM(HEX1, 48);
				HEX_write_ASM(HEX2, 48);
				HEX_write_ASM(HEX3, 48);
				HEX_write_ASM(HEX4, 48);
				HEX_write_ASM(HEX5, 48);
			}
		}
	}






/*
	PART 4 INTERRUPT BASED STOPWATCH
	First, call init_setup for the TIM0 timer (199) and the Pushbuttons (73)
	Then enable interrupts for the Pushbuttons you want to use
	Config the TIM0 timer
	Same infinite loop with the time units as Part 3 but with interrupt flags
	Check if the PB flag was changed and depending on the flag
	*/
	//enable the pb interrupts
	int_setup(2, (int[]) {73, 199 });
	enable_PB_INT_ASM(PB0 | PB1 | PB2);
	
	int count = 0;
	HPS_TIM_config_t hps_tim;
	//only need one timer
	hps_tim.tim = TIM0;
	hps_tim.timeout = 10000;
	hps_tim.LD_en = 1;
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;



	HPS_TIM_config_ASM(&hps_tim);
	int timerstart=0;
	int milli = 0;
	int seconds = 0;
	int minutes = 0;
	
	while (1) {
		//each 10 ms, we increment, we only go when the subroutine flag is active
		if (hps_tim0_int_flag && timerstart) {
			hps_tim0_int_flag = 0;
			milli += 10;



			//increment ms until we reach 1000, then +1 second then reset
			if (milli >= 1000) {
				milli -= 1000;
				seconds++;
				//increment seconds, until we reach 60, then +1 minute then reset
				if (seconds >= 60) {
					seconds -= 60;
					minutes++;
					//reset minutes since we have no hours
					if (minutes >= 60) {
						minutes = 0;
					}
				}
			}



			//write on the proper hex display
			HEX_write_ASM(HEX0, ((milli % 100) / 10) + 48);
			HEX_write_ASM(HEX1, (milli / 100) + 48);
			HEX_write_ASM(HEX2, (seconds % 10) + 48);
			HEX_write_ASM(HEX3, (seconds / 10) + 48);
			HEX_write_ASM(HEX4, (minutes % 10) + 48);
			HEX_write_ASM(HEX5, (minutes / 10) + 48);
		}
		//if pushbutton flag active, the ISR is active, we do something according to which button pressed
		if (pb_int_flag != 0){
			if(pb_int_flag == 1) //start
				timerstart=1;
			else if(pb_int_flag == 2) //pause
				timerstart = 0;
			else if(pb_int_flag == 4 & timerstart==0){ // reset timer
				milli = 0;
				seconds = 0;
				minutes = 0;
				HEX_write_ASM(HEX0, 48);
				HEX_write_ASM(HEX1, 48);
				HEX_write_ASM(HEX2, 48);
				HEX_write_ASM(HEX3, 48);
				HEX_write_ASM(HEX4, 48);
				HEX_write_ASM(HEX5, 48);
			}
			pb_int_flag = 0;
		}
	}


return 0;



}




