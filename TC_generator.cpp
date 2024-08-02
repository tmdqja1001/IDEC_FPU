/*
Random floating point number generator with adder
Test case generator for veritication of verilog HDL.
*/

#include <iostream>
#include <random>

using namespace std;

void printFP(float a){ // print FP numbers in binary format
	int *p;
	p = (int*)&a;
	for (int i = sizeof(float) * 8 - 1; i >= 0; i--)
    {   
        cout << ((*p) >> i & 1);
    }
}

int main()
{
	srand(time(NULL));
	float lo = -100.0;
	float hi = 100.0;
	float a, b, c; 
	
	for(int i=1; i<=10; i++){
		a = lo + static_cast <float> (rand()) / (static_cast <float> (RAND_MAX/(hi-lo)));
		b = lo + static_cast <float> (rand()) / (static_cast <float> (RAND_MAX/(hi-lo)));
		cout<< "#" << i << " : ";
		cout<< a << " " << b << " ";
		cout<< " a : ";
    		printFP(a);
		cout<< " b : ";
		printFP(b);
	    	cout << "\n";
	    	
	    	c = a + b;
	    	cout << "a + b = ";
	    	cout << c;
	    	cout << " c : ";
	    	printFP(c);
	    	cout << "\n";
	}

	return 0;
}
