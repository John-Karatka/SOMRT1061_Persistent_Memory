#ifndef RAM_DEBUG_H_
#define RAM_DEBUG_H_

#include <stdint.h>

namespace RAM_debug {

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

	/*
	 * @brief: Runs a check to see if any memory is saved to RAM and starts the snapshot task
	 * @param startingNAmes: Defines the data that should be stored with names to print to debug
	 * @param snapshotTaskDelay_ms: Delay between recording snapshot data
	 */
	void runFirstCheckReport(debugNames_t startingNames, unsigned int snapshotTaskDelay_ms);
}

#endif
