grammar Tuplet;

// All comments that start with "///" are copy-pasted from
// The Python Language Reference

tokens { INDENT, DEDENT }

/*
 * parser rules
 */
main:
  line* EOF
  ;


line:
  function_signature                                                #function_signature_line
 | lambda_signature                                                 #lambda_signature_line
  // vvv includes trailing comments vvv
 |  newline_and_tabs* line_items+                                   #misc_items_line
 | newline_and_tabs? function_signature comment_line?               #indented_function_signature_section
 | newline function_contract                                        #function_contract_section
 | multiline_comment                                                #multiline_comment_section
 | tabs* line_items+                                                #misc_items_line
 | tabs* function_signature                                         #function_signature_line
 | newline_and_tabs+                                                #indentation
 // vvv potentially trailing tabs, which we don't want
 | tabs                                                             #maybe_indentation
 ;

line_items:
   function_call+
   | dereferenced_function_call+
   | function_contract
   | let_declaration
   | variable_declaration
   | atom* (comment_line | ELIPSIS)
   | atom+ (comment_line | ELIPSIS)?
   | newline
;

atom:
 string
 | number
 | boolean
 | array_query
 | dictionary_query
 | VARIABLE_NAME
 | GLOBAL_VARIABLE_NAME
 | list
 | dictionary
 | FUNCTION_REF

;
string: STRING;
newline: NEWLINE;


// [foo]
// [ foo bar #comment
//     ]
// [ foo bar #comment
//   baz # comment
//  ]
// [ foo
//   bar ] # comment
function_def_args_list:
  START_LIST
    ( function_args comment_line? newline_and_tabs| function_args )*
    (newline_and_tabs)*
    function_args*
  END_LIST comment_line?
 ;


function_contract:
 TABS CONTRACT_FUNC
  START_LIST
    contract_arg_pair*
  END_LIST
  ROCKET
  (START_LIST FUNCTION_REF+ END_LIST // a tuple
    | FUNCTION_REF) // a simple return type
;

contract_arg_pair:
 START_LIST
    VARIABLE_NAME
    FUNCTION_REF+
 END_LIST
;

variadic_function_type_arg: DATA_TYPE_NAME ('*' | '+');

// the function def line
function_signature:
 DEF FUNCTION_NAME function_def_args_list
 ;
lambda_signature:
 LAMBDA function_def_args_list (LESS_THAN function_call  GREATER_THAN)?
 ;

dereferenced_function_call:
    '~:' VARIABLE_NAME
    (atom+ comment_line?
     | comment_line?)
;


function_call:
// foo: <bar: baz> # maybe comment
// foo: <bar: <baz: beedle>> # maybe comment
 grouped_function_call
// foo: bar baz # maybe comment
 | FUNCTION_NAME atom+ comment_line?
// foo: # maybe comment
 | FUNCTION_NAME comment_line?
 ;

grouped_function_call:
  LESS_THAN
  FUNCTION_NAME comment_line?
  (newline_and_tabs? (atom | grouped_function_call)+ comment_line?)+
  newline_and_tabs? GREATER_THAN comment_line?
  ;


FUNCTION_REF:
  FUNCTION_NAME '~'
;

list:
 START_LIST END_LIST
 | START_LIST (atom comment_line?| newline_and_tabs atom comment_line?)+ END_LIST
 ;

dictionary:
 START_DICTIONARY END_DICTIONARY
 | START_DICTIONARY (dictionary_pair comment_line?| newline_and_tabs dictionary_pair comment_line?)+ END_DICTIONARY
 ;
dictionary_pair:
    dictionary_key '=>' atom
;

dictionary_key:
 STRING
 | number
 | boolean
 | GLOBAL_VARIABLE_NAME
 | VARIABLE_NAME
 | function_call
 // note: dosen't include lists or dictionaries
 ;

comment_line:
  TABS* (
         HUMAN_COMMENT_START+
         | AUTO_GENERATED_COMMENT_START
          )
       ~'\n'*
  ;
boolean: TRUE | FALSE;
number: DECIMAL | INTEGER;

function_args:
    // foo [bar "baz] (multiple defaults)
    simple_function_args+ defaultable_function_arg+
    // foo [bar baz* (only one variadic)
    | simple_function_args+ variadic_function_arg
    // foo+
    | simple_function_args+
    | variadic_function_arg
    // <nothing>
;

