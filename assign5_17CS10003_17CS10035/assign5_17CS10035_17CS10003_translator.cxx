
#include "assign5_17CS10035_17CS10003_translator.h"


// Global variables
symtab* gTable;					// ptr to gtable
symtab* table;					// ptr to current table
quads qarr;						
etype TYPE;					// Store type specifier
sym* currsym; 					// ptr to latest function entry

// GlobalST Design Pattern 
GlobalST* GlobalST::pGlobalST= NULL;	// ptr to GST
GlobalST::GlobalST() {;}	
GlobalST* GlobalST::getInstance() {	// create instance of GST
	if (pGlobalST!= NULL) {	
		return pGlobalST;
	}
	else
	{
		pGlobalST = new GlobalST();
		return pGlobalST;
	}
	
}
symType::symType(etype cat, symType* ptr, int width): 
	cat (cat), 
	ptr (ptr), 
	width (width) {};
sym* symtab::lookup (string n) {
	sym* s;		
	list <sym>::iterator it = table.begin();
	while(it!=table.end()){
		if (it->name == n ) break;
		it++;
	}
	if(it==table.end())
	{
		s =  new sym (n);
		s->category = "local";
		table.push_back (*s);
		return &table.back();
	}
	else{
		return &*it;
	}
	
	
}
sym* gentemp (etype t, string init) {
	char n[20];
	bool ret = true;
	sprintf(n, "t%02d", table->tcount++);	
	sym* se = new sym (n, t);
	se->category = "temp";
	se-> init = init;

 	table->table.push_back ( *se);
	if (ret)	
		return &table->table.back();
}
sym* gentemp (symType* t, string init) {
	char n[20];
	sprintf(n, "t%02d", table->tcount++);	
	sym* se = new sym (n);
	se->type = t;
	se->category = "temp";
	se-> init = init;
	table->table.push_back ( *se);
	return &table->table.back();
}
symtab::symtab (string name): tname (name), tcount(0) {;}

void symtab::print(int all) {
	list<symtab*> tablelist;
	cout << setw(100) << setfill ('*') << "*"<< endl;
	cout << "Symbol Table:- " << setfill (' ') << left << setw(40)  << this -> tname ;
	cout << right << setw(20) << "Parent:- ";
	if (this->parent==NULL)
		cout << "null" ;
	else 
		cout << this -> parent->tname;

	cout << endl;
	cout << setw(100) << setfill ('=') << "="<< endl;
	cout << setfill (' ') << left << setw(16) << "Name";	//heading name
	cout << left << setw(16) << "Type";
	cout << left << setw(12) << "Category";
	cout << left << setw(12) << "Init Val";				//initial value
	cout << left << setw(8) << "Size";
	cout << left << setw(8) << "Offset";			// offset
	cout << left << "Nested table" << endl;
	cout << setw(100) << setfill ('-') << "-"<< setfill (' ') << endl;
	
	list <sym>::iterator it = table.begin();

	while ( it!=table.end()) {
		cout << &*it;
		if (it->nest==NULL)
		{

		} 
		else
		{
			tablelist.push_back (it->nest);
		}
		it++;
	}
	cout << setw(80) << setfill ('-') << "-"<< setfill (' ') << endl;
	cout << endl;
	if (all) {
		list<symtab*>::iterator iterator = tablelist.begin();
		while (iterator != tablelist.end()) {
		    (*iterator)->print();
		    iterator++;
		}		
	}
}
void symtab::computeOffsets() {		
	list<symtab*> tablelist;
	int off;
	list <sym>::iterator it = table.begin();
	while ( it!=table.end()) {
		if (it==table.begin()) {
			it->offset = 0;
			off = it->size;
		}
		else {
			it->offset = off;
			off = it->offset + it->size;
		}
		if (it->nest!=NULL) tablelist.push_back (it->nest);

		it++;
	}
	for (list<symtab*>::iterator iterator = tablelist.begin(); 
			iterator != tablelist.end(); 
			++iterator) {
	    (*iterator)->computeOffsets();
	}
}
sym* sym::linkst(symtab* t) {
	this->nest = t;
	this->category = "function";
}

