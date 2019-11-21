%{ 
	#include <string.h>
	#include <stdio.h>
	#include "assign5_17CS10035_17CS10003_translator.h"
	extern int yylex();
	void yyerror(char *s);
	
	extern etype TYPE;
%}

%code requires{
			#include "assign5_17CS10035_17CS10003_translator.h"
		}


%union {
	int intval;
	float floatval;
	char* strval;
	int instr;
	sym* symp;
	symType* st;
	statement* stat;
	expr* exp;
	list<int>* li;
	unary* UNA;
	char uop;
}

//punctuators
%token SQ_BRACKET_OPEN SQ_BRACKET_CLOSE C_BRACKET_OPEN C_BRACKET_CLOSE ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE
%token MODULO PLUS MINUS MULTIPLY FWD_SLASH AND OR XOR_K EXCLA_NOT AND_AND OR_OR TILDA LEFT_SHIFT RIGHT_SHIFT
%token LESS_THAN GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL EQUAL_EQUAL NOT_EQUAL
%token CMP_ASGN_MULTIPLY CMP_ASGN_DIVIDE CMP_ASGN_MODULO CMP_ASGN_PLUS CMP_ASGN_MINUS CMP_ASGN_LEFT_SHIFT
%token CMP_ASGN_RIGHT_SHIFT CMP_ASGN_AND CMP_ASGN_XOR CMP_ASGN_OR PLUS_PLUS MINUS_MINUS
%token DOT POINTER_ARROW QUESTION_MARK COLON SEMI_COLON THREE_DOTS ASSIGNMENT_OP COMMA HASH

//comments
%token SINGLE_LINE_COMMENT MULTI_LINE_COMMENT

//keywords
%token INCLUDE AUTO ENUM RESTRICT UNSIGNED BREAK_LOOP EXTERN RETURN_VAL VOID_K CASE_KEYWORD DT_FLOAT DT_SHORT
%token VOLATILE DT_CHAR FOR_KEYWORD SIGNED WHILE_KEYWORD CONST GOTO_K SIZEOF DT_BOOL CONTINUE_LOOP IF_KEYWORD
%token STATIC DT_COMPLEX DEFAULT INLINE STRUCT DT_IMAGINARY DO_KEYWORD DT_INT SWITCH DT_DOUBLE DT_LONG TYPEDEF
%token ELSE_KEYWORD REGISTER UNION_KEYWORD

//others
%token <symp> IDENTIFIER  
%token <intval> INTEGER_CONSTANT
%token <strval> FLOAT_CONSTANT
%token <strval> ENUM_CONSTANT
%token <cha> CHAR_CONSTANT
%token <strval> STRING_LITERAL

//%type_expressions
%type <intval> argument_expression_list
%type <st> pointer
%type <uop> unary_operator
%type <symp> constant
			initializer
			declarator
			direct_declarator
			init_declarator
%type <exp> expression
			primary_expression
			additive_expression
			multiplicative_expression
			shift_expression
			relational_expression
			equality_expression
			AND_expression
			exclusive_OR_expression
			inclusive_OR_expression
			logical_and_expression
			logical_or_expression
			conditional_expression
			assignment_expression
			expression_statement
			
%type <UNA> postfix_expression
			unary_expression
			cast_expression
			
%type <stat> statement
			labeled_statement
			compound_statement
			selection_statement
			iteration_statement
			jump_statement
			block_item
			block_item_list
			
%type <instr> M
%type <exp> N



%start translation_unit


%%

constant	
	: INTEGER_CONSTANT
	{
		$$ = gentemp(INT, number2string($1));
		emit(EQUAL, $$->name, $1);
	}
	| FLOAT_CONSTANT
	{
		$$ = gentemp(DOUBLE, *new string($1));
		emit(EQUAL, $$->name, *new string($1));
	}
	| CHAR_CONSTANT
	{
		$$ = gentemp(CHAR);
		emit(EQUAL, $$->name, "c");
	}
	| ENUM_CONSTANT
	{

	}
	;

