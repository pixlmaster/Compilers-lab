%{

#include "y.tab.h"
#include <math.h>
#include "assign5_17CS10035_17CS10003_translator.h"
#include <stdio.h>
#include <string.h>

extern void yyerror(const char *);

%}


%option yylineno

escape_seq "\\\\"|"\\\'"|"\\\""|"\\\?"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"

s_char {escape_seq}|[^\"\\\n]
s_char_SEQ ({s_char})+
string_literal_regex (\"){s_char_SEQ}(\")

c_char {escape_seq}|[^\'\\\n]
c_char_seq ({c_char})+
char_const_regex (\')({c_char_seq})(\')

integer_const_regex 0|[1-9][0-9]* 

digit_seq [0-9]+
exp_part (E|e)(\+|\-)?{digit_seq}
fraction_const_regex ({digit_seq}?(\.){digit_seq})|({digit_seq}(\.))  
float_const_regex ({fraction_const_regex})({exp_part}?)|({digit_seq})({exp_part})

enum_const_regex [a-zA-Z][a-zA-Z0-9]*
%%

[\t\n ] ;

"[" return SQ_BRACKET_OPEN;
"]" return SQ_BRACKET_CLOSE;
"{" return C_BRACKET_OPEN;
"}" return C_BRACKET_CLOSE;
"." return DOT;
"->" return POINTER_ARROW;
"++" return PLUS_PLUS;
"--" return MINUS_MINUS;
"&" return AND;
"*" return MULTIPLY;
"+" return PLUS;
"-" return MINUS;
"~" return TILDA;
"!" return EXCLA_NOT;
"/" return FWD_SLASH;
"%" return MODULO;
"<<" return LEFT_SHIFT;
">>" return RIGHT_SHIFT;
"<" return LESS_THAN;
">" return GREATER_THAN;
"<=" return LESS_THAN_EQUAL;
">=" return GREATER_THAN_EQUAL;
"==" return EQUAL_EQUAL;
"!=" return NOT_EQUAL;
"^" return XOR_K;
"|" return OR;
"&&" return AND_AND;
"||" return OR_OR;
"?" return QUESTION_MARK;
":" return COLON;
";" return SEMI_COLON;
"..." return THREE_DOTS;
"=" return ASSIGNMENT_OP;
"*=" return CMP_ASGN_MULTIPLY;
"/=" return CMP_ASGN_DIVIDE;
"%=" return CMP_ASGN_MODULO;
"+=" return CMP_ASGN_PLUS;
"-=" return CMP_ASGN_MINUS;
"<<=" return CMP_ASGN_LEFT_SHIFT;
">>=" return CMP_ASGN_RIGHT_SHIFT;
"&=" return CMP_ASGN_AND;
"^=" return CMP_ASGN_XOR;
"|=" return CMP_ASGN_OR;
"," return COMMA;
"#" return HASH;
"(" return ROUND_BRACKET_OPEN;
")" return ROUND_BRACKET_CLOSE;

\/\/.* { }
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]  { }

"include" return INCLUDE;
"auto" return AUTO;
"enum" return ENUM;
"restrict" return RESTRICT;
"unsigned" return UNSIGNED;
"break" return BREAK_LOOP;
"extern" return EXTERN;
"return" return RETURN_VAL;
"void" return VOID_K;
"case" return CASE_KEYWORD;
"float" return DT_FLOAT;
"short" return DT_SHORT;
"volatile" return VOLATILE;
"char" return DT_CHAR;
"for" return FOR_KEYWORD;
"signed" return SIGNED;
"while" return WHILE_KEYWORD;
"const" return CONST;
"goto" return GOTO_K;
"sizeof" return SIZEOF;
"_Bool" return DT_BOOL;
"continue" return CONTINUE_LOOP;
"if" return IF_KEYWORD;
"static" return STATIC;
"_Complex" return DT_COMPLEX;
"default" return DEFAULT;
"inline" return INLINE;
"struct" return STRUCT;
"_Imaginary" return DT_IMAGINARY;
"do" return DO_KEYWORD;
"int" return DT_INT;
"switch" return SWITCH;
"double" return DT_DOUBLE;
"long" return DT_LONG;
"typedef" return TYPEDEF;
"else" return ELSE_KEYWORD;
"register" return REGISTER;
"union" return UNION_KEYWORD;

[a-zA-Z][a-zA-Z0-9]* {yylval.symp = table -> lookup(yytext); return IDENTIFIER;}

{enum_const_regex} return ENUM_CONSTANT;
{string_literal_regex} {yylval.strval = yytext; return STRING_LITERAL;}
{integer_const_regex} {yylval.intval = atoi(yytext); return INTEGER_CONSTANT;}
{float_const_regex}	{yylval.strval = yytext; return FLOAT_CONSTANT;}
{char_const_regex} return CHAR_CONSTANT;

%%

int yywrap(void)
{
	return 1;
}
