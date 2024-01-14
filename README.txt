This crate was created doing the following:

alr init avrtest --bin
cd avrtest
alr with avrada_rts
alr with avrada_mcu
alr with avrada_lib

Modify avrtest.gpr to add the following:

with "avrada_rts.gpr";
with "avr_tool_options.gpr";
with "avrada_mcu.gpr";
with "avrada_lib.gpr";

   for Target use "avr";
   for Runtime ("Ada") use AVRAda_Rts'Project_Dir;
   
   package Builder renames AVR_Tool_Options.Builder;
   
   package Compiler is
      for Default_Switches ("Ada") use AVR_Tool_Options.ALL_ADAFLAGS;
   end Compiler;

   package Binder is
      for Switches ("Ada") use AVR_Tool_Options.Binder_Switches;
   end Binder;
   
   package Linker is
      for Switches ("Ada") use AVR_Tool_Options.Linker_Switches;
   end Linker;
   
Modify alire.toml:

Added
[configuration.values]
avrada_rts.AVR_MCU = "atmega328p"
avrada_rts.Clock_Frequency = 16000000

Created avrtest.adb

alr build

Flash to board:
avrdude -v -V -patmega328p -carduino -PCOM4 -b19200 -D -Uflash:w:bin/avrtest.elf