primary_expression	
	: IDENTIFIER 
	{
		$$ = new expr();
		$$->isbool = false;
		$$->symp = $1;
	}
	| constant
	{
		$$ = new expr();
		$$->symp = $1;
	} 
	| STRING_LITERAL 
	{
		$$ = new expr();
		$$->symp = gentemp(PTR, $1);
		$$->symp->initialize($1);
		$$->symp->type->ptr = new symType(CHAR);
	}
	| ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE 
	{
		$$ = $2;
	}
	;

postfix_expression	
	: primary_expression 
	{
		$$ = new unary();
		$$->loc = $$->symp;
		$$->symp = $1->symp;
		$$->type = $1->symp->type;
	}
	| postfix_expression SQ_BRACKET_OPEN expression SQ_BRACKET_CLOSE
	{
		$$ = new unary();
		$$->loc = gentemp(INT);		// store computed address
		$$->symp = $1->symp;			// copying the base
		$$->type = $1->type->ptr;		// both have same type
		
		// New address = already computed address + $3 * new width
		if ($1->cat !=ARR) {		// nothing alresdy computed
			emit(MULT, $$->loc->name, $3->symp->name, number2string(sizeOfType($$->type)));
		}
		else {					//  something already computed
			sym* t = gentemp(INT);
			emit(MULT, t->name, $3->symp->name, number2string(sizeOfType($$->type)));
			emit (ADD, $$->loc->name, $1->loc->name, t->name);
		}

		// We have to mark that it contains array address and first time computation is done
		$$->cat = ARR;
	} 
	| postfix_expression ROUND_BRACKET_OPEN argument_expression_list ROUND_BRACKET_CLOSE
	{
		$$ = new unary();
		$$->symp = gentemp($1->type->cat);
		emit(CALL, $$->symp->name, $1->symp->name, tostr($3));
	} 
	| postfix_expression ROUND_BRACKET_OPEN ROUND_BRACKET_CLOSE
	{
		$$ = new unary();
		$$->symp = gentemp($1->type->cat);
		emit(CALL, $$->symp->name, $1->symp->name, "0");
	}
	| postfix_expression DOT IDENTIFIER
	{

	} 
	| postfix_expression POINTER_ARROW IDENTIFIER  
	{

	}
	| postfix_expression PLUS_PLUS 
	{
		$$ = new unary();
		// first copy $1 to $$ before incrementing ('.' postfix operation)
		$$->symp = gentemp($1->symp->type->cat);
		emit (EQUAL, $$->symp->name, $1->symp->name);

		// then increment $1 by 1
		emit (ADD, $1->symp->name, $1->symp->name, "1");
	}
	| postfix_expression MINUS_MINUS 
	{
		$$ = new unary();
		// first copy $1 to $$ before decrementing ('.' postfix operation)
		$$->symp = gentemp($1->symp->type->cat);
		emit (EQUAL, $$->symp->name, $1->symp->name);

		// then decrement $1 by 1
		emit (SUB, $1->symp->name, $1->symp->name, "1");
	}
	| ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE C_BRACKET_OPEN initializer_list C_BRACKET_CLOSE 
	{
		$$ = new unary();
		$$->loc = gentemp(INT, "0");
		$$->symp = gentemp(INT, "0");
	}
	|  ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE C_BRACKET_OPEN initializer_list COMMA C_BRACKET_CLOSE 
	{
		$$ = new unary();
		$$->loc = gentemp(INT, "0");
		$$->symp = gentemp(INT, "0");
	}
	;

argument_expression_list	
	: assignment_expression
	{
		emit (PARAM, $1->symp->name);
		$$ = 1;
	} 
	| argument_expression_list COMMA assignment_expression 
	{
		emit (PARAM, $3->symp->name);
		$$ = $1+1;
	}
	;

