%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "You.tab.h"

#define $$ yyval.code
#define ADDTAB setTab($$)
#define TABPlus changNumTab(1)
#define TABMinus changNumTab(0)

extern FILE* yyin;
extern FILE* yyout;

int yylex();
int numTab = 0;

// Метод простановки табуляции
void setTab(char* str) {
	strcpy(str, "");
	for (int i=0; i < numTab; i++)
		strcat(str, "\t");
}

// Метод увеличения/уменьшения кол-ва табуляций
void changNumTab(char flag) {
	if(flag == 0 && numTab!=0)
		numTab--;
	else if(flag == 1)
		numTab++;
}

%}

%union{
	char code[1000];
	char data[50];	
}


%type <code> COMMAND COMMANDS CONTENT OPEN_TAB CLOSE_TAB SAVE_TAB
%type <code> EXP LOGIC CONDITION CYCLE DECLAR PARM OPER
%type <code> SIZE_ARRAY RET_ARRAY RET_VAR ELEMENT RET_TYPE

%token <data> LETTERS NUMBERS THIS ASSIGN COMMENT VAR END_VAR END_LINE PROGRAM END_PROGRAM RETURN
%token <data> MATH MOD NOT
%token <data> INPUT_PARENT OUTPUT_PARENT INPUT_SQUBRAC OUTPUT_SQUBRAC
%token <data> COMPARE EQUAL NOTEQUAL
%token <data> BOOL INT UINT BYTE FLOAT ARRAY OF SIZE COMMA
%token <data> IF ELSIF ELSE THEN END_IF
%token <data> WHILE DO END_WHILE FOR TO BY END_FOR
%start START
%%
START: 
	COMMANDS {fprintf(yyout, "%s", $1);};
COMMANDS:
	COMMAND {strcpy($$,$1);}
	|COMMANDS COMMAND {strcpy($$,$1); strcat($$,$2);}
	;
COMMAND: 
	CONTENT {ADDTAB; strcat($$, $1); strcat($$, "\n");}
	| OPEN_TAB {ADDTAB; strcat($$, $1); strcat($$, "\n"); TABPlus;}
	| SAVE_TAB {TABMinus; ADDTAB; strcat($$, $1); strcat($$, "\n"); TABPlus;}
	| CLOSE_TAB {TABMinus; ADDTAB; strcat($$, $1); strcat($$, "\n");}
	;
OPEN_TAB:
	CYCLE {strcpy($$, $1);}
	| IF LOGIC THEN {strcpy($$, "if ("); strcat($$, $2); strcat($$, ") {");}
	| PROGRAM LETTERS {strcpy($$, "#include <iostream>\n\nint main() {");}
	;
SAVE_TAB:
	ELSIF LOGIC THEN {strcpy($$, "} else if ("); strcat($$, $2); strcat($$, ") {");}
	| ELSE {strcpy($$, "} else {");}
	;
CLOSE_TAB:
	END_WHILE END_LINE {strcpy($$, "}");}
	| END_FOR END_LINE {strcpy($$, "}");}
	| END_IF END_LINE {strcpy($$,"}");}
	| END_PROGRAM {strcpy($$, "}");}
	;
CYCLE:
	WHILE LOGIC DO {strcpy($$, "while ("); strcat($$, $2); strcat($$, ") {");}
	| FOR CONDITION DO {strcpy($$, "for(int "); strcat($$, $2); strcat($$, ") {");}
	;
LOGIC:
	EXP COMPARE EXP {strcpy($$,$1); strcat($$, $2); strcat($$,$3);}
	| EXP EQUAL EXP {strcpy($$,$1); strcat($$, "=="); strcat($$,$3);}
	| EXP NOTEQUAL EXP {strcpy($$,$1); strcat($$, "!="); strcat($$,$3);}
	| INPUT_PARENT LOGIC OUTPUT_PARENT {strcpy($$, "("); strcat($$, $2); strcat($$, ")");}
	| INPUT_SQUBRAC LOGIC OUTPUT_SQUBRAC {strcpy($$, "["); strcat($$, $2); strcat($$, "]");}
	;
CONDITION:
	PARM ASSIGN PARM TO PARM {strcpy($$, $1); strcat($$, " = "); strcat($$, $3); strcat($$, "; ");
							strcat($$, $1); strcat($$, " <= "); strcat($$, $5); strcat($$, "; ");
							strcat($$, $1); strcat($$, "++");}
	| PARM ASSIGN PARM TO PARM BY PARM {strcpy($$, $1); strcat($$, " = "); strcat($$, $3); strcat($$, "; ");
										strcat($$, $1); strcat($$, " <= "); strcat($$, $5); strcat($$, "; ");
										strcat($$, $1); strcat($$, "+="); strcat($$, $7);}
	;
