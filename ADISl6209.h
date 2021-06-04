
/***************************************************************
*  Create Date   : 2020-09-16
*  Version   	 : V1.0
*  @author       : Huangyao
*  Function      : he time delay function
*  Description   : Delay.h
*  Support       :
******************************************************************/

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __ADISl6209_H
#define __ADISl6209_H

#ifndef __ADISl6209_C_     //如果没有定义 __ADISl6209_C_
#define __ADISl6209_C_  extern  // __ADISl6209_C_ 代表 extern
#else                  //如果  定义了__ADISl6209_C_
#define __ADISl6209_C_        //__DELAY_C_   是空
#endif

#ifdef __cplusplus
extern "C" {
#endif


/* Includes ------------------------------------------------------------------*/
#include "main.h"
//#include "dma.h"
#include "spi.h"
//#include "usart.h"
#include "gpio.h"
/* Exported macro ------------------------------------------------------------*/

#define SET_CS()		HAL_GPIO_WritePin(SPI_CS_GPIO_Port, SPI_CS_Pin, GPIO_PIN_SET);//PA4->/CS
#define CLR_CS()		HAL_GPIO_WritePin(SPI_CS_GPIO_Port, SPI_CS_Pin, GPIO_PIN_RESET);

/* Private define --------------------------------------------------------*/
//加括号防止边界效应
#define	ENDURANCE 		(0x00)
#define	SUPPLY_OUT 		(0x02)
#define	XACCL_OUT		  (0x04)
#define	YACCL_OUT 		(0x06)
#define	AUX_ADC 	 	  (0x08)
#define	TEMP_OUT 	    (0x0A)
#define	XINCL_OUT 		(0x0C)
#define	YINCL_OUT 	 	(0x0E)
#define	ROT_OUT		   	(0x10)
#define	XACCL_NULL 		(0x12)
#define	YACCL_NULL 	 	(0x14)
#define	XINCL_NULL 		(0x16)
#define	YINCL_NULL		(0x18)
#define	ROT_NULL		  (0x1A)
#define	ALM_MAG1 	 	  (0x20)
#define	ALM_MAG2		  (0x22)
#define	ALM_SMPL1	 	  (0x24)
#define	ALM_SMPL2		  (0x26)
#define	ALM_CTRL 		  (0x28)
#define	AUX_DAC 	 	  (0x30)
#define	GPIO_CTRL	 	  (0x32)
#define	MSC_CTRL	 	  (0x34)
#define	SMPL_PRD		  (0x36)
#define	AVG_CNT 	 	  (0x38)
#define	SLP_CNT		   	(0x3A)
#define	STATUS		   	(0x3C)
#define	COMMAND		   	(0x3E)
#define PROD_ID       (0x4A)
/* Exported types ------------------------------------------------------------*/
typedef struct 
{
   uint16_t XINCL_INI;
   uint16_t YINCL_INI;
   float XINCL_TRAN;
   float YINCL_TRAN;	
   uint16_t XINCL_TRAN1;
   uint16_t YINCL_TRAN1;
   uint16_t XINCL_TRAN2;
   uint16_t YINCL_TRAN2;
   uint8_t Rxdata;
   uint8_t flag;   
}bsp_adis_t;
/* Exported constants --------------------------------------------------------*/


/* Exported variables --------------------------------------------------------*/
extern bsp_adis_t bsp_adis;
/* Exported functions --------------------------------------------------------*/
uint8_t SPI1_ReadWriteByte(uint8_t TxData);
uint16_t ADIS_Read(uint8_t command);
void Export_XINCL(void);
void Export_YINCL(void);
#ifdef __cplusplus
}
#endif

#endif /*__XXX_H */

/**
  * @}
  */

/**
  * @}
  */

/************************ (C) COPYRIGHT HZHX ******************END OF FILE****/

