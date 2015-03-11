/* main.cc */

#include "heading.h"
#include <string.h>
#include <fstream>
#include <sstream>
#include <map>
using namespace std;


// prototype of bison-generated parser function
int yyparse();

int main(int argc, char **argv)
{
  string code_line = "";
  string code_file_name = "code.txt";
  ifstream code_file;
  remove("code.txt");
  remove("vars.txt");
  remove("mini_l.mil");
  if ((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
  {
    cerr << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
    exit( 1 );
  }
  
  yyparse();

  //combine vars.txt and code.txt
  /*
  code_file.open(code_file_name.c_str());
  string temp;
  while(code_file.good()){   
    getline(code_file, temp);
    code_line += temp + "\n";
  }
  
  freopen("vars.txt", "a", stdout);
  printf( "%s\n", code_line.c_str());
  fclose(stdout);fclose(stdin);
  //close file and return
  //remove("code.txt");
  rename("vars.txt", "mini_l.mil");
  */

  return 0;
}
