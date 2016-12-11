%option noyywrap

%{
#include <fstream>
%}

COMMENT_0 \/\*.*\*\/
COMMENT_1 \/\/.*$

C_TYPE (float|int|char|double)
SPACE [ ]
ENTER [\n]
TAB [\t]
ID [a-zA-Z_][a-zA-Z0-9_]*

OPEN_PAR \(
CLOSE_PAR \)
OPEN_BRA \{
CLOSE_BRA \}

COMMA ,
SEMICOLON ;
ADDRESS &
ASSIGN =

C_STRING \".*\"

%%

{COMMENT_0} {
	std::cout << "Token COMMENT_0: '" << yytext << "'\n";
}
{COMMENT_1} {
	std::cout << "Token COMMENT_1: '" << yytext << "'\n";
}
{C_TYPE} {
	std::cout << "Token C_TYPE: '" << yytext << "'\n";
}
{SPACE} {
	std::cout << "Token SPACE: '" << yytext << "'\n";
}
{ENTER} {
	std::cout << "Token ENTER: " << yytext;
}
{TAB} {
	std::cout << "Token TAB: '" << yytext << "'\n";
}
{ID} {
	std::cout << "Token ID: '" << yytext << "'\n";
}
{OPEN_PAR} {
	std::cout << "Token OPEN_PAR: '" << yytext << "'\n";
}
{CLOSE_PAR} {
	std::cout << "Token CLOSE_PAR: '" << yytext << "'\n";
}
{OPEN_BRA} {
	std::cout << "Token OPEN_PAR: '" << yytext << "'\n";
}
{CLOSE_BRA} {
	std::cout << "Token CLOSE_PAR: '" << yytext << "'\n";
}
{COMMA} {
	std::cout << "Token COMMA: '" << yytext << "'\n";
}
{SEMICOLON} {
	std::cout << "Token SEMICOLON: '" << yytext << "'\n";
}
{ADDRESS} {
	std::cout << "Token ADDRESS: '" << yytext << "'\n";
}
{ASSIGN} {
	std::cout << "Token ASSIGN: '" << yytext << "'\n";
}
{C_STRING} {
	std::cout << "Token C_STRING: '" << yytext << "'\n";
}

%%

int main(int argc, char** argv){
	std::ifstream f("code.c");
	yyFlexLexer lexer(&f);
	
	lexer.yylex();
	return 0;
}
