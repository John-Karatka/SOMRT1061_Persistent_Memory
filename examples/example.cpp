#include <init.h>
#include <nbrtos.h>
#include <stdlib.h>
#include <system.h>
#include <utils.h>
#include <SysLog.h>
#include <HiResDelay.h>
#include <MIMXRT1061.h>

#include "RAM_Debug.h"

const char *AppName = "RAM Logging Example";

uint32_t Task_milliSecondTaskStack[USER_TASK_STK_SIZE];
uint32_t Task_snapshotTaskStack[USER_TASK_STK_SIZE];

uint32_t loopCount_seconds = 0;
uint32_t loopCount_milliSeconds = 0;

/*
 * This task will count milliseconds and log them into RAM
 */
void Task_milliSecondTask(void *pd)
{
    SysLog("Starting millisecond counter...");
    static DelayObject delay;

    /*
     * Task loop will increment milliseconds and log them
     */
    while (1) {
    	debugStruct.debug_1.value = (int32_t)loopCount_milliSeconds;	//Write to RAM
    	loopCount_milliSeconds++;										//Increase counter
    	delay.DelayUsec(1000); 											//1 millisecond delay
    }
}

/*
 * This task will log snapshot data and log it into RAM
 */
void Task_snapshotTask(void *pd) {

	SysLog("Starting snapshot task...");
	static DelayObject delay;

	/*
	 * Saves snapshot data
	 */
	while(1) {
		snapshot.hfsr  = SCB->HFSR;
		snapshot.dfsr  = SCB->DFSR;
		snapshot.afsr  = SCB->AFSR;
		snapshot.mmfar = SCB->MMFAR;
		snapshot.bfar  = SCB->BFAR;
		snapshot.memFaultValid = ((SRC->SRSR) & SCB_CFSR_MMARVALID_Msk);
		snapshot.busFaultValid = ((SRC->SRSR) & SCB_CFSR_BFARVALID_Msk);
		delay.DelayUsec(100); 											//10 millisecond delay
	}
}


void UserMain(void *pd)
{
    int returnCode;

    init();                                       						// Initialize network stack
    WaitForActiveNetwork(TICKS_PER_SECOND * 5);   						// Wait for DHCP address

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
	 * Create tasks
	 */
    SysLog("Creating Millisecond Counter Task...");
    returnCode = OSTaskCreatewName(Task_milliSecondTask,                            // Task function name
                                   NULL,                         					// Optional parameter, NULL if not used
                                   &Task_milliSecondTaskStack[USER_TASK_STK_SIZE],  // Top of task stack
								   Task_milliSecondTaskStack,                       // Bottom of task stack
								   OSGetNextPrio(OSNextPrio::Above),                // Priority
                                   "Task RAM Debug");                          		// Name
    if (returnCode == OS_NO_ERR)
        SysLog("Millisecond task creation successful");
    else
        SysLog("*** Error creating millisecond task: status = %d", returnCode);

    SysLog("Creating Snapshot Task...");
	returnCode = OSTaskCreatewName(Task_snapshotTask,                            // Task function name
								   NULL,                         				 // Optional parameter, NULL if not used
								   &Task_snapshotTaskStack[USER_TASK_STK_SIZE],  // Top of task stack
								   Task_snapshotTaskStack,                       // Bottom of task stack
								   OSGetNextPrio(OSNextPrio::Above),             // Priority
								   "Task RAM Debug");                          	 // Name
	if (returnCode == OS_NO_ERR)
		SysLog("Snapshot task creation successful");
	else
		SysLog("*** Error creating snapshot task: status = %d", returnCode);


    /*
     * Main loop will increment seconds and log them
     */
    SysLog("Starting main loop...");
    while (1)
    {
    	debugStruct.debug_2.value = (int32_t)loopCount_seconds;	//Write to RAM
    	loopCount_seconds++;									//Increase counter
    	OSTimeDly(TICKS_PER_SECOND * 1);						//Delay one second
    }
}
