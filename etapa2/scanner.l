

%{
    #include "parser.tab.h"
%}


%option yylineno
%option noyywrap

digit [0-9]
wspc [ \t\n]+
comentarios "//".*
alpha [a-zA-Z_]
alphanum [a-zA-Z0-9_]
tokens_especiais [\- \! \* \/ \% \+ \- \< \> \{ \} \( \) \= \, \;] 

%%
{comentarios}   /*do nothing */  ;
{wspc}          /*do nothing */  ;

int         return      TK_PR_INT;
float       return      TK_PR_FLOAT;
if          return      TK_PR_IF;
else        return      TK_PR_ELSE;
while       return      TK_PR_WHILE;
return      return      TK_PR_RETURN;

"<="        return      TK_OC_LE;
">="        return      TK_OC_GE;
"=="        return      TK_OC_EQ;
"!="        return      TK_OC_NE;
"&"         return      TK_OC_AND;
"|"         return      TK_OC_OR;


{tokens_especiais}      return yytext[0];
{digit}+                return TK_LIT_INT; 
{digit}*[.]{digit}+     return TK_LIT_FLOAT;
{alpha}+{alphanum}*     return TK_IDENTIFICADOR;


.   return TK_ERRO;

%%
int get_line_number(void){ 
    return yylineno; 
}