int sizeOfType (symType* t)
{
		if(t->cat == VOID)
			return 0;
		else if(t->cat == CHAR)
			return char_size;
		else if(t->cat == INT)
			return int_size;
		else if(t->cat == DOUBLE)
			return double_size;
		else if(t->cat == PTR)
			return pointer_size;
		else if(t->cat == ARR)
			return t->width * sizeOfType(t->ptr);
		else if(t->cat == FUNC)
			return 0;
}
ostream& operator<<(ostream& os, const symType* t) {
	etype cat = t->cat;
	string stype = conv2string(t);
	os << stype;
	return os;
}
ostream& operator<<(ostream& os, const sym* it) {
	os << left << setw(16) << it->name;		// below respective headings
	os << left << setw(16) << it->type;
	os << left << setw(12) << it->category;
	os << left << setw(12) << it->init;			// below Initial values
	os << left << setw(8) << it->size;	
	os << left << setw(8) << it->offset;
	os << left;
	if (it->nest != NULL) {
		os << it->nest->tname <<  endl;			
	}
	else {
		os << "null" <<  endl;		
	}
}
quad::quad (string result, string arg1, optype op, string arg2):	//constructor
	result (result), arg1(arg1), arg2(arg2), op (op){;};

quad::quad (string result, int arg1, optype op, string arg2):		// constructor
	result (result), arg2(arg2), op (op) {
		this ->arg1 = number2string(arg1);		// conversion
	}
