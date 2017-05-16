{
  function buildBinaryExpression(head, tail) {
    return tail.reduce(function(result, element) {
      return {
        type: "BinaryExpression",
        operator: element[1],
        left: result,
        right: element[3]
      };
    }, head);
  }
  function extractList(list, index) {
    return list.map(function(element) { return element[index]; });
  }

  function buildList(head, tail, index) {
  	return [head].concat(extractList(tail, index));
  }
}

Program
  = s:Statement+ "\n"*  { return s;}

Statement
  = component:ComponentName _ DefinitionOperator _ expression:(Statement / Expression) { return {component: component.join(""), definition: true, expression: expression };}
  / component:ComponentName _ AssignmentOperator _ expression:(Statement / Expression) { return {component: component.join(""), definition: false, expression: expression };}

Expression
  = _ b:ORExpression _ { return b; }

ORExpression
  = head:ANDExpression
    tail:(_ '||' _ ANDExpression)*
    { return buildBinaryExpression(head, tail); }
  / ADDExpression

ANDExpression
  = head:PrimaryExpression
    tail:(_ '&&' _ PrimaryExpression)*
    { return buildBinaryExpression(head, tail); }

ADDExpression
  = head:PrimaryTerm
    tail:(_ ('+' / '-') _ PrimaryTerm)*
    { return buildBinaryExpression(head, tail); }

PrimaryTerm
  = component:ComponentName { return {type: 'Component', name: component.join("") };}
  / set:SetTerm { return set; }

PrimaryExpression
  = '(' _ expression:Expression _ ')' { return expression; }
  / AtomExpression
  / SetTerm

AtomExpression
  = k:Keyword _ '("' r:Regex '")' { return {type: 'AtomExpression', rule: k, regex: r.join("")};}

SetTerm
  = "[" head:Expression tail:(_ "," _ Expression)* "]" { return {type: 'SetExpression', elements: buildList(head, tail, 3)};}

ComponentName "term"
  = [a-zA-Z\_\$0-9]+

_ "whitespace"
  = [ \t\n\r]*

Keyword "keyword (file, namespace, class, function, variable)"
  = 'file'
  / 'namespace'
  / 'class'
  / 'function'
  / 'variable'

Regex "regex"
  = [-+/\*_<>=a-zA-Z\.!\(\)]+

DefinitionOperator ":="
  = ":="

AssignmentOperator "="
  = "="
