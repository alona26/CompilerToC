%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #include "lex.yy.c"

    void yyerror (char *s);
    int yylex();

    void push_int(char* name);
    void push_arr(char* name);
    int lookUpIntSymb(char* name);
    int lookUpArrSymb(char* name);
    extern FILE* yyout;
    int flag_digit = 0;
    char stInt [200][23];
    char stArr[200][23];
    int topArr=0;
    int topInt=0;
    char * temp_name_array;
    int flag_declarator = 1;
    int flag_arr = 0;
%}
/* Yacc definitions */
%union {
	char expression[1000];
	char eq[1];
    char opr[1];
    char relOp[2];
    int num;
} 
%token <opr> PLUS_AND_MINUS
%token <opr> MULTI_DEV
%token <expression> NUM 
%token <expression> INT
%token <expression> ARR 
%token <expression> INDEXING
%token <expression> IDN
%token <relOp> LOGICAL
%token DOT_PROD OPEN CLOSE OPEN_SQUER CLOSE_SQUER ASSIGN begin_t end_t if_t then_t while_t do_t SEMICOL COMMA_KEY PRINT
%start program

%type <opr> ops  
%type <expression> condition type identifier variable expression expressionList 

%right OPEN CLOSE
%left ASSIGN 
%left DOT_PROD
%left MULTI_DEV
%left PLUS_AND_MINUS
%left OPEN_SQUER CLOSE_SQUER
%left COMMA_KEY
%left INDEXING
 
%%

program : block 
;
block :  begin_t {fprintf(yyout,"{\n");} statementList end_t {fprintf(yyout,"}\n");} 
;
statementList : statement statementList {flag_arr=0;}
|{}
;
statement : declarator  SEMICOL {flag_declarator = 1;}
| assignment SEMICOL            
| ifStatement                   
| loop                          
| print  SEMICOL                
;

