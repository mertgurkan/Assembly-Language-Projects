#include "address_map_arm.h"

/* This program demonstrates the use of parallel ports in the DE1-SoC Computer
 * It performs the following: 
 * 	1. displays the SW switch values on the red lights LEDR
 * 	2. displays a rotating pattern on the HEX displays
 * 	3. if a KEY[3..0] is pressed, uses the SW switches as the pattern
*/
int main (){

int a[5] = {7, 20, 9, 4, 5};
	int min_val;

	min_val = a[0];
	
	int i;
	for (i=0; i < 5; i++){
		if(a[i] < min_val){
			min_val = a[i];
		}
	}

	return min_val;
}
