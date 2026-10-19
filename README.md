# SOMRT1061_Persistent_Memory

# What is this?
This code enables the ability to write to a section of RAM on the NXP SOMRT1061 for the purpose of debugging crashes that happen during runtime. RAM will hold all data between resets as long as there is no loss of power.

# How does it work?
There is a linker file provided that you will use in your project. It takes a section of RAM and prevents any data being written to it during boot. You are able to write to this section of RAM during application runtime. On boot the MCU will print any data written in RAM which may contain hints as to why it crashed.

# How do I use it?
Tell your IDE that you want to use the linker file included in this project. This is the default SOMRT1016 linker file that is provided by NXP with the debugging RAM section added. If you have made any changes to your linker file for your project you may need to add your own RAM section to your linker file instead of using the one provided here.

Add the "RAM_Debug.h" to your include list and "RAM_Debug.cpp" to your source list.

For adding the code to your project, see the example.


# NXP i.MX RT1061 linker script

The linker script in linker/ is derived from a linker script provided by NXP (formerly Freescale Semiconductor).

The original copyright notices and license identification are retained in the source file. The file may be modified and redistributed subject to the applicable license terms.

The MCU Debug project is an independent community project and is not affiliated with or endorsed by NXP.