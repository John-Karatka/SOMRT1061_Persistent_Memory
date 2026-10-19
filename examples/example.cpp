#include <init.h>
#include <nbrtos.h>
#include <stdlib.h>
#include <system.h>
#include <utils.h>

#include "RAM_Debug.h"

const char *AppName = "RAM Logging Example";

uint32_t Task_milliSecondTaskStack[USER_TASK_STK_SIZE];

uint32_t loopCount_seconds = 0;
uint32_t loopCount_milliSeconds = 0;


void Task_milliSecondTask(void *pd)
{
    iprintf("Starting millisecond counter...\r\n");

    /*
     * Task loop will increment milliseconds and log them
     */
    while (1) {
    	loopCount_milliSeconds++;										//Increase counter
    	debugStruct.debug_1.value = (int32_t)loopCount_milliSeconds;	//Write to RAM
    	OSTimeDly(TICKS_PER_SECOND * 0.001);							//Delay one millisecond
    }
}

void UserMain(void *pd)
{
    int returnCode;

    init();                                       // Initialize network stack
    WaitForActiveNetwork(TICKS_PER_SECOND * 5);   // Wait for DHCP address

    /*
     * Create names for the data we want to store.
     * You can create up to 10 names
     */
	debugNames_t startingNames {
		"MillisecondsCounter",
		"SecondsCounter"
	};

	runFirstCheckReport(startingNames);	//Check if this is the first reset

	/*
	 * Create millisecond counter task
	 */
    iprintf("Creating Millisecond Counter Task...\r\n");
    returnCode = OSTaskCreatewName(Task_milliSecondTask,                            // Task function name
                                   NULL,                         				// Optional parameter, NULL if not used
                                   &Task_milliSecondTaskStack[USER_TASK_STK_SIZE],  // Top of task stack
								   Task_milliSecondTaskStack,                       // Bottom of task stack
                                   MAIN_PRIO - 1,                             	// Priority
                                   "Task RAM Debug");                          	// Name
    if (returnCode == OS_NO_ERR)
        iprintf("Task creation successful\r\n");
    else
        iprintf("*** Error: status = %d\r\n", returnCode);


    /*
     * Main loop will increment seconds and log them
     */
    iprintf("Starting main loop...\r\n");
    while (1)
    {
    	loopCount_seconds++;									//Increase counter
    	debugStruct.debug_2.value = (int32_t)loopCount_seconds;	//Write to RAM
    	OSTimeDly(TICKS_PER_SECOND * 1);						//Delay one second
    }
}
