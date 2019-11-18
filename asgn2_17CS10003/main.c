
// Akash Tiwari
// 17CS10003
// Compilers Assignment 2


// Our custom Header file included
#include "myl.h"


// main function to call other functions
int main()
{
	// defining new-line
    char newline[2] = "\n";
    // defining a string to be printed
    char name[20] = "Akash Tiwari 17CS\0";
    // print newline
    printStr(newline);
    // print name string
    printStr(name);
    // assigning constant int to be printed
    int n = 10003 ;
    // print integer
    printInt(n);
    //print newline
    printStr(newline);
    // define prompt for user
    char name2[20] = "Give int : \n\0";
    // print prompt
    printStr(name2);
    int i, j;
    // read integer from console to j
    i = readInt(&j);
    // print error if not a valid integer
    if(i==ERR){
        printStr("ERR integer not valid");
    }
    // print it if successfull
    else{
        printInt(j);
    }
    // print newline
    printStr(newline);
    // define prompt for user
    char name3[20] = "Give float : \n\0";
    // print the prompt
    printStr(name3);
    float m, x;
    // read a float in m
    x = readFlt(&m);
    // print error message if float not valid
    if(x==ERR){
    	printStr("ERR Not a valid Float");
    }
    // print float if successful
    else{
    	printFlt(m);
    }
    printStr(newline);

}
