#include <windows.h>
#include <stdio.h>	
#include <string.h>

int main () {
	char ergebnis[10];
	char zahl1[10];
	char zahl2[10];

	strcpy(zahl1,"1234");
	strcpy(zahl2,"12");
	char ASD1[10];
	/*Typedef the hello function*/
	typedef void (*pfunc)(char[1], char[1], char[1]);
	typedef char* (*pfunc1)();
	pfunc1 ASD;
	/*Windows handle*/
	HINSTANCE hdll;
	
	/*A pointer to a function*/
	pfunc AddLongInt;
	
	/*LoadLibrary*/
	hdll = LoadLibrary("/masm32/test/BiehlCOMP.dll");
	
	ASD=(pfunc1)GetProcAddress(hdll, "GetVer");
	MessageBox(0,0,ASD(),MB_OK);
	/*GetProcAddress*/
	AddLongInt = (pfunc)GetProcAddress(hdll, "AddLongInt");
	/*Call the function*/
	AddLongInt(zahl1,zahl2,ergebnis);
	
	FreeLibrary(hdll);
	//printf("%s",zahl3);
	
	MessageBox(0,ergebnis,"Ergebnis",MB_OK);
	

	return 0;
}
