

%{
    #include "parser.tab.h"
    #include "valor_lexico.h"
    int get_line_number(void);
%}


%option yylineno
%option noyywrap

space [ \t\n\r\s]
digit [0-9]
wspc [ \t\n]+
comentarios "//".*


tokens_especiais [\- \! \* \/ \% \+ \- \< \> \{ \} \( \) \= \, \;] 

%%
{comentarios} /*do nothing */;
{wspc}        /*do nothing */;

int     return TK_PR_INT;
float   return TK_PR_FLOAT;
if      return TK_PR_IF;
else    return TK_PR_ELSE;
while   return TK_PR_WHILE;
return  return TK_PR_RETURN;

"<="    return TK_OC_LE;
">="    return TK_OC_GE;
"=="    return TK_OC_EQ;
"!="    return TK_OC_NE;
"&"     return TK_OC_AND;
"|"     return TK_OC_OR;

{tokens_especiais}  return yytext[0];

[0-9]+          { yylval.valor_lexico = valor_lexico_new(get_line_number(),LIT,strdup(yytext)); return TK_LIT_INT;}
[0-9]*[.][0-9]+ { yylval.valor_lexico = valor_lexico_new(get_line_number(),LIT,strdup(yytext)); return TK_LIT_FLOAT;}

[a-z_]+[a-z0-9_]* { yylval.valor_lexico = valor_lexico_new(get_line_number(),ID,strdup(yytext)); return TK_IDENTIFICADOR;}

. return TK_ERRO;

%%

int get_line_number(void){ 
    return yylineno; 
}
