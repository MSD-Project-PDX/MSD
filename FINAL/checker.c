/*
 *
 * Check syntax of output file
 *
 *
 */
 

 
 
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


#define MAXSTRLEN 120
 
#define NBANKS 4
#define NBANKGROUPS 4
 

unsigned int Time;
FILE *InFile;
 
  
  
  
void doNOP(char *CommandString) {
}
 
 
 
 

void doACT(char *CommandString) {
int Bank, BankGroup, RC;
int B, BG;
int Count;

if ((Count = fscanf(InFile,"%x %x %x\n", &BankGroup, &Bank, &RC)) != 3) {
 	fprintf(stderr,"ACT syntax error\n");
 	exit(1);
	}
	
 #ifdef DEBUG
 fprintf(stderr," BankGroup: %x Bank: %x  Row: %x\n",BankGroup, Bank,RC);
 #endif	
 	
if (Bank > NBANKS) {
 	fprintf(stderr,"Time: %d %s Bank %x out of range\n",Time, CommandString, Bank);
 	exit(1);
 	} 		
 		
if (BankGroup > NBANKGROUPS) {
	fprintf(stderr,"Time: %d %s BankGroup %x out of range\n",Time, CommandString, BankGroup);
 	exit(1);
 	} 		
}
 



 
void doPRE(char *CommandString) {
int Bank, BankGroup;
int Count;

if ((Count = fscanf(InFile,"%x %x\n", &BankGroup, &Bank)) !=2) {
 	fprintf(stderr,"PRE syntax error\n");
 	exit(1);
	} 
	
 #ifdef DEBUG
 fprintf(stderr," BankGroup: %x Bank: %x  \n",BankGroup, Bank);
 #endif	
 	
if (Bank > NBANKS) {
 	fprintf(stderr,"Time: %d %s Bank %x out of range\n",Time, CommandString, Bank);
 	exit(1);
 	} 		
 		
if (BankGroup > NBANKGROUPS) {
	fprintf(stderr,"Time: %d %s BankGroup %x out of range\n",Time, CommandString, BankGroup);
 	exit(1);
 	} 		 					 					 	
}
  
 
 
 

void doRD(char *CommandString) {
int Bank, BankGroup, RC;
int B, BG;
int Count;

if ((Count = fscanf(InFile,"%x %x %x\n", &BankGroup, &Bank, &RC)) != 3) {
 	fprintf(stderr,"RD syntax error\n");
 	exit(1);
	}
	
 #ifdef DEBUG
 fprintf(stderr," BankGroup: %x Bank: %x  Col: %x\n",BankGroup, Bank,RC);
 #endif		
if (Bank > NBANKS) {
 	fprintf(stderr,"Time: %d %s Bank %x out of range\n",Time, CommandString, Bank);
 	exit(1);
 	} 		
 		
if (BankGroup > NBANKGROUPS) {
	fprintf(stderr,"Time: %d %s BankGroup %x out of range\n",Time, CommandString, BankGroup);
 	exit(1);
 	} 		
}
 
 
 
 
 
void doRDAP(char *CommandString) {
fprintf(stderr,"Time: %d, RDAP not yet supported\n",Time); 
}
 
 
 


void doWR(char *CommandString) {
int Bank, BankGroup, RC;
int BG, B;
int Count;

if ((Count = fscanf(InFile,"%x %x %x\n", &BankGroup, &Bank, &RC)) != 3) {
 	fprintf(stderr,"WR syntax error\n");
 	exit(1);
	}
	
 #ifdef DEBUG
 fprintf(stderr," BankGroup: %x Bank: %x  Row: %x\n",BankGroup, Bank,RC);
 #endif	
 	
if (Bank > NBANKS) {
 	fprintf(stderr,"Time: %d %s Bank %x out of range\n",Time, CommandString, Bank);
 	exit(1);
 	} 		
 		
if (BankGroup > NBANKGROUPS) {
	fprintf(stderr,"Time: %d %s BankGroup %x out of range\n",Time, CommandString, BankGroup);
 	exit(1);
 	} 			
}




void doWRAP(char *CommandString) {
fprintf(stderr,"Time: %d, WRAP not yet supported\n",Time);
}
 
 
 
 
 
void doREF(char *CommandString) {
}
 
 
 
 
 
void doPREA(char *CommandString) {
}

 
 
 
 
 
int main(int argc, char *argv[]) {

int Count;
char CommandString[MAXSTRLEN];
int Bank;
int BankGroup;
unsigned int LastTime=0;
 
if (argc == 1)
 	InFile = stdin;
 else if (argc == 2) {
 	InFile = fopen(argv[1],"r");
 	if (!InFile) {
 		fprintf(stderr, "Can't open input file %s\n",argv[1]);
 		exit(1);
 		}
 	}
 else {
 	fprintf(stderr, "invoke as: \"checker\" or \"checker filename\"\n");
 	exit(1);
 	}
 
 
 while (!feof(InFile)) {
 	Count = fscanf(InFile,"%u %s",&Time, CommandString);

 #ifdef DEBUG
 	fprintf(stderr,"Time: %u, CommandString: %s",Time,CommandString);
 #endif
 	
 	if (Time < LastTime) {
 		fprintf(stderr,"Time: %d Time can't go backwards!\n",Time);
 		exit(1);
 		}
	LastTime = Time;
 		
 	if (!strcmp(CommandString, "NOP")) {
 		doNOP(CommandString);
 		}
 	else if (!strcmp(CommandString, "ACT")) {
 		doACT(CommandString);
 		}
 	else if (!strcmp(CommandString, "PRE")) {
 		doPRE(CommandString);
 		}
 	else if (!strcmp(CommandString, "RD")) {
 		doRD(CommandString);
 		}
 	else if (!strcmp(CommandString, "RDAP")) {
 		doRDAP(CommandString);
 		}
 	else if (!strcmp(CommandString, "WR")) {
 		doWR(CommandString);
 		}
 	else if (!strcmp(CommandString, "WRAP")) {
 		doWRAP(CommandString);
 		}
 	else if (!strcmp(CommandString, "REF")) {
 		doREF(CommandString);
 		}
 	else if (!strcmp(CommandString, "PREA")) {
 		doPREA(CommandString);
 		}
	else {
		fprintf(stderr,"Time: %d, Unrecognized DRAM Command %s\n",Time, CommandString);
		exit(1);
		}	
 	}	
 }
 
  
  











