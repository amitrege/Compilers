%option noyywrap
%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define INDENT (4)

/*
 *   SET THIS CONSTANT PROPERLY,
 *   IF THE VALUE IS TOO SMALL, IT WILL LEAD TO A SEGMENTATION FAULT 
 */
#define MAXSYMBOLS 50000

struct entry
{
    char *lexptr;
    int token;
};
struct entry symbolTable[MAXSYMBOLS];

int line = 1;
int column = 4;
int paren = 0;
int token = 32;    

void init();
int lookup(char*);
int insert(char*,int);
void indent();
void write_html_char(int);
void write_string();
void write_char();
void write_int();
void write_hex();
void write_oct();
void write_fp();
void write_comment();
void write_html();
void write_id();
void write_begin();
void write_end();
void write_open();
void write_begin();
void write_close();
void write_bopen();
void write_bclose();
void write_sep();
void write_op();
void write_inline();
void write_directive();
void error();
%}

quote   \'
ditto   \"
back    \\
digit   [0-9]
exp     (e|E)(+|-|?){digit}+
hex     {digit}|[a-fA-F]
alpha   [a-zA-Z]|"_"
ch      [^\\\n\'\"]

%%
"auto"|"double"|"int"|"struct"|"break"|"else"|"long"|"switch"|"case"|"enum"|"register"|"typedef"|"char"|"extern"|"return"|"union"|"const"|"float"|"short"|"unsigned"|"continue"|"for"|"signed"|"void"|"default"|"goto"|"sizeof"|"volatile"|"do"|"if"|"static"|"while"                                                                                                {printf("<font color='#0000FF'><b>"); write_html();                                                                                      printf("</b></font>"); printf(" ");}
{ditto}({back}{ch}|{back}{ch}|{back}{quote}|{back}{ditto}|{ch}|{quote})+{ditto}          write_string();
{quote}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{ditto}){quote}        write_char();
0[0-7]+                                                                                 write_oct();
0(x|X){hex}+                                                                            write_hex();
{digit}+                                                                                write_int();
{digit}*"."{digit}*(exp)?                                                               write_fp();
{alpha}({alpha}|{digit})*                                                                   write_id();
"{"                                                                                     write_begin();
"}"                                                                                     write_end();
"("                                                                                     write_open();
")"                                                                                     write_close();
"["                                                                                     write_bopen();
"]"                                                                                     write_bclose();
";"                                                                                     write_sep();
"?"|":"|"->"|"."|"++"|"--"|"+"|"-"|"!"|"~"|"*"|"/"|"%"|"<<"|">>"|"<"|"<="|">="|">"|"=="|"!="|"&"|"^"|"\|"|"&&"|"\||"|"="|"+="|"-="|"*="|"/="|"%="|">>="|"<<="|"&="|"^="|"\|="|","                                                          write_op();
"//"(.)*"\n"                                                                            write_inline();
"/*"                                                                                    write_comment();
"#"(.)*"\n"                                                                             write_directive();
[ \t\v\n\r\f]                                                                           
.                                                                                       error();    

%%

void write_html_char(int c)
{
    switch(c)
    {
        case '<': printf("&lt;"); break;
        case '>': printf("&gt;"); break;
        case '"': printf("&quot;"); break;
        case '&': printf("&amp;"); break;
        default: putchar(c);
    }
}

void write_html()
{
    char *s = yytext;
    while(*s)
        write_html_char(*s++);
}

void write_comment()
{
    char c, c1;
	printf("<font color='#00FF00'>/*");
	loop:
	while ((c = input()) != '*' && c != 0)
	{
            if(c!='\n')
                write_html_char(c);
            else
                indent();
        }
	write_html_char('*');
	if ((c1 = input()) != '/' && c != 0)
	{ 
		unput(c1);
		goto loop;
	}
	if (c != 0)
		write_html_char(c1);
	printf("</font>");
	indent();
}

void indent()
{
    printf("\n%-*d",column,line++);
}

void write_sep()
{
    write_html();
    if(!paren)
        indent();
    else
        putchar(' ');
}

void write_begin()
{
    indent();
    write_html();
    column+=INDENT;
    indent();
}

void write_end()
{
    column-=INDENT;
    indent();
    write_html();
    indent();
}

void write_open()
{
    write_html();
    paren++;
}

void write_close()
{
    write_html();
    paren--;
}

void write_bclose()
{
    write_html();
}

void write_bopen()
{
    write_html();
}

void write_string()
{
    printf("<font color=\"red\">");
    write_html();
    printf("</font>");
}

void write_char()
{
    printf("<font color='#00FFFF'><u>");
    write_html();
    printf("</u></font>");
}

void write_hex()
{
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_oct()
{
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_int()
{
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_fp()
{
    printf("<font color='#00FFFF'>");
    write_html();
    printf("</font>");
}

void write_id()
{
    printf("<font color='#0000FF'>");
    if(lookup(yytext) != -1)
    {
        printf("<a href=\"#");
    }
    else
    {
        insert(yytext, token);
        token++;
        printf("<a name=\"");
    }
    write_html();
    printf("\">");
    write_html();
    printf("</a>");
    printf("</font>");
    printf(" ");
}

void write_op()
{ 
    printf("<font color='#000000'><b>");
    write_html();
    printf("</b></font>");
}

void write_inline()
{
    printf("<font color='#008000'>");
    char *s = yytext;
    while((*s)!='\n')
        write_html_char(*s++);
    printf("</font>");
    indent();
}

void write_directive()
{
    printf("<font color='#FF00FF'><b>");
    char *s = yytext;
    while((*s)!='\n')
        write_html_char(*s++);
    printf("</b></font>"); 
    indent(); 
}

void error()
{
    write_html();
}

void init()
{
    char *keywords[] = {"auto","break","case","char","const","continue","default","do","double","else","enum","extern","float","for","goto","if","int","long","register","return","short","signed","sizeof","static","struct","switch","typedef","union","unsigned","void","volatile","while"};
	
    int n = 32, i = 0;	
    for(i=0; i < MAXSYMBOLS; i++)
    {
	if(i>=n)
	    symbolTable[i].lexptr = NULL;
	else
	{
	    symbolTable[i].lexptr = strdup(keywords[i]);
	    symbolTable[i].token = i+1;
	}
    }
}

int lookup(char *lexeme) 
{
    int i = 0;
    for(i = 0; i < MAXSYMBOLS; i++)
    {
        if(symbolTable[i].lexptr != NULL && (strcmp(symbolTable[i].lexptr, lexeme) == 0))
        {
            return i;
        }
    }
    return -1;
}

int insert(char *a, int token) 
{
    int i = 0;
    while(symbolTable[i].lexptr != NULL) 
        i++;
    
    symbolTable[i].lexptr = strdup(a);
    symbolTable[i].token = token; 
}

int main() 
{
    init();
    printf("<html><pre>\n");
    indent();
    yylex();
    printf("\n</pre></html>\n");
    return 0;
}

