#include "myl.h"
#define INTLIMIT 12
#define FLOATLIMIT 148


// reads an intefer from standard input
int readInt(int *n)
{
    // defining buffer and other variables
    char P[INTLIMIT + 1], zero = '0';
    int i;
    __asm__ __volatile__("movl $0, %%eax\n\t"
                         "movq $0, %%rdi\n\t"
                         "syscall\n\t"
                         :
                         : "S"(P), "d"(INTLIMIT + 1));

    __asm__("movl %%eax, %0;"
            : "=r"(i)
            :);
    if (i < 0)
        return ERR;

    i = 0;
    *n = 0;
    // skipping - sign if there, for now
    if (P[0] == '-')
        i = 1;
    while (P[i] != '\n')
    {
        // return Error if buffer char not an int
        if(!(P[i]>='0' && P[i]<='9')){
            return ERR;
        }
        *n *= 10;
        *n += P[i] - zero;
        i++;
    }
    // making number negative if - sign is there
    if (P[0] == '-')
        *n = -*n;
    // return OK
    return OK;
}

// prints integer to output
int printInt(int n)
{
    // initialising variables
    char P[INTLIMIT + 1], zero = '0';
    int i = 0;
    //if number is 0
    if (n == 0)
    {
        P[i] = zero;
        i++;
    }
    else
    {
        int j = 0, k;
        // if number is negative
        if (n < 0)
        {
            P[0] = '-';
            n = -n;
            i = 1;
            j = 1;
        }
        // assigning from i=1 if negative or from i=0 if positive
        while (n)
        {
            P[i] = (char)(zero + n % 10);
            n /= 10;
            i++;
        }

        k = i - 1;
        char swap;
        if (n < 0)
            j = 1;
        while (j < k)
        {
            swap = P[j];
            P[j++] = P[k];
            P[k--] = swap;
        }
    }
    P[i] = '\0';
    // calling printStr to print number converted to string
    i = printStr(P);
    if (i < 0)
        // return error
        return ERR;
    return i;
}

// function to print the string
int printStr(char *str)
{
    int size = 0;
    while (str[size] != '\0')
        size++;

    __asm__ __volatile__("movl $1, %%eax\n\t"
                         "movq $1, %%rdi\n\t"
                         "syscall\n\t"
                         :
                         : "S"(str), "d"(size));

    __asm__("movl %%eax, %0;"
            : "=r"(size)
            :);
    return size;
}

// function to read float
int readFlt(float *n)
{
    char P[FLOATLIMIT + 1], zero = '0';
    int i;
    float j = 0.1;
    __asm__ __volatile__("movl $0, %%eax\n\t"
                         "movq $0, %%rdi\n\t"
                         "syscall\n\t"
                         :
                         : "S"(P), "d"(FLOATLIMIT + 1));

    __asm__("movl %%eax, %0;"
            : "=r"(i)
            :);
    // return ERR
    if (i < 0)
        return ERR;

    i = 0;
    *n = 0;
    // starting from 1 if negative float
    if (P[0] == '-')
        i = 1;
    // handling numbers before '.'
    while (P[i] != '.' && P[i] !='\n')
    {
        // return ERR
        if(!(P[i]>='0' && P[i]<='9')){
            return ERR;
        }
        *n *= 10;
        *n += P[i] - zero;
        i++;
    }
    // skipping . if elements present after it
    if(P[i]=='.'){
        i++;
    }
    // handling numbers after . if present
    while (P[i] != '\n')
    {
        // return error
        if(!(P[i]>='0' && P[i]<='9')){
            return ERR;
        }
        *n += (P[i] - zero) * j;
        i++;
        j /= 10;
    }

    if (P[0] == '-')
        *n = -*n;
    // else return OK
    return OK;
}
// function to print Float
int printFlt(float n)
{
    char P[FLOATLIMIT + 1], zero = '0';
    int i = 0, m = (int)n, sum = 0;
    float swap;

    swap = n - m;
    if (swap < 0)
        swap = -swap;

    if ((int)(swap * 1000000) % 10 >= 5)
    {
        swap += 0.000001;
        swap = (int)(swap * 1000000) / 1000000.0;
        n = m + swap;
        m = (int)n;

        n = n - m;
        if (n < 0)
            n = -n;
    }
    else
    {
        n = swap;
    }

    i = printInt(m);
    if (i < 0)
        return ERR;
    sum += i;

    P[0] = '.';
    P[1] = '\0';
    i = printStr(P);
    if (i < 0)
        return ERR;
    sum += 1;

    i = 0;
    while (i != 6)
    {
        n *= 10;
        P[i] = (char)(zero + (int)n);
        n -= (int)n;
        i++;
    }
    P[i] = '\0';
    i = printStr(P);
    if (i < 0)
        return ERR;
    sum += i;

    return sum;
}
