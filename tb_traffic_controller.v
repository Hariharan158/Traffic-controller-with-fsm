`timescale 1ns/1ps

module tb_traffic_controller;

    reg clk;
    reg reset;

    wire ns_red;
    wire ns_yellow;
    wire ns_green;

    wire ew_red;
    wire ew_yellow;
    wire ew_green;

    //====================================================
    // DUT Instantiation
    //====================================================
    traffic_controller uut (
        .clk(clk),
        .reset(reset),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );

    //====================================================
    // Clock Generation
    // 10 ns clock period
    //====================================================
    always #5 clk = ~clk;

    //====================================================
    // VCD Dump
    //====================================================
    initial begin
        $dumpfile("traffic_controller.vcd");
        $dumpvars(0, tb_traffic_controller);
    end

    //====================================================
    // Test Sequence
    //====================================================
    initial begin

        // Initial values
        clk   = 1'b0;
        reset = 1'b1;

        // Apply reset
        #10;
        reset = 1'b0;

        // Run simulation
        // Long enough to observe multiple FSM cycles
        #300;

        $finish;
    end

    //====================================================
    // Monitor
    //====================================================
    initial begin
        $monitor(
            "Time=%0t | Reset=%b | State=%b | Count=%0d | ",
            $time, reset, uut.current_state, uut.count,
            "NS(RYG)=%b%b%b | EW(RYG)=%b%b%b",
            ns_red, ns_yellow, ns_green,
            ew_red, ew_yellow, ew_green
        );
    end

endmodule
