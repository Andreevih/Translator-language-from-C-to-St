%{
#include <stdio.h>
#include <stdlib.h>
#include "You.tab.h"
#include <string.h>

%}


%%
"PROGRAM" {return PROGRAM;}
"END_PROGRAM" {return END_PROGRAM;}
"RETURN" {return RETURN;}
"VAR" {return VAR;}
"END_VAR" {return END_VAR;}

"BOOL" {return BOOL;}
"BYTE" {return BYTE;}
"INT" {return INT;}
"UINT" {return UINT;}
"FLOAT" {return FLOAT;}
"ARRAY" {return ARRAY;}
"OF" {return OF;}
".." {return SIZE;}

"WHILE" {return WHILE;}
"DO" {return DO;}
"END_WHILE" {return END_WHILE;}

"IF" {return IF;}
"ELSIF" {return ELSIF;}
"ELSE" {return ELSE;}
"THEN" {return THEN;}
"END_IF" {return END_IF;}

"FOR" {return FOR;}
"TO" {return TO;}
"BY" {return BY;}
"END_FOR" {return END_FOR;}

"(" {return INPUT_PARENT;}
")" {return OUTPUT_PARENT;}
"[" {return INPUT_SQUBRAC;}
"]" {return OUTPUT_SQUBRAC;}
"," {return COMMA;}

"=" {return EQUAL;}
"<>" {return NOTEQUAL;}
"MOD" {return MOD;}
"NOT" {return NOT;}

[0-9]* {strcpy(yylval.data, yytext); return NUMBERS;}
[a-zA-Z_]* {strcpy(yylval.data, yytext); return LETTERS;}
"+"|"-"|"/"|"*" {strcpy(yylval.data, yytext); return MATH;}
">="|"<="|"<"|">" {strcpy(yylval.data, yytext); return COMPARE;}
"///".* {strcpy(yylval.data, yytext); return COMMENT;}

";"  {strcpy(yylval.data, yytext); return END_LINE;}
":=" {strcpy(yylval.data, yytext); return ASSIGN;}
":" {strcpy(yylval.data, yytext); return THIS;}
[" ""\n""\t"] {strcpy(yylval.data, "");}
%%

int yywrap(){
	return 1;
}