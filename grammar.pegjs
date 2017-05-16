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
  = left:BasicComponent _
    DefinitionOperator _
    right:((Statement / Expression))
    {
      return {
        type: "DefinitionExpression",
        operator: ":=",
        left: left,
        right: right
      };
    }
  / left:BasicComponent _
    AssignmentOperator _
    right:(Statement / Expression)
    {
      return {
        type: "AssignmentExpression",
        operator: ":=",
        left: left,
        right: right
      };
    }
Expression
  = _ b:ORExpression _ { return b; }

ORExpression
  = head:ANDExpression
    tail:(_ '||' _ ANDExpression)*
    { return buildBinaryExpression("OrExpression", head, tail); }
  / ADDExpression

ANDExpression
  = head:PrimaryExpression
    tail:(_ '&&' _ PrimaryExpression)*
    { return buildBinaryExpression("AndExpression", head, tail); }

ADDExpression
  = head:PrimaryTerm
    tail:(_ ('+' / '-') _ PrimaryTerm)*
    { return buildBinaryExpression("AddExpression", head, tail); }

PrimaryTerm
  = component:BasicComponent { return component;}
  / set:SetTerm { return set; }

PrimaryExpression
  = '(' _ expression:Expression _ ')' { return expression; }
  / AtomExpression
  / SetTerm

AtomExpression
  = k:Keyword _ '("' r:Regex '")' { return {type: 'AtomExpression', rule: k, regex: r.join("")};}

SetTerm
  = "[" head:Expression tail:(_ "," _ Expression)* "]" { return {type: 'SetExpression', elements: buildList(head, tail, 3)};}

BasicComponent "term"
  = component:[a-zA-Z\_0-9]+ { return {type: 'BasicComponent', name: component.join("") };}
  / CompoundComponent

CompoundComponent "term"
  = component:[a-zA-Z\_\$0-9]+ { return {type: 'CompoundComponent', name: component.join("") };}

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
