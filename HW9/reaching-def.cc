#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/CFG.h"

#include <iostream>
#include <set>
#include <unordered_map>
#include <string>
namespace
{
	struct BasicBlockInfo
	{
		std::set<std::string> gen;
 		std::set<std::string> in;
    		std::set<std::string> out;
  	};
  	bool ExtendSet(std::set<std::string> &set1, std::set<std::string> &set2)
  	{
    		int last_size = set1.size();
    		for (const std::string &s : set2)
      			set1.insert(s);
    		return set1.size() - last_size;
  	}
  	void PrintSet(std::set<std::string> &set)
  	{
   		llvm::errs() << "{";
   		for (const std::string &s : set)
      			llvm::errs() << ' ' << s;
    		llvm::errs() << " }";
  	} 
  	class PrintPass : public llvm::FunctionPass
  	{
  	public:
    		static char ID;
    		PrintPass() : llvm::FunctionPass(ID) { }
    		bool runOnFunction(llvm::Function &function) override
    		{
   		std::unordered_map<std::string, BasicBlockInfo *> basic_block_table;
      		bool changed = true;
      		int iterations = 0;

      		llvm::errs() << "Pass on function " << function.getName() << '\n';
      		for (llvm::Function::iterator basic_block = function.begin(),
	     		e = function.end();
	   		basic_block != e;
	   		++basic_block)
		{
	  		basic_block_table.insert(std::make_pair<std::string, BasicBlockInfo *>(basic_block->getName(),new BasicBlockInfo));

	  		for (llvm::BasicBlock::iterator bb_instr = basic_block->begin(); 
	       			bb_instr != basic_block->end(); 
	       			bb_instr++)
	    		{

	      		if (!bb_instr->getName().empty())
				{
		 			basic_block_table[basic_block->getName()]->gen.insert(bb_instr->getName());
				}
	      
	    		}

	  		(void)ExtendSet(basic_block_table[basic_block->getName()]->out,
			  basic_block_table[basic_block->getName()]->gen);

		}

      		for (std::unordered_map<std::string, BasicBlockInfo *>::iterator myit = basic_block_table.begin(); myit != basic_block_table.end(); myit++)
		{

	  		llvm::errs() << "GEN for " << myit->first << " = ";

	  		PrintSet(myit->second->gen);

	  		llvm::errs() << '\n';

		}
      
      		while (changed)
		{
	  
			changed = false;
			iterations++;

			for (llvm::Function::iterator bb = function.begin(); bb != function.end();bb++)
	 		{
	      			basic_block_table[bb->getName()]->in.clear();

	      		for (llvm::pred_iterator it = pred_begin(bb); 
		   		it != llvm::pred_end(bb); 
		   		it++)
			{
		  		llvm::BasicBlock * pred = *it;
		  
		  		(void)ExtendSet(basic_block_table[bb->getName()]->in,
				  	basic_block_table[pred->getName()]->out);

			}

	      		if (ExtendSet(basic_block_table[bb->getName()]->out,
			    	basic_block_table[bb->getName()]->in)) 
			changed = true;

	    		}	
	  
		}

      		llvm::errs() << "Iterations: " << iterations << "\n";

      		for (std::unordered_map<std::string, BasicBlockInfo *>::iterator thelist = basic_block_table.begin(); 
			thelist != basic_block_table.end(); 
	   			thelist++)
		{
	  		llvm::errs() << "Basic Block " << thelist->first << ": \n";
	  		llvm::errs() << "IN = ";
	  		PrintSet(thelist->second->in);
	  		llvm::errs() << "\nOUT = ";
	  		PrintSet(thelist->second->out);
	  		llvm::errs() << "\n";
		}

      		return false;
    		}
   	};
      	char PrintPass::ID = 0;
      	static llvm::RegisterPass<PrintPass> X("FuriosA",
					 "Reaching definitions pass",
					 false,
					 false);
}
