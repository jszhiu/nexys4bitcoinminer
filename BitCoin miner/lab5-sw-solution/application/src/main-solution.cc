// Lab 6 template


#include "xparameters.h"
#include "xiomodule.h"

/******************************************************************************
	Part 2: Uncomment the commented-out part in main.
	
	This gives a simple program that copies switch state to LEDs.
	
******************************************************************************/

/******************************************************************************
	Part 3: Send some data to the serial line. Use the xil_printf function, which is similar to printf but is more compact and thus suitable for a core with limited memory.
	
	- Add the following between the indicated lines:
	
		.....
		.....
		XIOModule_Start(&iom);
		
		// Add this:
		xil_printf("Hello world, this is a serial line test\n");
		
		while(1)			
		......
		.....
******************************************************************************/

/******************************************************************************
	Part 4: Use the hardware timer
	We will create an interrupt vector with a global variable incremented every 
	time that there is a timer interrupt occurring.
	
	4.1 Add a global variable as follows (volatile indicates to the compiler that 
	the variable can be modified by an interrupt and hence should be reloaded
	from memory each time it is used):
	
		.....
		.....
		volatile int int_counter=0;		
		.....
		.....
	
	
	4.2 Add a function timerTick, which will be called upon a timer interrupt, as follows:
	
		.....
		.....
		void timerTick(void* ref)
		{
			int_counter++;
		}
		......
		.....
		
	4.3 Enable the timer interrupt by adding the following code after XIOModule_Start:
	
		.....
		.....
		XIOModule_Start(&iom);
		
		// Add this
		// Connect the interrupt vector to our interrupt function
		XIOModule_Connect(&iom, XIN_IOMODULE_FIT_1_INTERRUPT_INTR, timerTick, NULL);
		// Enable timer interrupt
		XIOModule_Enable(&iom, XIN_IOMODULE_FIT_1_INTERRUPT_INTR);
		// Interrupts require to enable exceltions too
		Xil_ExceptionInit();
		Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler) XIOModule_DeviceInterruptHandler, NULL);
		Xil_ExceptionEnable();
		// Enable interrupts
		microblaze_enable_interrupts();
		.....
		.....
	

	4.4 Print the elapsed time in the while loop. Add the following in the while loop:
	
		.....
		.....
		while(1)
		{
		
			// Add this
			xil_printf("Elapsed time: %d ms after %d iterations.\n",int_counter,counter);
		.....
		.....
	
	4.5 The program runs almost too fast! We can now use the timer to delay operation
	Create a function sleep that will sleep for the specified number of milliseconds:
	
		.....
		.....	
		void sleep(int ms)
		{
			int t = int_counter;
			while(int_counter<t+ms);
		}
		.....
		.....

	4.6 Call the sleep function in the while loop after the xil_printf:
		
		.....
		.....			
		xil_printf("Elapsed time: %d ms after %d iterations.\n",int_counter,counter);
		// Add this
		sleep(100);
		.....
		.....	

	
	
	
******************************************************************************/


/******************************************************************************
	Part 5: Test the IO interface
	We will test the IO interface by reading data from it and writing data to it at regular intervals.
	The data we read should match what is put on the data read bus in the VHDL file.
	The data that is written should appear on the 7 segment display (both the address and the data, depending on sw(15)
	
	Data can be read with XIOModule_IoReadWord(&iom,address_to_read_from) and 
	data can be written with XIOModule_IoWriteWord(&iom,address_to_write_to,data_to_write);
	
	Add the following in the while loop:
	
		.....
		.....
		sleep(100)
		xil_printf("Read data bus data: %08X\n",XIOModule_IoReadWord(&iom,0));
		
		switch(counter)
		{
			case 100:
				XIOModule_IoWriteWord(&iom,23,79);
				break;
			case 200:
				XIOModule_IoWriteWord(&iom,22,0x12345678);
				break;
			case 300:	
				XIOModule_IoWriteWord(&iom,128*128-1,0xFEDCBA98);
				break;
			case 400:	
				XIOModule_IoWriteWord(&iom,256,0x55AABBDD);
				break;
			default:
				break;
		}
		.....
		.....
		
	
	Verify that the behaviour of the circuit is as expected: is the value read from the module as expected? 
	Are the values on the 7-segment display as expected?
	
******************************************************************************/


/******************************************************************************
	Part 6: Test the external memoryinterface
	We will test the external memory progressively writing data to subsequent addreses, and reading the first few bytes back
	
	6.1: First comment out the entirety of the statements included in part 5 (the xil_printf of the data on the bus and the switch statement.
	
	6.2: Replace it with this:
	
		.....
		.....
		sleep(100)
		
		// Write at the address of the counter some test value (here counter*3)
		XIOModule_IoWriteWord(&iom,counter,3*counter);
		
		// Read out the first few bytes of memory
		xil_printf("IO read:\n");
    for(int i=0;i<128;i++)
    {
    	xil_printf("%08X ",XIOModule_IoReadWord(&iom,i));
    	if((i%8)==7)
    		xil_printf("\n");
    }
    
	
	6.3: Verify that the behaviour of the circuit is as expected: is the content stored in the RAM as expected?
	
******************************************************************************/

