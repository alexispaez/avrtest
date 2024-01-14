
with AVR;               use AVR;
with AVR.MCU;
with AVR.Wait;
with AVR.Interrupts;
with AVR.UART;
with AVR.Ext_Int;       use AVR.Ext_Int;
with AVR.Real_Time;     use AVR.Real_Time;
with AVR.Real_Time.Clock;
with Interfaces;        use Interfaces;
with Avrada_Rts_Config;

package body Fan_Control_Int is
    Int0_Pin : Boolean renames MCU.PORTD_Bits(2);
    Int1_Pin : Boolean renames MCU.PORTD_Bits(3);
    Int0_DD  : Boolean renames MCU.DDRD_Bits(2);
    Int1_DD  : Boolean renames MCU.DDRD_Bits(3);

    Half_Revs_Fan_0 : Integer_16;
    Half_Revs_Fan_1 : Integer_16;

    Last_Time : Time;
    Elapsed_Time : AVR.Real_Time.Duration;

    procedure Init is
    begin
        AVR.UART.Put ("Init sequence");
        AVR.UART.CRLF;
        --  set the key pins to input
        Int0_DD := DD_Input;
        Int1_DD := DD_Input;
        --  enable internal pull ups
        Int0_Pin := High;
        Int1_Pin := High;

        Set_Int0_Sense_Control (Falling_Edge);
        Set_Int1_Sense_Control (Falling_Edge);

        Enable_External_Interrupt_0;
        Enable_External_Interrupt_1;
    end Init;

    procedure Wait_10_Secs is new
        AVR.Wait.Generic_Wait_USecs (Avrada_Rts_Config.Clock_Frequency,
                                10_000_000);
    procedure Wait_1_Sec is new
        AVR.Wait.Generic_Wait_USecs (Avrada_Rts_Config.Clock_Frequency,
                                1_000_000);

    procedure Start is
        RPM_Fan_0 : Float;
        RPM_Fan_1 : Float;
    begin
        Init;

        AVR.UART.Put ("Start loop");
        AVR.UART.CRLF;
        -- loop forever
        loop
            -- Reset counters
            Half_Revs_Fan_0 := 0;
            Half_Revs_Fan_1 := 0;
            Last_Time := Clock;

            -- Enable interrupts
            AVR.Interrupts.Enable;

            -- Delay
            -- Wait_10_Secs;
            Wait_1_Sec;

            -- Disable interrupts
            AVR.Interrupts.Disable;

            -- Calculate time elapsed, calculate rpm and send to UART
            Elapsed_Time := Clock - Last_Time;

            AVR.UART.Put ("Fan 0 half revs: ");
            AVR.UART.Put (Half_Revs_Fan_0);
            AVR.UART.CRLF;

            AVR.UART.Put ("Elapsed time: ");
            AVR.UART.Put (Integer_16 (Elapsed_Time * 1000));
            AVR.UART.CRLF;

            RPM_Fan_0 := Float ((Half_Revs_Fan_0 / 2) * 60) / Float (Elapsed_Time); -- every 10 seconds times 6
            RPM_Fan_1 := Float ((Half_Revs_Fan_1 / 2) * 60) / Float (Elapsed_Time); -- every 10 seconds times 6
            AVR.UART.Put ("RPM Fan 0: ");
            AVR.UART.Put (Integer_16 (RPM_Fan_0));
            AVR.UART.Put (", RPM Fan 1: ");
            AVR.UART.Put (Integer_16 (RPM_Fan_1));
            AVR.UART.CRLF;
        end loop;
    end Start;

   procedure On_Interrupt_0;
   pragma Machine_Attribute (Entity         => On_Interrupt_0,
                             Attribute_Name => "signal");
   pragma Export (C, On_Interrupt_0, AVR.MCU.Sig_INT0_String);

   procedure On_Interrupt_0 is
   begin
      Half_Revs_Fan_0 := Half_Revs_Fan_0 + 1;
   end On_Interrupt_0;

      procedure On_Interrupt_1;
   pragma Machine_Attribute (Entity         => On_Interrupt_1,
                             Attribute_Name => "signal");
   pragma Export (C, On_Interrupt_1, AVR.MCU.Sig_INT1_String);

   procedure On_Interrupt_1 is
   begin
      Half_Revs_Fan_1 := Half_Revs_Fan_1 + 1;
   end On_Interrupt_1;

end Fan_Control_Int;