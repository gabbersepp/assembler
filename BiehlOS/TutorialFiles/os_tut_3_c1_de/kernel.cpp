extern "C" void prnt(char *var);
extern char boot;

int main()
{
char *str;
str=&boot;
prnt(str);
return 0;
}