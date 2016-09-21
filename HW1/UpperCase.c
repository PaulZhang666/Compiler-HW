#include <stdio.h>

void upper_case(char* c){
    int i = 0;				//Label 'entry'
    while(c[i]){			//Label 'loop'
        if(c[i] >= 'a' && c[i] <= 'z'){ //Label 'cond1' & Label 'cond2'
            c[i] = c[i] - 32;		//Label 'rep'
        }else{
        }
	i++;				//Label 'incre'
    }
}					//Label 'end'
