define void @upper_case(i8* %s){

entry:
    %t0 = alloca i32;
    store i32 0, i32* %t0;			i32* %t0 = address of index of array   
    br label %loop;
loop:
    %t1 = load i32* %t0;			i32 %t1 = index of array
    %t2 = getelementptr i8* %s, i32 %t1;	i8* %t2 = address of char in array
    %t3 = load i8* %t2;				i8 %t3 = char in the array
    %t4 = icmp eq i8 %t3, 0;			i1 %t4 = (%t3 == NULL)?1:0
    br i1 %t4, label %end, label %cond1;		    
cond1:
    %t5 = icmp sge i8 %t3, 97;			i1 %t5 = (%t3 >= 97)?1:0
    br i1 %t5, label %cond2, label %incre;	
cond2:
    %t6 = icmp sle i8 %t3, 122;			i1 %t6 = (%t3 <= 122)?1:0
    br i1 %t6, label %rep, label %incre;
rep:
    %t7 = sub i8 %t3, 32;			i8 %t7 = %t3 - 32;
    store i8 %t7, i8* %t2;			save the upper case char in mem
    br label %incre;
incre:
    %t8 = add i32 %t1, 1;			i32 %t8 = next index of array
    store i32 %t8, i32* %t0;			i32* %t0 = address of new index
    br label %loop;
end:
    ret void;

}
