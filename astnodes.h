#include <iostream>
#include <vector>

class CodeGenContext;
class StmtNode;
class ExprNode;
class VarDeclNode;

typedef std::vector<StmtNode*> StmtList;
typedef std::vector<ExprNode*> ExprList;
typedef std::vector<VarDeclNode*> VarList;

class Node {
public:
	virtual ~Node() {}
};

class ExprNode : public Node {
};

class StmtNode : public Node {
};

class IntNode : public ExprNode {
public:
	long long value;
	IntNode(long long value) : value(value) { }
};

class DoubleNode : public ExprNode {
public:
	double value;
	DoubleNode(double value) : value(value) { }
};

class CharNode : public ExprNode {
	public:
		char c;
		CharNode(char ch) : c(ch){ }
};

class BoolNode : public ExprNode {
public:
	bool value;
	BoolNode(bool val) : value(val) { }
};

class IdenNode : public ExprNode {
public:
	std::string name;
	IdenNode(const std::string& name) : name(name) { }
};

class MethodCallNode : public ExprNode {
public:
	const ExprList& id;
	ExprList arguments;
	MethodCallNode(const ExprList& id, ExprList& arguments) :
		id(id), arguments(arguments) { }
};

class BinOpNode : public ExprNode {
public:
	int op;
	ExprNode& lhs;
	ExprNode& rhs;
	BinOpNode(ExprNode& lhs, int op, ExprNode& rhs) :
		lhs(lhs), rhs(rhs), op(op) { }
};

class AssigNode : public ExprNode {
public:
	IdenNode& lhs;
	ExprNode& rhs;
	AssigNode(IdenNode& lhs, ExprNode& rhs) : 
		lhs(lhs), rhs(rhs) { }
};

class CompStmtNode : public ExprNode {
public:
	StmtList statements;
	CompStmtNode() { }
};

class ExprStmtNode : public StmtNode {
public:
	ExprNode& expression;
	ExprStmtNode(ExprNode& expression) : 
		expression(expression) { }
};

class ReturStmtNode : public StmtNode {
public:
	ExprNode& expression;
	ReturStmtNode(ExprNode& expression) : 
		expression(expression) { }
};

class VarDeclNode : public StmtNode {
public:
	const IdenNode& type;
	IdenNode& id;
	ExprNode *assignmentExpr;
	VarDeclNode(const IdenNode& type, IdenNode& id) :
		type(type), id(id) { assignmentExpr = NULL; }
};


class FuncDeclNode : public StmtNode {
public:
	const IdenNode& type;
	const ExprList& id;
	VarList arg_list;
	CompStmtNode& block;

	FuncDeclNode(const IdenNode& type, const ExprList& id, 
			const VarList& arg_list, CompStmtNode& block) :
		type(type), id(id), arg_list(arg_list), block(block) { }
	
};


class FuncDeclNode2 : public StmtNode {
public:
	const ExprList& id;
	VarList arg_list;
	CompStmtNode& block;
	
	FuncDeclNode2(const ExprList& id,
			const VarList& arg_list, CompStmtNode& block) :
		id(id), arg_list(arg_list), block(block) { }
};
