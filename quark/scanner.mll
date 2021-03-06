{ open Parser }

let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z' '_']
let sign = ['+' '-']
let floating =
    digit+ '.' digit* | '.' digit+
  | digit+ ('.' digit*)? 'e' '-'? digit+
  | '.' digit+ 'e' '-'? digit+
        
rule token = parse
  (* whitespace *)
  | [' ' '\t' '\r' '\n'] { token lexbuf }

  (* meaningful character sequences *)
  | ';' { SEMICOLON }
  | ':' { COLON }
  | ',' { COMMA }
  | '$' { DOLLAR }
  | '(' { LPAREN }  | ')' { RPAREN }
  | '{' { LCURLY }  | '}' { RCURLY }
  | '[' { LSQUARE } | ']' { RSQUARE }
  | '=' { ASSIGN }
  | ''' { PRIME }
  | '?' { QUERY }
  (* unrealistic query that doesn't disrupt quantum state *)
  | "?'" { QUERY_UNREAL } 
  | "i(" { COMPLEX_SYM }
  | "<|" { LQREG }  | "|>" { RQREG }
  | "[|" { LMATRIX }  | "|]" { RMATRIX }
  | "def" { DEF }


  (* arithmetic *)
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { TIMES }
  | '/' { DIVIDE }
  | "mod" { MODULO }

  (* logical *)
  | '<'     { LT }
  | "<="    { LTE }
  | '>'     { GT }
  | ">="    { GTE }
  | "=="    { EQUALS }
  | "!="    { NOT_EQUALS }
  | "and"   { AND }
  | "or"    { OR }
  | "not"     { NOT }
  | "**"    { POWER }

  (* unary *)
  | '~'     { BITNOT }
  | '&'     { BITAND }
  | '^'     { BITXOR }
  | '|'     { BITOR }
  | "<<"    { LSHIFT }
  | ">>"    { RSHIFT }

  (* special assignment *)
  | "+=" { PLUS_EQUALS }
  | "-=" { MINUS_EQUALS }
  | "*=" { TIMES_EQUALS }
  | "/=" { DIVIDE_EQUALS }
  | "&=" { BITAND_EQUALS }
  | "++" { INCREMENT }
  | "--" { DECREMENT }

  | "bool"      { BOOLEAN }
  | "string"    { STRING }
  | "int"       { INT }
  | "float"     { FLOAT }
  | "void"      { VOID }
  | "complex"   { COMPLEX }
  | "fraction"  { FRACTION }
  | "qreg"      { QREG }

  (* literals *) 
  | digit+ as lit { INT_LITERAL(lit) } 
  | floating as lit { FLOAT_LITERAL(lit) }
  | "true" as lit { BOOLEAN_LITERAL(lit) }
  | "false" as lit { BOOLEAN_LITERAL(lit) }
  | '"' (('\\' _ | [^ '"'])* as str) '"' { STRING_LITERAL(str) }
  | "PI" { FLOAT_LITERAL("3.141592653589793") }
  | "E" { FLOAT_LITERAL("2.718281828459045") }

  (* keywords *)
  | "return" { RETURN }
  | "break" { BREAK } 
  | "continue" { CONTINUE }
  | "if" { IF }
  | "else" { ELSE }
  | "for" { FOR }
  | "while" { WHILE }
  | "in" { IN }

  (* ID *)
  | letter (letter | digit)* as lit { ID(lit) }

  (* comments *)
  | "%{" { comments lexbuf }
  | "%" {inline_comments lexbuf}

  (* end of file *)
  | eof { EOF }

and comments = parse
  | "}%" { token lexbuf}
  | _ { comments lexbuf}

and inline_comments = parse
  | "\n" {token lexbuf}
  | _ {inline_comments lexbuf}