/******************************************************************************
	Part 8: Working VGA framebuffer
	
	Assuming the addressing of the dual-port RAM neglects the lower 2 bits of the CPU address, this means
	that writes to cpu address 0-3 occur on the same memory cell at memory address 0, and writes to cpu address 4-7 occur
	on the same memory cell at memory address 1, etc.
	(previously writes to cpu address 0-3 occured on memory address 0, but writes to cpu address 4-7 occured to memory cell 4,
	thus wasting space; this was due to not using IO_Byte_Enable to simplify the hardware, but needs now to be "hacked around").
	
	We can now create a function to put a pixel at a specific memory location.
	
	8.1: Add the following two functions: 
	
		.....
		.....	
		void putpixel(XIOModule *iom,int x,int y,int c)
		{
			XIOModule_IoWriteWord(iom,(y*128+x)<<2,c);
		}
		
		void trypixels(XIOModule *iom)
		{
			for(int y=0;y<16;y++)
				for(int x=0;x<128;x++)
					putpixel(iom,x,y,0b111);
			for(int y=16;y<32;y++)
			{
				for(int x=0;x<32;x++)
				{
					putpixel(iom,x,y,0b100);
					putpixel(iom,x+32,y,0b010);
					putpixel(iom,x+64,y,0b001);
					putpixel(iom,x+96,y,0b000);
				}
			}
		}
		.....
		.....

	8.2: Add a call to trypixels just before the while(1) loop:
	
		.....
		.....
		trypixels(&iom);
		while(1)
		{
		.....
		.....

	
******************************************************************************/


volatile int int_counter=0;

void timerTick(void* ref)
{
	int_counter++;
}

void sleep(int ms)
{
	int t = int_counter;
	while(int_counter<t+ms);
}

void putpixel(XIOModule *iom,int x,int y,int c)
{
	XIOModule_IoWriteWord(iom,(y*128+x)<<2,c);
}

void trypixels(XIOModule *iom)
{
	for(int y=0;y<16;y++)
		for(int x=0;x<128;x++)
			putpixel(iom,x,y,0b111);
	for(int y=16;y<32;y++)
	{
		for(int x=0;x<32;x++)
		{
			putpixel(iom,x,y,0b100);
			putpixel(iom,x+32,y,0b010);
			putpixel(iom,x+64,y,0b001);
			putpixel(iom,x+96,y,0b000);
		}
	}
}

int main()
{
	// 
	// Part 2.2: Read GPI state and store it to GPO, effectively activating the LEDs according to the switches
	// Uncomment the following lines, and then compile the program with sdk-compile.bat
	// 
	
	int data;							// Used to read GPI and for other purposes
	int counter=0;				// Iteration counter
	XIOModule iom;				// IO module configuration structure; holds all configuration related to GPIO, FIT, PIT, etc 
	
	
	XIOModule_Initialize(&iom, XPAR_IOMODULE_0_DEVICE_ID);			// Initialize the IO data structure
	XIOModule_Start(&iom);																			// Enable the IO module
		
	// Connect the interrupt vector to our interrupt function
	XIOModule_Connect(&iom, XIN_IOMODULE_FIT_1_INTERRUPT_INTR, timerTick, NULL);
	// Enable timer interrupt
	XIOModule_Enable(&iom, XIN_IOMODULE_FIT_1_INTERRUPT_INTR);
	// Interrupts require to enable exceltions too
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler) XIOModule_DeviceInterruptHandler, NULL);
	Xil_ExceptionEnable();
	// Enable interrupts
	microblaze_enable_interrupts();		
		
	xil_printf("Hello world, this is a serial line test\n");
		
	trypixels(&iom);
	while(1)																										// Infinite loop
	{
		xil_printf("Elapsed time: %d ms after %d iterations.\n",int_counter,counter);
		sleep(100);
		
		/*xil_printf("Read data bus data: %08X\n",XIOModule_IoReadWord(&iom,0));
		
		switch(counter)
		{
			case 100:
				XIOModule_IoWriteWord(&iom,23,79);
				break;
			case 200:
				XIOModule_IoWriteWord(&iom,22,0x12345678);
				break;
			case 300:	
				XIOModule_IoWriteWord(&iom,128*128-1,0xFEDCBA98);
				break;
			case 400:	
				XIOModule_IoWriteWord(&iom,256,0x55AABBDD);
				break;
			default:
				break;
		}*/
		
		// Write at the address of the counter some test value (here counter*3)
		XIOModule_IoWriteWord(&iom,counter,3*counter);
		
		// Read out the first few bytes of memory
		xil_printf("IO read:\n");
    for(int i=0;i<128;i++)
    {
    	xil_printf("%08X ",XIOModule_IoReadWord(&iom,i));
    	if((i%8)==7)
    		xil_printf("\n");
    }
		
  	data = XIOModule_DiscreteRead(&iom, 1);										// Read the 32-bits on GPI 1
    XIOModule_DiscreteWrite(&iom, 1,data);										// Write them to GPO 1
    counter++;																								// Count how often this loop ran
	}
	
	
	while(1);		// Infinite loop
	return 0;
}

