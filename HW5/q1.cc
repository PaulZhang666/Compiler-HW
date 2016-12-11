#include <iostream>
#include "DFA.h"

int main(int argc, char** argv){
	// Syntax
	if(argc != 2){
		std::cerr << "Syntax: ./dfa-test <string>\n";
		return 1;
	}

	DFA dfa;
	dfa.debug = true;
	dfa.setFinalState(2);
	dfa.addTransition(0, 'a', 1);
	dfa.addTransition(1, 'a', 1);
	dfa.addTransition(1, 'b', 2);
	dfa.addTransition(1, 'c', 2);

	bool accepted = dfa.accepts(argv[1]);
	std::cout << "String " << (accepted ? "accepted" : "rejected") << "\n";
	return 0;
}
