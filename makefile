project.exe: lex.yy.c yacc.tab.c 
	gcc yacc.tab.c -o yacc.exe 

lex.yy.c: yacc.tab.c compiler.lex 
	flex compiler.lex

yacc.tab.c: yacc.y
	bison -d yacc.y --debug

clean: 
	del lex.yy.c yacc.tab.c yacc.tab.h project.exe
