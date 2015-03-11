/* Phase2*/
/* mini_l.y */
/*Calvin Huynh, Jonathan Pang*/
/*KEEP TRACK OF LINE AND COLUMN NUMBER!!!!!!!!!!!!!!!!!!!!!!!*/
/*Declarations*/
%{
#include "heading.h"
#include "y.tab.h"
#include <string.h>
#include <sstream>
#include <stdio.h>
#include <vector>
#include <map>
using namespace std;

int yyerror(char* s);
int yylex(void);
int data_type;
extern int arr_sz;
extern int line;
extern int column;
extern int err;
extern char *yytext;
extern FILE * mini_ptr; /*mini_l.mil*/

struct attribute{
  int data_type;
  int array_size;
  attribute* next;
  attribute()
  :data_type(0), array_size(0), next()  
  {}
};
extern attribute atb;
extern map<string,attribute> sym_table;

%}

/*bison declarations*/
/*
%union{
  int           int_val;
  string      op_val; 
}
*/

%error-verbose
%start input
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF IF THEN ENDIF ELSE ELSEIF WHILE DO BEGINLOOP ENDLOOP BREAK CONTINUE EXIT READ WRITE AND OR NOT TRUE FALSE L_BRACKET "[" R_BRACKET "]" L_PAREN "(" R_PAREN ")" IDENT NUMBER SEMICOLON ";" COLON ":" COMMA "," QUESTION "?" ASSIGN ":=" COMMENT EQ "==" NEQ "!=" LT "<" GT ">" LTE "<=" GTE ">=" 
%left ADD
%left SUB
%left MOD
%left DIV
%left MULT

%%

/*grammar rules*/
input: /* empty */
	| Program { }

	;
/*
exp: INTEGER_LITERAL { $$ = $1; }
	| exp PLUS exp { $$ = $1 + $3; }
	| exp MULT exp { $$ = $1 * $3; }
	;*/

/*NON-TERMINALS*/

/*
0 = undetermined
1 = integer
2 = array
3 = temp variable
array size must be declared and positive
*/


Program: PROGRAM IDENT ";" Block END_PROGRAM {
    /*Now that we have created all the code, append the variables to beginning of mil file */

    /*open mini_l.mil and store file pointer in mini_ptr*/
    mini_ptr = freopen("mini_l.mil","a",stdout);
    /*seek to beginning of file and append variables */
    fseek(mini_ptr, 0, SEEK_SET);
    for(map<string,attribute>::reverse_iterator it = sym_table.rbegin(); it != sym_table.rend(); it++)
    {
      if(it->second.data_type == 1) printf(". _%s\n", it->first.c_str());
      else if(it->second.data_type == 2) printf(".[] _%s, %d\n", it->first.c_str(), it->second.array_size);
      else if(it->second.data_type == 3) printf(". %s\n", it->first.c_str());
    }
    fclose(stdout);
    if(err != -1){
      remove("mini_l.mil");
    }
  }; 
  
Block: Declaration ";" Block1 BEGIN_PROGRAM Statement ";" Statement3 {}
  ;

Block1: /*EMPTY*/ {}
  | Declaration ";" Block1 {}
  ;
  
Declaration: IDENT Declaration1 ":" Declaration2 
  {
    if(data_type ==1 )
    {
      for(map<string,attribute>::iterator it = sym_table.begin(); it != sym_table.end(); it++)
      {
        if(it->second.data_type == 0)
        {
          it->second.data_type = 1;
        }
      }
    }
    else if(data_type == 2)
    {
      for(map<string,attribute>::iterator it = sym_table.begin(); it != sym_table.end(); it++)
      {
        if(it->second.data_type == 0)
        {
          it->second.data_type = 2;
          it->second.array_size = arr_sz;
        }
      }
    }
  }
  ;

Declaration1: /*EMPTY*/ {}
  | "," IDENT Declaration1 {}
  ;
/*add in data type*/

Declaration2: INTEGER {data_type = 1;}
  | ARRAY "[" NUMBER "]" OF INTEGER
  { 
    if(arr_sz <= 0){printf("%d\n", $3); yyerror("Array cannot have a size <= 0"); err = 4;}
    else if(arr_sz >0)
    {
      data_type = 2;
    }

  }
  ;

Statement: Var ":=" Exp  {}
  |Var ":=" Bool_Exp "?" Exp ":" Exp {}
  |IF Bool_Exp THEN Statement ";" Statement3 Statement4 ENDIF {}
  |WHILE Bool_Exp BEGINLOOP Statement ";" Statement3 ENDLOOP {}
  |DO BEGINLOOP Statement ";" Statement3 ENDLOOP WHILE Bool_Exp {}
  |READ Var Statement2 {}
  |WRITE Var Statement2 {}
  |BREAK
  |CONTINUE
  |EXIT
  | error Exp 
  ;

Statement2: /*EMPTY*/ {}
  | "," Var Statement2 {}
  ;

Statement3: /*EMPTY*/ {}
  | Statement ";" Statement3 {}
  ;

Statement4: /*EMPTY*/ {}
  | ELSEIF Bool_Exp Statement ";" Statement3 Statement4 {}
  | ELSE Statement ";" Statement3 {}
  ;

Bool_Exp: Rel_And_Exp Bool_Exp1 {}
  ;
Bool_Exp1:/*EMPTY*/{}
  | OR Rel_And_Exp Bool_Exp1 {}
  ;
  
Rel_And_Exp: Rel_Exp Rel_And_Exp1 {}
  ;
Rel_And_Exp1:/*EMPTY*/{}
  | AND Rel_Exp Rel_And_Exp1 {}
  ;
	
Rel_Exp: Rel_Exp1 Rel_Exp2 {}
	| Rel_Exp2 {}
	;

Rel_Exp1: NOT {}
  ;

Rel_Exp2: Exp Comp Exp {}
  | TRUE {}
  | FALSE {}
  | "(" Bool_Exp ")" {}
  ;
Comp: "==" 
  | "!=" 
  | "<"
  | ">" 
  | "<=" 
  | ">="  
  ;
Term: Term1 Term2 {}
	| Term2 {}
	;

Term1: SUB {}
	;

Term2: NUMBER {}
	| Var {}
	| L_PAREN Exp ")" {}
	;/*KEEP TRACK OF LINE AND COLUMN NUMBER!!!!!!!!!!!!!!!!!!!!!!!*/
/*{printf("\n");}*/
Var: IDENT {}
	| IDENT "[" Exp "]" {}
	;

Exp: Mul_Exp {$$ = $1}
	| Exp ADD Exp {$$ = $1 + $3;}
	| Exp SUB Exp {$$ = $1 - $3;}
	;

Mul_Exp: Mul_Exp MULT Mul_Exp {$$ = $1 * $3;}
	| Mul_Exp DIV Mul_Exp {$$ = $1 / $3;}
	| Mul_Exp MOD Mul_Exp {$$ = $1 % $3;}
	| Term {$$ = $1}
	;

/*TERMINALS*/

%%
/*additional c code*/
int yyerror(string s)
{
  const char *tmp;
  tmp = s.c_str();
  /* extern char *yytext;*/
    printf("Parse error at line %d, column %d: %s\n", line, column, tmp);
  
}

int yyerror(char *s)
{
  return yyerror(string(s));
}