sym::sym (string name, etype t, symType* ptr, int width): name(name)  {
	type = new symType (symType(t, ptr, width));
	nest = NULL;
	init = "";
	category = "";
	offset = 0;
	size = sizeOfType(type);
}
sym* sym::initialize (string init) {
	this->init = init;
}
sym* sym::update(symType* t) {
	type = t;
	this -> size = sizeOfType(t);
	return this;
}
sym* sym::update(etype t) {
	this->type = new symType(t);
	this->size = sizeOfType(this->type);
	return this;
}
void quad::update (int addr) {	//backpatching address
	this ->result = addr;
}
void quad::print () {

		//Unary Operators
		if(op==ADDRESS) 	cout << result << " = &" << arg1;
		else if(op==PTRR) 			cout << result	<< " = *" << arg1 ;
		else if(op==PTRL) 			cout << "*" << result	<< " = " << arg1;
		else if(op==UMINUS) 		cout << result 	<< " = -" << arg1;
		else if(op==BNOT) 			cout << result 	<< " = ~" << arg1;
		else if(op==LNOT) 			cout << result 	<< " = !" << arg1;

		else if(op==ARRR) 	 		cout << result << " = " << arg1 << "[" << arg2 << "]";
		else if(op==ARRL) 	 		cout << result << "[" << arg1 << "]" <<" = " <<  arg2;

		//Relational Operations
		else if(op==EQOP) 			cout << "if " << arg1 <<  " == " << arg2 << " goto " << result;
		else if(op==NEOP) 			cout << "if " << arg1 <<  " != " << arg2 << " goto " << result;				
		else if(op==LT) 			cout << "if " << arg1 <<  " < "  << arg2 << " goto " << result;
		else if(op==GT) 			cout << "if " << arg1 <<  " > "  << arg2 << " goto " << result;
		else if(op==GE) 			cout << "if " << arg1 <<  " >= " << arg2 << " goto " << result;
		else if(op==LE) 			cout << "if " << arg1 <<  " <= " << arg2 << " goto " << result;		
		//Binary Operations

		else if(op==ADD)			cout << result << " = " << arg1 << " + " << arg2;
		else if(op==SUB)			cout << result << " = " << arg1 << " - " << arg2;
		else if(op == MULT)			cout << result << " = " << arg1 << " * " << arg2;
		else if(op == DIVIDE)		cout << result << " = " << arg1 << " / " << arg2;
		else if(op == MODOP)		cout << result << " = " << arg1 << " % " << arg2;
		else if(op == XOR)		cout << result << " = " << arg1 << " ^ " << arg2;
		else if(op == INOR)		cout << result << " = " << arg1 << " | " << arg2;
		else if(op == BAND)		cout << result << " = " << arg1 << " & " << arg2;
		//Shift Operations
		else if(op==LEFTOP) 		cout << result << " = " << arg1 << " << " << arg2;
		else if(op==RIGHTOP) 		cout << result << " = " << arg1 << " >" << "> " << arg2;
		else if(op==EQUAL) 			cout << result << " = " << arg1 ;		

		//for goto
		else if(op==GOTO) 		cout << "goto " << result;		

		// subroutine call operations
		else if(op==RETURN)  		cout << "ret " << result;
		else if(op==PARAM) 		cout << "param " << result;
		else if(op==CALL) 			cout << result << " = " << "call " << arg1<< ", " << arg2;
		else if(op==LABEL) 			cout << result << ": ";	
		else			cout << "op";			
	
	cout << endl;
}
void quads::printtab() {
	cout << "**** Quad Table ****" << endl;
	cout << setw(8) << "index";
	cout << setw(8) << " op";
	cout << setw(8) << "arg 1";
	cout << setw(8) << "arg 2";
	cout << setw(8) << "result" << endl;
	for (vector<quad>::iterator itr = array.begin(); itr!=array.end(); itr++) {
		cout << left << setw(8) << itr - array.begin(); 
		cout << left << setw(8) << op2str(itr->op);
		cout << left << setw(8) << itr->arg1;
		cout << left << setw(8) << itr->arg2;
		cout << left << setw(8) << itr->result << endl;
	}
}
void backpatch (list <int> l, int addr) {
	for (list<int>::iterator it= l.begin(); it!=l.end(); it++) qarr.array[*it].result = tostr(addr);
}
void quads::print () {
	cout << setw(20) << setfill ('*') << "*"<< endl;
	cout << "Quad Translation" << endl;
	cout << setw(20) << setfill ('=') << "="<< setfill (' ') << endl;
	
	vector<quad>::iterator itr = array.begin();

	while ( itr!=array.end()) {
		if (itr->op == LABEL) {
			cout << "\n";
			itr->print();
			cout << "\n";
		}
		else {
			cout << "\t" << setw(4) << itr - array.begin() << ":\t";
			itr->print();
		}
		itr++;
	}
	cout << setw(20) << setfill ('-') << "-"<< endl;	// finishing line
}

// emit functions
void emit(optype op, string result, string arg1, string arg2) {
	qarr.array.push_back(*(new quad(result,arg1,op,arg2)));
}
void emit(optype op, string result, int arg1, string arg2) {
	qarr.array.push_back(*(new quad(result,arg1,op,arg2)));
}

string conv2string (const symType* t){
	if (t==NULL) 
		return "null";

	if(t->cat == VOID)
	{
		return "void";
	}
	else if(t->cat == CHAR)
	{
		return "char";
	}
	else if(t->cat ==INT)
	{
		return "int";
	}
	else if(t->cat ==DOUBLE)
	{
		return "double";
	}
	else if(t->cat ==PTR)
	{
		return "ptr("+ conv2string(t->ptr)+")";
	}
	else if(t->cat == ARR)
	{
		return "arr(" + tostr(t->width) + ", "+ conv2string (t->ptr) + ")";
	}
	else if(t->cat == FUNC)
	{
		return "funct";
	}
	else
	{
		return "type";
	}
	
}

