%{
#include <iostream>
#include "parser.h"

#define YY_DECL extern "C" int yylex()

using namespace std;
%}

%option noyywrap

%%
void {
	return TokenType;
}
int {
	return TokenType;
}
float {
	return TokenType;
}
[a-zA-Z_][a-zA-Z_0-9]* {
	return TokenId;
}
"(" {
	return TokenParOpen;
}
")" {
	return TokenParClose;
}
"," {
	return TokenComma;
}
";" {
	return TokenSemicolon;
}
[ \t\n]+ {
	// Skip spaces, tabs, and newlines
}
. {
	std::cout << "Invalid token\n";
}

%%
