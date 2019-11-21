a.out: lex.yy.o y.tab.o assign5_17CS10035_17CS10003_translator.o
	g++ lex.yy.o y.tab.o assign5_17CS10035_17CS10003_translator.o -lfl

assign5_17CS10035_17CS10003_translator.o: assign5_17CS10035_17CS10003_translator.cxx assign5_17CS10035_17CS10003_translator.h
	g++ -c assign5_17CS10035_17CS10003_translator.h
	g++ -c assign5_17CS10035_17CS10003_translator.cxx

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: assign5_17CS10035_17CS10003.l y.tab.h assign5_17CS10035_17CS10003_translator.h
	flex assign5_17CS10035_17CS10003.l

y.tab.c: assign5_17CS10035_17CS10003.y
	yacc -dtv assign5_17CS10035_17CS10003.y -W

y.tab.h: assign5_17CS10035_17CS10003.y
	yacc -dtv assign5_17CS10035_17CS10003.y -W

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o assign5_17CS10035_17CS10003_translator.o y.output a.out assign5_17CS10035_17CS10003_translator.h.gch

test: 
	./a.out < assign5_17CS10035_17CS10003_test1.c > assign5_17CS10035_17CS10003_quads1.out
	./a.out < assign5_17CS10035_17CS10003_test2.c > assign5_17CS10035_17CS10003_quads2.out
	./a.out < assign5_17CS10035_17CS10003_test3.c > assign5_17CS10035_17CS10003_quads3.out
	./a.out < assign5_17CS10035_17CS10003_test4.c > assign5_17CS10035_17CS10003_quads4.out