// string | integer boolean*
// impling (string | integer) boolean*
// maybe < string | integer > boolean*
//function_type_arg:
//  // string integer boolean*
//  DATA_TYPE_NAME
//  // < string | integer >
//  | LESS_THAN DATA_TYPE_NAME (ARG_OR DATA_TYPE_NAME)* GREATER_THAN
//  ;

defaultable_function_arg
 : newline_and_tabs*  default_parameter_def+
;

// no, you can't break this over multiple lines.
// deal. :P
default_parameter_def
: START_LIST VARIABLE_NAME default_parameter_value END_LIST
;

default_parameter_value:
 FUNCTION_REF
 | STRING
 | number
 | boolean
 | GLOBAL_VARIABLE_NAME
;


variadic_function_arg:
 VARIABLE_NAME ('*' | '+')
 ;

newline_and_tabs: NEWLINE TABS;
simple_function_args:
    newline_and_tabs? (FUNCTION_REF | VARIABLE_NAME | DATA_TYPE_NAME)
;

variable_declaration:
    VAR_FUNC (GLOBAL_VARIABLE_NAME | VARIABLE_NAME)
    (atom | lambda_signature)  comment_line*
;
let_declaration:
    LET_FUNC START_LIST (START_LIST VARIABLE_NAME ATOM END_LIST)+ END_LIST
    ;


multiline_comment: MULTILINE_COMMENT;
tabs: TABS;


array_query:
    (GLOBAL_VARIABLE_NAME | VARIABLE_NAME) START_LIST INTEGER END_LIST
;
dictionary_query:
    (GLOBAL_VARIABLE_NAME | VARIABLE_NAME) START_DICTIONARY dictionary_key END_DICTIONARY
;
/*
 * lexer rules
 */


STRING
 : STRING_LITERAL
 ;

//NUMBER
// : INTEGER
// | DECIMAL
// ;


DEF : 'def';
LAMBDA: 'lambda:';
VAR_FUNC : 'var:';
LET_FUNC : 'let:';
ERROR_FUNC : 'error:';
CONTRACT_FUNC : 'contract:';
TRUE : 'true';
FALSE : 'false';
NEWLINE : '\n';
ELIPSIS : ('…' | '...');

GLOBAL_VARIABLE_NAME :  GLOBAL_ID_START GLOBAL_ID_CONTINUE* ;

FUNCTION_NAME
  : ID_START FUNCTION_ID_CONTINUE* FUNCTION_ID_END
  | RETURN
  | SPECIAL_FUNCTION
  ;

RETURN : 'return';

DATA_TYPE_NAME:
  'any'
  | 'boolean'
  | 'dictionary'
  | 'float'
  | 'function'
  | 'integer'
  | 'list'
  | 'string'
  ;

VARIABLE_NAME :
ID_START ID_CONTINUE*
// DATA_TYPE_NAMEs are not great variable names
// but people do use them
;


NAME
 : GLOBAL_VARIABLE_NAME
 | FUNCTION_NAME
 | VARIABLE_NAME
 ;


SPECIAL_FUNCTION
 :
 (ASSIGN
    | ADD
    | MINUS
    | DIV
    | MOD
    | LESS_THAN
    | GREATER_THAN
    | GT_EQ
    | LT_EQ
    | NOT_EQ
    ) ':'
    ;


ADD : '+';
ASSIGN  : '=' ;
MINUS : '-';
DIV : '/';
MOD : '%';
LESS_THAN : '<';
GREATER_THAN : '>';
EQUALS : '==';
GT_EQ : '>=';
LT_EQ : '<=';
NOT_EQ : '!=';
ROCKET : '=>';
ARG_OR : '|' ;

/// stringliteral   ::=  [stringprefix](shortstring | longstring)
/// stringprefix    ::=  "r" | "u" | "R" | "U" | "f" | "F"
///                      | "fr" | "Fr" | "fR" | "FR" | "rf" | "rF" | "Rf" | "RF"
//STRING_LITERAL
// : ( [rR] | [uU] | [fF] | ( [fF] [rR] ) | ( [rR] [fF] ) )? ( SHORT_STRING  )
// ;

fragment ESCAPED_QUOTE : '\\"';
STRING_LITERAL
  : '"' ( ESCAPED_QUOTE | . )*? '"'
  | '\'' ( ESCAPED_QUOTE | . )*? '\''
;


/// decimalinteger ::=  nonzerodigit digit* | "0"+
INTEGER
 : NON_ZERO_DIGIT DIGIT*
 | '0'+
 ;


START_LIST : '[' ;
END_LIST : ']' ;
START_DICTIONARY : '{' ;
END_DICTIONARY : '}' ;
AT : '@';

