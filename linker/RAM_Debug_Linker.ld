/*
** ###################################################################
**     Processors:          MIMXRT1061CVJ5A
**                          MIMXRT1061CVL5A
**                          MIMXRT1061DVJ6A
**                          MIMXRT1061DVL6A
**
**     Compiler:            GNU C Compiler
**     Reference manual:    IMXRT1060RM Rev.1, 12/2018
**     Version:             rev. 0.1, 2017-01-10
**     Build:               b190312
**
**     Abstract:
**         Linker file for the GNU C Compiler
**
**     Copyright 2016 Freescale Semiconductor, Inc.
**     Copyright 2016-2019 NXP
**     All rights reserved.
**
**     SPDX-License-Identifier: BSD-3-Clause
**
**     http:                 www.nxp.com
**     mail:                 support@nxp.com
**
** ###################################################################
*/

/* Entry Point */
ENTRY(_start)

HEAP_SIZE  = DEFINED(__heap_size__)  ? __heap_size__  : 0x0400;
STACK_SIZE = DEFINED(__stack_size__) ? __stack_size__ : 0x0400;

/* Specify the memory areas. noinit is used for debugging on this project */
MEMORY
{
  vects                (rwx)  : ORIGIN = 0x00000000, LENGTH = 0x00000400
  itcm                 (rwx)  : ORIGIN = 0x00000400, LENGTH = 0x0001FC00
  dtcm                 (rwx)  : ORIGIN = 0x20000000, LENGTH = 0x00020000
  noinit               (rwx)  : ORIGIN = 0x20200000, LENGTH = 0x100
  sram                 (rwx)  : ORIGIN = 0x20200000 + 0x100, LENGTH = 0x000C0000 - 0x100
  hRAM                 (RWX)  : ORIGIN = 0x60000000, LENGTH = 0x02000000
  flash                (RW)   : ORIGIN = 0x68000000, LENGTH = 0x00800000
  SEMC                 (RWX)  : ORIGIN = 0x98000000, LENGTH = 0x01000000
}

PROVIDE (BASE_SRAM  = ORIGIN(sram));

PROVIDE(BASE_FLASH = ORIGIN(m_flash_config));
PROVIDE(FlashAppBase = ORIGIN(flash)+0x20000);
PROVIDE(FlashLimit = ORIGIN(flash)+0x100000);
PROVIDE(FLASH_ALIAS = ORIGIN(flash_alias));
PROVIDE(HyperRAM_BASE = ORIGIN(hRAM));
PROVIDE(HyperRAM_END = ORIGIN(hRAM)+LENGTH(hRAM));
PROVIDE(SEMC_Base = ORIGIN(SEMC));
PROVIDE(__BOOT_MON_CMD = ORIGIN(sram)+LENGTH(sram)-0x180);
PROVIDE(__BOOT_LOOP_PROT = ORIGIN(sram)+LENGTH(sram)-0x10);
__dram_start = ORIGIN(hRAM);
__dram_end = ORIGIN(hRAM)+LENGTH(hRAM);

