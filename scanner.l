%{
    #include "tokens.h"
%}

%option noyywrap

%%
int return TK_PR_INT;

%%
int get_line_number(void){ 
    return 0;
}