unary_expression	
	: postfix_expression
	{
		$$ = $1;
	} 
	| PLUS_PLUS unary_expression
	{
		// Increment $1
		emit (ADD, $2->symp->name, $2->symp->name, "1");

		// Use the same value
		$$ = $2;
	} 
	| MINUS_MINUS unary_expression 
	{
		// Decrement $1
		emit (SUB, $2->symp->name, $2->symp->name, "1");

		// Use the same value
		$$ = $2;
	}
	| unary_operator cast_expression 
	{
		$$ = new unary();
		if($1 == '&'){
			$$->symp = gentemp(PTR);
			$$->symp->type->ptr = $2->symp->type; 
			emit (ADDRESS, $$->symp->name, $2->symp->name);
		}
		else if($1 == '*'){
			$$->cat = PTR;
			$$->loc = gentemp ($2->symp->type->ptr);
			emit (PTRR, $$->loc->name, $2->symp->name);
			$$->symp = $2->symp;
		}
		else if($1 == '+'){
			$$ = $2;
		}
		else if($1 == '-'){
			$$->symp = gentemp($2->symp->type->cat);
			emit (UMINUS, $$->symp->name, $2->symp->name);
		}
		else if($1 == '~'){
			$$->symp = gentemp($2->symp->type->cat);
			emit (BNOT, $$->symp->name, $2->symp->name);
		}
		else if($1 == '!'){
			$$->symp = gentemp($2->symp->type->cat);
			emit (LNOT, $$->symp->name, $2->symp->name);
		}
	}
	| SIZEOF unary_expression
	{
		$$ = $2;
	}
	| SIZEOF ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE 
	{
		$$->symp = gentemp(INT, tostr(sizeOfType(new symType(TYPE))));
	}
	;

unary_operator	
	: AND 
	{
		$$ = '&';
	}
	| MULTIPLY 
	{
		$$ = '*';
	}
	| PLUS 
	{
		$$ = '+';
	}
	| MINUS 
	{
		$$ = '-';
	}
	| TILDA 
	{
		$$ = '~';
	}
	| EXCLA_NOT 
	{
		$$ = '!';
	}
	;

cast_expression	
	: unary_expression
	{
		$$ = $1;
	} 
	| ROUND_BRACKET_OPEN type_name ROUND_BRACKET_CLOSE cast_expression 
	{
		$$ = $4;
	}
	;

