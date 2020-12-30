`default_nettype none
`timescale 1ns / 1ps

module top(
	// 27 MHz clocks
	input [1:0]	CLOCK_27,
	
	// Yellow led
	output reg LED,
  
   // SDRAM interface
   inout [15:0]    SDRAM_DQ,       // SDRAM Data bus 16 Bits
   output [12:0]   SDRAM_A,        // SDRAM Address bus 13 Bits
   output          SDRAM_DQML,     // SDRAM Low-byte Data Mask
   output          SDRAM_DQMH,     // SDRAM High-byte Data Mask
   output          SDRAM_nWE,      // SDRAM Write Enable
   output          SDRAM_nCAS,     // SDRAM Column Address Strobe
   output          SDRAM_nRAS,     // SDRAM Row Address Strobe
   output          SDRAM_nCS,      // SDRAM Chip Select
   output [1:0]    SDRAM_BA,       // SDRAM Bank Address
   output          SDRAM_CLK,      // SDRAM Clock
   output          SDRAM_CKE,      // SDRAM Clock Enable

	// VGA
	output       VGA_HS,
	output       VGA_VS,
	output [5:0] VGA_R,
	output [5:0] VGA_G,
	output [5:0] VGA_B,
	
	// SPI
	inout	SPI_DO,
	input	SPI_DI,
	input	SPI_SCK,
	input	SPI_SS2,	// data_io
	input	SPI_SS3,	// OSD
	input	SPI_SS4,	// unused in this core
	input	CONF_DATA0,	// SPI_SS for user_io

	// AUDIO
	output AUDIO_L,
	output AUDIO_R,
	
	// UART
	output UART_TX,
	input  UART_RX
);

localparam CONF_STR = {
	"SuperChip;CH8;",
	"O1,Monitor type,4:3,16:9;",
	"O2,CPU Speed,Fast,Slow;"
};

wire doublescan_disable;

wire reset;

wire clk_locked;
wire clk_108M  /* synthesis noprune */;
wire clk_27M   /* synthesis noprune */;
wire clk_13_5M /* synthesis noprune */;
wire clk_6_75M /* synthesis noprune */;
wire clk_12k   /* synthesis noprune */;

assign SDRAM_CLK = clk_108M;
assign SDRAM_CKE = 1;

SystemClocks systemClocks(
	.areset(reset),
	.inclk0(CLOCK_27[0]),
	.c0(clk_108M),
	.c1(clk_27M),
	.c2(clk_13_5M),
	.c3(clk_6_75M),
	.locked(clk_locked));

Ps2Clock ps2Clock(
	.areset(1'b0),
	.inclk0(CLOCK_27[0]),
	.c0(clk_12k));

// Program uploader

wire uploading;
wire upload_clk;
wire upload_en;
wire [11:0] upload_a;
wire [7:0] upload_d;

/*
data_io DataIO(
	SPI_SCK,
	SPI_SS2,
	SPI_DI,
	
	uploading,
	upload_clk,
	upload_en,
	upload_a,
	upload_d
);
*/

// User IO handler

wire [1:0] buttons;
wire       kbd_ready;
wire       kbd_make;
wire       kbd_extend;
wire [7:0] kbd_data;
wire       no_csync;

user_io#(.STRLEN(14 + 25 + 23)) userIo(
	.clk_sys   (clk_13_5M),
	
	.SPI_CLK   (SPI_SCK),
	.SPI_SS_IO (CONF_DATA0),
	.SPI_MISO  (SPI_DO),
	.SPI_MOSI  (SPI_DI),

	.conf_str  (CONF_STR			),

//	.switches  (switches),
	.buttons   (buttons),
//	.joystick0 (joystick0),
//	.joystick1 (joystick1),

//	.status    (status),

	.key_strobe  (kbd_ready),
	.key_code    (kbd_data),
	.key_pressed (kbd_make),
	.key_extended(kbd_extend),
	
	.no_csync(no_csync),
	.scandoubler_disable(doublescan_disable)
);

// Reset circuit

wire uploading_negedge;
util_negedge UploadingNegedge(clk_12k, 0, uploading, uploading_negedge);

wire button1_posedge;
util_posedge ButtonPosedge(clk_12k, 0, buttons[1], button1_posedge);

// Code for waiting for a button press (for debugging in SignalTap)
reg perma_res = 0;

always @(posedge clk_12k) begin
	if (button1_posedge) begin
		perma_res <= 1'b0;
	end
end

reg [4:0] res_count = 0;
reg res = 1;
assign reset = res || perma_res;

always @(posedge clk_12k) begin
	if (res) begin
		if (res_count[4]) begin
			res <= 1'b0;
			res_count <= 0;
		end else begin
			res_count <= res_count + 1'b1;
		end
	end else if (uploading_negedge || button1_posedge) begin
		res <= 1'b1;
	end
end


// OSD

wire [5:0] core_R;
wire [5:0] core_G;
wire [5:0] core_B;
wire core_hs;
wire core_vs;
wire osd_hs;
wire osd_vs;
wire clk_pixel = doublescan_disable ? clk_13_5M : clk_27M;

OSD osd(
	.pclk (clk_pixel),
	
	.sck (SPI_SCK),
	.ss  (SPI_SS3),
	.sdi (SPI_DI),
	
	.red_in   (core_R),
	.green_in (core_G),
	.blue_in  (core_B),
	.hs_in    (core_hs),
	.vs_in    (core_vs),

	.red_out   (VGA_R),
	.green_out (VGA_G),
	.blue_out  (VGA_B),
	.hs_out    (osd_hs),
	.vs_out    (osd_vs)
);

