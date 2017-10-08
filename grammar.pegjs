{
  function buildBinaryExpression(name, head, tail) {
    return tail.reduce(function(result, element) {
      return {
        type: name,
        operator: element[1],
        left: result,
        right: element[3]
      };
    }, head);
  }
  function buildUnaryExpression(name, operator, operand) {
    return {
      type: name,
      operator: operator,
      operand: operand
    };
  }
  function buildAtomExpression(rule, regex) {
    return {
      type: "AtomExpression",
      rule: rule,
      regex: regex
    };
  }
  function extractList(list, index) {
    return list.map(function(element) { return element[index]; });
  }

  function buildList(head, tail, index) {
  	return [head].concat(extractList(tail, index));
  }
  
  function buildDefinitionStatement(left, right) {
  	return {
        type: "DefinitionExpression",
        operator: "=",
        left: left,
        right: right
      };
  }
  
  function buildAssignmentStatement(left, right) {
  	return {
        type: "AssignmentExpression",
        operator: ":=",
        left: left,
        right: right
      };
  }
}

Program
  = s:Statement+ "\n"*  { return s;}

Statement
  = left:Artifact _ DefinitionOperator _ right:Expression { return buildDefinitionStatement(left, right);} 
  / left:Artifact _ AssignmentOperator _ right:Expression { return buildAssignmentStatement(left, right);} 
 
Expression
  = _ expression:ORExpression _ { return expression; }

ORExpression
  = head:ANDExpression tail:(_ '||' _ ANDExpression)* { return buildBinaryExpression("OrExpression", head, tail); }

ANDExpression
  = head:NotExpression tail:(_ '&&' _ NotExpression)* { return buildBinaryExpression("AndExpression", head, tail); }

NotExpression
 = '!' _ expression:PrimaryExpression { return buildUnaryExpression("NotExpression", "!", expression); }
  / expression:PrimaryExpression { return expression; }

PrimaryExpression
  = '(' _ expression:Expression _ ')' { return expression; }
  / atomExpression:AtomExpression { return atomExpression; }
  / set:SetTerm { return set; }
  / artifact:Artifact { return artifact; }

AtomExpression
  = keyword:Keyword _ '("' regex:Regex '")' { return buildAtomExpression(keyword, regex.join(""));}

SetTerm
  = "[" head:Expression tail:(_ "," _ Expression)* "]" { return {type: 'SetExpression', elements: buildList(head, tail, 3)};}

Artifact "term"
  = artifact:[a-zA-Z\_\$0-9]+ { return {type: 'Artifact', name: artifact.join("") };}

_ "whitespace"
  = [ \t\n\r]*

Keyword "keyword (infile, namespace, class, classHierarchy, function, variable)"
  = 'infile'
  / 'namespace'
  / 'class'
  / 'classHierarchy'
  / 'function'
  / 'variable'

Regex "regex"
  = [-+/\*\$_<>=a-zA-Z0-9\.\^!\(\)]+

DefinitionOperator "="
  = "="

AssignmentOperator ":="
  = ":=" 
