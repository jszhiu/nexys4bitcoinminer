
/*******************************************************************
*
* CAUTION: This file is automatically generated by HSI.
* Version: 
* DO NOT EDIT.
*
* Copyright (C) 2010-2016 Xilinx, Inc. All Rights Reserved.*
*Permission is hereby granted, free of charge, to any person obtaining a copy
*of this software and associated documentation files (the Software), to deal
*in the Software without restriction, including without limitation the rights
*to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*copies of the Software, and to permit persons to whom the Software is
*furnished to do so, subject to the following conditions:
*
*The above copyright notice and this permission notice shall be included in
*all copies or substantial portions of the Software.
* 
* Use of the Software is limited solely to applications:
*(a) running on a Xilinx device, or
*(b) that interact with a Xilinx device through a bus or interconnect.
*
*THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*XILINX CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
*WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
*OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*Except as contained in this notice, the name of the Xilinx shall not be used
*in advertising or otherwise to promote the sale, use or other dealings in
*this Software without prior written authorization from Xilinx.
*

* 
* Description: Driver configuration
*
*******************************************************************/

#include "xparameters.h"
#include "xiomodule.h"



/*
* The configuration table for devices
*/

XIOModule_Config XIOModule_ConfigTable[] =
{
	{
		XPAR_IOMODULE_0_DEVICE_ID,
		XPAR_IOMODULE_0_BASEADDR,
		XPAR_IOMODULE_0_IO_BASEADDR,
		XPAR_IOMODULE_0_INTC_HAS_FAST,
		XPAR_IOMODULE_0_INTC_BASE_VECTORS,
		((XPAR_IOMODULE_0_INTC_LEVEL_EDGE << 16) | 0x7FF),
		XIN_SVC_SGL_ISR_OPTION,
		XPAR_IOMODULE_0_FREQ,
		XPAR_IOMODULE_0_UART_BAUDRATE,
		{
			XPAR_IOMODULE_0_USE_PIT1,
			XPAR_IOMODULE_0_USE_PIT2,
			XPAR_IOMODULE_0_USE_PIT3,
			XPAR_IOMODULE_0_USE_PIT4,
		},
		{
			XPAR_IOMODULE_0_PIT1_SIZE,
			XPAR_IOMODULE_0_PIT2_SIZE,
			XPAR_IOMODULE_0_PIT3_SIZE,
			XPAR_IOMODULE_0_PIT4_SIZE,
		},
		{
			XPAR_IOMODULE_0_PIT1_EXPIRED_MASK,
			XPAR_IOMODULE_0_PIT2_EXPIRED_MASK,
			XPAR_IOMODULE_0_PIT3_EXPIRED_MASK,
			XPAR_IOMODULE_0_PIT4_EXPIRED_MASK,
		},
		{
			XPAR_IOMODULE_0_PIT1_PRESCALER,
			XPAR_IOMODULE_0_PIT2_PRESCALER,
			XPAR_IOMODULE_0_PIT3_PRESCALER,
			XPAR_IOMODULE_0_PIT4_PRESCALER,
		},
		{
			XPAR_IOMODULE_0_PIT1_READABLE,
			XPAR_IOMODULE_0_PIT2_READABLE,
			XPAR_IOMODULE_0_PIT3_READABLE,
			XPAR_IOMODULE_0_PIT4_READABLE,
		},
		{
			XPAR_IOMODULE_0_GPO1_INIT,
			XPAR_IOMODULE_0_GPO2_INIT,
			XPAR_IOMODULE_0_GPO3_INIT,
			XPAR_IOMODULE_0_GPO4_INIT,
		},
		{
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			},
			{
				XNullHandler,
				(void *)XNULL
			}
		}

	}
};
