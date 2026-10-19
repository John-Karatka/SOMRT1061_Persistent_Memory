#ifndef RAM_DEBUG_H_
#define RAM_DEBUG_H_

/*
 * !!THIS REQUIRES A NEW LINKER FILE THAT CAN BE FOUND IN THIS FOLDER!!
 * Go to properties -> C/C++ Build -> GNU C/C++ Linker -> Miscellaneous
 * Set it to this:
	-Wl,-n -T${ProjDirPath}/wam-v-22-mre-firmware-libraries/include/Debug/SOMRT1061_custom_OPT.ld -Wl,-R${NNDK_ROOT}/platform/${PLATFORM}/lib/sys.ld -Wl,--cref
 *
 * HOW TO USE:
 * Define a local debugNames_t in your code with the names you want to give to the values 1 - 5
 * Call runFirstCheckReport() with your assigned naming convention before your main loop
 * Set the values in debugStruct during your main loop according to how you named them
 * You do not need to use all 5 values. More can also be added if needed
 *
 * If runFirstCheckReport is run for the first time it will set the names associated with the values
 * If runFirstCheckReport finds available data it will not write anything and only read
 *
 *

 Example code:
//---------------------------------------------------------------------
	//Initialization
	init() {
	//Declare names for the values you're writing during main loop
	debugNames_t startingNames {
		"loopCount",
		"lastHeartbeatMs",
		"maxLoopoDtMs",
		"lastLoopMs",
		"tempDegC"
	};

	//Check if this is the first reset
	runFirstCheckReport(startingNames);
	}

	//Main loop
	mainLooop() {
		//Set values during main loop
	    debugStruct.debug_1.value = (int32_t)loopCount;
        debugStruct.debug_2.value = (int32_t)lastHeartbeatMs;
        debugStruct.debug_3.value = (int32_t)maxLoopDtMs;
        debugStruct.debug_4.value = (int32_t)lastLoopMs;
        debugStruct.debug_5.value = (int32_t)tempDegC;
	}
 //---------------------------------------------------------------------
 */

#include <stdint.h>

struct FaultSnapshot
{
    uint32_t hfsr;
    uint32_t dfsr;
    uint32_t afsr;
    uint32_t mmfar;
    uint32_t bfar;
    bool memFaultValid;
    bool busFaultValid;
};

struct debugObject_t {
	uint32_t value = 0x00;
	const char * name = "unnamed";
};

struct debugStruct_t {
	debugObject_t debug_1;
	debugObject_t debug_2;
	debugObject_t debug_3;
	debugObject_t debug_4;
	debugObject_t debug_5;
	debugObject_t debug_6;
	debugObject_t debug_7;
	debugObject_t debug_8;
	debugObject_t debug_9;
	debugObject_t debug_10;
};

struct debugNames_t {
	const char* debug_name1 = "unnamed";
	const char* debug_name2 = "unnamed";
	const char* debug_name3 = "unnamed";
	const char* debug_name4 = "unnamed";
	const char* debug_name5 = "unnamed";
	const char* debug_name6 = "unnamed";
	const char* debug_name7 = "unnamed";
	const char* debug_name8 = "unnamed";
	const char* debug_name9 = "unnamed";
	const char* debug_name10 = "unnamed";
};

//First reset check stuff
#define FIRST_RESET_CHECK 0xDEADBEEF

extern volatile uint32_t first_reset_check_RAM;
extern volatile uint32_t reset_count_RAM;
extern volatile debugStruct_t debugStruct;
extern volatile FaultSnapshot snapshot;
//----------------------------------------------------------------

void runFirstCheckReport(debugNames_t startingNames);

#endif