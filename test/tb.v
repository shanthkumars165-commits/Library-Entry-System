`default_nettype none
`timescale 1ns/1ps

/*
  This testbench is a structural wrapper that instantiates the 
  shortened module 'tt_um_lib_sys' for Cocotb simulation.
*/
module tb (
    // If gate-level simulation requires power pins, they are declared here
    `ifdef GL_TEST
        input wire VPWR,
        input wire VGND,
    `endif
    input wire clk,
    input wire rst_n,
    input wire ena,
    input wire [7:0] ui_in,
    input wire [7:0] uio_in,
    output wire [7:0] uo_out,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    // Structural instance of your custom library system module
    tt_um_lib_sys user_project (
        `ifdef GL_TEST
            .VPWR (VPWR),
            .VGND (VGND),
        `endif
        .clk     (clk),
        .rst_n   (rst_n),
        .ena     (ena),
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe)
    );

    // Generate waveform dump trace files for GTKWave debugging analysis
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

endmodule
