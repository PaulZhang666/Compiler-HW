#include <stdio.h>

int StringCompare(char* s1, char* s2);

int main(){
    char *s1 = "FurzosA";
    char *s2 = "FuriosA";
    int ret = StringCompare(s1, s2);
    printf("Results:\t%d\n", ret);
    return 0;
}
