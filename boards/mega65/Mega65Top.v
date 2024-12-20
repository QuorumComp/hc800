`define HDMI

`default_nettype none
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 12:59:26 PM
// Design Name: 
// Module Name: Mega65Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mega65Top (
    // Onboard crystal oscillator = 100 MHz
    input  wire         sys_clk_i,

    // Reset button on the side of the machine
    input  wire         sys_rst_i,         // Active high

    // USB-RS232 Interface
    input  wire         uart_rxd_i,
    output wire         uart_txd_o,

    // VGA via VDAC. U3 = ADV7125BCPZ170
    output wire [7:0]   vga_red_o,
    output wire [7:0]   vga_green_o,
    output wire [7:0]   vga_blue_o,
        
    output wire         vga_hs_o,
    output wire         vga_vs_o,
    inout  wire         vga_scl_io,             
    inout  wire         vga_sda_io,             
    output wire         vdac_clk_o,              
    output wire         vdac_sync_n_o,           
    output wire         vdac_blank_n_o,          
    output wire         vdac_psave_n_o,

    // HDMI. U10 = PTN3363BSMP
    // I2C address 0x40
    output wire [2:0]   tmds_data_p_o,
    output wire [2:0]   tmds_data_n_o,
    output wire         tmds_clk_p_o,            
    output wire         tmds_clk_n_o,            
    output wire         hdmi_hiz_en_o,          // Connect to U10.HIZ_EN
    output wire         hdmi_ls_oe_n_o,         // Connect to U10.OE#
    input  wire         hdmi_hpd_i,             // Connect to U10.HPD_SOURCE
    inout  wire         hdmi_scl_io,            // Connect to U10.SCL_SOURCE
    inout  wire         hdmi_sda_io,            // Connect to U10.SDA_SOURCE

    // MEGA65 smart keyboard controller
    output wire         kb_io0_o,               // clock to keyboard
    output wire         kb_io1_o,               // data output wire to keyboard
    input  wire         kb_io2_i                // data input  wire from keyboard
    //output wire         kb_tck_o,                
    //input  wire         kb_tdo_i,
    //output wire         kb_tms_o,
    //output wire         kb_tdi_o,
    //output wire         kb_jtagen_o             

    // Micro SD Connector (external slot at back of the cover)
    /*
    output wire         sd_reset_o,              
    output wire         sd_clk_o,                
    output wire         sd_mosi_o,               
    input  wire         sd_miso_i,
    input  wire         sd_cd_i,
    input  wire         sd_d1_i,
    input  wire         sd_d2_i,
    */

    // SD Connector (this is the slot at the bottom side of the case under the cover)
    /*
    output wire         sd2_reset_o,             
    output wire         sd2_clk_o,               
    output wire         sd2_mosi_o,              
    input  wire         sd2_miso_i,              
    input  wire         sd2_cd_i,                
    input  wire         sd2_wp_i,                
    input  wire         sd2_d1_i,                
    input  wire         sd2_d2_i,                
    */

    // Audio DAC. U37 = AK4432VT
    // I2C address 0x19
    /*
    output wire         audio_mclk_o,           // Master Clock Input  wire Pin,      12.288 MHz
    output wire         audio_bick_o,           // Audio Serial Data Clock Pin,       3.072 MHz
    output wire         audio_sdti_o,           // Audio Serial Data Input  wire Pin, 16-bit LSB justified
    output wire         audio_lrclk_o,          // Input  wire Channel Clock Pin,     48.0 kHz
    output wire         audio_pdn_n_o,          // Power-Down & Reset Pin
    output wire         audio_i2cfil_o,         // I2C Interface Mode Select Pin
    inout  wire         audio_scl_io,           // Control Data Clock Input  wire Pin
    inout  wire         audio_sda_io,           // Control Data Input/Output wire Pin
    */

    // Joysticks and Paddles
    /*
    input  wire         fa_up_n_i,               
    input  wire         fa_down_n_i,             
    input  wire         fa_left_n_i,             
    input  wire         fa_right_n_i,            
    input  wire         fa_fire_n_i,             
    output wire         fa_fire_n_o,            // 0: Drive pin low (output). 1: Leave pin floating (input)
    output wire         fa_up_n_o,               
    output wire         fa_left_n_o,             
    output wire         fa_down_n_o,             
    output wire         fa_right_n_o,            
    input  wire         fb_up_n_i,               
    input  wire         fb_down_n_i,             
    input  wire         fb_left_n_i,             
    input  wire         fb_right_n_i,            
    input  wire         fb_fire_n_i,             
    output wire         fb_up_n_o,               
    output wire         fb_down_n_o,             
    output wire         fb_fire_n_o,             
    output wire         fb_right_n_o,            
    output wire         fb_left_n_o,             
    */

    // Joystick power supply
    /*
    output wire         joystick_5v_disable_o,  // 1: Disable 5V power supply to joysticks
    input  wire         joystick_5v_powergood_i, 
    
    input  wire [3:0]   paddle_i,
    output wire         paddle_drain_o,          
    */

    // HyperRAM. U29 = IS66WVH8M8DBLL-100B1LI
    /*
    inout  wire [7:0]   hr_d_io,
    inout  wire         hr_rwds_io,             
    output wire         hr_reset_o,              
    output wire         hr_clk_p_o,              
    output wire         hr_cs0_o,                
    */

    // CBM-488/IEC serial port
    /*
    output wire         iec_reset_n_o,           
    output wire         iec_atn_n_o,             
    output wire         iec_clk_en_n_o,          
    input  wire         iec_clk_n_i,             
    output wire         iec_clk_n_o,             
    output wire         iec_data_en_n_o,         
    input  wire         iec_data_n_i,            
    output wire         iec_data_n_o,            
    output wire         iec_srq_en_n_o,          
    input  wire         iec_srq_n_i,             
    output wire         iec_srq_n_o,
    */

    // C64 Expansion Port (aka Cartridge Port)
    /*
    output wire         cart_phi2_o,             
    output wire         cart_dotclock_o,         
    input  wire         cart_dma_i,              
    output wire         cart_reset_oe_n_o,       
    inout  wire         cart_reset_io,          
    output wire         cart_game_oe_n_o,        
    inout  wire         cart_game_io,           
    output wire         cart_exrom_oe_n_o,       
    inout  wire         cart_exrom_io,          
    output wire         cart_nmi_oe_n_o,         
    inout  wire         cart_nmi_io,            
    output wire         cart_irq_oe_n_o,         
    inout  wire         cart_irq_io,            
    output wire         cart_ctrl_en_o,          
    output wire         cart_ctrl_dir_o,        // =1 means FPGA->Port, =0 means Port->FPGA
    inout  wire         cart_ba_io,             
    inout  wire         cart_rw_io,             
    inout  wire         cart_io1_io,            
    inout  wire         cart_io2_io,            
    output wire         cart_romh_oe_n_o,        
    inout  wire         cart_romh_io,           
    output wire         cart_roml_oe_n_o,        
    inout  wire         cart_roml_io,           
    output wire         cart_en_o,               
    output wire         cart_addr_en_o,          
    output wire         cart_haddr_dir_o,       // =1 means FPGA->Port, =0 means Port->FPGA
    output wire         cart_laddr_dir_o,       // =1 means FPGA->Port, =0 means Port->FPGA
    inout  wire [15:0]  cart_a_io,
    output wire         cart_data_en_o,          
    output wire         cart_data_dir_o,        // =1 means FPGA->Port, =0 means Port->FPGA
    inout  wire [7:0]   cart_d_io,
    */

    // The remaining ports are not supported

    // SMSC Ethernet PHY. U4 = KSZ8081RNDCA
    /*
    output wire         eth_clock_o,             
    output wire         eth_led2_o,              
    output wire         eth_mdc_o,               
    inout  wire         eth_mdio_io,            
    output wire         eth_reset_o,             
    input  wire [1:0]   eth_rxd_i,
    input  wire         eth_rxdv_i,              
    input  wire         eth_rxer_i,              
    output wire [1:0]   eth_txd_o,
    output wire         eth_txen_o,              
    */

    // FDC interface
    /*
    output wire         f_density_o,             
    input  wire         f_diskchanged_i,         
    input  wire         f_index_i,               
    output wire         f_motora_o,              
    output wire         f_motorb_o,              
    input  wire         f_rdata_i,               
    output wire         f_selecta_o,             
    output wire         f_selectb_o,             
    output wire         f_side1_o,               
    output wire         f_stepdir_o,             
    output wire         f_step_o,                
    input  wire         f_track0_i,              
    output wire         f_wdata_o,               
    output wire         f_wgate_o,               
    input  wire         f_writeprotect_i,        
    */

    // I2C bus for on-board peripherals
    // U36. 24AA025E48T. Address 0x50. 2K Serial EEPROM.
    // U38. RV-3032-C7.  Address 0x51. Real-Time Clock Module.
    // U39. 24LC128.     Address 0x56. 128K CMOS Serial EEPROM.
    /*
    inout  wire         fpga_sda_io,            
    inout  wire         fpga_scl_io,            
    */

    // Connected to J18
    /*
    inout  wire         grove_sda_io,           
    inout  wire         grove_scl_io,           
    */

    // On board LEDs
    /*
    output wire         led_g_n_o,               
    output wire         led_r_n_o,               
    output wire         led_o,                   
    */

    // Pmod Header
    /*
    inout  wire [3:0]   p1lo_io,
    inout  wire [3:0]   p1hi_io,
    inout  wire [3:0]   p2lo_io,
    inout  wire [3:0]   p2hi_io,
    output wire         pmod1_en_o,              
    input  wire         pmod1_flag_i,            
    output wire         pmod2_en_o,              
    input  wire         pmod2_flag_i,            
    */

    // Quad SPI Flash. U5 = S25FL512SAGBHIS10
    /*
    inout  wire [3:0]   qspidb_io,
    output wire         qspicsn_o,               
    */


    // I2C bus
    // U32 = PCA9655EMTTXG. Address 0x40. I/O expander.
    // U12 = MP8869SGL-Z.   Address 0x61. DC/DC Converter.
    // U14 = MP8869SGL-Z.   Address 0x67. DC/DC Converter.
    /*
    inout  wire         i2c_scl_io,             
    inout  wire         i2c_sda_io,             
    */

    // Debug.
    /*
    inout  wire         dbg_11_io,              
    */

    // SDRAM - 32M x 16 bit, 3.3V VCC. U44 = IS42S16320F-6BL
    /*
    output wire         sdram_clk_o,             
    output wire         sdram_cke_o,             
    output wire         sdram_ras_n_o,           
    output wire         sdram_cas_n_o,           
    output wire         sdram_we_n_o,            
    output wire         sdram_cs_n_o,            
    output wire [1:0]   sdram_ba_o,
    output wire [12:0]  sdram_a_o,
    output wire         sdram_dqml_o,            
    output wire         sdram_dqmh_o,            
    inout  wire [15:0]  sdram_dq_io
    */
);

