{
  function buildBinaryExpression(name, head, tail) {
    return tail.reduce(function(result, element) {
      return {
        type: name,
        operator: element[1],
        left: result,
        right: element[3]{
2
  function buildBinaryExpression(name, head, tail) {
3
    return tail.reduce(function(result, element) {
4
      return {
5
        type: name,
6
        operator: element[1],
7
        left: result,
8
        right: element[3]
9
      };
10
    }, head);
11
  }
12
  function extractList(list, index) {
13
    return list.map(function(element) { return element[index]; });
14
  }
15
​
16
  function buildList(head, tail, index) {
17
    return [head].concat(extractList(tail, index));
18
  }
19
}
20
​
21
Program
22
  = s:Statement+ "\n"*  { return s;}
23
​
24
Statement
25
  = left:BasicComponent _
26
    DefinitionOperator _
27
    right:((Statement / Expression))
28
    {
29
      return {
30
        type: "DefinitionExpression",
31
        operator: ":=",
32
        left: left,
33
        right: right
34
      };
35
    }
36
  / left:BasicComponent _
37
    AssignmentOperator _
38
    right:(Statement / Expression)
39
    {
40
      return {
41
        type: "AssignmentExpression",
42
        operator: ":=",
43
        left: left,
44
        right: right
45
      };
46
    }
47
Expression
48
  = _ b:ORExpression _ { return b; }
49
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
    right:Expression
    {
      return {
        type: "DefinitionExpression",
        operator: ":=",
        left: left,
        right: right
      };
    } 
  / left:CompoundComponent _
    DefinitionOperator _
    right:Expression
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
    right:Statement
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
  / SUBExpression

ANDExpression
  = head:PrimaryExpression
    tail:(_ '&&' _ PrimaryExpression)*
    { return buildBinaryExpression("AndExpression", head, tail); }

SUBExpression
  = head:ADDExpression 
    tail:(_ '-' _ ADDExpression)*
    { return buildBinaryExpression("SubExpression", head, tail); }

ADDExpression
  = head:PrimaryTerm 
    tail:(_ '+' _ PrimaryTerm)*
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
  / component:CompoundComponent { return component; }

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