string op2str (int op) {
	switch(op) {
		// alu
		case ADD:				return " + ";
		case SUB:				return " - ";
		case MULT:				return " * ";
		case DIVIDE:			return " / ";
		// relational
		case EQUAL:				return " = ";
		case EQOP:				return " == ";
		case NEOP:				return " != ";
		case LT:				return " < ";
		case GT:				return " > ";
		case GE:				return " >= ";
		case LE:				return " <= ";
		
		case GOTO:			return " goto ";
		
		//Unary Operators
		case ADDRESS:			return " &";
		case PTRR:				return " *R";
		case PTRL:				return " *L";
		case UMINUS:			return " -";
		case BNOT:				return " ~";
		case LNOT:				return " !";
		// array
		case ARRR:	 			return " =[]R";
		// subroutine call
		case RETURN: 			return " ret";
		case PARAM: 			return " param ";
		case CALL: 				return " call ";
		default:				return " op ";
	}
}
list<int> makelist (int i) {
	list<int> l(1,i);
	return l;
}
list<int> merge (list<int> &a, list <int> &b) {
	a.merge(b);
	return a;
}
int nextinstr() {
	return qarr.array.size();
}
string number2string ( int Number ) {
	ostringstream ss;
	ss << Number;
	return ss.str();
}
expr* conv2bool (expr* ex) {	// Convert any expr to bool
	if (!ex->isbool) {
		ex->falselist = makelist (nextinstr());
		emit (EQOP, "", ex->symp->name, "0");
		ex->truelist = makelist (nextinstr());
		emit (GOTO, "");
	}
}
expr* convfrombool (expr* ex) {	// Convert any expr to bool
	if (ex->isbool) {
		ex->symp = gentemp(INT);
		backpatch (ex->truelist, nextinstr());
		emit (EQUAL, ex->symp->name, "true");
		emit (GOTO, tostr (nextinstr()+1));
		backpatch (ex->falselist, nextinstr());
		emit (EQUAL, ex->symp->name, "false");
	}
}
bool typecheck(sym*& s1, sym*& s2){ 	
	symType* type1 = s1->type;
	symType* type2 = s2->type;
	if ( typecheck (type1, type2) ) return true;
	else if (s1 = conv (s1, type2->cat) ) return true;
	else if (s2 = conv (s2, type1->cat) ) return true;
	return false;
}
bool typecheck(symType* t1, symType* t2){
	if (t1 != NULL || t2 != NULL) {
		if (t1==NULL) return false;
		if (t2==NULL) return false;
		if (t1->cat==t2->cat) return typecheck(t1->ptr, t2->ptr);
		else return false;
	}
	return true;
}

sym* conv (sym* s, etype t) {
	sym* temp = gentemp(t);
	switch (s->type->cat) {
		case INT: {
			switch (t) {
				case DOUBLE: {
					emit (EQUAL, temp->name, "int2double(" + s->name + ")");
					return temp;
				}
				case CHAR: {
					emit (EQUAL, temp->name, "int2char(" + s->name + ")");
					return temp;
				}
			}
			return s;
		}
		case DOUBLE: {
			switch (t) {
				case INT: {
					emit (EQUAL, temp->name, "double2int(" + s->name + ")");
					return temp;
				}
				case CHAR: {
					emit (EQUAL, temp->name, "double2char(" + s->name + ")");
					return temp;
				}
			}
			return s;
		}
		case CHAR: {
			switch (t) {
				case INT: {
					emit (EQUAL, temp->name, "char2int(" + s->name + ")");
					return temp;
				}
				case DOUBLE: {
					emit (EQUAL, temp->name, "char2double(" + s->name + ")");
					return temp;
				}
			}
			return s;
		}
	}
	return s;
}
void changeTable (symtab* newtable) {	// modify the current symbol table
	table = newtable;
} 


int  main (int argc, char* argv[]){
	gTable = new symtab("Global");
	table = gTable;
	yyparse();
	table->computeOffsets();
	table->print(1);
	qarr.print();
	int n, x;
	cin >> n;
	if (n==10) {
		while (n--) {
			cin >> x;
			if(x==2) {
				emit(ADD, "a", "b", "c");
			}
			else if (x==1) {
					gentemp(DOUBLE);
			}
		}	
	}

};
