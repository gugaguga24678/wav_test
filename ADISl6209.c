/***************************************************************
*  Create Date   : 2020-09-16
*  Version   	 : V1.0
*  @author       : Huangyao
*  Function      : 
*  Description   : c.c
*  Support       :
******************************************************************/

/*****************************************************************
  * @note
  *
  ****************************************************************/

/* Includes -----------------------------------------------------*/
#include "ADISl6209.h"

/* Private typedef ----------------------------------------------*/

/* Private define -----------------------------------------------*/

/* Private variables --------------------------------------------*/
bsp_adis_t bsp_adis;
/* Public variables ---------------------------------------------*/

/* Private functions --------------------------------------------*/
uint8_t SPI1_ReadWriteByte(uint8_t TxData)
{
    uint8_t Rxdata;
    HAL_SPI_TransmitReceive_DMA(&hspi1, &TxData, &Rxdata, 1);
    return Rxdata;
}

uint16_t ADIS_Read(uint8_t command)
{
	uint16_t Temp = 0;	  
	HAL_GPIO_WritePin(GPIOA,GPIO_PIN_4,GPIO_PIN_RESET);	        
	SPI1_ReadWriteByte(command); 	    
	SPI1_ReadWriteByte(0x00);
	Temp|=SPI1_ReadWriteByte(0xFF)<<8;  
	Temp|=SPI1_ReadWriteByte(0xFF);	 
	HAL_GPIO_WritePin(GPIOA,GPIO_PIN_4,GPIO_PIN_SET);  
	return Temp;
}

void Export_XINCL(void)
{
   bsp_adis.XINCL_INI = ADIS_Read(XINCL_OUT);
   if(bsp_adis.XINCL_INI>>13&1)
   {
      bsp_adis.XINCL_TRAN2 = bsp_adis.XINCL_INI|0xe000;
	  bsp_adis.XINCL_TRAN1 = (bsp_adis.XINCL_TRAN2^0xffff)+1;
	  bsp_adis.XINCL_TRAN = -bsp_adis.XINCL_TRAN1*0.025;
   }
   else
   {
      bsp_adis.XINCL_TRAN1 = bsp_adis.XINCL_INI&0x1fff;
	  bsp_adis.XINCL_TRAN = bsp_adis.XINCL_TRAN1*0.025;
   }
}

void Export_YINCL(void)
{
   bsp_adis.YINCL_INI = ADIS_Read(YINCL_OUT);
   if(bsp_adis.YINCL_INI>>13&1)
   {
      bsp_adis.YINCL_TRAN2 = bsp_adis.YINCL_INI|0xe000;
	  bsp_adis.YINCL_TRAN1 = (bsp_adis.YINCL_TRAN2^0xffff)+1;
	  bsp_adis.YINCL_TRAN = -bsp_adis.YINCL_TRAN1*0.025;
   }
   else
   {
      bsp_adis.YINCL_TRAN1 = bsp_adis.YINCL_INI&0x1fff;
	  bsp_adis.YINCL_TRAN = bsp_adis.YINCL_TRAN1*0.025;
   }
}
/**
  * @}
  */

/**
  * @}
  */

/************************ (C) COPYRIGHT HZHX ******************END OF FILE****/
