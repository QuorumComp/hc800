`define HDMI

`default_nettype none
`timescale 1ns / 1ps

module SpecNextTop(
	input	wire	clock_50_i,
	input wire	btn_divmmc_n_i,
	input	wire	btn_multiface_n_i,
	input	wire	btn_reset_n_i,
	
	output wire [2:0]	rgb_r_o,
	output wire [2:0]	rgb_g_o,
	output wire [2:0]	rgb_b_o,
	output wire			vsync_o,
	output wire			hsync_o,
	output wire			csync_o,
	
	output wire [3:0]	hdmi_p_o,
	output wire [3:0]	hdmi_n_o,
	 
	output wire			joyp7_o,
	input wire			joyp9_i,
	output wire			joysel_o,

	inout wire [7:0]	keyb_row_o,
	input wire [6:0]	keyb_col_i,

	output wire [18:0]	ram_addr_o,
	inout  wire [15:0]	ram_data_io,
	output wire				ram_oe_n_o,
	output wire				ram_we_n_o,
	output wire [3:0]		ram_ce_n_o
);

wire composite_sync = 1;
wire doublescan = 1;

wire clk_bus_5x;
wire clk_bus_2x;
wire clk_bus;
wire clk_cpu;
wire clk_locked;
wire hdmiclk_pix = clk_bus_2x;
wire hdmiclk_pix_5x;
wire hdmiclk_pix_5x_n;

wire [4:0] red, green, blue;
wire hsync, vsync;

wire [4:0] dblRed, dblGreen, dblBlue;
wire dblHSync, dblVSync, dblBlank;


//
// Reset, clocks
//

reg reset = 1;
reg count_in = 0;

always @(posedge clk_cpu) begin
	if (clk_locked) begin
		count_in <= 1'b1;
	end;
end;

reg [3:0] clk_count = 4'd8;

// Hold reset for a number of cycles when starting

always @(posedge clk_bus_5x) begin
	if (clk_locked && count_in) begin
		if (clk_count != 4'd0) begin
			clk_count <= clk_count - 4'd1;
		end else begin
			reset <= 0;
		end;
	end;
end;


SystemClocks clockPll(
	.CLK_IN1(clock_50_i),	// IN
	
	// Clock out ports
	.CLK_OUT1(clk_bus_5x),			// OUT
	.CLK_OUT2(clk_bus_2x),	// OUT
	.CLK_OUT3(clk_bus),			// OUT
	.CLK_OUT4(clk_cpu),		// OUT
	.CLK_OUT5(hdmiclk_pix_5x),
	.CLK_OUT6(hdmiclk_pix_5x_n),
	
	// Status and control signals
	.RESET(1'b0),			// IN
	.LOCKED(clk_locked));	// OUT


//
// RGB colors
//

assign rgb_r_o = doublescan ? dblRed[4:2] : red[4:2];
assign rgb_g_o = doublescan ? dblGreen[4:2] : green[4:2];
assign rgb_b_o = doublescan ? dblBlue[4:2] : blue[4:2];

//
// Sync signals
//

wire hsync_n = !(doublescan ? dblHSync : hsync);
wire vsync_n = !(doublescan ? dblVSync : vsync);
wire csync_n = hsync_n & vsync_n;

assign hsync_o = composite_sync ? csync_n : hsync_n;
assign vsync_o = composite_sync ? 1'b1 : vsync_n;
assign csync_o = 1'bZ;

//
// Joystick port UART
//

wire RsRx = joyp9_i;
wire RsTx;
assign joyp7_o = RsTx;
assign joysel_o = 1'b0;	// left port

//
// Memory bus
//

wire [20:0] ram_address;
wire ram_upper = ram_address[19];
wire [1:0] ram_chip = ram_address[20:19];

wire ram_enable;
wire ram_write;
wire [ 7:0] ram_data_out;
wire [15:0] ram_word_out = {ram_data_out, ram_data_out};
wire [ 7:0] ram_data_in = (ram_upper == 1'b1) ? (ram_data_io[15:8]) : (ram_data_io[7:0]);
reg  [ 7:0] ram_data_in_bus_r;

reg ram_write_r = 0;
reg [4:0] ram_cycle = 5'b10000;

always @ (posedge clk_bus_5x or posedge reset) begin
	if (reset) begin
		ram_cycle   <= 5'b10000;
		ram_write_r <= 1'b0;
	end else begin
		if (ram_cycle[1]) begin
			ram_write_r <= ram_write;
		end else if (ram_cycle[4]) begin
			ram_write_r <= 1'b0;
		end
		ram_cycle <= {ram_cycle[3:0], ram_cycle[4]};
	end;
end

always @ (posedge clk_bus) begin
	ram_data_in_bus_r <= ram_enable ? ram_data_in : 0;
end

assign ram_oe_n_o = !(ram_enable && !ram_write_r);
assign ram_we_n_o = !(ram_enable && ram_write_r);

assign ram_ce_n_o[3] = !(ram_enable && (ram_chip == 2'b11));
assign ram_ce_n_o[2] = !(ram_enable && (ram_chip == 2'b10));
assign ram_ce_n_o[1] = !(ram_enable && (ram_chip == 2'b01));
assign ram_ce_n_o[0] = !(ram_enable && (ram_chip == 2'b00));

assign ram_addr_o = ram_address[18:0];

assign ram_data_io = (ram_enable && ram_write_r) ? ram_word_out : 16'hzzzz;

//
// Keyboard
//

wire [7:0] keyboard_rows;
assign keyb_row_o[7] = keyboard_rows[7] ? 1'bZ : 1'b0;
assign keyb_row_o[6] = keyboard_rows[6] ? 1'bZ : 1'b0;
assign keyb_row_o[5] = keyboard_rows[5] ? 1'bZ : 1'b0;
assign keyb_row_o[4] = keyboard_rows[4] ? 1'bZ : 1'b0;
assign keyb_row_o[3] = keyboard_rows[3] ? 1'bZ : 1'b0;
assign keyb_row_o[2] = keyboard_rows[2] ? 1'bZ : 1'b0;
assign keyb_row_o[1] = keyboard_rows[1] ? 1'bZ : 1'b0;
assign keyb_row_o[0] = keyboard_rows[0] ? 1'bZ : 1'b0;


//
// HDMI
//

`ifdef HDMI
wire [9:0] hdmiRed, hdmiGreen, hdmiBlue;

