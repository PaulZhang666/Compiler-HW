define i32 @StringCompare(i8* %s1, i8* %s2){
    entry:
	%t0 = alloca i32;			i32* %t0 = &index
	store i32 0, i32* %t0;			
	br label %loop;
    loop:
	%t1 = load i32* %t0;			i32 %t1 = index of array
	%t2 = getelementptr i8* %s1, i32 %t1;	i8* %t2 = address of char in string s1
	%t3 = load i8* %t2;			i8 %t3 = char in the string s1
	%t4 = getelementptr i8* %s2, i32 %t1;	i8* %t4 = address of char in string s2
	%t5 = load i8* %t4;			i8 %t5 = char in the string s2
	%t6 = icmp eq i8 %t3, 0;		i1 %t6 = (%t3 == '\0')?1:0
	br i1 %t6, label %cond3, label %cond1;
    cond1:
	%t7 = icmp ugt i8 %t3, %t5;		i1 %t7 = (%t3 > %t5)?1:0
	br i1 %t7, label %end, label %cond2;
    cond2:
	%t8 = icmp ult i8 %t3, %t5;		i1 %t8 = (%t3 < %t5)?1:0
	br i1 %t8, label %end, label %incre;
    incre:
	%t9 = add i32 %t1, 1;			i32 %t9 = index++
	store i32 %t9, i32* %t0;
	br label %loop;
    cond3:
	%t10 = icmp eq i8 %t5, 0;		i1 %t10 = (%t5 == '\0')?1:0
	br i1 %t10, label %end, label %else;
    else:
	br label %end;
    end:
	%t11 = phi i32 [1, %cond1],[-1, %cond2],[0, %cond3],[-1, %else];	i32 %t11 is the final return value
	ret i32 %t11; 
  	
}