declarator : type expressionList { 
    if(strcmp($1,"arr") == 0)
    {
        char * token_arr_name = strtok($2, ",");
        while( token_arr_name ) {
        if (lookUpArrSymb(token_arr_name) !=-1 || lookUpIntSymb(token_arr_name) !=-1){
                fprintf(stderr,"%s already declered !",token_arr_name);
        }
        fprintf(yyout,"\nint size_%s = 0;",token_arr_name);
        fprintf(yyout,"\nint* %s;",token_arr_name);
        push_arr(token_arr_name);
        token_arr_name = strtok(NULL, ", ");

        }
        flag_declarator = 0;
    }
    else{
    fprintf(yyout,"%s %s;",$1,$2);
        char * token = strtok($2,",");
            while( token != NULL ) {
            if (lookUpArrSymb(token) !=-1 || lookUpIntSymb(token) !=-1){
            fprintf(stderr,"%s already declered !",token);
            }
            push_int(token);
            token = strtok(NULL,", ");
        }
        flag_declarator = 0;
    }
}
;
assignment : variable ASSIGN expressionList  { 
    if (strchr($1,'[') == NULL){  // not fib[?]
        if((lookUpArrSymb($1) != -1)){ // $1 is array
            if(lookUpArrSymb($3) != -1 && flag_arr == 0) {// $3 is array
                fprintf(yyout, "\nif(size_%s != size_%s){",$1,$3);
                fprintf(yyout, "\nsize_%s = size_%s;",$1,$3); // size_$1 = size_$3;
                fprintf(yyout,"\nfree(%s);\n %s = (int *) malloc( (size_%s) * sizeof(int));\n",$1,$3);
                fprintf(yyout,"for(int i=0; i<size_%s; i++ )\n\t\t %s[i]= %s[i]; \n}\n",$3,stArr[lookUpArrSymb($1)],stArr[lookUpArrSymb($3)]);
            
                fprintf(yyout,"for(int i=0; i<size_%s; i++ )\n\t\t %s[i]= %s[i]; \n",$3,stArr[lookUpArrSymb($1)],stArr[lookUpArrSymb($3)]);
                }
            else if (flag_squre){ //array like : {1,1,1...}
                flag_squre=0;
                char * temp = strtok($3, "}");
                char * token_comma = strtok(temp+1, ",");
                
                fprintf(yyout,"\nif(size_%s != 0){\nfree(%s);\n}",$1,$1); 
                fprintf(yyout, "\nsize_%s = %d;",$1,count_comma+1);
                fprintf(yyout,"\n %s = (int *) malloc( (%d) * sizeof(int));\n",$1,count_comma+1);
                int i = 0;
                while( token_comma ) {
                fprintf( yyout,"\n%s[%d]= %s;\n", $1,i,token_comma ); //printing each token
                token_comma = strtok(NULL, ",");
                i+=1;
                }

            }
            else if(flag_arr){
                fprintf(yyout, "\nif(size_%s <= result_size){",$1); // size = 1;
                fprintf(yyout,"\n %s = (int *) realloc(%s, (result_size) * sizeof(int));\n size_%s = result_size; \n}\n",$1,$1,$1);
                fprintf(yyout,"for(int i=0;i<result_size;i++){");
                fprintf(yyout, "\n%s[i] = result[i];",$1);
                fprintf(yyout,"\n}\n");

            }
            else { // $3 = number
                fprintf(yyout, "\nif(size_%s > 1){\n",$1);
                fprintf(yyout, "\nsize_%s = 1;",$1); // size = 1;
                fprintf(yyout,"\n%s[0]= %s;",stArr[lookUpArrSymb($1)],$3);
                fprintf(yyout,"\n%s[1]= '\\0'; \n}\n",stArr[lookUpArrSymb($1)]);
                fprintf(yyout, "\nelse{\n");
                fprintf(yyout,"%s = (int *) malloc( (1) * sizeof(int));",$1,$1);
                fprintf(yyout,"\n%s[0]= %s; \n}\n",stArr[lookUpArrSymb($1)],$3);
            }
        }
    }
    else if (strchr($1,'[') != NULL){

            char* temp_name = strdup($1);
            char * temp1 = strtok(temp_name, "[");
            char* temp2 = strtok(NULL, "]");
            if (count_comma > 1 ) 
            {
                fprintf(stderr,"can't do %s = %s\n",temp1, $3);
            }
            else{
                fprintf(yyout,"\nif (size_%s == 0){ \n %s = (int *) malloc((%s+1) * sizeof(int));\n size_%s += 1; \n}\n",temp1,temp1,temp2,temp1);

                fprintf(yyout,"\nif (%s > size_%s - 1){ \n %s = (int *) realloc(%s, (1) * sizeof(int));\n size_%s += 1; \n}\n",temp2,temp1,temp1,temp1,temp1);
                fprintf(yyout,"\n%s = %s; \n",$1,$3);
            }
    }
    if(lookUpIntSymb($1) != -1){
        if (count_comma > 1 ) 
            {
                fprintf(stderr,"can't do %s = %s \n",$1, $3);
            }

        else {
        fprintf(yyout,"%s = %s;\n",$1,$3);
        }
    }

}
;
ifStatement : if_t  condition then_t {fprintf(yyout,"if %s", $2) ; } block 
;
loop : while_t condition do_t {fprintf(yyout,"while %s", $2) ; } block 
;

print : PRINT  expressionList {
fprintf(yyout,"printf(\"");
fprintf(yyout,"%%d");
for(int i=1;i<count;i++)
{
    fprintf(yyout,", %%d ");    
    }
    fprintf(yyout,"\\n\",%s);\n", $2);
    }
;
expressionList : expression expressionList {sprintf($$,"%s %s",$1,$2); }
                
| {strcpy($$,"");}
  ;
variable : identifier   
| INDEXING expression {sprintf($$,"%s[%s]",$1,$2);
}
| OPEN_SQUER expressionList CLOSE_SQUER  {if (dot_prod_flag){sprintf($$, "{%s},%d)",$2,count_comma+1);dot_prod_flag = 0;} 
else if(ops_flag){sprintf($$, "{%s},%d",$2,count_comma+1); ops_flag = 0;} else {sprintf($$, "{%s}",$2);} }
;

