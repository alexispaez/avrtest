
with AVR.UART;
with Fan_Control_Int;

procedure Fan_Control is
begin
    AVR.UART.Init (AVR.UART.Baud_19200_16MHz);
    AVR.UART.Put ("Start test of fan controller using interrupts");
    AVR.UART.CRLF;

    Fan_Control_Int.Start;
end;
