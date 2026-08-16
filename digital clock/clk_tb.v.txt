`timescale 1ns/1ps

module digital_clock_tb;

reg clk;
reg reset;

wire [4:0] hour;
wire [5:0] minute;
wire [5:0] second;

digital_clock uut (
    .clk(clk),
    .reset(reset),
    .hour(hour),
    .minute(minute),
    .second(second)
);

always #10 clk = ~clk;

initial begin

    clk = 0;
    reset = 1;

    #20;
    reset = 0;

    #100000;

    $finish;

end

endmodule