expression : variable  {
    if (!flag_declarator){
        flag_digit = 0;
            for(int i=0; i< strlen($1);i++){
            
                if(!isdigit($1[i]) && ($1[i]!='-')){
                    flag_digit = 1;
                    break;
                    }
            }
        if (strchr($1,'[') != NULL){  // not fib[?] {
        char* temp_nam = strdup($1);
        char * temppp = strtok(temp_nam, "[");
        if (lookUpArrSymb(temppp) == -1)
            fprintf(stderr,"\n ---%s does not declared---\n",$1);
            
        }
            
        if( strchr($1,'[') == NULL && (lookUpArrSymb($1) == -1) && (lookUpIntSymb($1) == -1)&& (flag_digit == 1)){ 
            
            fprintf(stderr,"\n ---%s does not declared---\n",$1);
        }
        else { 
            sprintf($$,"%s",$1);
        }
    }
}
| variable  expression{
    sprintf($$,"%s%s",$1,$2);
    }
|OPEN expression CLOSE {sprintf($$,"(%s)",$2)}
| expression DOT_PROD expression{ count_comma = 1;
    if(lookUpArrSymb($3) == -1 && lookUpArrSymb($1) != -1){
    sprintf($$,"dot_product(%s,size_%s,(int [])%s",$1,$1,$3);
    }
    if(lookUpArrSymb($1) == -1 && lookUpArrSymb($3) != -1){
    sprintf($$,"dot_product((int [])%s,%s,size_%s)",$1,$3,$3);
    }
    if(lookUpArrSymb($1) == -1 && lookUpArrSymb($3) == -1){
    sprintf($$,"dot_product((int [])%s,(int [])%s",$1,$3);
    }
    if(lookUpArrSymb($1) != -1 && lookUpArrSymb($3) != -1){
    sprintf($$,"dot_product(%s,size_%s,%s,size_%s)",$1,$1,$3,$3);
    }
}
|expression ops expression{ flag_arr =1;
    if( (lookUpArrSymb($1) != -1)  && lookUpArrSymb($3) != -1 && strchr($3,'[') == NULL && strchr($1,'[') == NULL){
            fprintf(yyout, "\nops_function(%s,size_%s,%s,size_%s,'%s');",$1,$1,$3,$3,$2);
        }
    if( (lookUpArrSymb($1) != -1)  && count_comma && strchr($1,'[') == NULL){
            fprintf(yyout, "\nops_function(%s,size_%s,(int [])%s,%d,'%s');",$1,$1,$3,count_comma+1,$2);
        } 
    if( count_comma  && lookUpArrSymb($3) != -1 && strchr($3,'[') == NULL){

        fprintf(yyout, "\nops_function((int [])%s,%d,%s,size_%s,'%s');",$1,count_comma,$3,$3,$2);
    } 
    if( (lookUpArrSymb($1) == -1)  && lookUpArrSymb($3) == -1  && strchr($1,'{') != NULL && strchr($3,'{') != NULL && (strchr($2,'+') != NULL || strchr($2,'-') != NULL || strchr($2,'*') != NULL|| strchr($2,'/') != NULL)){
        fprintf(yyout, "\nops_function((int [])%s,(int [])%s,'%s');",$1,$3,$2);
    } 
          else {
        sprintf($$,"%s %s %s",$1,$2,$3);
    }

}
| expression COMMA_KEY expression { ++count; ++count_comma; sprintf($$,"%s , %s",$1,$3);}

;

condition : OPEN expression LOGICAL expression CLOSE{ sprintf($$,"(%s %s %s)", $2,$3,$4); }
  ;

ops : MULTI_DEV 
|PLUS_AND_MINUS 
;

identifier : IDN 
| NUM
;
type : INT 
| ARR 
  ;
  
%%


