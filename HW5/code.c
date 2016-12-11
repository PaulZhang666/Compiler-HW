/* Main function */
int main( )
{
    float m, n;
    printf("\nEnter a number: ");
    scanf("%f", &m);

    //Function call
    n = square(m);
    printf("\nSquare of the given number %f is %f", m, n);
}