SKIP_
 : ( SPACES |  LINE_JOINING ) -> skip
 ;

HUMAN_COMMENT_START : '#';
AUTO_GENERATED_COMMENT_START: '#=';


MULTILINE_COMMENT:  NEWLINE TABS* '##' NEWLINE .* TABS* '##' NEWLINE;

TABS
 : [\t]+
 ;


UNKNOWN_CHAR
 : .
 ;

/*
 * fragment
 */

/// shortstring     ::=  "'" shortstringitem* "'" | '"' shortstringitem* '"'
/// shortstringitem ::=  shortstringchar | stringescapeseq
/// shortstringchar ::=  <any source character except "\" or newline or the quote>
fragment SHORT_STRING
 : '\'' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f'] )* '\''
 | '"' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f"] )* '"'
 ;


/// stringescapeseq ::=  "\" <any source character>
fragment STRING_ESCAPE_SEQ
 : '\\' .
 | '\\' NEWLINE
 ;

/// nonzerodigit   ::=  "1"..."9"
fragment NON_ZERO_DIGIT
 : [1-9]
 ;

/// digit          ::=  "0"..."9"
fragment DIGIT
 : [0-9]
 ;

/// intpart       ::=  digit+
fragment INT_PART
 : DIGIT+
 ;

/// DECIMAL      ::=  "." digit+
DECIMAL : DIGIT+ '.' DIGIT+ ;


/// exponent      ::=  ("e" | "E") ["+" | "-"] digit+
fragment EXPONENT
 : [eE] [+-]? DIGIT+
 ;

fragment SPACES
 : [ ]+
 ;

fragment LINE_JOINING
 : '\\' SPACES? ( '\r'? '\n' | '\r' | '\f')
 ;


// TODO: ANTLR seems lack of some Unicode property support...
//$ curl https://www.unicode.org/Public/13.0.0/ucd/PropList.txt | grep Other_ID_
//1885..1886    ; Other_ID_Start # Mn   [2] MONGOLIAN LETTER ALI GALI BALUDA..MONGOLIAN LETTER ALI GALI THREE BALUDA
//2118          ; Other_ID_Start # Sm       SCRIPT CAPITAL P
//212E          ; Other_ID_Start # So       ESTIMATED SYMBOL
//309B..309C    ; Other_ID_Start # Sk   [2] KATAKANA-HIRAGANA VOICED SOUND MARK..KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
//00B7          ; Other_ID_Continue # Po       MIDDLE DOT
//0387          ; Other_ID_Continue # Po       GREEK ANO TELEIA
//1369..1371    ; Other_ID_Continue # No   [9] ETHIOPIC DIGIT ONE..ETHIOPIC DIGIT NINE
//19DA          ; Other_ID_Continue # No       NEW TAI LUE THAM DIGIT ONE

fragment UNICODE_OIDS
 : '\u1885'..'\u1886'
 | '\u2118'
 | '\u212e'
 | '\u309b'..'\u309c'
 ;

fragment UNICODE_OIDC
 : '\u00b7'
 | '\u0387'
 | '\u1369'..'\u1371'
 | '\u19da'
 ;

/// id_start     ::=  <all characters in general categories Lu, Ll, Lt, Lm, Lo, Nl, and characters with the Other_ID_Start property>
//fragment ID_START
// : [\p{L}]
// | [\p{Nl}]
// //| [\p{Other_ID_Start}]
// | UNICODE_OIDS
// ;
fragment ID_START
 : '!'? [a-z]
 ;



fragment GLOBAL_ID_START
 : '@' [A-Z]
 ;
fragment GLOBAL_ID_CONTINUE
 : [A-Z_]+ DIGIT*
 | DIGIT+ [A-Z_]*
 ;




/// id_continue  ::=  <all characters in id_start, plus characters in the categories Mn, Mc, Nd, Pc and others with the Other_ID_Continue property>
fragment ID_CONTINUE
 : ID_START
 | [\p{Mn}]
 | [\p{Mc}]
 | [\p{Nd}]
 | [\p{Pc}]
 //| [\p{Other_ID_Continue}]
 | UNICODE_OIDC
 | DIGIT
 ;

fragment FUNCTION_ID_CONTINUE
 : ID_START
 | [/><=-] | DIGIT
// | [\p{Mn}]
// | [\p{Mc}]
// | [\p{Nd}]
// | [\p{Pc}]
// //| [\p{Other_ID_Continue}]
// | UNICODE_OIDC
 ;
fragment FUNCTION_ID_END
 : [!?]? ':'
 ;

