/***************************************************************************

 Author        : Neil Zhao  - CAST

 Date          : Dec 22th, 2008

 File          : ADIS16209_IO.c

 Hardware      : ADuC7026 and ADIS16209

 Description   : Use the GPIO to simulate the SPI communication of ADIS16209
	
***************************************************************************/
#include<ADuC7026.h>	
#include "ADIS16209_IO.h"

#define SET_CS()		GP4DAT = (GP4DAT | 0x00080000)	//P4.3->/CS
#define CLR_CS()		GP4DAT = (GP4DAT & 0xFFF7FFFF)

#define	SET_SCL()		GP4DAT = (GP4DAT | 0x00100000)	//P4.4->SCLK
#define	CLR_SCL()		GP4DAT = (GP4DAT & 0xffefffff)

#define SET_SDO()		GP4DAT = (GP4DAT | 0x00200000)	//P4.5->DIN
#define CLR_SDO()		GP4DAT = (GP4DAT & 0xffdfffff)

void delay (signed int length)
{
	while (length >0)
    	length--;
}
//---------------------------------
//WriteToADIS16209ViaSpi();
//---------------------------------
//Function that writes to the ADIS16209 via the SPI port. It sends first the control
//word that includes the start address and then the data to write.
//When writing registers which take up multi-bytes, ADIS16209 must be written one byte by one byte.
//CS must be pulled high and then pulled low before writing the next byte
//--------------------------------------------------------------------------------
void WriteToADIS16209ViaSpi(unsigned char RegisterAddress, unsigned char NumberofRegisters, unsigned char *RegisterData)
{
	unsigned	char	ControlValue = 0;
	unsigned	int		ValueToWrite = 0;
	unsigned	char	RegisterIndex = 0;
	unsigned	char	i = 0;
	
	for(RegisterIndex=0; RegisterIndex<NumberofRegisters*2; RegisterIndex++)//every register of ADIS16209 takes up two bytes
	{
		//Create the 8-bit header
		ControlValue = (RegisterAddress + RegisterIndex) | 0x80;
		SET_SCL();
		delay(1);
		SET_CS();
		delay(1);
		CLR_CS();
		delay(1);
		//Write out the control word
		for(i=0; i<8; i++)
		{ 	
			CLR_SCL();
			if(0x80 == (ControlValue & 0x80))
			{
				SET_SDO();		//Send one to DIN pin of ADIS16209
			}
			else
			{
				CLR_SDO();		//Send zero to DIN pin of ADIS16209	 
			}
			delay(1);
			SET_SCL();
			delay(1);
			ControlValue <<= 1;	//Rotate data	
		}
		//And then the data
		ValueToWrite = *(RegisterData + RegisterIndex);
		for (i=0; i<8; i++)
		{
			CLR_SCL();
			if(0x80 == (ValueToWrite & 0x80))
			{
				SET_SDO();	  //Send one to DIN pin	of ADIS16209
			}
			else
			{
				CLR_SDO();	  //Send zero to DIN pin of ADIS16209
			}
			delay(1);
			SET_SCL();
			delay(1);
			ValueToWrite <<= 1;	//Rotate data
		}
	    SET_CS();				//bring CS high again
	    delay(2);
	}
}

//---------------------------------
//ReadFromADIS16209ViaSpi();
//---------------------------------
//Function that reads from the ADIS16209 via the SPI port. ADIS16209 supports full duplex mode operation.
//It first send the control word that includes the start address which you are going to access and then 8 clcoks
//Now,the data on DOUT pin of ADIS16209 is the register which you accessed just before this operation
//Then repeat sending control word and clock, read data at the same time and now
//the data on DOUT pin of ADIS16209 is the register which you are going to read
//CS must be pulled high and then pulled low before reading the next register
//--------------------------------------------------------------------------------
void ReadFromADIS16209ViaSpi(unsigned char RegisterAddress, unsigned char NumberofRegisters, unsigned char *RegisterData)
{
	unsigned	char	ControlValue = 0;
	unsigned	char	RegisterIndex = 0;
	unsigned	char	ReceiveData = 0;
	unsigned	char	i = 0, j = 0;
	unsigned	int		iTemp = 0;

	for(RegisterIndex=0; RegisterIndex<NumberofRegisters; RegisterIndex++)
	{
		for(j=0;j<2;j++)	//Repeat reading to make sure the data on DOUT is just the register which you are going to read
		{
			//Create the 8-bit header
			ControlValue = RegisterAddress + RegisterIndex*2;//every register of ADIS16209 takes up two bytes
			SET_SCL();
			delay(1);	
			SET_CS();
			delay(1);
			CLR_CS();	 //bring CS low
			delay(1);
	
			//Write out the control word
			for(i=0; i<8; i++)
			{
				CLR_SCL();
				if(0x80 == (ControlValue & 0x80))
				{
					SET_SDO();	  //Send one to DIN pin	of ADIS16209
				}
				else
				{
					CLR_SDO();	  //Send zero to DIN pin of ADIS16209
				}
				delay(1);
				SET_SCL();
				ReceiveData <<= 1;		//Rotate data
				iTemp = GP0DAT;			//Read DOUT of ADIS16209
				if(0x00000020 == (iTemp & 0x00000020))
				{
					ReceiveData |= 1;	
				}
				delay(1);
				ControlValue <<= 1;	//Rotate data
			}
			*(RegisterData + RegisterIndex*2 + 1) = ReceiveData;
			//Read data in
			for(i=0; i<8; i++)
			{
				CLR_SCL();
				delay(1);
				SET_SCL();
				ReceiveData <<= 1;		//Rotate data
				iTemp = GP0DAT;			//Read DOUT of ADIS16209
				if(0x00000020 == (iTemp & 0x00000020))
				{
					ReceiveData |= 1;	
				}
				delay(1);
			}
			*(RegisterData + RegisterIndex*2) = ReceiveData;
			SET_CS();	//bring CS high again
			delay(2);	
		}
	}
} 