/* Define output sections */
SECTIONS
{
    .itcm : AT(__pevects)
    {
        _sitcm = .;
        _s_ram_func = .;
        SRAMFnBase = .;
        *:tcp.o(.text.*);
        *:ethernet.o(.text.*);
        *:ether_phys.o(.text.*);
        *:nbrtos.o(.text.*);
        *:OSTaskDly.o(.text.*);
        *:nbiprintf.o(.text.*);
        *:netrx.o(.text.*);
        *:ip.o(.text.*);
        *:udp.o(.text.*);
        *:usb.o(.text.*);
        *:serial.o(.text.*);
        *:usb_dev.o(.text.*);
        *:buffers.o(.text.*);
        *:SPIFlash.o(.text.*);
        *:pin_irq_as.o(.text.*);
        *:tcp.od(.text.*);
        *:ethernet.od(.text.*);
        KEEP( *:dbethernet.od(.text.*) );
        *:ether_phys.od(.text.*);
        *:nbrtos.od(.text.*);
        *:OSTaskDly.od(.text.*);
        *:netrx.od(.text.*);
        *:ip.od(.text.*);
        *:udp.od(.text.*);
        *:usb.od(.text.*);
        *:serial.od(.text.*);
        *:usb_dev.od(.text.*);
        *:buffers.od(.text.*);
        *:SPIFlash.od(.text.*);
        *:pin_irq_as.od(.text.*);

        *(.ram_func);
        SHORT(0xbf00); /* This is a load bearing line,                   */
        SHORT(0xbf00); /*   as otherwise this segment will not be output */
        SRAMFnEnd = .;
        _e_ram_func = .;
        _eitcm = .;
        
    } > itcm

   .rel_dtcm : AT(__peitcm)
    {
        _sdtcm = .;
        . = ALIGN(4);
        *netburner.a:*.o(.rodata._ZTV*); /* Place vtables here */
        *:pin_irq_as.o(.bss.*);
        *netburner.a:*.od(.rodata._ZTV*); /* Place vtables here */
        *:pin_irq_as.od(.bss.*);
        
        . = ALIGN (4);
        *( SYS_VAR_SECT_REL )
        *( SYS_VAR_SECT_REL_STR )
        SYS_VAR_SECT_END = .;
        . = ALIGN (4);  
        *( USB_VAR_SECT_REL )
        USB_VAR_SECT_END = .;
        . = ALIGN (4);  
        *( IP_VAR_SECT_REL )
        IP_VAR_SECT_END = .;
        . = ALIGN (4);
        *( TCP_VAR_SECT_REL )
        TCP_VAR_SECT_END = .;
    } > dtcm


    /*__sfixed = _eshim + SIZEOF(.relocate); */
    .text :
    {
        _stext = .;
        /* Support C constructors, and C destructors in both user code
           and the C library. This also provides support for C++ code. */
        . = ALIGN(4);
        KEEP(*(.init))
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP (*(.preinit_array))
        __preinit_array_end = .;

        . = ALIGN(4);
        __hw_init_array_start = .;
        KEEP (*:hal.o(.init_array .init_array.*))
        KEEP (*:hal_storage.o(.init_array .init_array.*))
        KEEP (*:hal.od(.init_array .init_array.*))
        KEEP (*:hal_storage.od(.init_array .init_array.*))
        __hw_init_array_end = .;
        . = ALIGN(4);
        __init_array_start = .;
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array))
        __init_array_end = .;

        . = ALIGN(0x4);
        KEEP (*crtbegin.o(.ctors))
        KEEP (*crtbegin.od(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.od) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*crtend.o(.ctors))
        KEEP (*crtend.od(.ctors))

        . = ALIGN(4);
        KEEP(*(.fini))

        . = ALIGN(4);
        __fini_array_start = .;
        KEEP (*(.fini_array))
        KEEP (*(SORT(.fini_array.*)))
        __fini_array_end = .;

        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin.od(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o) .dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.od) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*crtend.o(.dtors))
        KEEP (*crtend.od(.dtors))

        KEEP (*(.text._start))
        *(.text .text.*)
        . = ALIGN(4);
        _etext = .;
        _srodata = .;
        KEEP (*(.rodata.*openocd*))
        *(.rodata .rodata* .gnu.linkonce.r.*)
        _erodata = .;
        . = ALIGN (8);
        *(.got);
        *(.got.*);
        . = ALIGN(4);
        _efixed = .;            /* End of text section */
    } > hRAM

    .ramfunc.exidx : AT(__e_hram)
    {
        __ramfunc_exidx_start = .;
        _ramfunc_sexidx = .;
        *:tcp.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:ethernet.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:ether_phys.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:nbrtos.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:OSTaskDly.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:nbiprintf.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:netrx.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:ip.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:udp.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:usb.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:serial.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:usb_dev.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:buffers.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:SPIFlash.o(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:tcp.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:ethernet.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:dbethernet.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:ether_phys.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:nbrtos.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:OSTaskDly.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:netrx.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:ip.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:udp.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:usb.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:serial.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:usb_dev.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:buffers.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *:SPIFlash.od(.ARM.exidx.* .gnu.linkonce.armexidx.*)
        *(.ARM.exidx.ram_func .gnu.linkonce.armexidx.ram_func)
        _ramfunc_eexidx = .;
        __ramfunc_exidx_end = .;
    } > sram

    .ramfunc.extab : AT(__e_hram + SIZEOF(.ramfunc.exidx) )
    {
        __ramfunc_extab_start = .;
        _ramfunc_sextab = .;
        *:tcp.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:ethernet.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:ether_phys.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:nbrtos.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:OSTaskDly.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:nbiprintf.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:netrx.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:ip.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:udp.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:usb.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:serial.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:usb_dev.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:buffers.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:SPIFlash.o(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:tcp.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:ethernet.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:dbethernet.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:ether_phys.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:nbrtos.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:OSTaskDly.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:netrx.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:ip.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:udp.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:usb.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:serial.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:usb_dev.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:buffers.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *:SPIFlash.od(.ARM.extab.* .gnu.linkonce.armextab.*)
        *(.ARM.extab.ram_func .gnu.linkonce.armextab.ram_func)
        . = ALIGN(8);
        _ramfunc_eextab = .;
        __ramfunc_extab_end = .;
    } > sram
	
	/* OPT custom debugging section of persistant memory */
	.noinit (NOLOAD) :
	{
		KEEP(*(*.noinit*))
	} > noinit

    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    .ARM.exidx : /*AT(__efixed)*/
    {
        __exidx_start = .;
        _sexidx = .;
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        _eexidx = .;
        __exidx_end = .;
    } > hRAM
    .ARM.extab :
    {
        __extab_start = .;
      *(.ARM.extab* .gnu.linkonce.armextab.*)
        __extab_end = .;
    } > hRAM
    .got :
    {
        __got_start = .;
        *(.got .got.plt)
        __got_end = .;
    } > hRAM

    . = . + 4;
    . = ALIGN(4);

    .relocate :
    {
        _srelocate = .;
        _data = .;
        *(.data.hRAM);
        *(.data .data.*);
        _erelocate = .;
        _edata = .;
    } >hRAM

    .bss (NOLOAD):
    {
        _szero = .;
        _sbss = .;
        . = ALIGN(64);
        _s_buff_pool = .;
        *( BUFFER_POOL )
        _e_buff_pool = .;
        *(.bss .bss.*)
        *(.bss.hRAM);
        _ebss = .;
        _ezero = .;
        _end = . ;
    } >hRAM


    .master_data :
    {
      img_base = .;
      __simg_hdr = .;
      LONG(_start | 0x1);
      __eimg_hdr = .;

      __section_table_start = .;
      __relocation_table = .;
      /*LONG(LOADADDR(.relocate));
      LONG(    ADDR(.relocate));
      LONG(  SIZEOF(.relocate));*/
      LONG(LOADADDR(.vects));
      LONG(    ADDR(.vects));
      LONG(  SIZEOF(.vects));
      LONG(LOADADDR(.itcm));
      LONG(    ADDR(.itcm));
      LONG(  SIZEOF(.itcm));
      LONG(LOADADDR(.rel_dtcm));
      LONG(    ADDR(.rel_dtcm));
      LONG(  SIZEOF(.rel_dtcm));
      LONG(LOADADDR(.ramfunc.exidx));
      LONG(    ADDR(.ramfunc.exidx));
      LONG(  SIZEOF(.ramfunc.exidx));
      LONG(LOADADDR(.ramfunc.extab));
      LONG(    ADDR(.ramfunc.extab));
      LONG(  SIZEOF(.ramfunc.extab));
      LONG(LOADADDR(.rel_sram));
      LONG(    ADDR(.rel_sram));
      LONG(  SIZEOF(.rel_sram));
      LONG(LOADADDR(.text));
      LONG(    ADDR(.text));
      LONG(  SIZEOF(.text));
      __relocation_table_end = .;
      __bss_table = .;
      LONG(LOADADDR(.bss_dtcm));
      LONG(         ISRStkTop);   /* We explicitly do *not* zero the Isr Stack, */
      LONG(  SIZEOF(.bss_dtcm) - (ISRStkTop - ADDR(.bss_dtcm)));  /*  as it is in use during the memory         */
      LONG(LOADADDR(.bss_sram));  /*  initialization.                           */
      LONG(    ADDR(.bss_sram));
      LONG(  SIZEOF(.bss_sram));
      LONG(LOADADDR(.bss));
      LONG(    ADDR(.bss));
      LONG(  SIZEOF(.bss));
      LONG(LOADADDR(.fast_buffs));
      LONG(    ADDR(.fast_buffs));
      LONG(  ((_e_fast_buff_pool - _s_fast_buff_pool) < 0x190) 
      ? 0 
      : ((_e_fast_buff_pool - _s_fast_buff_pool)-0x190)
      );
      __bss_table_end = .;
      /*    __ouroboros_reloc_table = .;
      LONG(LOADADDR(.text));
      LONG(    ADDR(.text));
      LONG(  SIZEOF(.text));
      LONG(LOADADDR(.ARM.exidx));
      LONG(    ADDR(.ARM.exidx));
      LONG(  SIZEOF(.ARM.exidx));
      LONG(LOADADDR(.ARM.extab));
      LONG(    ADDR(.ARM.extab));
      LONG(  SIZEOF(.ARM.extab));
      LONG(LOADADDR(.got));
      LONG(    ADDR(.got));
      LONG(  SIZEOF(.got));
      LONG(LOADADDR(.relocate));
      LONG(    ADDR(.relocate));
      LONG(  SIZEOF(.relocate));
      __ouroboros_reloc_table_end = .;
      __ouroboros_bss_table = .;
      LONG(LOADADDR(.bss));
      LONG(    ADDR(.bss));
      LONG(  SIZEOF(.bss));
      __ouroboros_bss_table_end = .; */
__section_table_end = .;
KEEP(*(.startup));
KEEP(*(.startup.memcpy));
KEEP(*(.startup.data));
. = ALIGN(4);
__e_hram = .;
} > hRAM

/* __perelocate = __e_hram + SIZEOF(.ramfunc.exidx) + SIZEOF(.ramfunc.extab) */

__peramextab = __e_hram + SIZEOF(.ramfunc.exidx) + SIZEOF(.ramfunc.extab);
/* __peramextab = __perelocate; */

/* The startup code goes first into internal RAM */
.vects : AT(__peramextab)
{
    _vector_base = .;
    __VECTOR_TABLE = .;
    *(.vectors .vectors.*)
    _e_vectors = .;
    . = ALIGN(4);
} > vects
_vector_base = ORIGIN(vects);

__pevects = __peramextab + SIZEOF(.vects);

__peitcm = __pevects + SIZEOF(.itcm);

__pedtcm = __peitcm + SIZEOF(.rel_dtcm);
    .bss_dtcm (NOLOAD) :
    {
        KEEP(*(.isr_stk))
        . = ALIGN(8);
        ISRStkTop = .;
        . = ALIGN (4);
        *( SYS_VAR_SECT )
        SYS_VAR_SECT_END = .;
        . = ALIGN (4);
        *( IP_VAR_SECT )
        IP_VAR_SECT_END = .;
        . = ALIGN (4);
        *( TCP_VAR_SECT )
        TCP_VAR_SECT_END = .;
        . = ALIGN (4);
        *( TCM_VAR_SECT )
        TCM_VAR_SECT_END = .;
        . = ALIGN (8);
        *( IDLE_STK_SECT )
        IDLE_STK_SECT_END = .;
        . = ALIGN (8);
        *( ETHER_STK_SECT )
        ETHER_STK_SECT_END = .;
        . = ALIGN (4);  
        *( USB_VAR_SECT )
        USB_VAR_SECT_END = .;
        . = ALIGN (8);
        *( USB_STK_SECT )
        USB_STK_SECT_END = .;
        . = ALIGN (4);  
        *( IP_STK_SECT )
        IP_STK_SECT_END = .;
        . = ALIGN (4);
        *( TCP_STK_SECT )
        TCP_STK_SECT_END = .;
        . = ALIGN (8);
        *( HTTP_STK_SECT )
        HTTP_STK_SECT_END = .;
        . = ALIGN (8);
        *( FTP_STK_SECT )
        FTP_STK_SECT_END = .;
        . = ALIGN (4);
        *( MAIN_STK_SECT ) 
        MAIN_STK_SECT_END = .;
        . = ALIGN (8);
        *( USER_STK_SECT )
        USER_STK_SECT_END = .;
        _edtcm = .;
    } > dtcm

    /*__efixed = _eshim + SIZEOF(.relocate) + SIZEOF(.text);*/

    .rel_sram : AT(__pedtcm) 
    {
        SRAM_START = .;
        _srelocate_core = .;
        . = ALIGN (4);
        *( ETHER_VAR_SECT_REL )
        ETHER_VAR_SECT_END = .;
        . = ALIGN (4);
        *( TLS_VAR_SECT_REL )
        TLS_VAR_SECT_END = .;
        . = ALIGN (4);
        BUFFERS_SECT_REL_START = .;
        . = ALIGN (8);
        *( BUFFERS_VAR_SECT_REL )
        . = ALIGN (8);
        BUFFERS_VAR_SECT_REL_END = .;
        . = ALIGN (8);
        _sno_cache = .;
        *( NO_CACHE_SECT )
        . = ALIGN(32);
        _eno_cache = .;
        _erelocate_core = .;

        _sfixed = .;
        . = ALIGN(4);
        *(.gnu.linkonce.t.*)
        *(.glue_7t) *(.glue_7)

        . = ALIGN(8);
        __mem_data_regions = .;
        LONG(ORIGIN(dtcm));
        LONG(LENGTH(dtcm));
        LONG(ORIGIN(sram));
        LONG(LENGTH(sram));
        LONG(ORIGIN(hRAM));
        LONG(LENGTH(hRAM));
        LONG(        0x00);
        LONG(        0x00);
        __mem_text_sections = .;
        LONG(      _sitcm);
        LONG(      _eitcm);
        LONG(      _stext);
        LONG(      _etext);
        __emem_text_sections = .;

        . = ALIGN(4);
    } > sram
    __pesram = __pedtcm + SIZEOF(.rel_sram);

    .bss_sram (NOLOAD) :
    {
         . = ALIGN (8);
        *( ETHER_VAR_SECT )
        ETHER_VAR_SECT_END = .;
         . = ALIGN (8);
        *( WIFI_STK_SECT )
        WIFI_STK_SECT_END = .;
        . = ALIGN (8);
        *( PPP_STK_SECT )
        PPP_STK_SECT_END = .;
        . = ALIGN (4);
        *( TLS_VAR_SECT )
        TLS_VAR_SECT_END = .;
        . = ALIGN (4);
        BUFFERS_SECT_START = .;
        . = ALIGN (8);
        *( BUFFERS_VAR_SECT )
        . = ALIGN (8);
        BUFFERS_VAR_SECT_END = .;
        . = ALIGN (4);
        *( USER_VAR_SECT )
        USER_VAR_SECT_END = .;
        . = ALIGN (8);
        *( COMMAND_STK_SECT )
        COMMAND_STK_SECT_END = .;
       . = ALIGN(4);
        *(.bss.sram)
        *(COMMON)
    } > sram

    PROVIDE( vector_base = 0x20400000 );

    /* stack section */
/*    .stack (NOLOAD):
    {
        . = ALIGN(8);
        _sstack = .;
        . = . + STACK_SIZE;
        . = ALIGN(8);
        _estack = .;
    } > dtcm */

    /* Battery backed ram section */
    .bkup (NOLOAD):
    {
        /* OscDly = .;
        LONG(0x0);
        OscState = .;
        LONG(0x0);
        PrevOscDly = .;
        LONG(0x0);
        PrevOscState = .;
        LONG(0x0); */
        *( BACKUP_RAM )
    } > sram

    .fast_buffs (NOLOAD) :
    {
        . = ALIGN(0x40);
        _s_fast_buff_pool = .;
    } > sram

    SRAM_END = _s_fast_buff_pool;
    SRAM_END_ADDR = ORIGIN(sram) + LENGTH(sram);
    _e_fast_buff_pool = ORIGIN(sram) + LENGTH(sram);

    .data_bus (NOLOAD) :
    {
        . = ALIGN(4);
        _s_data_bus = .;
        *( DATABUS_VAR_SECT )
        _e_data_bus = .;
    } > SEMC

    IMG_LENGTH = SIZEOF(.master_data) + SIZEOF(.vects) + SIZEOF(.itcm) 
                + SIZEOF(.rel_dtcm) + SIZEOF(.text) + SIZEOF(.rel_sram)
                + SIZEOF(.ARM.exidx) + SIZEOF(.ARM.extab)
                + SIZEOF(.got) + SIZEOF(.relocate);
    /* need to have something in section otherwise it is tossed */
/*    .fill : AT(__efixed + SIZEOF(.ARM.exidx))
    {

        FILL(0x5A);
        . = ORIGIN(flash) + LENGTH(flash) - 1 - (__efixed + SIZEOF(.ARM.exidx));
        BYTE(0x5A); 
        __END_OF_FLASH = .;
    } > flash */


    /* heap section */
    /* .heap (noload):
    {
        . = align(8);
         _sheap = .;
        . = . + heap_size;
        . = ALIGN(8);
        _eheap = .;
    } > sram */

    /*.ext (NOLOAD):
    {
        *( DRAM_VAR_SECT )
    } > ram */

    .hram_stat (NOLOAD) :
    {
        _e_app_img = __pesram;
    } > hRAM
    . = ALIGN(4);
    __end = _end;
    ecopy = _end;
    /*_ram_end_ = ORIGIN(sram) + LENGTH(sram) ;
    __stack = _ram_end_; */

    /*.meta (NOLOAD) :
    {
        *(.debug*);
        *(.comment*);
        *(.ARM.attributes);
    }

    .missing (NOLOAD) :
    {
        _s_missing_section = .;
        *( * );
        _e_missing_section = .;
    } >hRAM
    */


/************************************************/
/* The following symbols are for use by build   */ 
/*  utilities to calculate usage statistics.    */
/************************************************/

/*****************************************************************************/
/* NOTE: In order for the build utilities to automatically be able to report */
/*        the memory area name, we have use symbol names containing a space  */
/*        character so that the name is part of the name symbol itself as    */
/*        symbols may only have numeric values. The space allows us to find  */
/*        the name symbol and also read off it's name.                       */
/*****************************************************************************/
    /* Storage size statistics symbols */
    __FLASH_ADDR = 0x0;
    __FLASH_SIZE = 0x800000;
    __FLASH_USED = _e_app_img - ORIGIN(hRAM);
    "__FLASH_NAME flash" = 1;

    /* Linker allocation statistics symbols */
    __MEMORY_REGION_COUNT = 4;
    __REG_0_ADDR = ORIGIN(itcm);
    __REG_0_SIZE = LENGTH(itcm);
    __REG_0_USED = (_eitcm - __REG_0_ADDR);
    "__REG_0_NAME itcm" = 1;
    __REG_1_ADDR = ORIGIN(dtcm);
    __REG_1_SIZE = LENGTH(dtcm);
    __REG_1_USED = (_edtcm - __REG_1_ADDR);
    "__REG_1_NAME dtcm" = 1;
    __REG_2_ADDR = ORIGIN(sram);
    __REG_2_SIZE = LENGTH(sram);
    __REG_2_USED = (SRAM_END - __REG_2_ADDR);
    "__REG_2_NAME sram" = 1;
    __REG_3_ADDR = ORIGIN(hRAM);
    __REG_3_SIZE = LENGTH(hRAM);
    __REG_3_USED = (_end - __REG_3_ADDR);
    "__REG_3_NAME ram" = 1;
}
