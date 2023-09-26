// Lab 6 template


#include "xparameters.h"
#include "xiomodule.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h> 


unsigned long hex2int(char *hex) {
    unsigned long val = 0;
    while (*hex) {
        // get current character then increment
        unsigned char byte = *hex++; 
        // transform hex character to the 4bit equivalent number, using the ascii table indexes
        if (byte >= '0' && byte <= '9') byte = byte - '0';
        else if (byte >= 'a' && byte <='f') byte = byte - 'a' + 10;
        else if (byte >= 'A' && byte <='F') byte = byte - 'A' + 10;    
        // shift 4 to make space for new digit, and add the 4 bits of the new digit 
        val = (val << 4) | (byte & 0xF);
    }
    return val;
}

int main()
{

    int data;							// Used to read GPI and for other purposes
    XIOModule iom;				// IO module configuration structure; holds all configuration related to GPIO, FIT, PIT, etc 
    
    
    XIOModule_Initialize(&iom, XPAR_IOMODULE_0_DEVICE_ID);			// Initialize the IO data structure
    XIOModule_Start(&iom);																			// Enable the IO module
        
    // Connect the interrupt vector to our interrupt function
    //XIOModule_Connect(&iom, XIN_IOMODULE_FIT_1_INTERRUPT_INTR, timerTick, NULL);
    // Enable timer interrupt
    XIOModule_Enable(&iom, XIN_IOMODULE_FIT_1_INTERRUPT_INTR);
    // Interrupts require to enable exceltions too
    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler) XIOModule_DeviceInterruptHandler, NULL);
    Xil_ExceptionEnable();
    // Enable interrupts
    microblaze_enable_interrupts();		
        
    xil_printf("Hello world, this is a serial line test\n");
        
    //char buffer1[8];	
    //char buffer2[8];
    //char buffer3[8];
    //char buffer4[8];
    
    
    char buffer1[9];
    char buffer2[9];
    char buffer3[9];
    char buffer4[9];
    
    unsigned int gpo1;
    unsigned int gpo2;
    unsigned int gpo3;
    unsigned int gpo4;
    
    int state = 0;
	int Astate = 0;
    int Aiter = 0;

    char version[9] = "00000001";
	// !! change below !!
	char timestamp[9] = "00000000";
	
	char bits[9] = "00000000";
    
    // 00000000 00000b60 bc96a447 24fd72da f9b92cf8 ad00510b 5224c625 3ac40095
    char prevBlock[65] = "0000000000000b60bc96a44724fd72daf9b92cf8ad00510b5224c6253ac40095";
	// 0e60651a 9934e8f0 decd1c5f de39309e 48fca0cd 1c84a21d dfde9503 3762d86c
    char merkleroot[65] = "0e60651a9934e8f0decd1c5fde39309e48fca0cd1c84a21ddfde95033762d86c";
	
	char prevAndMerkle[129];
	char vertimebits[33];


    while(1)
    {
		switch(state)
		{
			case 0:
			
				switch(Astate)
				{
					case 0:
					strcpy(prevAndMerkle, prevBlock);
					strcat(prevAndMerkle, merkleroot);
				
					gpo1 = hex2int(version); // Version into GPO1
					gpo2 = hex2int(timestamp); //Timestamp into GPO2
					gpo3 = hex2int(bits); //Bits (Target difficulty) into GPO3
					
					gpo4 = 0x00000000; //Clock cycle
					
					Astate = 1; // Switch to next state of initialisation

					break;
		
		
					case 1:
					
        				for(int i = Aiter ; i < Aiter+8 ; i++) // from Aiter --> Aiter + 8
        				{
        				 	buffer1[i-(Aiter)] = prevAndMerkle[i];
        				}
    
    					for(int i = (Aiter+8) ; i < Aiter+16 ; i++) // from Aiter+8 --> Aiter+16
    					{
        					buffer2[i-8-(Aiter)] = prevAndMerkle[i];
    					}
    
    					for(int i = (Aiter+16) ; i < (Aiter+24) ; i++) // from Aiter+16 --> Aiter+24
    					{
     						buffer3[i-16-(Aiter)] = prevAndMerkle[i];
    					}
						
    					gpo4 = gpo4 + 1; // Clock cycle
						
    					//Convert 8 byte hexadecimal string into unsigned int for transfer
    					gpo1 = hex2int(buffer1); 
    					gpo2 = hex2int(buffer2);
    					gpo3 = hex2int(buffer3);
					
						Aiter = Aiter + 24; // Increment Aiter by 24 every cycle, as 96 bits/24 hexadecimals are being sent every cycle
					
						if(Aiter == 120) 
						{
							Astate = 2; // Last cycle of initialisation
						}
					
					break;
					
					case 2:
					
						for(int i = Aiter ; i < Aiter+8 ; i++)
        					{
        					 	buffer1[i-(Aiter)] = prevAndMerkle[i];
        					}
							
							gpo1 = hex2int(buffer1);
    						gpo2 = 0x00000000;
							gpo3 = 0x00000000;
							
							gpo4 = gpo4 + 1;
					
						Astate = 3;
					break;
					
					case 3:
					
						gpo1 = 0x00000000;
						gpo2 = 0x00000000;
						gpo3 = 0x00000000;
						Aiter = Aiter + 1;
						
					break;
				
				}
		}
    
    



    	xil_printf("state :%d Astate :%d Aiter :%d\n", state, Astate, Aiter);
    	xil_printf("gpo1 :%s gpo2 :%s gpo3 :%s  gpo4 :%d\n", buffer1, buffer2, buffer3, gpo4);

	

  	    data = XIOModule_DiscreteRead(&iom, 1);	// Read the 32-bits on GPI 1

 	    XIOModule_DiscreteWrite(&iom, 1, gpo1);	// Write them to GPO 1		
 	    XIOModule_DiscreteWrite(&iom, 2, gpo2);	// Write them to GPO 2	
  	    XIOModule_DiscreteWrite(&iom, 3, gpo3);	// Write them to GPO 3	
  	    XIOModule_DiscreteWrite(&iom, 4, gpo4);	// Write them to GPO 4	


    }
    
    return 0;
}

