%{
#include <iostream>
#include <cstdio>
#include <cstdlib>

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);
%}

%token TokenType
%token TokenId
%token TokenParOpen
%token TokenParClose
%token TokenComma
%token TokenSemicolon

%%
Function: TokenType TokenId TokenParOpen Argu_A TokenParClose TokenSemicolon

Argu_A:
	| TokenType TokenId Argu_B

Argu_B: 
	| TokenComma TokenType TokenId Argu_B
%%

int main(int argc, char** argv){
	// Syntax
	if(argc != 2){
		std::cerr << "Syntax: ./main <file>\n";
		exit(1);
	}

	// Open file in 'yyin'
	yyin = fopen(argv[1], "r");
	if (!yyin){
		std::cerr << "Cannot open file\n";
		exit(1);
	}

	// Parse input until there is no more
	do{
		yyparse();
	}while(!feof(yyin));

	// Accept
	std::cout << "Program accepted\n";
}

void yyerror(const char* s){
	std::cerr << s << std::endl;
	exit(1);	
}

