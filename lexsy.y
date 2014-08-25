%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	FILE *yyin;

	void yyerror (char const *s);
    
    char locate_problem[64] = "Is the method correct ?";
    int postFlag = 0;
    int errFlag = 0;
    int countFlag = 1;
    int cVal = 0;
	
	extern int line;
	extern int ch_count;
	extern int spaces;
    extern char* yytext;
%}

%token COLUMN
%token SLASH
%token SPACE
%token SEMICOLUMN
%token HTTP
%token FHTTP
%token GET
%token HEAD
%token POST
%token CONNECTION
%token KEEP_ALIVE
%token CLOSE
%token DATE
%token D_FORMAT
%token TF_ENCODING
%token CHUNKED
%token GZIP
%token DEFLATE
%token ACCEPT_CHSET
%token REFERER
%token USER_AGENT
%token CONTENT_LENGTH
%token EXPIRES
%token TIME
%token VER
%token WORD
%token CRLF
%token NUM
%token CHARS_CHARS
%start http_msg

%%

// ----------------------------------------------------> Start

http_msg		: http_request;

// ----------------------------------------------------> Form of an http request message

http_request	:  	method method_content main_body msg
				  | {postFlag = 1;} POST method_content main_body_cl {ch_count = 0; spaces = 0;} message
				  | error method_content main_body msg
				;

method			: 	GET	
				  | HEAD
				;

msg 			: 
				  | message
				;

main_body 		:		general_header request_header entity_header
				;

main_body_cl	: 	general_header request_header {strcpy(locate_problem, "Method is POST you must add the Content-Length field first !");} Content_length entity_header

method_content 	:   SPACE request_URI SPACE http_version { strcpy(locate_problem, "Invalid general header syntax. Type Connection or Date or Transfer-Encoding"); } newlines
				;


				

request_URI 	: { strcpy(locate_problem, "Maybe the URI contains an invalid character "); } 

				  SLASH WORD SLASH WORD;

http_version	: { strcpy(locate_problem, "Invalid HTTP version syntax"); } 

				    HTTP SLASH VER 
				  | error SLASH VER

				;

// ----------------------------------------------------> General Header

general_header	: 	  gA gB;
				  	| error gB  { strcpy(locate_problem, "Invalid keyword"); }

gA 				:   Connection
				  | Date
				  | TF_Encoding 
				;

gB				: 
				  | general_header
				;


Connection 		:   CONNECTION COLUMN SPACE state newlines;	
				  | CONNECTION COLUMN SPACE { strcpy(locate_problem, "Invalid connection state. Check for spelling errors"); }  error newlines;
state			: 	CLOSE 
				  | KEEP_ALIVE;


Date 			: { strcpy(locate_problem, "Maybe you meant \"Date:\" "); } 
				  DATE COLUMN SPACE dateNtime newlines;
dateNtime		: date_str SPACE time_str;
date_str 		: { strcpy(locate_problem, "Invalid date or date format"); }  D_FORMAT;
time_str		: { strcpy(locate_problem, "Invalid time or time format"); }  TIME;

TF_Encoding 	: { strcpy(locate_problem, "Maybe you meant \"Transfer-Encoding:\""); }
				  TF_ENCODING COLUMN SPACE { strcpy(locate_problem, "Invalid encoding method (gzip or deflate or chunked)"); } Enc_method newlines;


Enc_method		: { strcpy(locate_problem, "Invalid encoding method (gzip or deflate or chunked)"); }
					GZIP
				  | DEFLATE 
				  | CHUNKED
				;

// ----------------------------------------------------> Request Header

request_header	:	  rA rB
					| error rB;

rA 				:  { strcpy(locate_problem, "Request header field (Accept-Charset or Referer or User-Agent)"); }
					Accept_charset
				  | Referer
				  | User_agent 
				;

rB				: 
				  | request_header
				;


Accept_charset	: ACCEPT_CHSET COLUMN SPACE WORD newlines;

Referer 		: REFERER COLUMN SPACE FHTTP mix newlines;

User_agent 		: USER_AGENT COLUMN SPACE mix VER newlines;

mix				: mA mB

mA 				:   WORD 
				  | SLASH
				;

mB 				: 
				  | mix
				;




// ----------------------------------------------------> Entity Header

entity_header	:	  eA eB
					| error eB;

eA 				:  { strcpy(locate_problem, "Request header field (Content-Length or Expires)"); }
					Content_length 
				  | Expires
				;

eB 				: 
				  | entity_header
				;

Content_length 	: CONTENT_LENGTH COLUMN SPACE NUM {cVal = atoi(yytext);} newlines; 

Expires 		: EXPIRES COLUMN SPACE dateNtime newlines;

// ----------------------------------------------------> Message Body

message 		:  { 
						 if (postFlag) {
						 	strcpy(locate_problem, "Method is POST you must have a message !"); 
						 }
						 else 
						 	strcpy(locate_problem, "No hint here :("); 
						 
						 ch_count += strlen(yytext);
						 countFlag = 1;
					 } 

					 possible_input more_input
				;

possible_input	: 	WORD
				  | SLASH
				  | SPACE {spaces++;}
				  | COLUMN
				  | SEMICOLUMN
				  | HTTP
				  | FHTTP
				  | GET
				  | HEAD
				  | POST
				  | GZIP
				  | CHUNKED
				  | DEFLATE
				  | CONNECTION
				  | TF_ENCODING
				  | ACCEPT_CHSET
				  | KEEP_ALIVE
				  | CLOSE
				  | DATE
				  | D_FORMAT
				  | TIME
				  | NUM
				  | REFERER
				  | USER_AGENT
				  | CONTENT_LENGTH
				  | EXPIRES
				  | VER
				  | CHARS_CHARS
				  | CRLF
				;

more_input 		: 
				  | message
				;



// ----------------------------------------------------> Extras

newlines		: CRLF additional;

additional		: 
				  | newlines
				;


%%




int main(int argc, char **argv) {
	
	if (argc == 1) {
		yyparse();
	} else if (argc == 2) {
		yyin = fopen(argv[1], "r");
		yyparse(); 
		fclose(yyin);
	}

	if (countFlag && cVal != ch_count) {
		errFlag++;

		printf("\n The content of the field Content-Length does not match the characters we counted in the message body (%d chars instead of %d you entered) \n\n", ch_count, cVal);
	}
 
	if ( !errFlag ) {
		printf("\n\t\t -> Parsing complete, no errors found \n\n");
	} else {
		printf("\n\t\t -> Parsing complete, %d errors caught \n\n", errFlag);
	}

	return 0;
}

void yyerror(char const *s) {
	errFlag++;

	printf ("\n %s: in line %d we caught this -> \"%s\" \t Hint: %s \n\n", s, line+1, yytext, locate_problem);
	yyclearin;
}