// Core

wire core_led;

//
// RAM
//


wire [20:0] ram_address;
wire ram_enable;
wire ram_write;
wire [ 7:0] ram_data_out;
wire [15:0] ram_data_in;
reg  [ 7:0] ram_data_in_bus_r;

always @(posedge clk_13_5M) begin
	ram_data_in_bus_r <= ram_enable ? ram_data_in[7:0] : 8'b0;
end


sdram SDRAM(
   // interface to the MT48LC16M16 chip
   .sd_data        ( SDRAM_DQ                  ),
   .sd_addr        ( SDRAM_A                   ),
   .sd_dqm         ( {SDRAM_DQMH, SDRAM_DQML}  ),
   .sd_cs          ( SDRAM_nCS                 ),
   .sd_ba          ( SDRAM_BA                  ),
   .sd_we          ( SDRAM_nWE                 ),
   .sd_ras         ( SDRAM_nRAS                ),
   .sd_cas         ( SDRAM_nCAS                ),

   // system interface
   .clk            ( clk_108M                  ),
   .clkref         ( clk_13_5M                 ),
   .init           ( reset                     ),

   // cpu interface
   .addr           ( ram_address               ),
   .din            ( {ram_data_out, ram_data_out} ),
   .we             ( ram_write && ram_enable   ),
   .oe             ( ram_enable                ),
   .ds             ( {ram_enable, ram_enable}  ),
   .dout           ( ram_data_in               )
);



//
// HC800
//

wire [4:0] red, green, blue;
wire hsync, vsync;

wire [4:0] dblRed, dblGreen, dblBlue;
wire dblHSync, dblVSync, dblBlank;

assign core_R[5:1] = doublescan_disable ? red : dblRed;
assign core_G[5:1] = doublescan_disable ? green : dblGreen;
assign core_B[5:1] = doublescan_disable ? blue : dblBlue;

assign core_hs = doublescan_disable ? hsync : dblHSync;
assign core_vs = doublescan_disable ? vsync : dblVSync;

wire hsync_n = !osd_hs;
wire vsync_n = !osd_vs;
wire csync_n = hsync_n & vsync_n;

assign VGA_HS = no_csync ? hsync_n : csync_n;
assign VGA_VS = no_csync ? vsync_n : 1'b1;


HC800 hc800(
	.dbl_clk(clk_27M),
	.dbl_reset(reset),
	.bus_clk(clk_13_5M),
	.bus_reset(reset),
	.cpu_clk(clk_6_75M),
	.cpu_reset(reset),

//	.io_seg(),
//	.io_an(),
//	.io_btn({!btn_reset_n_i,!btn_multiface_n_i,!btn_reset_n_i,!btn_divmmc_n_i,!btn_reset_n_i}),
	
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
	
	.io_txd(UART_TX),
	.io_rxd(UART_RX),
	
	.io_ps2Code(kbd_data),
	.io_ps2Make(kbd_make),
	.io_ps2Extend(kbd_extend),
	.io_ps2Strobe(kbd_ready),
	
	.io_ramBus_enable(ram_enable),
	.io_ramBus_write(ram_write),
	.io_ramBus_dataToMaster(ram_data_in_bus_r),
	.io_ramBus_dataFromMaster(ram_data_out),
	.io_ramBus_address(ram_address)
);


always @(posedge clk_27M or posedge res)
	if (res)
		LED <= 1'b1;
	else if (core_led)
		LED <= 1'b0;


endmodule


module AttributeMemory (
	input				clka,
	input				ena,
	input				wea,
	input	 [11:0]	addra,
	input  [15:0]	dina,
	output [15:0]	douta,
	
	input				clkb,
	input				enb,
	input				web,
	input	 [12:0]	addrb,
	input  [7:0]	dinb,
	output [7:0]	doutb
);

AttributeMemoryAltera attrAltera(
	.clock(clka),

	.address_a(addra),
	.data_a(dina),
	.rden_a(ena),
	.wren_a(ena && wea),
	.q_a(douta),

	.address_b(addrb),
	.data_b(dinb),
	.rden_b(enb),
	.wren_b(enb && web),
	.q_b(doutb)
);

endmodule
 
 module PaletteMemory (
	input				clka,
	input				ena,
	input				wea,
	input	 [7:0]	addra,
	input  [15:0]	dina,
	output [15:0]	douta,
	
	input				clkb,
	input				enb,
	input				web,
	input	 [8:0]	addrb,
	input  [7:0]	dinb,
	output [7:0]	doutb
);

PaletteMemoryAltera paletteAltera(
	.clock(clka),
	
	.address_a(addra),
	.data_a(dina),
	.rden_a(ena),
	.wren_a(ena && wea),
	.q_a(douta),

	.address_b(addrb),
	.data_b(dinb),
	.rden_b(enb),
	.wren_b(enb && web),
	.q_b(doutb)
);

endmodule


module ScanlineMemory (
	input				clka,
	input				ena,
	input				wea,
	input	 [9:0]	addra,
	input  [14:0]	dina,
	
	input				clkb,
	input				enb,
	input	 [9:0]	addrb,
	output [14:0]	doutb
);

ScanlineMemoryAltera scanlineAltera(
	.wrclock(clka),
	.data(dina),
	.wraddress(addra),
	.wren(wea && ena),
	
	.rdclock(clkb),
	.rden(enb),
	.rdaddress(addrb),
	.q(doutb)
);


endmodule

 