multiplicative_expression	
	: cast_expression 
	{
		$$ = new expr();
		if ($1->cat==ARR) { // Array
			$$->symp = gentemp($1->loc->type);
			emit(ARRR, $$->symp->name, $1->symp->name, $1->loc->name);
		}
		else if ($1->cat==PTR) { // Pointer
			$$->symp = $1->loc;
		}
		else { // otherwise
			$$->symp = $1->symp;
		}
	}
	| multiplicative_expression MULTIPLY cast_expression
	{
		if (typecheck ($1->symp, $3->symp) ) 
		{
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			emit (MULT, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;

	} 
	| multiplicative_expression FWD_SLASH cast_expression
	{
		if (typecheck ($1->symp, $3->symp) ) {
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			emit (DIVIDE, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;
	} 
	| multiplicative_expression MODULO cast_expression 
	{
		if (typecheck ($1->symp, $3->symp) ) {
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			emit (MODOP, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;
	}
	;

additive_expression	
	: multiplicative_expression
	{
		$$ = $1;
	}
	| additive_expression PLUS multiplicative_expression 
	{
		if (typecheck($1->symp, $3->symp)) {
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			emit (ADD, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;
	}
	| additive_expression MINUS multiplicative_expression 
	{
		if (typecheck($1->symp, $3->symp)) {
			$$ = new expr();
			$$->symp = gentemp($1->symp->type->cat);
			emit (SUB, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;
	}
	;

shift_expression	
	: additive_expression 
	{
		$$ = $1;
	}
	| shift_expression LEFT_SHIFT additive_expression
	{
		if ($3->symp->type->cat == INT) {
			$$ = new expr();
			$$->symp = gentemp (INT);
			emit (LEFTOP, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;
	} 
	| shift_expression RIGHT_SHIFT additive_expression 
	{
		if ($3->symp->type->cat == INT) {
			$$ = new expr();
			$$->symp = gentemp (INT);
			emit (RIGHTOP, $$->symp->name, $1->symp->name, $3->symp->name);
		}
		else cout << "Error in type compatibility !"<< endl;
	}
	;

relational_expression	
	: shift_expression
		{
			$$ = $1;
		} 
	| relational_expression LESS_THAN shift_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// New bool
				$$ = new expr();
				$$->isbool = true;

				$$->truelist = makelist (nextinstr());
				$$->falselist = makelist (nextinstr()+1);
				emit(LT, "", $1->symp->name, $3->symp->name);
				emit (GOTO, "");
			}
			else cout << "Error in type compatibility !"<< endl;
		} 
	| relational_expression GREATER_THAN shift_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// New bool
				$$ = new expr();
				$$->isbool = true;

				$$->truelist = makelist (nextinstr());
				$$->falselist = makelist (nextinstr()+1);
				emit(GT, "", $1->symp->name, $3->symp->name);
				emit (GOTO, "");
			}
			else cout << "Error in type compatibility !"<< endl;
		} 
	| relational_expression LESS_THAN_EQUAL shift_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// New bool
				$$ = new expr();
				$$->isbool = true;

				$$->truelist = makelist (nextinstr());
				$$->falselist = makelist (nextinstr()+1);
				emit(LE, "", $1->symp->name, $3->symp->name);
				emit (GOTO, "");
			}
			else cout << "Error in type compatibility !"<< endl;
		} 
	| relational_expression GREATER_THAN_EQUAL shift_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// New bool
				$$ = new expr();
				$$->isbool = true;

				$$->truelist = makelist (nextinstr());
				$$->falselist = makelist (nextinstr()+1);
				emit(GE, "", $1->symp->name, $3->symp->name);
				emit (GOTO, "");
			}
			else cout << "Error in type compatibility !"<< endl;
		} 	;

equality_expression	
	: relational_expression
		{
			$$ = $1;
		} 
	| equality_expression EQUAL_EQUAL relational_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// If anyone is bool- get its value
				convfrombool($1);
				convfrombool($3);
				
				$$ = new expr();
				$$->isbool = true;
				
				$$->truelist = makelist (nextinstr());
				$$->falselist = makelist (nextinstr()+1);
				emit (EQOP, "", $1->symp->name, $3->symp->name);
				emit (GOTO, "");
			}
			else cout << "Error in type compatibility !"<< endl;
		} 
	| equality_expression EXCLA_NOT relational_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// If anyone is bool- get its value
				convfrombool($1);
				convfrombool($3);
				
				$$ = new expr();
				$$->isbool = true;
				
				$$->truelist = makelist (nextinstr());
				$$->falselist = makelist (nextinstr()+1);
				emit (NEOP, "", $1->symp->name, $3->symp->name);
				emit (GOTO, "");
			}
			else cout << "Error in type compatibility !"<< endl;
		} 	;

AND_expression	
	: equality_expression
		{
			$$ = $1;
		} 
	| AND_expression AND equality_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				$$ = new expr();
				$$->isbool = false;

				$$->symp = gentemp (INT);
				emit (BAND, $$->symp->name, $1->symp->name, $3->symp->name);
			}
			else cout << "Error in type compatibility !"<< endl;
		} 	;

exclusive_OR_expression	
	: AND_expression
		{
			$$ = $1;
		} 
	| exclusive_OR_expression XOR_K AND_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// If any is bool get its value
				convfrombool ($1);
				convfrombool ($3);

				$$ = new expr();
				$$->isbool = false;

				$$->symp = gentemp (INT);
				emit (XOR, $$->symp->name, $1->symp->name, $3->symp->name);
			}
			else cout << "Error in type compatibility !"<< endl;
		} 	; 

inclusive_OR_expression	
	: exclusive_OR_expression
		{
			$$ = $1;
		} 
	| inclusive_OR_expression OR exclusive_OR_expression
		{
			if (typecheck ($1->symp, $3->symp) ) {
				// If any is bool get its value
				convfrombool ($1);
				convfrombool ($3);

				$$ = new expr();
				$$->isbool = false;

				$$->symp = gentemp (INT);
				emit (INOR, $$->symp->name, $1->symp->name, $3->symp->name);
			}
			else cout << "Error in type compatibility !"<< endl;
		} 	;

logical_and_expression	
	: inclusive_OR_expression
		{
			$$ = $1;
		} 
	| logical_and_expression N AND_AND M inclusive_OR_expression
		{
			conv2bool($5);

			// N:- to convert $1 to bool
			backpatch($2->nextlist, nextinstr());
			conv2bool($1);

			$$ = new expr();
			$$->isbool = true;

			backpatch($1->truelist, $4);
			$$->truelist = $5->truelist;
			$$->falselist = merge($1->falselist, $5->falselist);
		} 	;

