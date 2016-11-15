%{
#include <iostream>
#include <vector>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Type.h>

extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char* s);

llvm::Module *module;
llvm::IRBuilder<> *builder;

%}

%token TokenInt
%token TokenFloat
%token TokenVoid
%token<name> TokenId
%token TokenOpenPar
%token TokenClosePar
%token TokenSemicolon
%token TokenComma

%type<type> Type
%type<types> Argument_A
%type<types> Argument_B

%union {
	// For 'A' and 'B'
	std::vector<llvm::Type *> *types;

	// For 'Type'
	llvm::Type *type;

	// For 'id'
	char *name;
}

%%

Function:
	Type TokenId TokenOpenPar Argument_A TokenClosePar TokenSemicolon	
	{
		llvm::FunctionType * ftype = llvm::FunctionType::get($1, *$4, false);
		llvm::Constant * constant = module->getOrInsertFunction($2, ftype);
	}

Argument_A:
	{ $$ = new std::vector<llvm::Type *>;}
	| Argument_B Type TokenId
	{
		$$ = new std::vector<llvm::Type *>;
		$$->push_back($2);
		$$->insert($$->begin(), $1->begin(), $1->end());
		delete $1;
	}

Argument_B:
	{ $$ = new std::vector<llvm::Type *>;}
	| Argument_B Type TokenId TokenComma
	{
		$$ = new std::vector<llvm::Type *>;
		$$->push_back($2);
		$$->insert($$->begin(), $1->begin(), $1->end());
		delete $1;
	}

Type:
	TokenInt
	{ $$ = llvm::Type::getInt32Ty(llvm::getGlobalContext());}
	| TokenFloat
	{ $$ = llvm::Type::getFloatTy(llvm::getGlobalContext());}
	| TokenVoid
	{ $$ = llvm::Type::getVoidTy(llvm::getGlobalContext());}

%%

int main(int argc, char** argv){
	if (argc != 2){
		std::cerr << "Syntax: ./main <file>\n";
		exit(1);
	}

	yyin = fopen(argv[1], "r");
    	if (!yyin){
        std::cerr << "Cannot open file\n";
	exit(1);	
	}

	llvm::LLVMContext &context = llvm::getGlobalContext();
	builder = new llvm::IRBuilder<>(context);
	module = new llvm::Module("TestModule", context);

	do{
		yyparse();
	}while(!feof(yyin));

	module->dump();
	return 0;


}

void yyerror(const char*s){
	std::cerr << s << std::endl;
	exit(1);
}
