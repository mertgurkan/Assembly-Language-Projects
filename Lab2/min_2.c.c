extern int MIN_2(int x, int y);

int main() {
	int a[5] = {100, 20, 39, 11, 71};
	int min_val;

	min_val = a[0];
	
	int i;
	for (i=0; i < 5; i++){
	int b = a[i];
	int c = MIN_2(min_val, b);
		if(c < min_val){
			min_val = c;
		}
	}

	return min_val;
}
