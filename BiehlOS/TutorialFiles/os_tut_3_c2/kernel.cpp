extern "C" void prnt(char *var);
extern char boot;
extern "C" char get_char();

int main()
{
char *str;
char key[2];
int i;
str=&boot;
prnt(str);

for(i=0;i<10;i++) {
key[0]=get_char();
key[1]=0;
prnt(key);
}

return 0;
}