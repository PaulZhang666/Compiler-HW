int StringCompare(char* s1, char* s2){
    int index = 0;			//Label 'entry'
    while(s1[index]){			//Label 'loop'
	if(s1[index] > s2[index]){	//Label 'cond1'
	    return 1;			//Label 'end'
	}else if(s1[index] < s2[index]){//Label 'cond2'
	    return -1;			//Label 'end'
	}
	index++;			
    }
    if(!s2[index]){			//Label 'cond3'
	return 0;			//Label 'end'
    }else{
	return -1;			//Label 'end'
    }    
}				
