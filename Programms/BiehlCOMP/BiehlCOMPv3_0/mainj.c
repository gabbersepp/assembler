#include <windows.h>
#include <stdio.h>	
#include <string.h>

int main () {
	char ergebnis[10];
	char zahl1[10];
	char zahl2[10];

	strcpy(zahl1,"1234");
	strcpy(zahl2,"12");
	/*Typedef the hello function*/
	typedef void (*pfunc)(char[1], char[1], char[1]);
	
	/*Windows handle*/
	HINSTANCE hdll;
	
	/*A pointer to a function*/
	pfunc AddLongInt;
	
	/*LoadLibrary*/
	hdll = LoadLibrary("/masm32/test/BiehlCOMP.dll");
	
	/*GetProcAddress*/
	AddLongInt = (pfunc)GetProcAddress(hdll, "AddLongInt");
	/*Call the function*/
	AddLongInt(zahl1,zahl2,ergebnis);
	
	FreeLibrary(hdll);
	//printf("%s",zahl3);
	
	MessageBox(0,ergebnis,"Ergebnis",MB_OK);
	

	return 0;
}
