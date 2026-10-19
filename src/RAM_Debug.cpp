#include "RAM_Debug.h"
#include <SysLog.h>
#include <MIMXRT1061.h>
#include <HiResDelay.h>
#include <nbrtos.h>

__attribute__((section(".noinit"))) volatile uint32_t first_reset_check_RAM;
__attribute__((section(".noinit"))) volatile uint32_t reset_count_RAM;
__attribute__((section(".noinit"))) volatile debugStruct_t debugStruct;
__attribute__((section(".noinit"))) volatile FaultSnapshot snapshot;
__attribute__((section(".noinit"))) volatile bool snapshotRunning;

uint32_t Task_snapshotTaskStack[USER_TASK_STK_SIZE];

void Task_snapshotTask(void *pd) {

	SysLog("Starting snapshot task...");
	unsigned int delayMsec = (unsigned int)pd;
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
		delay.DelayUsec(delayMsec * 1000); 									//Delay
	}
}

void startSnapshotLogging(unsigned int delay) {
    SysLog("Creating Snapshot Task...");
    int returnCode;

	returnCode = OSTaskCreatewName(Task_snapshotTask,                            // Task function name
								   (void *)&delay,                         				 // Optional parameter, NULL if not used
								   &Task_snapshotTaskStack[USER_TASK_STK_SIZE],  // Top of task stack
								   Task_snapshotTaskStack,                       // Bottom of task stack
								   OSGetNextPrio(OSNextPrio::Above),             // Priority
								   "Task RAM Debug");                          	 // Name
	if (returnCode == OS_NO_ERR) {
		SysLog("Snapshot task creation successful");
		snapshotRunning = true;
	}
	else
		SysLog("*** Error creating snapshot task: status = %d", returnCode);
}

//This will take a starting struct and will only use it if it doesn't remember what it used to be
void runFirstCheckReport(debugNames_t startingNames, unsigned int snapshotTaskDelay_ms) {
	SysLog("------------BEGIN DEBUG REPORT------------------");

	if (first_reset_check_RAM != FIRST_RESET_CHECK) {
	  first_reset_check_RAM = FIRST_RESET_CHECK;
	  reset_count_RAM = 0;

	  //Save the names so we can read them later
	  debugStruct.debug_1.name = startingNames.debug_name1;
	  debugStruct.debug_2.name = startingNames.debug_name2;
	  debugStruct.debug_3.name = startingNames.debug_name3;
	  debugStruct.debug_4.name = startingNames.debug_name4;
	  debugStruct.debug_5.name = startingNames.debug_name5;
	  debugStruct.debug_6.name = startingNames.debug_name6;
	  debugStruct.debug_7.name = startingNames.debug_name7;
	  debugStruct.debug_8.name = startingNames.debug_name8;
	  debugStruct.debug_9.name = startingNames.debug_name9;
	  debugStruct.debug_10.name = startingNames.debug_name10;

	  SysLog("Could not load previous data, try soft resetting");
	}
	else {
		reset_count_RAM++;
		SysLog("Data load successful! This is reset number %lu", reset_count_RAM);

	    //Get reset status
	    uint32_t reset_status = SRC->SRSR;

	    //Report the recorded reset reason
	    if ((reset_status & SRC_SRSR_WDOG_RST_B_MASK) != 0U) {
	        /* Main watchdog timeout */
	    	SysLog("SRC reports reset due to watchdog timeout");
	    }

	    if ((reset_status & SRC_SRSR_WDOG3_RST_B_MASK) != 0U) {
	        /* Watchdog 3 timeout */
	    	SysLog("SRC reports reset due to watchdog 3 timeout");
	    }

	    if ((reset_status & SRC_SRSR_LOCKUP_SYSRESETREQ_MASK) != 0U) {
	        /* CPU lockup */
	    	SysLog("SRC reports reset due to CPU lockup");
	    }

	    if ((reset_status & SRC_SRSR_IPP_RESET_B_MASK) != 0U) {
	        /* Reset button */
	    	SysLog("SRC reports reset due to external reset button");
	    }

	    if ((reset_status & SRC_SRSR_TEMPSENSE_RST_B_MASK) != 0U) {
	    	/* Overtemp */
	    	SysLog("SRC reports reset due to over temperature");
	    }

	    if ((reset_status & SRC_SRSR_CSU_RESET_B_MASK) != 0U) {
	    	/* CSU reset */
	    	SysLog("SRC reports reset due to CSU");
	    }

	    //Report the data held in RAM
	    if (debugStruct.debug_1.name != "unnamed")
	    	SysLog("%s - %lu", debugStruct.debug_1.name, debugStruct.debug_1.value);
	    if (debugStruct.debug_2.name != "unnamed")
	    	SysLog("%s - %lu", debugStruct.debug_2.name, debugStruct.debug_2.value);
	    if (debugStruct.debug_3.name != "unnamed")
	    	SysLog("%s - %lu", debugStruct.debug_3.name, debugStruct.debug_3.value);
	    if (debugStruct.debug_4.name != "unnamed")
	    	SysLog("%s - %lu", debugStruct.debug_4.name, debugStruct.debug_4.value);
	    if (debugStruct.debug_5.name != "unnamed")
	    	SysLog("%s - %lu", debugStruct.debug_5.name, debugStruct.debug_5.value);
		if (debugStruct.debug_6.name != "unnamed")
			SysLog("%s - %lu", debugStruct.debug_6.name, debugStruct.debug_6.value);
		if (debugStruct.debug_7.name != "unnamed")
			SysLog("%s - %lu", debugStruct.debug_7.name, debugStruct.debug_7.value);
		if (debugStruct.debug_8.name != "unnamed")
			SysLog("%s - %lu", debugStruct.debug_8.name, debugStruct.debug_8.value);
		if (debugStruct.debug_9.name != "unnamed")
			SysLog("%s - %lu", debugStruct.debug_9.name, debugStruct.debug_9.value);
		if (debugStruct.debug_10.name != "unnamed")
			SysLog("%s - %lu", debugStruct.debug_10.name, debugStruct.debug_10.value);

		if(snapshotRunning) {
			SysLog("Snapshot report:");
			SysLog("HardFault register - %lu", snapshot.hfsr);
			SysLog("DebugFault register - %lu", snapshot.dfsr);
			SysLog("AuxiliaryFault register - %lu", snapshot.afsr);

			if(snapshot.memFaultValid) {
				SysLog("Memfault has a valid address - 0x%X", snapshot.mmfar);
			}
			else {
				SysLog("No MemFault errors");
			}
			if (snapshot.busFaultValid) {
				SysLog("Busfault has a valid address - 0x%X", snapshot.bfar);
			}
			else {
				SysLog("No BusFault errors");
			}
		}
	}
	SysLog("--------------END DEBUG REPORT------------------");
	startSnapshotLogging(snapshotTaskDelay_ms);
}
