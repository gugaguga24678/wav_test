/*-----------------------ADIS16209 Driver Test Code-----------------------------------

Author: 		ADI CAST (China Application Support Team)
Date:			2008-12-22
Rev:			V1.0
Description:	Realize ADIS16209 Driver£¬Use ADuC7026 as MCU£¬Development Tool: KEIL C
				Test program for burst reading and writing register of ADIS16209
---------------------------------------------------------------------------------------------------------*/
#include <ADuC7026.h>
#include "ADIS16209_IO.h"
#include "ADIS16209.h"

unsigned char RegisterData[8];

void putchar(unsigned char ch)/* Write character to Serial Port  */  
{          
	COMTX = ch;				 //COMTX is an 8-bit transmit register.
    while(!(0x020==(COMSTA0 & 0x020)))
    {;}
}

void ADuC7026_Initiate(void)
{
    //Clock Initial
    POWKEY1 = 0x01;				//Start PLL Setting
    POWCON = 0x00;				//Set PLL Active Mode With CD = 0  CPU CLOCK DIVIDER = 41.78MHz
    POWKEY2 = 0xF4;				//Finish PLL Setting

	GP1CON = 0x011;					//PIN set up for UART
 
	GP0DAT = GP0DAT & 0xDFFFFFFF;	//Configure the P0.5 pin as input for DOUT of ADIS16209

	GP4DAT = GP4DAT | 0x38380000;	//Configure the P4.3 pin as output for CS of ADIS16209, CS Stall High
									//Configure the P4.4 pin as output for SCLK of ADIS16209, SCLK Stall High
									//Configure the P4.5 pin as output for DIN of ADIS16209	
   	//UART Initial£¬Baud Rate = 9600
	COMCON0 = 0x080;  
	COMDIV0 = 0x088;    		
	COMDIV1 = 0x000;
	COMCON0 = 0x007; 
}   
void main (void)
{ 
    ADuC7026_Initiate();

	RegisterData[0] = 0x01;
	RegisterData[1] = 0x23;
	RegisterData[2] = 0x05;
	RegisterData[3] = 0xA6;
	putchar(RegisterData[0]);
	putchar(RegisterData[1]);
	putchar(RegisterData[2]);
	putchar(RegisterData[3]);

    WriteToADIS16209ViaSpi(XACCL_NULL,2,RegisterData);

	RegisterData[0] = 0x88;
	RegisterData[1] = 0x88;
	RegisterData[2] = 0x88;
	RegisterData[3] = 0x88;

    ReadFromADIS16209ViaSpi(XACCL_NULL,2,RegisterData);

	putchar(RegisterData[0]);
	putchar(RegisterData[1]);
	putchar(RegisterData[2]);
	putchar(RegisterData[3]);	

	while(1)
    {;}

}