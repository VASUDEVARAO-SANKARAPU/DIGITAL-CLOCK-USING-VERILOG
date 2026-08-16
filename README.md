# DIGITAL CLOCK USING VERILOG


PROJECT_IDEA

The idea of this project is to design a 24-hour digital clock using Verilog HDL. The clock uses an input clock signal to generate a sequence of seconds, minutes, and hours. Three counters are used in a cascading manner: the seconds counter counts from 00–59, the minutes counter counts from 00–59, and the hours counter counts from 00–23. When one counter reaches its maximum value, it resets to zero and increments the next counter. A reset input is also provided to initialize the clock to 00:00:00.

WORKING_PROCEDURE

The operation begins when the clock receives the input clk and reset signals. When reset is active, the internal counter, hours, minutes, and seconds are all set to zero, so the clock starts at 00:00:00.

After reset is released, the circuit starts counting on every positive edge of the clock. An internal counter is used to control when the seconds value should change. When this counter reaches 4, it is reset to zero and the seconds counter is incremented by one.

The seconds counter counts from 00 to 59. When it reaches 59, it resets to 00 and increments the minutes counter. The minutes counter also counts from 00 to 59. When it reaches 59, it resets to 00 and increments the hours counter.

The hours counter counts from 00 to 23. When the hour reaches 23, the next increment resets it to 00. Thus, the clock continuously follows the sequence 00:00:00 → 00:00:01 → ... → 23:59:59 → 00:00:00.

The testbench generates the clock signal and initially applies the reset. After 20 ns, the reset is released, allowing the clock to start counting. The hour, minute, and second outputs are then observed in the simulation waveform to verify the operation of the digital clock. 