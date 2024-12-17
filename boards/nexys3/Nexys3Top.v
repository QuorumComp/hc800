`timescale 1ns / 1ps

module Nexys3Top(
	input			clk,
	input  [4:0]	btn,
	input  [7:0]	sw,
	
	inout			PS2KeyboardData,
	inout			PS2KeyboardClk,
	
	output	[2:0]	vgaRed,
	output	[2:0]	vgaGreen,
	output	[2:1]	vgaBlue,
	output			Hsync,
	output			Vsync,
	
	output [7:0]	Led,
	output [7:0]	seg,
	output [3:0]	an,
	
	output			RsTx,
	input			RsRx
);


assign Led = 8'hFF;

wire clk_double_bus;
wire clk_bus;
wire clk_cpu;
wire clk_locked;
wire reset = (!clk_locked) || (clk_count != 0);

reg [3:0] clk_count = 4'd15;

always @(negedge clk_cpu) begin
	if (clk_locked) begin
		if (clk_count != 4'd0) begin
			clk_count <= clk_count - 4'd1;
		end;
	end;
end;


SystemClocks clockPll(
	.CLK_IN1(clk),	// IN
	
	// Clock out ports
	.CLK_OUT1(clk_double_bus),	// OUT
	.CLK_OUT2(clk_bus),			// OUT
	.CLK_OUT3(clk_cpu),		// OUT
	
	// Status and control signals
	.RESET(1'b0),			// IN
	.LOCKED(clk_locked));	// OUT


HC800 hc800(
	.bus_clk(clk_bus),
	.bus_reset(reset),
	.cpu_clk(clk_cpu),
	.cpu_reset(reset),

	.io_seg(seg),
	.io_an(an),
	.io_btn(btn),
	
	.io_red(vgaRed),
	.io_green(vgaGreen),
	.io_blue(vgaBlue),
	.io_hsync(Hsync),
	.io_vsync(Vsync),
	
	.io_txd(RsTx),
	.io_rxd(RsRx)
);

endmodule
