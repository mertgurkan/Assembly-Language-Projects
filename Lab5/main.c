	#include "./drivers/inc/vga.h"
	#include "./drivers/inc/ISRs.h"
	#include "./drivers/inc/LEDs.h"
	#include "./drivers/inc/audio.h"
	#include "./drivers/inc/HPS_TIM.h"
	#include "./drivers/inc/int_setup.h"
	#include "./drivers/inc/wavetable.h"
	#include "./drivers/inc/pushbuttons.h"
	#include "./drivers/inc/ps2_keyboard.h"
	#include "./drivers/inc/HEX_displays.h"
	#include "./drivers/inc/slider_switches.h"

	// Array of keyPresses
	int keyPresses[] = {0,0,0,0,0,0,0,0};

	// initialize the sample
	int sample = 0;

	// initialize sampling instant
	int t = 0;
	int color = 0;

	// Volume
	double volume = 1.0;

	double generateSample(double frequency, int time){
	double signal;	//initialize return value		
	int index  = ((int)frequency*time) % 48000;	// Compute Index
	double decimal = frequency - (int) frequency;	// Extract decimal places for interpolation
	if (decimal == 0) signal = sine[index];		
	else signal = ((1-decimal)*sine[index] + decimal*sine[index+1]);	// Interpolate
	return signal;
	}

	int main() {
	// Clear interfaces
	VGA_clear_pixelbuff_ASM();
	VGA_clear_charbuff_ASM();
	audio_write_data_ASM(0x00, 0x00);
		
	short colours[] = {0x0000ff, 0x00ff00, 0x000f0};	// Loop different colours between colours
	double past[320] = { 0 };
	
	// Hold keyPress;
	char keyPress;

	// Notes: C, D, E, F, G, A, B, C
	double frequency[] = {130.813, 146.832, 164.814, 174.614, 195.998, 220.000, 246.942, 261.626, 0.0}; // Required frequencies
		
	// Construct table of note waves samples
	int notes[9][48000];
	int i,j;
	for(i=0;i<9;i++){
		for(j=0;j<48000;j++){
			notes[i][j] = (int)generateSample(frequency[i], j);
		}
	}
	
	int_setup(1, (int[]){199});

	// Timer for sound synth output
	HPS_TIM_config_t hps_tim;
	hps_tim.tim = TIM0; // First Timer
	hps_tim.timeout = 20;
	hps_tim.LD_en = 1;	
	hps_tim.INT_en = 1;
	hps_tim.enable = 1;
	HPS_TIM_config_ASM(&hps_tim);  

	int icolour=0;

	while(1) {
		// reset values
		long sample = 0; // reset the sample

		// Store keypress into array (keypress=1 when the key is pressed and continues for the whole time the key is held at pressed position)
		if(read_ps2_data_ASM(&keyPress)){
			if (keyPress != 0xF0){
				if (keyPress == 0X1C){	// A = C Note
					keyPresses[0] = 1;
				}
				else if (keyPress == 0X1B){	// S = D Note
					keyPresses[1] = 1;
				}
				else if (keyPress == 0X23){	// D = E Note
					keyPresses[2] = 1;
				}
				else if (keyPress == 0X2B){	// F = F Note
					keyPresses[3] = 1;
				}
				else if (keyPress == 0X3B){	// J = G Note
					keyPresses[4] = 1;
				}
				else if (keyPress == 0X42){	// K = A Note
					keyPresses[5] = 1;
				}
				else if (keyPress == 0X4B){	// L = B Note
					keyPresses[6] = 1;
				}
				else if (keyPress == 0X4C){	// ; = C Note
					keyPresses[7] = 1;
				}
				else if ((keyPress == 0x55) && (volume < 3.0)){ // + (Increase Volume)
					volume += 0.2; 
				} 
				else if ((keyPress == 0x4E) && (volume >= 0.2)){ // - (Decrease Volume)
					volume -= 0.2; 
				}
			}
			else if (keyPress == 0xF0){ // Break code found in the buffer (keypress=0 when the pressed key is released) 
				while(!read_ps2_data_ASM(&keyPress)); // Wait until next keypress is read to see which which button was up

				// Set to off in array. 
				if (keyPress == 0X1C){	// A is up
					keyPresses[0] = 0;
				}
				else if (keyPress == 0X1B){	// S is up
					keyPresses[1] = 0;
				}
				else if (keyPress == 0X23){	// D is up
					keyPresses[2] = 0;
				}
				else if (keyPress == 0X2B){	// F is up
					keyPresses[3] = 0;
				}
				else if (keyPress == 0X3B){	// J is up 
					keyPresses[4] = 0;
				}
				else if (keyPress == 0X42){	// K is up 
					keyPresses[5] = 0;
				}
				else if (keyPress == 0X4B){	// L is up
					keyPresses[6] = 0;
				}
				else if (keyPress == 0X4C){	// ; is up
					keyPresses[7] = 0;
				}
			}
		}

		
		// Check for timer flag
		if (hps_tim0_int_flag){
			hps_tim0_int_flag = 0; // Flag down	

			//find waves and if more than 1 key is pressed add them together
			int x;
			for (x = 0; x < 8; x ++){
				if (keyPresses[x] == 1){ 
					sample += notes[x][t];
				}
			}
			sample *= volume;
			
			// Write to audio codec port.
			if(audio_write_data_ASM(sample, sample)){
				t++;
				int index = 0;
				double val = 0;
			
				// Only draw every 10 polls.
				if((t%10 == 0)){  

					index = (t/10)%320; // Grab index for drawing point (x-coordinate)
                                                                                                    
					// Clear past point at index
					VGA_draw_point_ASM(index, past[index], 0);
					
					// Compute y for the display of the waves 
					// 120 is the center of the screen
					// Scale down y by 600000 
					val = 120 + sample/600000;

					//We keep track of past values 
					past[index] = val;

					//Draw point
					VGA_draw_point_ASM(index, val, colours[icolour]);		
				}
			}
			
			// Modulo back on 48000
			if (t == 48000){
				t = 0;
			}
		}
		if(icolour==2){
			icolour=0;
		}
		icolour++;
	}


	return 0;
}
