/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 by Bart Kiers
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Project      : MLang-parser; an ANTLR4 grammar for Python 3
 *                https://github.com/bkiers/MLang-parser
 * Developed by : Bart Kiers, bart@big-o.nl
 */
grammar MLangLexer;

// All comments that start with "///" are copy-pasted from
// The Python Language Reference

tokens { INDENT, DEDENT }

//options {
//    superClass=MLangLexerBase;
//}

/*
 * parser rules
 */
main: NEWLINE
  | atom+ NEWLINE
  | function_def atom+
  | COMMENT
  | MULTILINE_COMMENT;

// FIXME: FUNCTION_NAME shouldn't be necessary
// something to do with the ordering of things below
atom:
 STRING
 | FUNCTION_NAME
 | NAME
 | NUMBER
 | list
;

function_def:
 DEF FUNCTION_NAME list NEWLINE TABS
 ;

list:
 START_LIST END_LIST
 | START_LIST atom+ END_LIST
 ;


/*
 * lexer rules
 */


STRING
 : STRING_LITERAL
 ;

NUMBER
 : INTEGER
 | DECIMAL
 ;


DEF : 'def';
VAL : 'val';
RETURN : 'return';
TRUE : 'true';
FALSE : 'false';

NEWLINE : '\n';
//NEWLINE
// : ( {this.atStartOfInput()}?
//   | ( '\r'? '\n' | '\r' | '\f' )
//   )
//   {this.onNewLine();}
// ;

FUNCTION_NAME : ID_START FUNCTION_ID_CONTINUE* FUNCTION_ID_END ;
/// identifier   ::=  id_start id_continue*

NAME
 : GLOBAL_VARIABLE_NAME
 | FUNCTION_NAME
 | VARIABLE_NAME
 ;

GLOBAL_VARIABLE_NAME : GLOBAL_ID_START GLOBAL_ID_CONTINUE* ;

VARIABLE_NAME : ID_START ID_CONTINUE* ;


/// stringliteral   ::=  [stringprefix](shortstring | longstring)
/// stringprefix    ::=  "r" | "u" | "R" | "U" | "f" | "F"
///                      | "fr" | "Fr" | "fR" | "FR" | "rf" | "rF" | "Rf" | "RF"
//STRING_LITERAL
// : ( [rR] | [uU] | [fF] | ( [fF] [rR] ) | ( [rR] [fF] ) )? ( SHORT_STRING  )
// ;

STRING_LITERAL
 : '"' .*? '"'
 ;



/// decimalinteger ::=  nonzerodigit digit* | "0"+
INTEGER
 : NON_ZERO_DIGIT DIGIT*
 | '0'+
 ;


START_LIST : '[' {this.openBrace();};
END_LIST : ']' {this.closeBrace();};
AT : '@';

SKIP_
 : ( SPACES | COMMENT | LINE_JOINING ) -> skip
 ;

TABS
 : [\t]+
 ;

UNKNOWN_CHAR
 : .
 ;

/*
 * fragments
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
fragment DECIMAL
 : DIGIT+ '.' DIGIT+
 ;

/// exponent      ::=  ("e" | "E") ["+" | "-"] digit+
fragment EXPONENT
 : [eE] [+-]? DIGIT+
 ;

fragment SPACES
 : [ ]+
 ;

fragment COMMENT
 : '#=' ~[\r\n\f]*
 | '#' ~[\r\n\f]*
 ;

fragment MULTILINE_COMMENT_BOUNDARY
 : SPACES* '##' [\r\n\f]+
 ;
fragment MULTILINE_COMMENT
 : MULTILINE_COMMENT_BOUNDARY UNKNOWN_CHAR* NEWLINE MULTILINE_COMMENT_BOUNDARY
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
 : [a-z]
 ;
fragment GLOBAL_ID_START
 : '@' [A-Z]
 ;
fragment GLOBAL_ID_CONTINUE
 : [A-Z_] DIGIT*
 | DIGIT [A-Z_]*

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
 | '-'
 | [\p{Mn}]
 | [\p{Mc}]
 | [\p{Nd}]
 | [\p{Pc}]
 //| [\p{Other_ID_Continue}]
 | UNICODE_OIDC
 ;
fragment FUNCTION_ID_END
 : [!?]? ':'
 ;