int main (int argc, char** argv) {
    /* #ifdef YYDEBUG */
	/* yydebug = 1; */
	/* #endif */
	yyin = fopen("test.txt", "r");
	if(yyin == NULL) {
		fprintf(stderr,"Could not open source code from '%s'\n", argv[1]);
		return 1;
	}

	yyout = fopen("output.c", "w");
	if(yyout == NULL) {
		fprintf(stderr,"Could not open destination file '%s'\n", argv[1]);
		return 1;
	}

	fprintf(yyout, "#include <stdio.h>\n");
	fprintf(yyout, "#include <stdlib.h>\n\n");

    fprintf(yyout, "\nstatic int* result;");
    fprintf(yyout, "\nstatic int result_size;");

    fprintf(yyout, "\n\n int dot_product(int* v,int n1, int* u, int n2){ \n");
    fprintf(yyout, "\tint i; \n");
    fprintf(yyout, "\tint n=0; \n");

    fprintf(yyout, "\tint resultt = 0; \n");
    fprintf(yyout, "\tif (n1<n2){\n\t n = n1;\n\t}\n\telse {\n\tn = n2;\n\t}\n");

    fprintf(yyout, "\tfor (i = 0; i < n; i++) {\n");
    fprintf(yyout, "\t\t resultt += v[i]*u[i]; \n\t}\n");
    fprintf(yyout, "\treturn resultt;\n}\n");


    fprintf(yyout, "\n\nvoid ops_function(int *v, int size_v, int *u, int size_u, char c){ \n");
    fprintf(yyout, "\nresult_size = size_v;");
    fprintf(yyout,"\nresult = (int *) malloc( (result_size) * sizeof(int));\n");
    fprintf(yyout,"\nfor(int i=0;i<result_size;i++){");
    
    fprintf(yyout, "\n\tif (c == '+'){\n");
    fprintf(yyout, "\nif(i > size_u){");
    fprintf(yyout, "\nresult[i] = v[i] + 0;");
    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\telse{\n");
    fprintf(yyout, "\nresult[i] = v[i] + u[i];");
    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\n}\n");


    
    fprintf(yyout, "\tif (c == '-'){\n");
    fprintf(yyout, "\nif(i > size_u){");
    fprintf(yyout, "\nresult[i] = v[i] - 0;");
    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\telse{\n");
    fprintf(yyout, "\nresult[i] = v[i] - u[i];");
    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\n}\n");



    fprintf(yyout, "\tif (c == '*'){\n");
    fprintf(yyout, "\nif(i > size_u){");
    fprintf(yyout, "\nresult[i] = v[i] * 0;");
    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\telse{\n");
    fprintf(yyout, "\nresult[i] = v[i] * u[i];");
    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\n}\n");

    fprintf(yyout, "\tif (c == '/'){\n");

    fprintf(yyout, "\nif(i > size_u){");
    fprintf(yyout,"\t\tfprintf(stderr,\" ---Cannot be divided by 0---\\n\");\n");
    fprintf(yyout, "\n}\n");

    fprintf(yyout, "\t\tif (u[i] == 0){\n");
     fprintf(yyout,"\t\tfprintf(stderr,\" ---Cannot be divided by 0---\\n\");\n");
    fprintf(yyout, "\n}\n");

    fprintf(yyout,"\t\telse{\n\t\t result[i] = v[i] / u[i]; \n\t\t}\n");
    fprintf(yyout, "\n}\n");

    fprintf(yyout, "\n}\n");
    fprintf(yyout, "\n}\n");

	fprintf(yyout, "\n\nvoid main(void) \n");
	yyparse ( );
	
	return 0;
}

 void push_arr(char* name)
 {
  int n = topArr;
  strcpy(stArr[topArr++],name);

 }

int lookUpArrSymb(char* name) {
    for ( int i =0;i<topArr;i++) {
        if(strlen(name) + 1 == strlen(stArr[i])){
            if(strncmp(name, stArr[i], strlen(name)) == 0)
            return i;
        }  
        else if(strlen(name) + 1 > strlen(stArr[i])){
            if(strncmp(name, stArr[i], strlen(stArr[i])-1) == 0)
            return i;
        }
    } 
    return -1;
}
void push_int(char* name)
 {
  int n = topInt;
  strcpy(stInt[topInt++],name);
 }

int lookUpIntSymb(char* name) {
    for ( int i =0;i<topInt;i++) {
        if(strncmp(name, stInt[i], strlen(name))==0){
            return i;
        }
    } 
    return -1;
}
void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 