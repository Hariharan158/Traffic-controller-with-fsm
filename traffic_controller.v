`timescale 1ns/1ps
module traffic_controller (
    input  wire clk,
    input  wire reset,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green
);

    // FSM states
    parameter NS_GREEN  = 2'b00;
    parameter NS_YELLOW = 2'b01;
    parameter EW_GREEN  = 2'b10;
    parameter EW_YELLOW = 2'b11;

    reg [1:0] current_state, next_state;

    // Timer
    reg [3:0] count;

    // Number of clock cycles for each state
    parameter GREEN_TIME  = 10;
    parameter YELLOW_TIME = 3;

    //====================================================
    // State Register + Timer
    //====================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= NS_GREEN;
            count <= 0;
        end
        else begin
            current_state <= next_state;

            if (current_state != next_state)
                count <= 0;
            else
                count <= count + 1;
        end
    end

    //====================================================
    // Next-State Logic
    //====================================================
    always @(*) begin

        case (current_state)

            NS_GREEN: begin
                if (count == GREEN_TIME - 1)
                    next_state = NS_YELLOW;
                else
                    next_state = NS_GREEN;
            end

            NS_YELLOW: begin
                if (count == YELLOW_TIME - 1)
                    next_state = EW_GREEN;
                else
                    next_state = NS_YELLOW;
            end

            EW_GREEN: begin
                if (count == GREEN_TIME - 1)
                    next_state = EW_YELLOW;
                else
                    next_state = EW_GREEN;
            end

            EW_YELLOW: begin
                if (count == YELLOW_TIME - 1)
                    next_state = NS_GREEN;
                else
                    next_state = EW_YELLOW;
            end

            default:
                next_state = NS_GREEN;

        endcase

    end

    //====================================================
    // Output Logic
    //====================================================
    always @(*) begin

        // Default: all lights OFF
        ns_red    = 1'b0;
        ns_yellow = 1'b0;
        ns_green  = 1'b0;

        ew_red    = 1'b0;
        ew_yellow = 1'b0;
        ew_green  = 1'b0;

        case (current_state)

            // North-South GREEN
            NS_GREEN: begin
                ns_green = 1'b1;
                ew_red   = 1'b1;
            end

            // North-South YELLOW
            NS_YELLOW: begin
                ns_yellow = 1'b1;
                ew_red    = 1'b1;
            end

            // East-West GREEN
            EW_GREEN: begin
                ns_red   = 1'b1;
                ew_green = 1'b1;
            end

            // East-West YELLOW
            EW_YELLOW: begin
                ns_red    = 1'b1;
                ew_yellow = 1'b1;
            end

            default: begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

        endcase

    end

endmodule