CONTENT:
	COMMENT {strcpy($$, $1);}
	| DECLAR END_LINE {strcpy($$, $1); strcat($$, $2);}
	| PARM ASSIGN EXP END_LINE {strcpy($$, $1); strcat($$, " = "); strcat($$, $3); strcat($$, $4);}
	| LETTERS INPUT_SQUBRAC EXP OUTPUT_SQUBRAC ASSIGN EXP END_LINE {strcpy($$, $1); strcat($$, "["); strcat($$, $3); strcat($$, "]"); strcat($$, " = "); strcat($$, $6); strcat($$, $7);}
	| VAR {strcpy($$, "/*We are starting initialization of variables.*/");}
	| END_VAR {strcpy($$, "/*Finishing initialization. Getting started with data processing.*/");}
	| RETURN EXP END_LINE {strcpy($$, "return "); strcat($$, $2); strcat($$, $3);}
	;
DECLAR:	
	RET_VAR {strcpy($$, $1);}
	| RET_ARRAY {strcpy($$, $1); strcat($$, "]");}
	;
RET_VAR:
	LETTERS THIS RET_TYPE {strcpy($$, $3); strcat($$, $1);}
	| LETTERS THIS RET_TYPE ASSIGN EXP {strcpy($$, $3); strcat($$, $1); strcat($$, " = "); strcat($$, $5);}
	;
RET_ARRAY:
	LETTERS THIS ARRAY INPUT_SQUBRAC SIZE_ARRAY OUTPUT_SQUBRAC OF RET_TYPE {strcpy($$, $8); strcat($$, $1); strcat($$, "["); strcat($$, $5);}
	| LETTERS THIS ARRAY INPUT_SQUBRAC SIZE_ARRAY OUTPUT_SQUBRAC OF RET_TYPE ASSIGN INPUT_SQUBRAC ELEMENT OUTPUT_SQUBRAC {strcpy($$, $8); strcat($$, $1); strcat($$, "["); strcat($$, $5); strcat($$, "] = ["); strcat($$, $11);}
	;
RET_TYPE:
	INT {strcpy($$, "int ");}
	| UINT {strcpy($$, "unsigned int ");}
	| BYTE {strcpy($$, "char ");}
	| FLOAT {strcpy($$, "float ");}
	| BOOL {strcpy($$, "bool ");}
	;
SIZE_ARRAY:
	PARM SIZE PARM {strcpy($$, $3);}
	;
ELEMENT:
	PARM {strcpy($$, $1);}
	| PARM COMMA ELEMENT {strcpy($$, $1); strcat($$, ", "); strcat($$, $3);}
	;
EXP:
	INPUT_PARENT EXP OUTPUT_PARENT {strcpy($$, "("); strcat($$, $2); strcat($$, ")");}
	| INPUT_SQUBRAC EXP OUTPUT_SQUBRAC {strcpy($$, "["); strcat($$, $2); strcat($$, "]");}
	| INPUT_PARENT EXP OUTPUT_PARENT OPER EXP {strcpy($$, "("); strcat($$, $2); strcat($$, ")"); strcat($$, $4); strcat($$, $5);}
	| INPUT_SQUBRAC EXP OUTPUT_SQUBRAC OPER EXP {strcpy($$, "("); strcat($$, $2); strcat($$, ")"); strcat($$, $4); strcat($$, $5);}
	| PARM OPER EXP {strcpy($$, $1); strcat($$, $2); strcat($$, $3);}
	| NOT EXP {strcpy($$, "!"); strcat($$, $2);}
	| LETTERS INPUT_SQUBRAC EXP OUTPUT_SQUBRAC {strcpy($$, $1); strcat($$, "["); strcat($$, $3); strcat($$, "]");}
	| LETTERS INPUT_SQUBRAC EXP OUTPUT_SQUBRAC OPER EXP {strcpy($$, $1); strcat($$, "["); strcat($$, $3); strcat($$, "]"); strcat($$, $5); strcat($$, $6);}
	| PARM {strcpy($$,$1);}
	; 
OPER:
	MATH {strcpy($$, $1);}
	| MOD {strcpy($$, "%");}
	;
PARM:
	LETTERS {strcpy($$,$1);}
	| NUMBERS {strcpy($$,$1);}
	;
%%

int main() {
	yyin = fopen("Code.txt", "r");
	yyout = fopen("OutCode.txt", "w");
	
	if (!yyin || !yyout) {
		printf("File(s) cannot be opened");
		return 1;
	} else {
		do {
			yyparse();
		} while(!feof(yyin));
		fclose(yyin);
		fclose(yyout);
	}
	return 0;
}

void yyerror(char *err) {
	fprintf(yyout, "error: %s", err);	
}
