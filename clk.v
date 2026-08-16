module digital_clock(
    input clk,
    input reset,
    output reg [4:0] hour,
    output reg [5:0] minute,
    output reg [5:0] second
);

reg [22:0] count;

always @(posedge clk) begin

    if (reset) begin
        count = 0;
        hour = 0;
        minute = 0;
        second = 0;
    end

    else begin

        if (count ==4)begin
            count = 0;
            second = second + 1;

            if (second == 59) begin
                second = 0;
                minute = minute + 1;

                if (minute == 59) begin
                    minute = 0;
                    hour = hour + 1;

                    if (hour == 23) begin
                        hour = 0;
                    end
                end
            end
        end

        else begin
            count = count + 1;
        end

    end

end

endmodule