wire doublescan = 1;

wire clk_13_5M;
wire clk_27M;
wire clk_100M;
wire clk_135M;
wire clk_135M_n;
wire clk_locked;

wire hdmiclk_pix = clk_27M;
wire hdmiclk_pix_5x = clk_135M;
wire hdmiclk_pix_5x_n = clk_135M_n;

wire [4:0] red, green, blue;
wire hsync, vsync, blank;

wire [4:0] dblRed, dblGreen, dblBlue;
wire dblHSync, dblVSync, dblBlank;


//
// Reset, clocks
//

reg reset = 1;
reg count_in = 0;
reg [3:0] clk_count = 4'd8;

// Hold reset for a number of cycles when starting

always @(posedge sys_clk_i) begin
    if (clk_locked) begin
        count_in <= 1'b1;
    end
end

reg [2:0] reset_i_13_5M = 0;
always @(posedge clk_13_5M) begin
    if (clk_locked) begin
        reset_i_13_5M <= {sys_rst_i, reset_i_13_5M[2:1]};
        if (count_in) begin
            if (clk_count != 4'd0) begin
                clk_count <= clk_count - 4'd1;
            end else if (reset_i_13_5M[0]) begin
                reset <= 1;
            end else begin
                reset <= 0;
            end
        end
    end
end


Clocks pll (
    .clk_in_100M(sys_clk_i),
    .clk_out_13_5M(clk_13_5M),
    .clk_out_27M(clk_27M),
    .clk_out_100M(clk_100M),
    .clk_out_135M(clk_135M),
    .clk_out_135M_n(clk_135M_n),
    .locked(clk_locked)
);


//
// RGB colors
//

assign vga_red_o[2:0]   = 0;
assign vga_green_o[2:0] = 0;
assign vga_blue_o[2:0]  = 0;

assign vga_red_o[7:3]   = doublescan ? dblRed   : red;
assign vga_green_o[7:3] = doublescan ? dblGreen : green;
assign vga_blue_o[7:3]  = doublescan ? dblBlue  : blue;


//
// Sync signals
//

wire hsync_n = !(doublescan ? dblHSync : hsync);
wire vsync_n = !(doublescan ? dblVSync : vsync);
wire csync_n = hsync_n & vsync_n;
wire blank_n = !(doublescan ? dblBlank : blank);

assign vga_hs_o = hsync_n;
assign vga_vs_o = vsync_n;
assign vdac_sync_n_o = csync_n;
assign vdac_blank_n_o = blank_n;
assign vdac_clk_o = doublescan ? clk_27M : clk_13_5M;
assign vdac_psave_n_o = 1'b1;


//
// HDMI
//

/*

OBUFDS obuf_data_2(
    .I(2'b0),
    .O(tmds_data_p_o[2]),
    .OB(tmds_data_n_o[2])
);

OBUFDS obuf_data_1(
    .I(2'b0),
    .O(tmds_data_p_o[1]),
    .OB(tmds_data_n_o[1])
);

OBUFDS obuf_data_0(
    .I(2'b0),
    .O(tmds_data_p_o[0]),
    .OB(tmds_data_n_o[0])
);

OBUFDS obuf_clk(
    .I(2'b0),
    .O(tmds_clk_p_o),
    .OB(tmds_clk_n_o)
);

*/


//
// HC800
//

wire [20:0] mem_addr;
wire  [7:0] mem_din;
wire  [7:0] mem_dout;
wire        mem_ena;
wire        mem_we;
reg         mem_ena_out;
wire  [7:0] mem_to_master;

assign mem_to_master = mem_ena_out ? mem_dout : 8'h00;

always @(posedge clk_13_5M) begin
    mem_ena_out <= mem_ena && !mem_we;
end


MainMemory main_memory(
    .addra(mem_addr[19:0]),
    .dina(mem_din),
    .douta(mem_dout),
    .clka(clk_13_5M),
    .ena(mem_ena),
    .wea(mem_we && mem_ena)
);


`ifdef HDMI

wire [9:0] hdmiRed, hdmiGreen, hdmiBlue;

hdmi hdmi_encoder(
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
    .O_BLUE(hdmiBlue)
);
    
hdmi_out_xilinx hdmi_out(
	.clock_pixel_i(hdmiclk_pix),
	.clock_tdms_i(hdmiclk_pix_5x),
	.clock_tdms_n_i(hdmiclk_pix_5x_n),
	
	.red_i(hdmiRed),
	.green_i(hdmiGreen),
	.blue_i(hdmiBlue),
	
	.tmds_out_p({tmds_clk_p_o, tmds_data_p_o}),
	.tmds_out_n({tmds_clk_n_o, tmds_data_n_o})
);

assign hdmi_hiz_en_o = 1'b0;    // enable/disable 50 Ohm internal termination (0 = disable)
assign hdmi_ls_oe_n_o = 1'b0;   // enable output (0 = enable)

`else

OBUFDS OBUFDS_clock(.I(0), .O(tmds_clk_p_o[3]),  .OB(tmds_clk_n_o[3]));
OBUFDS OBUFDS_red  (.I(0), .O(tmds_data_p_o[2]), .OB(tmds_data_n_o[2]));
OBUFDS OBUFDS_green(.I(0), .O(tmds_data_p_o[1]), .OB(tmds_data_n_o[1]));
OBUFDS OBUFDS_blue (.I(0), .O(tmds_data_p_o[0]), .OB(tmds_data_n_o[0]));

assign hdmi_hiz_en_o = 1'b0;    // enable/disable 50 Ohm internal termination (0 = disable)
assign hdmi_ls_oe_n_o = 1'b1;   // enable output (0 = enable)

`endif


HC800 hc800(
    .io_red(red),
    .io_green(green),
    .io_blue(blue),
    .io_hsync(hsync),
    .io_vsync(vsync),
    .io_blank(blank),
    .io_dblRed(dblRed),
    .io_dblGreen(dblGreen),
    .io_dblBlue(dblBlue),
    .io_dblHSync(dblHSync),
    .io_dblVSync(dblVSync),
    .io_dblBlank(dblBlank),
    .bus_clk(clk_13_5M),
    .bus_reset(reset),
    .dbl_clk(clk_27M),
    .dbl_reset(reset),
    .io_txd(uart_txd_o),
    .io_rxd(uart_rxd_i),
    .io_ramBus_enable(mem_ena),
    .io_ramBus_write(mem_we),
    .io_ramBus_dataFromMaster(mem_din),
    .io_ramBus_dataToMaster(mem_to_master),
    .io_ramBus_address(mem_addr),
    .io_kio8_o(kb_io0_o),
    .io_kio9_o(kb_io1_o),
    .io_kio10_i(kb_io2_i)
);


endmodule
