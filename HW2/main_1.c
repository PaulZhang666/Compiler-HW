#include <stdio.h>
#include <math.h>

typedef struct{
	double x;
	double y;
}Pixel;

double getPixelDistance(Pixel *pixels)
{
    double dist_x = pixels[1].x - pixels[0].x;
    double dist_y = pixels[1].y - pixels[0].y;
    return sqrt(dist_x * dist_x + dist_y * dist_y);
};

double getPixelDist(Pixel *pixels);

int main(){
	Pixel pixels[2];
	pixels[0].x = 1.0;
	pixels[0].y = 2.5;
	pixels[1].x = 4.5;
	pixels[1].y = 3.0;
	double dist = getPixelDist(pixels);
	double dist_c = getPixelDistance(pixels);
	printf("Results: \t%f\n", dist);
	printf("Ans: \t\t%f\n", dist_c);
	return 0;
}