logical_or_expression	
	: logical_and_expression
		{
			$$ = $1;
		} 
	| logical_or_expression N OR_OR M logical_and_expression
		{
			conv2bool($5);

			// N to convert $1 to bool
			backpatch($2->nextlist, nextinstr());
			conv2bool($1);

			$$ = new expr();
			$$->isbool = true;

			backpatch ($$->falselist, $4);
			$$->truelist = merge ($1->truelist, $5->truelist);
			$$->falselist = $5->falselist;
		}	;

M 		: %empty	// To store the address of the next instruction for further use.
			{
				$$ = nextinstr();
			}
		;

N 		: %empty 	// Non terminal to prevent fallthrough of expr statement by emitting a goto
			{
				$$  = new expr();
				$$->nextlist = makelist(nextinstr());
				emit (GOTO,"");
			}
		;

conditional_expression	
	: logical_or_expression
		{
			$$ = $1;
		} 
	| logical_or_expression N QUESTION_MARK M expression N COLON M conditional_expression
		{
			$$->symp = gentemp();
			$$->symp->update($5->symp->type);
			emit(EQUAL, $$->symp->name, $9->symp->name);
			list<int> l = makelist(nextinstr());
			emit (GOTO, "");

			backpatch($6->nextlist, nextinstr());
			emit(EQUAL, $$->symp->name, $5->symp->name);
			list<int> m = makelist(nextinstr());
			l = merge (l, m);
			emit (GOTO, "");

			backpatch($2->nextlist, nextinstr());
			conv2bool ($1);
			backpatch ($1->truelist, $4);
			backpatch ($1->falselist, $8);
			backpatch (l, nextinstr());
		} 	;

assignment_expression	
	: conditional_expression
		{
			$$ = $1;
		} 
	| unary_expression assignment_operator assignment_expression
		{
			switch ($1->cat) {
				case ARR:
					$3->symp = conv($3->symp, $1->type->cat);
					emit(ARRL, $1->symp->name, $1->loc->name, $3->symp->name);	
					break;
				case PTR:
					emit(PTRL, $1->symp->name, $3->symp->name);	
					break;
				default:
					$3->symp = conv($3->symp, $1->symp->type->cat);
					emit(EQUAL, $1->symp->name, $3->symp->name);
					break;
			}
			$$ = $3;
		} 	;

assignment_operator	
	: ASSIGNMENT_OP
	| CMP_ASGN_MULTIPLY 
	| CMP_ASGN_DIVIDE 
	| CMP_ASGN_MODULO 
	| CMP_ASGN_PLUS 
	| CMP_ASGN_MINUS 
	| CMP_ASGN_LEFT_SHIFT 
	| CMP_ASGN_RIGHT_SHIFT 
	| CMP_ASGN_AND 
	| CMP_ASGN_XOR 
	| CMP_ASGN_OR 
	;

expression	
	: assignment_expression
		{
			$$ = $1;
		} 
	| expression COMMA assignment_expression
	{} 
	;

constant_expression	
	: conditional_expression 
	{}
	;


declaration 
	: declaration_specifiers SEMI_COLON
	{} 
	| declaration_specifiers init_declarator_list SEMI_COLON
	{} 
	;

declaration_specifiers 
	: storage_class_specifier 
	| storage_class_specifier declaration_specifiers 
	| type_specifier 
	| type_specifier declaration_specifiers 
	| type_qualifier 
	| type_qualifier declaration_specifiers 
	| function_specifier  
	| function_specifier declaration_specifiers
	{} 
	;

init_declarator_list 
	: init_declarator 
	| init_declarator_list COMMA init_declarator
	{} 
	;

init_declarator 
	: declarator
		{
			$$ = $1;
		} 
	| declarator ASSIGNMENT_OP initializer
		{
			if ($3->init!="") 
				$1->initialize($3->init);
			emit (EQUAL, $1->name, $3->name);
		} 
	;

