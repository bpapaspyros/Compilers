%{

#include <stdio.h>
#include "lexsy.tab.h"

int line = 0;
int spaces = 0;
int ch_count = 0;


%}


letter [a-zA-Z]
digit [0-9]
time [0-2][0-3]:[0-5][0-9]
date (0?[1-9]|[12][0-9]|3[01])[\/](0?[1-9]|1[012])[\/][0-9][0-9][0-9][0-9]
ver [0-9]\.[0-9]
other_chars [,.\:-]
ws [\t]

%%

"HTTP"/"/"										{ return HTTP; 			   }
"http://"									    { return FHTTP; 		   }
"GET"											{ return GET;    		   }
"HEAD"											{ return HEAD;   		   }
"Connection"/":"								{ return CONNECTION; 	   }
"POST"											{ return POST;   		   }
"Keep-Alive"									{ return KEEP_ALIVE;	   }
"close"											{ return CLOSE;			   }
"Date"/":"										{ return DATE;      	   }
"Transfer-Encoding"/":" 						{ return TF_ENCODING;	   }
"chunked"										{ return CHUNKED;		   }
"gzip"											{ return GZIP; 			   }
"deflate"										{ return DEFLATE;          }
"Accept-Charset"/":"							{ return ACCEPT_CHSET; 	   }
"Referer"/":"									{ return REFERER;		   }
"User-Agent"/":"								{ return USER_AGENT; 	   }
"Content-Length"/":"							{ return CONTENT_LENGTH;   }
"Expires"/":"									{ return EXPIRES;		   }

":"												{ return COLUMN; 		   } 
"/"												{ return SLASH;  		   }
" "												{ return SPACE; 		   }
";"												{ return SEMICOLUMN;	   }
\n												{ line++; return CRLF; 	   }

{ver}											{ return VER; 			   }
{time}											{ return TIME;			   }
{date}  										{ return D_FORMAT;		   }
{digit}* 										{ return NUM;			   }
({letter}|{digit}|{other_chars}|{ws})*			{ return WORD; 		       }	

. 												{ return CHARS_CHARS;      }

%%