hdmi HDMIEncoder(
	.I_CLK_PIXEL(hdmiclk_pix),

	.I_R({dblRed, 3'b0}),
	.I_G({dblGreen, 3'b0}),
	.I_B({dblBlue, 3'b0}),
	.I_HSYNC(dblHSync),
	.I_VSYNC(dblVSync),
	.I_BLANK(dblBlank),

	.I_AUDIO_ENABLE(1),
	.I_AUDIO_PCM_L(0),
	.I_AUDIO_PCM_R(0),

	.O_RED(hdmiRed),
	.O_GREEN(hdmiGreen),
	.O_BLUE(hdmiBlue));

hdmi_out_xilinx HDMIOut(
	.clock_pixel_i(hdmiclk_pix),
	.clock_tdms_i(hdmiclk_pix_5x),
	.clock_tdms_n_i(hdmiclk_pix_5x_n),
	
	.red_i(hdmiRed),
	.green_i(hdmiGreen),
	.blue_i(hdmiBlue),
	
	.tmds_out_p(hdmi_p_o),
	.tmds_out_n(hdmi_n_o));
	
/*
HDMI_test hdmiTest(
    .pixclk(clk_bus_2x),
	 .hSync(dblHSync),
	 .vSync(dblVSync),
	 .DrawArea(!dblBlank),
	 .red({dblRed, 3'b0}),
	 .green({dblGreen, 3'b0}),
	 .blue({dblBlue, 3'b0}),

    .TMDSp(hdmi_p_o[2:0]),
    .TMDSn(hdmi_n_o[2:0]),

    .TMDSp_clock(hdmi_p_o[3]),
    .TMDSn_clock(hdmi_n_o[3])
);
*/
`else
OBUFDS OBUFDS_clock(.I(0), .O(hdmi_p_o[3]), .OB(hdmi_n_o[3]));
OBUFDS OBUFDS_red  (.I(0), .O(hdmi_p_o[2]), .OB(hdmi_n_o[2]));
OBUFDS OBUFDS_green(.I(0), .O(hdmi_p_o[1]), .OB(hdmi_n_o[1]));
OBUFDS OBUFDS_blue (.I(0), .O(hdmi_p_o[0]), .OB(hdmi_n_o[0]));
`endif

//
// HC800
//

HC800 hc800(
	.dbl_clk(clk_bus_2x),
	.dbl_reset(reset),
	.bus_clk(clk_bus),
	.bus_reset(reset),
	.cpu_clk(clk_cpu),
	.cpu_reset(reset),

//	.io_seg(),
//	.io_an(),
	.io_btn({!btn_reset_n_i,!btn_multiface_n_i,!btn_reset_n_i,!btn_divmmc_n_i,!btn_reset_n_i}),
	
	.io_red(red),
	.io_green(green),
	.io_blue(blue),
	.io_hsync(hsync),
	.io_vsync(vsync),
	
	.io_dblRed(dblRed),
	.io_dblGreen(dblGreen),
	.io_dblBlue(dblBlue),
	.io_dblHSync(dblHSync),
	.io_dblVSync(dblVSync),
	.io_dblBlank(dblBlank),
	
	.io_txd(RsTx),
	.io_rxd(RsRx),

	.io_keyboardColumns(keyb_col_i),
	.io_keyboardRows(keyboard_rows),

	.io_ramBus_enable(ram_enable),
	.io_ramBus_write(ram_write),
	.io_ramBus_dataToMaster(ram_data_in_bus_r),
	.io_ramBus_dataFromMaster(ram_data_out),
	.io_ramBus_address(ram_address)
);

endmodule