storage_class_specifier 
	: EXTERN 
	| STATIC 
	| AUTO 
	| REGISTER
	{} 
	;

type_specifier 
	: VOID_K
		{
			TYPE = VOID;
		} 
	| DT_CHAR
		{
			TYPE = CHAR;
		} 
	| DT_SHORT 
	| DT_INT
		{
			TYPE = INT;
		} 
	| DT_LONG 
	| DT_FLOAT 
	| DT_DOUBLE
		{
			TYPE = DOUBLE;
		} 
	| SIGNED 
	| UNSIGNED 
	| DT_BOOL 
	| DT_COMPLEX 
	| DT_IMAGINARY 
	| enum_specifier
	{} 
	;

specifier_qualifier_list 
	: type_specifier specifier_qualifier_list 
	| type_specifier 
	| type_qualifier specifier_qualifier_list 
	| type_qualifier
	{} 
	;


enum_specifier 
	: ENUM C_BRACKET_OPEN enumerator_list C_BRACKET_CLOSE 
	| ENUM IDENTIFIER C_BRACKET_OPEN enumerator_list C_BRACKET_CLOSE 
	| ENUM C_BRACKET_OPEN enumerator_list COMMA C_BRACKET_CLOSE 
	| ENUM IDENTIFIER C_BRACKET_OPEN enumerator_list COMMA C_BRACKET_CLOSE 
	| ENUM IDENTIFIER
	{} 
	;

enumerator_list 
	: enumerator 
	| enumerator_list COMMA enumerator
	{} 
	;

enumerator 
	: IDENTIFIER 
	| IDENTIFIER ASSIGNMENT_OP constant_expression 
	;

type_qualifier 
	: CONST 
	| VOLATILE 
	| RESTRICT 
	;

function_specifier 
	: INLINE 
	;

declarator 
	: 
	pointer direct_declarator
		{
			symType * t = $1;
			while (t->ptr)
				t = t->ptr;
			t->ptr = $2->type;
			$$ = $2->update($1);
		} 
	| direct_declarator 
	;

direct_declarator 
	: IDENTIFIER
		{
			$$ = $1->update(TYPE);
			currsym = $$;
		} 
	| ROUND_BRACKET_OPEN declarator ROUND_BRACKET_CLOSE
		{
			$$ = $2;
		} 
	| direct_declarator SQ_BRACKET_OPEN type_qualifier_list assignment_expression SQ_BRACKET_CLOSE
	| direct_declarator SQ_BRACKET_OPEN type_qualifier_list SQ_BRACKET_CLOSE
	| direct_declarator SQ_BRACKET_OPEN assignment_expression SQ_BRACKET_CLOSE
	{
				symType* t = $1 -> type;
				symType* prev = NULL;
				while (t->cat == ARR) {
					prev = t;
					t = t->ptr;
				}
				if (prev==NULL) {
					int x = atoi($3->symp->init.c_str());
					symType* s = new symType(ARR, $1->type, x);
					int y = sizeOfType(s);
					$$ = $1->update(s);
				}
				else {
					prev->ptr =  new symType(ARR, t, atoi($3->symp->init.c_str()));
					$$ = $1->update ($1->type);
				}
	}
	| direct_declarator SQ_BRACKET_OPEN SQ_BRACKET_CLOSE
	{
				symType * t = $1 -> type;
				symType * prev = NULL;
				while (t->cat == ARR) {
					prev = t;
					t = t->ptr;
				}
				if (prev==NULL) {
					symType* s = new symType(ARR, $1->type, 0);
					int y = sizeOfType(s);
					$$ = $1->update(s);
				}
				else {
					prev->ptr =  new symType(ARR, t, 0);
					$$ = $1->update ($1->type);
				}
	}
	| direct_declarator SQ_BRACKET_OPEN STATIC type_qualifier_list assignment_expression SQ_BRACKET_CLOSE 
	| direct_declarator SQ_BRACKET_OPEN STATIC assignment_expression SQ_BRACKET_CLOSE 
	| direct_declarator SQ_BRACKET_OPEN type_qualifier_list MULTIPLY SQ_BRACKET_CLOSE
	| direct_declarator SQ_BRACKET_OPEN MULTIPLY SQ_BRACKET_CLOSE
	| direct_declarator ROUND_BRACKET_OPEN CST parameter_type_list ROUND_BRACKET_CLOSE 
	{
		table->tname = $1->name;

		if ($1->type->cat !=VOID) {
			sym *s = table->lookup("retVal");
			s->update($1->type);		
		}

		$1 = $1->linkst(table);

		table->parent = gTable;
		changeTable (gTable);				// Come back to global symbol table
	
		currsym = $$;
	}
	| direct_declarator ROUND_BRACKET_OPEN identifier_list ROUND_BRACKET_CLOSE 
	| direct_declarator ROUND_BRACKET_OPEN CST ROUND_BRACKET_CLOSE 
	{
				table->tname = $1->name;			// Update function symbol table name

				if ($1->type->cat !=VOID) {
					sym *s = table->lookup("retVal");// Update type of return value
					s->update($1->type);
				}
				
				$1 = $1->linkst(table);		// Update type of function in global table
			
				table->parent = gTable;
				changeTable (gTable);			// to Come back to global symbol table
			
				currsym = $$;
			}
	;

