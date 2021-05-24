#include "RM3100.h"
#include "bsp_spi.h"
#include "bsp_usart1.h"  

/** �������ݽṹ */
struct config {
    short rx;
    short ry;
    short rz;
}rm3100;

/*****************************
   ��ʼ��SPI_NSS�ӿ�
*****************************/
void RM3100_Init(void)
{	
  GPIO_InitTypeDef GPIO_InitStructure;
	RCC_APB2PeriphClockCmd(	RCC_APB2Periph_GPIOB, ENABLE );//PORTBʱ��ʹ�� 

	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;  // 
 	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;  //�������
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
 	GPIO_Init(GPIOB, &GPIO_InitStructure);
 	GPIO_SetBits(GPIOB,GPIO_Pin_12);   //NSS
 				
	SPI2_Init();		   	//��ʼ��SPI
  RM3100_CS=1;
}  

/*********************************
  SPI��ָ����ַ����ָ���ֽڵ�����
*********************************/
void SPIWriteBytes(unsigned char ucAddr,unsigned char ucLength,unsigned char ucData[])
{
	unsigned char i;
	RM3100_CS = 0;
	SPI2_ReadWriteByte(ucAddr);
	for (i=0;i<ucLength;i++)
		SPI2_ReadWriteByte(ucData[i]);
	RM3100_CS = 1;
}

/*********************************
  SPI��ָ����ַ��ȡָ���ֽڵ�����
*********************************/
void SPIReadBytes(unsigned char ucAddr,unsigned char ucLength,unsigned char ucData[])
{
	unsigned char i;
	RM3100_CS = 0;
	SPI2_ReadWriteByte(ucAddr);
	for (i=0;i<ucLength;i++)
		ucData[i] = SPI2_ReadWriteByte(0);
	RM3100_CS = 1;
}

/*********************************
  SPI��ָ����ַ����һ�ֽڵ�����
*********************************/
void SPIWrite(unsigned char ucAddr,unsigned char ucData)
{
	SPIWriteBytes(ucAddr,1,&ucData);
}

/*********************************
  SPI��ָ����ַ��ȡһ�ֽڵ�����
*********************************/
unsigned char SPIRead(unsigned char ucAddr)
{
	unsigned char ucData[1];
	SPIReadBytes(ucAddr,1,ucData);
	return ucData[0];
}

/*********************************
  ����RM3100ѭ����������
*********************************/
void setCycleCount ( u16 value ) 
{
	unsigned char to_reg[6];

	if (value > 400)
			value=400;
	else if (value < 30)
			value=30;
	to_reg[0] = value>>8;
	to_reg[1] = value;
	to_reg[2] = to_reg[0];
	to_reg[3] = to_reg[1];
	to_reg[4] = to_reg[0];
	to_reg[5] = to_reg[1];

	SPIWriteBytes(M3D_3100_CCX,6,to_reg);
}

/*********************************
  ����RM3100��������Ƶ��
*********************************/
void setCMMdatarate ( unsigned char conf ) 
{
	unsigned char *ptr;

	ptr = &conf ;
	
	SPIWriteBytes(M3D_3100_TMRC,1,ptr);
}

/*********************************
  ����RM3100��ʼ����״̬
*********************************/
void RM3100_SetUp(void)
{ 
	unsigned char CCR[6] = {0x00,0xC8,0,0xC8,0,0xC8};   // 200  
	SPIWriteBytes(0x04,6,CCR);
	setCycleCount(50);
	setCMMdatarate(12);
	SPIWrite(0x01,0x70);
}

/*********************************
    ���RM3100�Ƿ�����
*********************************/
char CheckMagDataReady(void)
{
	char cResult;
	unsigned char temp[1]={0};	
	temp[0] = SPIRead(0xB4);
	cResult = temp[0]&0x80;
	return cResult;	
}

/*********************************
  ��ȡRM3100��������
*********************************/
void RM3100_GetData(void) 
{ 	
	int i = 0;
	unsigned char temp[9]={0};
	static long Mag_Data[3]={0};
	static char cNoDataCnt = 0;
	if (CheckMagDataReady())
	{
		//��ȡ���ݵ�����
		SPIReadBytes(0xA4,9,temp);
		
		//���ݼ���
		Mag_Data[0]=temp[0]<<16 | temp[1]<<8 | temp[2];			//ned����ϵ--ǰ�������к��Ӷ��Ǳ��λ���ӵ�N
		Mag_Data[1]=temp[3]<<16 | temp[4]<<8 | temp[5];
		Mag_Data[2]=temp[6]<<16 | temp[7]<<8 | temp[8];

		for(i=0;i<3;i++)
		{
			if(Mag_Data[i]&0x00800000)
				Mag_Data[i]|=0xff000000;
		}
		
		temp[0]=0x70;
		SPIWrite(0,0x70);
	}
	else
	{
		//��������û׼���ô�������
		cNoDataCnt+=5;
		if (cNoDataCnt>=20)
		{
			cNoDataCnt=0;
			SPIWrite(0,0x70);
		}
	}
	
	//����ת�Ƶ��ṹ��
	rm3100.rx = Mag_Data[0];
	rm3100.ry = Mag_Data[1];
	rm3100.rz = Mag_Data[2];
	
	//���ڴ�ӡ�������
	printf("�ų�ǿ��\r\n");
	printf("X��:%d\r\n",rm3100.rx);
	printf("Y��:%d\r\n",rm3100.ry);
	printf("Z��:%d\r\n",rm3100.rz);
	
}


