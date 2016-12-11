%{
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <list>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include "SymbolTable.h"
#include "Type.h"
    extern "C" int yylex();
    extern "C" int yyparse();
    extern "C" FILE *yyin;
    void yyerror(const char *s);
    llvm::Module *module;
    llvm::Function *function;
    llvm::BasicBlock *basic_block;
    llvm::IRBuilder<> *builder;
    std::list<SymbolTable *> environment;
    %}
%token TokenInt
%token TokenFloat
%token TokenVoid
%token TokenStruct
%token<name> TokenId
%token<value> TokenNumber
%token TokenOpenCurly
%token TokenCloseCurly
%token TokenOpenSquare
%token TokenCloseSquare
%token TokenOpenPar
%token TokenClosePar
%token TokenSemicolon
%token TokenEqual
%token TokenPoint
%left TokenPlus TokenMinus
%left TokenMult TokenDiv
%type<type> Type
%type<type> Pointer
%type<indices> Indices
%type<llvalue> Expression
%type<llvalue> InversibleExpression
%type<lvalue> LValue
%union {
    char *name;
    llvm::Value *llvalue;
    int value;
    Type *type;
    std::list<int> *indices;
    struct {
	Type *type;
	llvm::Value *lladdress;
	std::vector<llvm::Value *> *llindices;
    } lvalue;
}
%%
Start:
Declarations Functions
Functions:
{
}
|
TokenVoid TokenId TokenOpenPar TokenClosePar TokenOpenCurly
{
    SymbolTable *symbol_table = new SymbolTable(SymbolTable::ScopeLocal);
    environment.push_back(symbol_table);
    llvm::Constant *constant = module->getOrInsertFunction($2,
							   llvm::Type::getVoidTy(llvm::getGlobalContext()),
							   nullptr);
    function = llvm::cast<llvm::Function>(constant);
    llvm::BasicBlock *block = llvm::BasicBlock::Create(
						       llvm::getGlobalContext(),
						       "entry",
						       function);
    builder->SetInsertPoint(block);
}
Declarations Statements TokenCloseCurly
{
    builder->CreateRetVoid();
    SymbolTable *symbol_table = environment.back();
    environment.pop_back();
}
Functions
Declarations:
{
}
| Pointer TokenId Indices TokenSemicolon
{
    SymbolTable *symbol_table = environment.back();
    Symbol *symbol = new Symbol($2);
    symbol->type = $1;
    symbol->index = symbol_table->size();
    for (int index : *$3)
	{
	    Type *type = new Type(Type::KindArray);
	    type->num_elem = index;
	    type->subtype = symbol->type;
	    type->lltype = llvm::ArrayType::get(symbol->type->lltype, index);
	    symbol->type = type;
	}
    if (symbol_table->getScope() == SymbolTable::ScopeGlobal)
	symbol->lladdress = new llvm::GlobalVariable(
						     *module,
						     symbol->type->lltype,
						     false,
						     llvm::GlobalValue::ExternalLinkage,
						     nullptr,
						     symbol->getName());
    else if (symbol_table->getScope() == SymbolTable::ScopeLocal)
	symbol->lladdress = builder->CreateAlloca(symbol->type->lltype,
						  nullptr, Symbol::getTemp());
    symbol_table->addSymbol(symbol);
}
Declarations
Indices:
{
    $$ = new std::list<int>();
}
| TokenOpenSquare TokenNumber TokenCloseSquare Indices
{
    $$ = $4;
    $$->push_back($2);
}
Pointer:
Type
{
    $$ = $1;
}
| Pointer TokenMult
{
    $$ = new Type(Type::KindPointer);
    $$->subtype = $1;
    $$->lltype = llvm::PointerType::get($1->lltype, 0);
}
Type:
TokenInt
{
    $$ = new Type(Type::KindInt);
    $$->lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
}
| TokenFloat
{
    $$ = new Type(Type::KindFloat);
    $$->lltype = llvm::Type::getFloatTy(llvm::getGlobalContext());
}
| TokenStruct TokenOpenCurly
{
    SymbolTable *symbol_table = new SymbolTable(SymbolTable::ScopeStruct);
    environment.push_back(symbol_table);
    $<type>$ = new Type(Type::KindStruct);
    $<type>$->symbol_table = symbol_table;
}
Declarations TokenCloseCurly
{
    $$ = $<type>3;
    SymbolTable *symbol_table = environment.back();
    std::vector<llvm::Type *> lltypes;
    symbol_table->getLLVMTypes(lltypes);
    $$->lltype = llvm::StructType::create(llvm::getGlobalContext(), lltypes);
    environment.pop_back();
}
Statements:
| Statements Statement
Statement:
LValue TokenEqual InversibleExpression TokenSemicolon
{
    llvm::Value *lladdress = $1.llindices->size() > 1 ?
	builder->CreateGEP($1.lladdress,
			   *$1.llindices,
			   Symbol::getTemp()) :
	$1.lladdress;
    builder->CreateStore($3, lladdress);
}