CST : %empty // Used to change to symbol table for a function
		{
			if (currsym->nest)
				{
					changeTable (currsym ->nest);				// Function symbol table already exists
					emit (LABEL, table->tname);
				}
			else {
				changeTable(new symtab(""));	// Function symbol table does not already exist
			}
		}
	;

pointer 
	: MULTIPLY
		{
			$$ = new symType(PTR);
		} 
	| MULTIPLY type_qualifier_list
	{} 
	| MULTIPLY pointer
		{
			$$ = new symType(PTR, $2);
		} 
	| MULTIPLY type_qualifier_list pointer
	{} 
	;

type_qualifier_list 
	: type_qualifier 
	| type_qualifier_list type_qualifier 
	;

parameter_type_list 
	: parameter_list 
	| parameter_list COMMA THREE_DOTS 
	;

parameter_list
	: parameter_declaration 
	| parameter_list COMMA parameter_declaration 
	;

parameter_declaration
	: declaration_specifiers declarator
		{
			$2->category = "param";
		} 
	| declaration_specifiers 
	;

identifier_list
	: IDENTIFIER 
	| identifier_list COMMA IDENTIFIER 
	;

type_name
	: specifier_qualifier_list 
	;

initializer
	: assignment_expression
		{
			$$ = $1->symp;
		} 
	| C_BRACKET_OPEN initializer_list C_BRACKET_CLOSE
	{} 
	| C_BRACKET_OPEN initializer_list COMMA C_BRACKET_CLOSE
	{}
	;

initializer_list
	: initializer 
	| designation initializer 
	| initializer_list COMMA initializer 
	|  initializer_list COMMA designation initializer 
	;

designation
	: designator_list ASSIGNMENT_OP 
	;

designator_list
	: designator 
	| designator_list designator 
	;

designator
	: SQ_BRACKET_OPEN constant_expression SQ_BRACKET_CLOSE 
	| DOT IDENTIFIER 
	;

statement
	: labeled_statement 
	| compound_statement
		{
			$$ = $1;
		} 
	| expression_statement
		{
			$$ = new statement();
			$$->nextlist = $1->nextlist;
		} 
	| selection_statement
		{
			$$ = $1;
		} 
	| iteration_statement
		{
			$$ = $1;
		} 
	| jump_statement
		{
			$$ = $1;
		} 
	;

labeled_statement
	: IDENTIFIER COLON statement
		{
			$$ = new statement();
		} 
	| CASE_KEYWORD constant_expression COLON statement
		{
			$$ = new statement();
		} 
	| DEFAULT COLON statement
		{
			$$ = new statement();
		} 
	;

compound_statement
	: C_BRACKET_OPEN C_BRACKET_CLOSE
	{	$$ = new statement();} 
	| C_BRACKET_OPEN block_item_list C_BRACKET_CLOSE
	{	$$ = $2; } 
	;

block_item_list
	: block_item
	{$$ = $1;	} 
	| block_item_list M block_item
		{
			$$ = $3;
	backpatch ($1->nextlist, $2);
		} 
	;

