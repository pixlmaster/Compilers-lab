%{
#include "y.tab.h"
#include <math.h>
extern void yyerror(const char *);  /* prints grammar violation message */
void count(void);
%}

/* Definitions */

CONSTANT {IC}|{FC}|{EC}|{CC}

/* Non-Zero Digits */
NZ_DIGIT [1-9]

/* Digit Including Zero */
DIGIT [0-9]

/* Expression of Digit Sequence */
DIGIT_SEQ ({DIGIT}+)

 /* Non Zero Integer Constant */
NIC ({NZ_DIGIT}({DIGIT})*)

  /* Integer Constant */
IC ({NIC}|[0])

 /* Sign */
sign [+-]

/* Exponential Part */
E ([eE]{sign}?{DIGIT_SEQ})

/* Fractional Constant */
FRACTIONAL_CONSTANT (({DIGIT_SEQ}?[\.]{DIGIT_SEQ})|({DIGIT_SEQ}[\.]))

/*Floating point constant */
FC (({FRACTIONAL_CONSTANT}{E}?)|{DIGIT_SEQ}{E})

/* Identifier Non Digit */
ALPHABET [a-zA-Z_]

/* Identifier Identifier non digit */
ID {ALPHABET}({ALPHABET}|{DIGIT})*


EC 		{ID}
ESC_SEQ		\\['"?\\abfnrtv]
cchar 		[^'\\\n]|{ESC_SEQ}
CC 		'({cchar})+'
schar 		[^"\\\n]|{ESC_SEQ}
SC 		\"({schar}+)\"
WS  		[ \t\v\n\f]
SINGLELINE_COMMENT  \/\/.*
MULTILINE_COMMENT	\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*\/

%%

"auto"			{ return AUTO; }
"break"         	{ return BREAK; }
"case"          	{ return CASE; }
"char"          	{ return CHAR; }
"const"         	{ return CONST; }
"continue"      	{ return CONT; }
"default"       	{ return DEFAULT; }
"do"            	{ return DO; }
"double"        	{ return DOUBLE; }
"else"          	{ return ELSE; }
"enum"          	{ return ENUM; }
"extern"        	{ return EXTERN; }
"float"         	{ return FLOAT; }
"for"           	{ return FOR; }
"goto"          	{ return GOTO; }
"if"            	{ return IF; }
"inline"        	{ return INLINE; }
"int"           	{ return INT; }
"long"          	{ return LONG; }
"register"      	{ return REGISTER; }
"restrict"      	{ return RESTRICT; }
"return"        	{ return RETURN; }
"short"         	{ return SHORT; }
"signed"        	{ return SIGNED; }
"sizeof"        	{ return SIZEOF; }
"static"        	{ return STATIC; }
"struct"        	{ return STRUCT; }
"switch"        	{ return SWITCH; }
"typedef"       	{ return TDEF; }
"union"         	{ return UNION; }
"unsigned"      	{ return UNSIGNED; }
"void"          	{ return VOID; }
"volatile"      	{ return VOLATILE; }
"while"        	    { return WHILE; }
"_Bool"         	{ return _BOOL; }
"_Complex"     		{ return _COMPLEX; }
"_Imaginary"    	{ return _IMAGINARY; }

{SC} 			{ return STR_LITERAL; }
{ID}			{ return IDENTIFIER; }
{IC} 			{ return INT_CONST; }
{FC} 			{ return FLOAT_CONST; }
{EC} 			{ return ENU_CONST; }
{CC} 			{ return CHAR_CONST; }

"["			{ return '['; }
"]"			{ return ']'; }
"("			{ return '('; }
")"			{ return ')'; }
"{"			{ return '{'; }
"}"			{ return '}'; }
"."			{ return '.'; }
"->"			{ return PTR_OP; }
"++"			{ return INC_OP; }
"--"			{ return DEC_OP; }
"&"			{ return '&'; }
"*"			{ return '*'; }
"+"			{ return '+'; }
"-"			{ return '-'; }
"~"			{ return '~'; }
"!"			{ return '!'; }
"/"			{ return '/'; }
"%"			{ return '%'; }
"<<"			{ return LEFT_OP; }
">>"			{ return RIGHT_OP; }
"<"			{ return '<'; }
">"			{ return '>'; }
"<="			{ return LE_OP; }
">="			{ return GE_OP; }
"=="			{ return EQ_OP; }
"!="			{ return NE_OP; }
"^"			{ return '^'; }
"|"			{ return '|'; }
"&&"			{ return AND_OP; }
"||"			{ return OR_OP; }

"?"			{ return '?'; }
":"			{ return ':'; }
";"			{ return ';'; }
"..."			{ return ELLIPSIS; }
"="			{ return '='; }

"*="			{ return MUL_ASSGN; }
"/="			{ return DIV_ASSGN; }
"%="			{ return MOD_ASSGN; }
"+="			{ return ADD_ASSGN; }
"-="			{ return SUB_ASSGN; }
"<<="			{ return LEFT_ASSGN; }
">>="			{ return RIGHT_ASSGN; }
"&="			{ return AND_ASSGN; }
"^="			{ return XOR_ASSGN; }
"|="			{ return OR_ASSGN; }

","			{ return ','; }
"#"			{ return '#'; }
{SINGLELINE_COMMENT}    {}
{MULTILINE_COMMENT}	{}
{WS}			{}

%%
int column = 0;
void count(void) {
	int i;
	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n') column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;
	ECHO;
}