InversibleExpression:
TokenMinus Expression
{ 
    $$ = builder->CreateNeg($2, Symbol::getTemp());
}
| Expression

Expression:
LValue
{
    llvm::Value *lladdress = $1.llindices->size() > 1 ?
	builder->CreateGEP($1.lladdress, *$1.llindices,
			   Symbol::getTemp()) :
	$1.lladdress;
    $$ = builder->CreateLoad(lladdress, Symbol::getTemp());
}
| TokenNumber
{
    llvm::Type *lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
    $$ = llvm::ConstantInt::get(lltype, $1);
}
| Expression TokenPlus Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::Add, $1, $3, Symbol::getTemp());
}
| Expression TokenMinus Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::Sub, $1, $3, Symbol::getTemp());
}
| Expression TokenMult Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::Mul, $1, $3, Symbol::getTemp());
}
| Expression TokenDiv Expression
{
    $$ = builder->CreateBinOp(llvm::Instruction::SDiv, $1, $3, Symbol::getTemp());
}
| TokenOpenPar Expression TokenClosePar
{
    $$ = $2;
}
LValue:
TokenId
{
    Symbol *symbol = nullptr;
    for (auto it = environment.rbegin();
	 it != environment.rend();
	 ++it)
	{
	    SymbolTable *symbol_table = *it;
	    symbol = symbol_table->getSymbol($1);
	    if (symbol)
		break;
	}
    if (!symbol)
	{
	    std::cerr << "Undeclared identifier: " << $1 << '\n';
	    exit(1);
	}
    $$.type = symbol->type;
    $$.lladdress = symbol->lladdress;
    $$.llindices = new std::vector<llvm::Value *>();
    llvm::Type *lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
    llvm::Value *llindex = llvm::ConstantInt::get(lltype, 0);
    $$.llindices->push_back(llindex);
}
| LValue TokenOpenSquare Expression TokenCloseSquare
{
    if ($1.type->getKind() != Type::KindArray)
	{
	    std::cerr << "L-value is not an array\n";
	    exit(1);
	}
    $$.llindices = $1.llindices;
    $$.llindices->push_back($3);
    $$.type = $1.type->subtype;
    $$.lladdress = $1.lladdress;
}
| LValue TokenPoint TokenId
{
    if ($1.type->getKind() != Type::KindStruct)
	{
	    std::cerr << "L-value is not a struct\n";
	    exit(1);
	}
    Symbol *symbol = $1.type->symbol_table->getSymbol($3);
    if (!symbol)
	{
	    std::cerr << "Invalid field: " << $3 << '\n';
	    exit(1);
	}
    llvm::Type *lltype = llvm::Type::getInt32Ty(llvm::getGlobalContext());
    llvm::Value *llindex = llvm::ConstantInt::get(lltype, symbol->index);
    $$.llindices = $1.llindices;
    $$.llindices->push_back(llindex);
    $$.type = symbol->type;
    $$.lladdress = $1.lladdress;
}
%%
int main(int argc, char **argv)
{
    if (argc != 2)
	{
	    std::cerr << "Syntax: ./main <file>\n";
	    exit(1);
	}
    yyin = fopen(argv[1], "r");
    if (!yyin)
	{
	    std::cerr << "Cannot open file\n";
	    exit(1);
	}
    llvm::LLVMContext &context = llvm::getGlobalContext();
    builder = new llvm::IRBuilder<>(context);
    module = new llvm::Module("TestModule", context);
    SymbolTable *global_symbol_table = new SymbolTable(SymbolTable::ScopeGlobal);
    environment.push_back(global_symbol_table);
    do
	{
	    yyparse();
	} while (!feof(yyin));
    module->dump();
    return 0;
}
void yyerror(const char *s)
{
    std::cerr << s << std::endl;
    exit(1);
}
