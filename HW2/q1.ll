declare double @sqrt(double);

%Pixel = type{double, double};

define double @getPixelDist(%Pixel* %x){
    entry:
	%t0 = getelementptr %Pixel* %x, i32 0, i32 0;	double* %t0 = &pixels[0].x
	%t1 = load double* %t0;				double %t1 = pixels[0].x
	%t2 = getelementptr %Pixel* %x, i32 0, i32 1;   double* %t2 = &pixels[0].y
	%t3 = load double* %t2;				double %t3 = pixels[0].y
    
	%t4 = getelementptr %Pixel* %x, i32 1, i32 0;	double* %t4 = &pixels[1].x
	%t5 = load double* %t4;				double %t5 = pixels[1].x
	%t6 = getelementptr %Pixel* %x, i32 1, i32 1;   double* %t6 = &pixels[1].y
	%t7 = load double* %t6;				double %t7 = pixels[1].y

	%t8 = fsub double %t1, %t5;			double %t8 = pixels[0].x - pixels[1].x
	%t9 = fsub double %t3, %t7;			double %t9 = pixels[0].y - pixels[1].y

	%t10 = fmul double %t8, %t8;			double %t10 = dist_x^2
	%t11 = fmul double %t9, %t9;			double %t11 = dist_y^2

	%t12 = fadd double %t10, %t11;			double %t12 = dist_x^2 + dist_y^2
	%t13 = call double @sqrt(double %t12);     	double %t13 = distance of two pixels
	ret double %t13;
}