block_item
	: declaration
	{$$ = new statement();} 
	| statement
	{$$ = $1;} 
	;

expression_statement 
	: SEMI_COLON
	{$$ = new expr();} 
	| expression SEMI_COLON
	{$$ = $1;} 
	;

selection_statement
	: IF_KEYWORD ROUND_BRACKET_OPEN expression N ROUND_BRACKET_CLOSE M statement N 
		{
			backpatch ($4->nextlist, nextinstr());
			conv2bool($3);
			$$ = new statement();
			backpatch ($3->truelist, $6);
			list<int> temp = merge ($3->falselist, $7->nextlist);
			$$->nextlist = merge ($8->nextlist, temp);
		} 
	| IF_KEYWORD ROUND_BRACKET_OPEN expression N ROUND_BRACKET_CLOSE M statement N ELSE_KEYWORD M statement
		{
			backpatch ($4->nextlist, nextinstr());
			conv2bool($3);
			backpatch ($3->truelist, $6);
			backpatch ($3->falselist, $10);
			list<int> temp = merge ($7->nextlist, $8->nextlist);
			$$->nextlist = merge (temp, $11->nextlist);
		} 
	| SWITCH ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE statement 
	{

	}
	;

iteration_statement
	: WHILE_KEYWORD M ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE M statement
		{
			$$ = new statement();
			conv2bool($4);
			
			// M1 to go back to boolean again
			// M2 to go to statement if the boolean is true
			backpatch($7->nextlist, $2);
			backpatch($4->truelist, $6);
			$$->nextlist = $4->falselist;
			
			// Emit to prevent fallthrough
			emit (GOTO, tostr($2));
		} 
	| DO_KEYWORD M statement M WHILE_KEYWORD ROUND_BRACKET_OPEN expression ROUND_BRACKET_CLOSE SEMI_COLON
		{
			$$ = new statement();
			conv2bool($7);
			// M1 to go back to statement if expression is true
			// M2 to go to check expression if statement is complete
			backpatch ($7->truelist, $2);
			backpatch ($3->nextlist, $4);

			// Some bug in the next statement
			$$->nextlist = $7->falselist;
		} 
	| FOR_KEYWORD ROUND_BRACKET_OPEN expression_statement M expression_statement ROUND_BRACKET_CLOSE M statement
		{
				$$ = new statement();
				conv2bool($5);
				backpatch ($5->truelist, $7);
				backpatch ($8->nextlist, $4);
				
				emit (GOTO, tostr($4));
				$$->nextlist = $5->falselist;
		} 
	| FOR_KEYWORD ROUND_BRACKET_OPEN expression_statement M expression_statement M expression N ROUND_BRACKET_CLOSE M statement
		{
				$$ = new statement();
				conv2bool($5);
				backpatch ($5->truelist, $10);
				backpatch ($8->nextlist, $4);
				backpatch ($11->nextlist, $6);
				
				emit (GOTO, tostr($6));
				$$->nextlist = $5->falselist;
		}	;

jump_statement 
	: GOTO_K IDENTIFIER SEMI_COLON
	{$$ = new statement();} 
	| CONTINUE_LOOP SEMI_COLON
	{$$ = new statement();} 
	| BREAK_LOOP SEMI_COLON
	{$$ = new statement();} 
	| RETURN_VAL SEMI_COLON
		{
			$$ = new statement();
			emit(RETURN,"");
		} 
	| RETURN_VAL expression SEMI_COLON
	{$$ = new statement();} 
	;


translation_unit
	: external_declaration 
	| translation_unit external_declaration 
	| SINGLE_LINE_COMMENT
	| MULTI_LINE_COMMENT
	;


external_declaration
	: function_definition 
	| declaration 
	;

function_definition 
	: declaration_specifiers declarator declaration_list CST compound_statement 
	| declaration_specifiers declarator CST compound_statement
		{
			table->parent = gTable;
			changeTable (gTable);
		} 
	| declarator declaration_list compound_statement 
	{}
	| declarator compound_statement 
	{}
	;

declaration_list 
	: declaration 
	{}
	| declaration_list declaration
	{} 	;

%%

void yyerror(char *s) {
	printf ("ERROR IS : %s",s);
}
