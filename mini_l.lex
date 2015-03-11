/* 
 * CS 152 - Project Phase 1
 * Jonathan Pang
 * Calvin Huynh
 */
/*KEEP TRACK OF LINE AND COLUMN NUMBER!!!!!!!!!!!!!!!!!!!!!!!*/
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
int arr_sz;

vector <string> ident_list;
string output_vars;
string output_code;
FILE * mini_ptr; 

/*
0 = undetermined
1 = integer
2 = array
3 = temp variable
array size must be declared and positive
*/

struct attribute{
  int data_type;
  int array_size;
  attribute* next;
  attribute()
  :data_type(0), array_size(0), next()  
  {}
};
attribute atb;
map<string,attribute> sym_table;
%}

/* Keep track of current line and column for error messages */
	int line = 1, column = 1, err = -1, produc = 0, ignore_prog = 0;

/* Task 1: Read text from standard-in and prints identified tokens, 1 token per line */

/* Reserved Words*/
PROGRAM ("program")
BEGIN_PROGRAM ("beginprogram")
END_PROGRAM ("endprogram")
INTEGER ("integer")
ARRAY ("array")
OF ("of")
IF ("if")
THEN ("then")
ENDIF ("endif")
ELSE ("else")
ELSEIF ("elseif")
WHILE ("while")
DO ("do")
BEGINLOOP ("beginloop")
ENDLOOP ("endloop")
BREAK ("break")
CONTINUE ("continue")
EXIT ("exit")
READ ("read")
WRITE ("write")
AND ("and")
OR ("or")
NOT ("not")
TRUE ("true")
FALSE ("false")

/* Arithemetic Operators*/
SUB ("-")
ADD ("+")
MULT ("*")
DIV ("/")
MOD ("%")

/* Comparison Operators*/
EQ ("==")
NEQ ("!=")
LT ("<")
GT (">")
LTE ("<=")
GTE (">=")

/* Identifiers and Numbers*/
digit [0-9]
IDENT  [a-z][a-z0-9_]*[a-z0-9]|[a-z]
FAKE_IDENT1 [0-9][a-z][a-z0-9_]*|[_][a-z][a-z0-9_]*
FAKE_IDENT2 [a-z][a-z0-9_]*_
NUMBER ({digit}+)




/* Other Special Symbols*/
SEMICOLON (";")
COLON (":")
COMMA (",")
QUESTION ("?")
L_BRACKET ("[")
R_BRACKET ("]")
L_PAREN ("(")
R_PAREN (")")
ASSIGN (":=")

/* Comment */
COMMENT ("##")(.)*

/* Actions that occur when reading in token */
%%
{PROGRAM} column+=yyleng; produc +=1; { ignore_prog = 1; return PROGRAM;}
{BEGIN_PROGRAM} column+=yyleng; produc +=1; { return BEGIN_PROGRAM;}
{END_PROGRAM} column+=yyleng; produc +=1; { return END_PROGRAM;}
{INTEGER} column+=yyleng; produc +=1; { return INTEGER;}
{ARRAY} column+=yyleng; produc +=1; { return ARRAY;}
{OF} column+=yyleng; produc +=1; { return OF;}
{IF} column+=yyleng; produc +=1; { return IF;}
{THEN} column+=yyleng; produc +=1; { return THEN;}
{ENDIF} column+=yyleng; produc +=1; { return ENDIF;}
{ELSE} column+=yyleng; produc +=1; { return ELSE;}
{ELSEIF} column+=yyleng; produc +=1; { return ELSEIF;}
{WHILE} column+=yyleng; produc +=1; { return WHILE;}
{DO} column+=yyleng; produc +=1; { return DO;}
{BEGINLOOP} column+=yyleng; produc +=1; { return BEGINLOOP;}
{ENDLOOP} column+=yyleng; produc +=1; { return ENDLOOP;}
{BREAK} column+=yyleng; produc +=1; { return BREAK;}
{CONTINUE} column+=yyleng; produc +=1; { return CONTINUE;}
{EXIT} column+=yyleng;produc +=1; { return EXIT;}
{READ} column+=yyleng; produc +=1; { return READ;}
{WRITE} column+=yyleng; produc +=1; { return WRITE;}
{AND} column+=yyleng; produc +=1; { return AND;}
{OR} column+=yyleng; produc +=1; { return OR;}
{NOT} column+=yyleng; produc +=1; { return NOT;}
{TRUE} column+=yyleng; produc +=1; { return TRUE;}
{FALSE} column+=yyleng; produc +=1; { return FALSE;}
{SUB} column+=yyleng; {return SUB;}
{ADD} column+=yyleng; {return ADD;}
{MULT} column+=yyleng; {return MULT;}
{DIV} column+=yyleng; {return DIV;}
{MOD} column+=yyleng; {return MOD;}
{EQ} column+=yyleng; produc +=1; { return EQ;}
{NEQ} column+=yyleng; produc +=1; { return NEQ;}
{LT} column+=yyleng; produc +=1; { return LT;}
{GT} column+=yyleng; produc +=1; { return GT;}
{LTE} column+=yyleng; produc +=1; { return LTE;}
{GTE} column+=yyleng; produc +=1; { return GTE;}
{NUMBER} column+=yyleng; produc +=1; { arr_sz = atoi(yytext); return NUMBER;}
{SEMICOLON} column+=yyleng; produc +=1; { return SEMICOLON;}
{COLON} column+=yyleng;produc +=1; { return COLON;}
{COMMA} column+=yyleng; produc +=1; { return COMMA;}
{QUESTION} column+=yyleng; produc +=1; { return QUESTION;}
{L_BRACKET} column+=yyleng; produc +=1; { return L_BRACKET;}
{R_BRACKET} column+=yyleng; produc +=1; { return R_BRACKET;}
{L_PAREN} column+=yyleng; produc +=1; { return L_PAREN;}
{R_PAREN} column+=yyleng; produc +=1; { return R_PAREN;}
{ASSIGN} column+=yyleng; produc +=1; { return ASSIGN;}

{IDENT} column+=yyleng; produc +=1; {
  if(ignore_prog ==1){
    ignore_prog = 0;
  }
  else{
    attribute atb_tmp; 
    sym_table.insert(pair<string,attribute>(yytext, atb_tmp));
  } 
  return IDENT;
}
{COMMENT} column+=yyleng;

[ \t\r] column++; /*ignore whitespace. the space at the front is necessary for single space */
[\n] ++line; column = 1;


{FAKE_IDENT1} {err = 1; yyerror(""); }
{FAKE_IDENT2} {err = 2; yyerror(""); }
. err = 3; yyerror("");

%%
/*
int main( int argc, char **argv )
{
	 ++argv, --argc;  
	 if ( argc > 0 )
		 yyin = fopen( argv[0], "r" );
	 else
		 yyin = stdin;
 
	 yylex();
	 
}
*/
