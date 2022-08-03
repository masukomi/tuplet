grammar TupletPass1;

pass1:
    line* EOF
    ;

line:
     multiline_comment                              #big_comment
     | comment_line                                 #comment
     | newline_and_tabs whatevs trailing_comment?   #indented_line
     | NEWLINE whatevs trailing_comment?            #unindented_line
     | whatevs trailing_comment?                    #unindented_line
     | NEWLINE+                                     #ignore
    ;


multiline_comment: MULTILINE_COMMENT;
//
newline_and_tabs: NEWLINE TABS;
//whatevs: (SKIP_ | OTHER)+ ;
comment_line: NEWLINE TABS* '#' SPACES* whatevs;
trailing_comment: '#' whatevs*;
whatevs: OTHER+;
OTHER: ~[\n\t] ;
//
//
MULTILINE_COMMENT:  NEWLINE TABS* '##' NEWLINE .* TABS* '##' NEWLINE;
NEWLINE : '\n';
TABS : [\t]+ ;
//OTHER : (. | '#') ;
//
//SKIP_
// :  SPACES  -> skip
// ;
//
//
fragment SPACES
 : [ ]+
;

