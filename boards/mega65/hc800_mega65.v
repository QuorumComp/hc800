// Generator : SpinalHDL v1.6.4    git head : 598c18959149eb18e5eee5b0aa3eef01ecaa41a1
// Component : HC800
// Git hash  : b510c9d3fd07afdcfb2f9e3f5079db917e3b2bc5

`timescale 1ns/1ps 

module HC800 (
  output     [4:0]    io_red,
  output     [4:0]    io_green,
  output     [4:0]    io_blue,
  output              io_hsync,
  output              io_vsync,
  output              io_blank,
  output     [4:0]    io_dblRed,
  output     [4:0]    io_dblGreen,
  output     [4:0]    io_dblBlue,
  output              io_dblHSync,
  output              io_dblVSync,
  output              io_dblBlank,
  output              io_txd,
  input               io_rxd,
  output              io_ramBus_enable,
  output              io_ramBus_write,
  output     [7:0]    io_ramBus_dataFromMaster,
  input      [7:0]    io_ramBus_dataToMaster,
  output     [20:0]   io_ramBus_address,
  output     [1:0]    io_sd_cs,
  output              io_sd_clock,
  output              io_sd_di,
  input               io_sd_do,
  input               bus_clk,
  input               dbl_clk,
  input               bus_reset,
  input               dbl_reset
);
  localparam MapSource_cpu = 1'd0;
  localparam MapSource_chipsetCharGen = 1'd1;

  wire                memoryArea_mmu_io_regBus_enable;
  wire       [3:0]    memoryArea_mmu_io_regBus_address;
  wire       [15:0]   memoryArea_mmu_io_mapAddressIn;
  wire                memoryArea_boardId_enable;
  wire       [0:0]    memoryArea_boardId_address;
  wire                memoryArea_keyboard_io_bus_enable;
  wire       [0:0]    memoryArea_keyboard_io_bus_address;
  wire                memoryArea_interruptController_io_regBus_enable;
  wire       [1:0]    memoryArea_interruptController_io_regBus_address;
  wire                memoryArea_math_io_enable;
  wire       [2:0]    memoryArea_math_io_address;
  wire                memoryArea_bootROM_io_enable;
  wire       [10:0]   memoryArea_bootROM_io_address;
  wire                memoryArea_kernel_io_enable;
  wire       [13:0]   memoryArea_kernel_io_address;
  wire                memoryArea_font_io_enable;
  wire       [13:0]   memoryArea_font_io_address;
  wire                memoryArea_uart_io_bus_enable;
  wire       [0:0]    memoryArea_uart_io_bus_address;
  wire                memoryArea_sd_io_bus_enable;
  wire       [0:0]    memoryArea_sd_io_bus_address;
  wire                cpuArea_cpu_io_bus_enable;
  wire                cpuArea_cpu_io_bus_write;
  wire       [7:0]    cpuArea_cpu_io_bus_dataFromMaster;
  wire       [15:0]   cpuArea_cpu_io_bus_address;
  wire                cpuArea_cpu_io_io;
  wire                cpuArea_cpu_io_code;
  wire                cpuArea_cpu_io_system;
  wire       [7:0]    memoryArea_mmu_io_regBus_dataToMaster;
  wire       [21:0]   memoryArea_mmu_io_mapAddressOut;
  wire       [7:0]    memoryArea_boardId_dataToMaster;
  wire       [7:0]    memoryArea_keyboard_io_bus_dataToMaster;
  wire                memoryArea_interruptController_io_outRequest;
  wire       [7:0]    memoryArea_interruptController_io_regBus_dataToMaster;
  wire       [7:0]    memoryArea_math_io_dataToMaster;
  wire       [7:0]    memoryArea_bootROM_io_dataToMaster;
  wire       [7:0]    memoryArea_kernel_io_dataToMaster;
  wire       [7:0]    memoryArea_font_io_dataToMaster;
  wire       [7:0]    memoryArea_uart_io_bus_dataToMaster;
  wire                memoryArea_uart_io_uart_txd;
  wire       [7:0]    memoryArea_sd_io_bus_dataToMaster;
  wire       [1:0]    memoryArea_sd_io_sd_cs;
  wire                memoryArea_sd_io_sd_clock;
  wire                memoryArea_sd_io_sd_di;
  wire       [4:0]    graphicsArea_videoGenerator_io_red;
  wire       [4:0]    graphicsArea_videoGenerator_io_green;
  wire       [4:0]    graphicsArea_videoGenerator_io_blue;
  wire                graphicsArea_videoGenerator_io_hSync;
  wire                graphicsArea_videoGenerator_io_vSync;
  wire                graphicsArea_videoGenerator_io_hBlanking;
  wire                graphicsArea_videoGenerator_io_vBlanking;
  wire       [4:0]    graphicsArea_videoGenerator_io_dblRed;
  wire       [4:0]    graphicsArea_videoGenerator_io_dblGreen;
  wire       [4:0]    graphicsArea_videoGenerator_io_dblBlue;
  wire                graphicsArea_videoGenerator_io_dblHSync;
  wire                graphicsArea_videoGenerator_io_dblVSync;
  wire                graphicsArea_videoGenerator_io_dblBlank;
  wire                graphicsArea_videoGenerator_io_attrBus_enable;
  wire       [11:0]   graphicsArea_videoGenerator_io_attrBus_address;
  wire                graphicsArea_videoGenerator_io_paletteBus_enable;
  wire       [7:0]    graphicsArea_videoGenerator_io_paletteBus_address;
  wire                graphicsArea_videoGenerator_io_memBus_enable;
  wire       [15:0]   graphicsArea_videoGenerator_io_memBus_address;
  wire       [0:0]    graphicsArea_videoGenerator_io_memBusSource;
  wire       [7:0]    graphicsArea_videoGenerator_io_regBus_dataToMaster;
  wire       [15:0]   graphicsArea_graphicsMemoryArea_attrMemory_io_wideBus_dataToMaster;
  wire       [7:0]    graphicsArea_graphicsMemoryArea_attrMemory_io_byteBus_dataToMaster;
  wire       [15:0]   graphicsArea_graphicsMemoryArea_paletteMemory_io_wideBus_dataToMaster;
  wire       [7:0]    graphicsArea_graphicsMemoryArea_paletteMemory_io_byteBus_dataToMaster;
  reg        [3:0]    mainArea_cycleCounter;
  wire       [1:0]    mainArea_lowCycleCounter;
  wire                mainArea_cpuBusMaster;
  wire                mainArea_chipsetBusMaster;
  reg        [0:0]    _zz_when_ClockDomain_l353;
  wire                when_ClockDomain_l353;
  reg                 when_ClockDomain_l353_regNext;
  wire                cpuArea_irq;
  wire       [0:0]    memoryArea_chipSource;
  wire       [0:0]    memoryArea_source;
  wire                memoryArea_chipMemBus_enable;
  wire       [7:0]    memoryArea_chipMemBus_dataToMaster;
  wire       [15:0]   memoryArea_chipMemBus_address;
  wire                memoryArea_graphicsRegBus_enable;
  wire                memoryArea_graphicsRegBus_write;
  wire       [7:0]    memoryArea_graphicsRegBus_dataFromMaster;
  wire       [7:0]    memoryArea_graphicsRegBus_dataToMaster;
  wire       [7:0]    memoryArea_graphicsRegBus_address;
  wire                memoryArea_attributeMemBus_enable;
  wire                memoryArea_attributeMemBus_write;
  wire       [7:0]    memoryArea_attributeMemBus_dataFromMaster;
  wire       [7:0]    memoryArea_attributeMemBus_dataToMaster;
  wire       [12:0]   memoryArea_attributeMemBus_address;
  wire                memoryArea_paletteMemBus_enable;
  wire                memoryArea_paletteMemBus_write;
  wire       [7:0]    memoryArea_paletteMemBus_dataFromMaster;
  wire       [7:0]    memoryArea_paletteMemBus_dataToMaster;
  wire       [8:0]    memoryArea_paletteMemBus_address;
  wire                memoryArea_machineBus_enable;
  wire                memoryArea_machineBus_write;
  wire       [7:0]    memoryArea_machineBus_dataFromMaster;
  wire       [7:0]    memoryArea_machineBus_dataToMaster;
  wire       [21:0]   memoryArea_machineBus_address;
  reg                 _zz_memoryArea_machineBus_enable;
  reg                 _zz_memoryArea_machineBus_write;
  reg        [7:0]    cpuArea_cpu_io_bus_dataFromMaster_regNext;
  reg        [21:0]   memoryArea_mmu_io_mapAddressOut_regNext;
  wire                memoryArea_mmuEnable;
  wire                memoryArea_boardIdEnable;
  wire                memoryArea_graphicsEnable;
  wire                memoryArea_keyboardEnable;
  wire                memoryArea_boardEnable;
  wire                memoryArea_mathEnable;
  wire                memoryArea_uartEnable;
  wire                memoryArea_sdEnable;
  wire                memoryArea_intCtrlEnable;
  wire                memoryArea_bootEnable;
  wire                memoryArea_kernelEnable;
  wire                memoryArea_fontEnable;
  wire                memoryArea_attrMemEnable;
  wire                memoryArea_paletteMemEnable;
  wire                memoryArea_ramEnable;
  wire                memoryArea_hBlanking;
  wire                memoryArea_vBlanking;
  reg        [6:0]    _zz_io_inRequest;
  wire       [7:0]    memoryArea_nexys3IoDataIn;
  wire       [7:0]    memoryArea_memDataIn;
  `ifndef SYNTHESIS
  reg [111:0] memoryArea_chipSource_string;
  reg [111:0] memoryArea_source_string;
  `endif


  CPU cpuArea_cpu (
    .io_irq                           (cpuArea_irq                             ), //i
    .io_bus_enable                    (cpuArea_cpu_io_bus_enable               ), //o
    .io_bus_write                     (cpuArea_cpu_io_bus_write                ), //o
    .io_bus_dataFromMaster            (cpuArea_cpu_io_bus_dataFromMaster[7:0]  ), //o
    .io_bus_dataToMaster              (memoryArea_memDataIn[7:0]               ), //i
    .io_bus_address                   (cpuArea_cpu_io_bus_address[15:0]        ), //o
    .io_io                            (cpuArea_cpu_io_io                       ), //o
    .io_code                          (cpuArea_cpu_io_code                     ), //o
    .io_system                        (cpuArea_cpu_io_system                   ), //o
    .bus_clk                          (bus_clk                                 ), //i
    .bus_reset                        (bus_reset                               ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext           )  //i
  );
  MMU memoryArea_mmu (
    .io_regBus_enable            (memoryArea_mmu_io_regBus_enable             ), //i
    .io_regBus_write             (memoryArea_machineBus_write                 ), //i
    .io_regBus_dataFromMaster    (memoryArea_machineBus_dataFromMaster[7:0]   ), //i
    .io_regBus_dataToMaster      (memoryArea_mmu_io_regBus_dataToMaster[7:0]  ), //o
    .io_regBus_address           (memoryArea_mmu_io_regBus_address[3:0]       ), //i
    .io_mapSource                (memoryArea_source                           ), //i
    .io_mapCode                  (cpuArea_cpu_io_code                         ), //i
    .io_mapSystem                (cpuArea_cpu_io_system                       ), //i
    .io_mapIo                    (cpuArea_cpu_io_io                           ), //i
    .io_mapAddressIn             (memoryArea_mmu_io_mapAddressIn[15:0]        ), //i
    .io_mapAddressOut            (memoryArea_mmu_io_mapAddressOut[21:0]       ), //o
    .bus_clk                     (bus_clk                                     ), //i
    .bus_reset                   (bus_reset                                   )  //i
  );
  BoardId memoryArea_boardId (
    .enable          (memoryArea_boardId_enable             ), //i
    .dataToMaster    (memoryArea_boardId_dataToMaster[7:0]  ), //o
    .address         (memoryArea_boardId_address            ), //i
    .bus_clk         (bus_clk                               ), //i
    .bus_reset       (bus_reset                             )  //i
  );
  NullKeyboard memoryArea_keyboard (
    .io_bus_enable          (memoryArea_keyboard_io_bus_enable             ), //i
    .io_bus_dataToMaster    (memoryArea_keyboard_io_bus_dataToMaster[7:0]  ), //o
    .io_bus_address         (memoryArea_keyboard_io_bus_address            ), //i
    .bus_clk                (bus_clk                                       ), //i
    .bus_reset              (bus_reset                                     )  //i
  );
  InterruptController memoryArea_interruptController (
    .io_inRequest                (_zz_io_inRequest[6:0]                                       ), //i
    .io_outRequest               (memoryArea_interruptController_io_outRequest                ), //o
    .io_regBus_enable            (memoryArea_interruptController_io_regBus_enable             ), //i
    .io_regBus_write             (memoryArea_machineBus_write                                 ), //i
    .io_regBus_dataFromMaster    (memoryArea_machineBus_dataFromMaster[7:0]                   ), //i
    .io_regBus_dataToMaster      (memoryArea_interruptController_io_regBus_dataToMaster[7:0]  ), //o
    .io_regBus_address           (memoryArea_interruptController_io_regBus_address[1:0]       ), //i
    .bus_clk                     (bus_clk                                                     ), //i
    .bus_reset                   (bus_reset                                                   )  //i
  );
  Math memoryArea_math (
    .io_enable            (memoryArea_math_io_enable                  ), //i
    .io_write             (memoryArea_machineBus_write                ), //i
    .io_dataFromMaster    (memoryArea_machineBus_dataFromMaster[7:0]  ), //i
    .io_dataToMaster      (memoryArea_math_io_dataToMaster[7:0]       ), //o
    .io_address           (memoryArea_math_io_address[2:0]            ), //i
    .bus_clk              (bus_clk                                    ), //i
    .bus_reset            (bus_reset                                  )  //i
  );
  BootROM memoryArea_bootROM (
    .io_enable          (memoryArea_bootROM_io_enable             ), //i
    .io_dataToMaster    (memoryArea_bootROM_io_dataToMaster[7:0]  ), //o
    .io_address         (memoryArea_bootROM_io_address[10:0]      ), //i
    .bus_clk            (bus_clk                                  ), //i
    .bus_reset          (bus_reset                                )  //i
  );
  RAM memoryArea_kernel (
    .io_enable            (memoryArea_kernel_io_enable                ), //i
    .io_write             (memoryArea_machineBus_write                ), //i
    .io_dataFromMaster    (memoryArea_machineBus_dataFromMaster[7:0]  ), //i
    .io_dataToMaster      (memoryArea_kernel_io_dataToMaster[7:0]     ), //o
    .io_address           (memoryArea_kernel_io_address[13:0]         ), //i
    .bus_clk              (bus_clk                                    ), //i
    .bus_reset            (bus_reset                                  )  //i
  );
  Font memoryArea_font (
    .io_enable          (memoryArea_font_io_enable             ), //i
    .io_dataToMaster    (memoryArea_font_io_dataToMaster[7:0]  ), //o
    .io_address         (memoryArea_font_io_address[13:0]      ), //i
    .bus_clk            (bus_clk                               ), //i
    .bus_reset          (bus_reset                             )  //i
  );
  UART memoryArea_uart (
    .io_bus_enable            (memoryArea_uart_io_bus_enable              ), //i
    .io_bus_write             (memoryArea_machineBus_write                ), //i
    .io_bus_dataFromMaster    (memoryArea_machineBus_dataFromMaster[7:0]  ), //i
    .io_bus_dataToMaster      (memoryArea_uart_io_bus_dataToMaster[7:0]   ), //o
    .io_bus_address           (memoryArea_uart_io_bus_address             ), //i
    .io_uart_txd              (memoryArea_uart_io_uart_txd                ), //o
    .io_uart_rxd              (io_rxd                                     ), //i
    .bus_clk                  (bus_clk                                    ), //i
    .bus_reset                (bus_reset                                  )  //i
  );
  SD memoryArea_sd (
    .io_bus_enable            (memoryArea_sd_io_bus_enable                ), //i
    .io_bus_write             (memoryArea_machineBus_write                ), //i
    .io_bus_dataFromMaster    (memoryArea_machineBus_dataFromMaster[7:0]  ), //i
    .io_bus_dataToMaster      (memoryArea_sd_io_bus_dataToMaster[7:0]     ), //o
    .io_bus_address           (memoryArea_sd_io_bus_address               ), //i
    .io_sd_cs                 (memoryArea_sd_io_sd_cs[1:0]                ), //o
    .io_sd_clock              (memoryArea_sd_io_sd_clock                  ), //o
    .io_sd_di                 (memoryArea_sd_io_sd_di                     ), //o
    .io_sd_do                 (io_sd_do                                   ), //i
    .bus_clk                  (bus_clk                                    ), //i
    .bus_reset                (bus_reset                                  )  //i
  );
  VideoGenerator graphicsArea_videoGenerator (
    .io_red                        (graphicsArea_videoGenerator_io_red[4:0]                                      ), //o
    .io_green                      (graphicsArea_videoGenerator_io_green[4:0]                                    ), //o
    .io_blue                       (graphicsArea_videoGenerator_io_blue[4:0]                                     ), //o
    .io_hSync                      (graphicsArea_videoGenerator_io_hSync                                         ), //o
    .io_vSync                      (graphicsArea_videoGenerator_io_vSync                                         ), //o
    .io_hBlanking                  (graphicsArea_videoGenerator_io_hBlanking                                     ), //o
    .io_vBlanking                  (graphicsArea_videoGenerator_io_vBlanking                                     ), //o
    .io_dblRed                     (graphicsArea_videoGenerator_io_dblRed[4:0]                                   ), //o
    .io_dblGreen                   (graphicsArea_videoGenerator_io_dblGreen[4:0]                                 ), //o
    .io_dblBlue                    (graphicsArea_videoGenerator_io_dblBlue[4:0]                                  ), //o
    .io_dblHSync                   (graphicsArea_videoGenerator_io_dblHSync                                      ), //o
    .io_dblVSync                   (graphicsArea_videoGenerator_io_dblVSync                                      ), //o
    .io_dblBlank                   (graphicsArea_videoGenerator_io_dblBlank                                      ), //o
    .io_attrBus_enable             (graphicsArea_videoGenerator_io_attrBus_enable                                ), //o
    .io_attrBus_dataToMaster       (graphicsArea_graphicsMemoryArea_attrMemory_io_wideBus_dataToMaster[15:0]     ), //i
    .io_attrBus_address            (graphicsArea_videoGenerator_io_attrBus_address[11:0]                         ), //o
    .io_paletteBus_enable          (graphicsArea_videoGenerator_io_paletteBus_enable                             ), //o
    .io_paletteBus_dataToMaster    (graphicsArea_graphicsMemoryArea_paletteMemory_io_wideBus_dataToMaster[15:0]  ), //i
    .io_paletteBus_address         (graphicsArea_videoGenerator_io_paletteBus_address[7:0]                       ), //o
    .io_memBus_enable              (graphicsArea_videoGenerator_io_memBus_enable                                 ), //o
    .io_memBus_dataToMaster        (memoryArea_chipMemBus_dataToMaster[7:0]                                      ), //i
    .io_memBus_address             (graphicsArea_videoGenerator_io_memBus_address[15:0]                          ), //o
    .io_memBusSource               (graphicsArea_videoGenerator_io_memBusSource                                  ), //o
    .io_memBusCycle                (mainArea_cycleCounter[3:0]                                                   ), //i
    .io_regBus_enable              (memoryArea_graphicsRegBus_enable                                             ), //i
    .io_regBus_write               (memoryArea_graphicsRegBus_write                                              ), //i
    .io_regBus_dataFromMaster      (memoryArea_graphicsRegBus_dataFromMaster[7:0]                                ), //i
    .io_regBus_dataToMaster        (graphicsArea_videoGenerator_io_regBus_dataToMaster[7:0]                      ), //o
    .io_regBus_address             (memoryArea_graphicsRegBus_address[7:0]                                       ), //i
    .bus_clk                       (bus_clk                                                                      ), //i
    .dbl_clk                       (dbl_clk                                                                      ), //i
    .bus_reset                     (bus_reset                                                                    ), //i
    .dbl_reset                     (dbl_reset                                                                    )  //i
  );
  SpinalAttributeMemory graphicsArea_graphicsMemoryArea_attrMemory (
    .bus_clk                      (bus_clk                                                                   ), //i
    .io_wideBus_enable            (graphicsArea_videoGenerator_io_attrBus_enable                             ), //i
    .io_wideBus_dataToMaster      (graphicsArea_graphicsMemoryArea_attrMemory_io_wideBus_dataToMaster[15:0]  ), //o
    .io_wideBus_address           (graphicsArea_videoGenerator_io_attrBus_address[11:0]                      ), //i
    .io_byteBus_enable            (memoryArea_attributeMemBus_enable                                         ), //i
    .io_byteBus_write             (memoryArea_attributeMemBus_write                                          ), //i
    .io_byteBus_dataFromMaster    (memoryArea_attributeMemBus_dataFromMaster[7:0]                            ), //i
    .io_byteBus_dataToMaster      (graphicsArea_graphicsMemoryArea_attrMemory_io_byteBus_dataToMaster[7:0]   ), //o
    .io_byteBus_address           (memoryArea_attributeMemBus_address[12:0]                                  ), //i
    .bus_reset                    (bus_reset                                                                 )  //i
  );
  SpinalPaletteMemory graphicsArea_graphicsMemoryArea_paletteMemory (
    .bus_clk                      (bus_clk                                                                      ), //i
    .io_wideBus_enable            (graphicsArea_videoGenerator_io_paletteBus_enable                             ), //i
    .io_wideBus_dataToMaster      (graphicsArea_graphicsMemoryArea_paletteMemory_io_wideBus_dataToMaster[15:0]  ), //o
    .io_wideBus_address           (graphicsArea_videoGenerator_io_paletteBus_address[7:0]                       ), //i
    .io_byteBus_enable            (memoryArea_paletteMemBus_enable                                              ), //i
    .io_byteBus_write             (memoryArea_paletteMemBus_write                                               ), //i
    .io_byteBus_dataFromMaster    (memoryArea_paletteMemBus_dataFromMaster[7:0]                                 ), //i
    .io_byteBus_dataToMaster      (graphicsArea_graphicsMemoryArea_paletteMemory_io_byteBus_dataToMaster[7:0]   ), //o
    .io_byteBus_address           (memoryArea_paletteMemBus_address[8:0]                                        ), //i
    .bus_reset                    (bus_reset                                                                    )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(memoryArea_chipSource)
      MapSource_cpu : memoryArea_chipSource_string = "cpu           ";
      MapSource_chipsetCharGen : memoryArea_chipSource_string = "chipsetCharGen";
      default : memoryArea_chipSource_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(memoryArea_source)
      MapSource_cpu : memoryArea_source_string = "cpu           ";
      MapSource_chipsetCharGen : memoryArea_source_string = "chipsetCharGen";
      default : memoryArea_source_string = "??????????????";
    endcase
  end
  `endif

  assign mainArea_lowCycleCounter = mainArea_cycleCounter[1 : 0];
  assign mainArea_cpuBusMaster = (mainArea_lowCycleCounter == 2'b00);
  assign mainArea_chipsetBusMaster = (! mainArea_cpuBusMaster);
  assign when_ClockDomain_l353 = (_zz_when_ClockDomain_l353 == 1'b1);
  assign memoryArea_source = (mainArea_cpuBusMaster ? MapSource_cpu : memoryArea_chipSource);
  assign memoryArea_machineBus_enable = _zz_memoryArea_machineBus_enable;
  assign memoryArea_machineBus_write = _zz_memoryArea_machineBus_write;
  assign memoryArea_machineBus_dataFromMaster = cpuArea_cpu_io_bus_dataFromMaster_regNext;
  assign memoryArea_mmu_io_mapAddressIn = (mainArea_cpuBusMaster ? cpuArea_cpu_io_bus_address : memoryArea_chipMemBus_address);
  assign memoryArea_machineBus_address = memoryArea_mmu_io_mapAddressOut_regNext;
  assign memoryArea_mmuEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h100100);
  assign memoryArea_boardIdEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h107ff0);
  assign memoryArea_graphicsEnable = ((memoryArea_machineBus_address & 22'h3fff00) == 22'h100500);
  assign memoryArea_keyboardEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h100300);
  assign memoryArea_boardEnable = ((memoryArea_machineBus_address & 22'h3fffe0) == 22'h107e00);
  assign memoryArea_mathEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h100200);
  assign memoryArea_uartEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h100400);
  assign memoryArea_sdEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h100600);
  assign memoryArea_intCtrlEnable = ((memoryArea_machineBus_address & 22'h3ffff0) == 22'h100000);
  assign memoryArea_bootEnable = ((memoryArea_machineBus_address & 22'h3fc000) == 22'h0);
  assign memoryArea_kernelEnable = ((memoryArea_machineBus_address & 22'h3fc000) == 22'h004000);
  assign memoryArea_fontEnable = ((memoryArea_machineBus_address & 22'h3fc000) == 22'h020000);
  assign memoryArea_attrMemEnable = ((memoryArea_machineBus_address & 22'h3fc000) == 22'h10c000);
  assign memoryArea_paletteMemEnable = ((memoryArea_machineBus_address & 22'h3fc000) == 22'h108000);
  assign memoryArea_ramEnable = ((memoryArea_machineBus_address & 22'h200000) == 22'h200000);
  always @(*) begin
    _zz_io_inRequest = 7'h0;
    _zz_io_inRequest[0] = memoryArea_vBlanking;
    _zz_io_inRequest[1] = memoryArea_hBlanking;
  end

  assign cpuArea_irq = memoryArea_interruptController_io_outRequest;
  assign io_txd = memoryArea_uart_io_uart_txd;
  assign io_sd_cs = memoryArea_sd_io_sd_cs;
  assign io_sd_clock = memoryArea_sd_io_sd_clock;
  assign io_sd_di = memoryArea_sd_io_sd_di;
  assign memoryArea_nexys3IoDataIn = 8'h0;
  assign memoryArea_graphicsRegBus_enable = (memoryArea_machineBus_enable && memoryArea_graphicsEnable);
  assign memoryArea_graphicsRegBus_write = memoryArea_machineBus_write;
  assign memoryArea_graphicsRegBus_dataFromMaster = memoryArea_machineBus_dataFromMaster;
  assign memoryArea_graphicsRegBus_address = memoryArea_machineBus_address[7:0];
  assign memoryArea_mmu_io_regBus_enable = (memoryArea_machineBus_enable && memoryArea_mmuEnable);
  assign memoryArea_mmu_io_regBus_address = memoryArea_machineBus_address[3:0];
  assign memoryArea_boardId_enable = (memoryArea_machineBus_enable && memoryArea_boardIdEnable);
  assign memoryArea_boardId_address = memoryArea_machineBus_address[0:0];
  assign memoryArea_keyboard_io_bus_enable = (memoryArea_machineBus_enable && memoryArea_keyboardEnable);
  assign memoryArea_keyboard_io_bus_address = memoryArea_machineBus_address[0:0];
  assign memoryArea_math_io_enable = (memoryArea_machineBus_enable && memoryArea_mathEnable);
  assign memoryArea_math_io_address = memoryArea_machineBus_address[2:0];
  assign memoryArea_uart_io_bus_enable = (memoryArea_machineBus_enable && memoryArea_uartEnable);
  assign memoryArea_uart_io_bus_address = memoryArea_machineBus_address[0:0];
  assign memoryArea_sd_io_bus_enable = (memoryArea_machineBus_enable && memoryArea_sdEnable);
  assign memoryArea_sd_io_bus_address = memoryArea_machineBus_address[0:0];
  assign memoryArea_interruptController_io_regBus_enable = (memoryArea_machineBus_enable && memoryArea_intCtrlEnable);
  assign memoryArea_interruptController_io_regBus_address = memoryArea_machineBus_address[1:0];
  assign memoryArea_bootROM_io_enable = (memoryArea_machineBus_enable && memoryArea_bootEnable);
  assign memoryArea_bootROM_io_address = memoryArea_machineBus_address[10:0];
  assign memoryArea_kernel_io_enable = (memoryArea_machineBus_enable && memoryArea_kernelEnable);
  assign memoryArea_kernel_io_address = memoryArea_machineBus_address[13:0];
  assign memoryArea_font_io_enable = (memoryArea_machineBus_enable && memoryArea_fontEnable);
  assign memoryArea_font_io_address = memoryArea_machineBus_address[13:0];
  assign memoryArea_attributeMemBus_enable = (memoryArea_machineBus_enable && memoryArea_attrMemEnable);
  assign memoryArea_attributeMemBus_write = memoryArea_machineBus_write;
  assign memoryArea_attributeMemBus_dataFromMaster = memoryArea_machineBus_dataFromMaster;
  assign memoryArea_attributeMemBus_address = memoryArea_machineBus_address[12:0];
  assign memoryArea_paletteMemBus_enable = (memoryArea_machineBus_enable && memoryArea_paletteMemEnable);
  assign memoryArea_paletteMemBus_write = memoryArea_machineBus_write;
  assign memoryArea_paletteMemBus_dataFromMaster = memoryArea_machineBus_dataFromMaster;
  assign memoryArea_paletteMemBus_address = memoryArea_machineBus_address[8:0];
  assign io_ramBus_enable = (memoryArea_machineBus_enable && memoryArea_ramEnable);
  assign io_ramBus_write = memoryArea_machineBus_write;
  assign io_ramBus_dataFromMaster = memoryArea_machineBus_dataFromMaster;
  assign io_ramBus_address = memoryArea_machineBus_address[20:0];
  assign memoryArea_memDataIn = ((((((((((((((memoryArea_nexys3IoDataIn | memoryArea_graphicsRegBus_dataToMaster) | memoryArea_mmu_io_regBus_dataToMaster) | memoryArea_boardId_dataToMaster) | memoryArea_keyboard_io_bus_dataToMaster) | memoryArea_math_io_dataToMaster) | memoryArea_uart_io_bus_dataToMaster) | memoryArea_sd_io_bus_dataToMaster) | memoryArea_interruptController_io_regBus_dataToMaster) | memoryArea_bootROM_io_dataToMaster) | memoryArea_kernel_io_dataToMaster) | memoryArea_font_io_dataToMaster) | memoryArea_attributeMemBus_dataToMaster) | memoryArea_paletteMemBus_dataToMaster) | io_ramBus_dataToMaster);
  assign memoryArea_chipMemBus_dataToMaster = memoryArea_memDataIn;
  assign io_red = graphicsArea_videoGenerator_io_red;
  assign io_green = graphicsArea_videoGenerator_io_green;
  assign io_blue = graphicsArea_videoGenerator_io_blue;
  assign io_hsync = graphicsArea_videoGenerator_io_hSync;
  assign io_vsync = graphicsArea_videoGenerator_io_vSync;
  assign io_blank = (graphicsArea_videoGenerator_io_hBlanking || graphicsArea_videoGenerator_io_vBlanking);
  assign io_dblRed = graphicsArea_videoGenerator_io_dblRed;
  assign io_dblGreen = graphicsArea_videoGenerator_io_dblGreen;
  assign io_dblBlue = graphicsArea_videoGenerator_io_dblBlue;
  assign io_dblHSync = graphicsArea_videoGenerator_io_dblHSync;
  assign io_dblVSync = graphicsArea_videoGenerator_io_dblVSync;
  assign io_dblBlank = graphicsArea_videoGenerator_io_dblBlank;
  assign memoryArea_chipMemBus_enable = graphicsArea_videoGenerator_io_memBus_enable;
  assign memoryArea_chipMemBus_address = graphicsArea_videoGenerator_io_memBus_address;
  assign memoryArea_chipSource = graphicsArea_videoGenerator_io_memBusSource;
  assign memoryArea_vBlanking = graphicsArea_videoGenerator_io_vBlanking;
  assign memoryArea_hBlanking = graphicsArea_videoGenerator_io_hBlanking;
  assign memoryArea_graphicsRegBus_dataToMaster = graphicsArea_videoGenerator_io_regBus_dataToMaster;
  assign memoryArea_attributeMemBus_dataToMaster = graphicsArea_graphicsMemoryArea_attrMemory_io_byteBus_dataToMaster;
  assign memoryArea_paletteMemBus_dataToMaster = graphicsArea_graphicsMemoryArea_paletteMemory_io_byteBus_dataToMaster;
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      mainArea_cycleCounter <= 4'b0000;
      _zz_when_ClockDomain_l353 <= 1'b0;
      when_ClockDomain_l353_regNext <= 1'b0;
    end else begin
      mainArea_cycleCounter <= (mainArea_cycleCounter + 4'b0001);
      _zz_when_ClockDomain_l353 <= (_zz_when_ClockDomain_l353 + 1'b1);
      if(when_ClockDomain_l353) begin
        _zz_when_ClockDomain_l353 <= 1'b0;
      end
      when_ClockDomain_l353_regNext <= when_ClockDomain_l353;
    end
  end

  always @(posedge bus_clk) begin
    _zz_memoryArea_machineBus_enable <= (mainArea_cpuBusMaster ? cpuArea_cpu_io_bus_enable : mainArea_chipsetBusMaster);
    _zz_memoryArea_machineBus_write <= (mainArea_cpuBusMaster ? cpuArea_cpu_io_bus_write : 1'b0);
    cpuArea_cpu_io_bus_dataFromMaster_regNext <= cpuArea_cpu_io_bus_dataFromMaster;
    memoryArea_mmu_io_mapAddressOut_regNext <= memoryArea_mmu_io_mapAddressOut;
  end


endmodule

module SpinalPaletteMemory (
  input               bus_clk,
  input               io_wideBus_enable,
  output     [15:0]   io_wideBus_dataToMaster,
  input      [7:0]    io_wideBus_address,
  input               io_byteBus_enable,
  input               io_byteBus_write,
  input      [7:0]    io_byteBus_dataFromMaster,
  output reg [7:0]    io_byteBus_dataToMaster,
  input      [8:0]    io_byteBus_address,
  input               bus_reset
);

  wire       [15:0]   memory_douta;
  wire       [7:0]    memory_doutb;
  reg                 io_byteBus_enable_delay_1;

  PaletteMemory memory (
    .clka     (bus_clk                         ), //i
    .ena      (io_wideBus_enable               ), //i
    .wea      (2'b00                           ), //i
    .addra    (io_wideBus_address[7:0]         ), //i
    .dina     (16'h0                           ), //i
    .douta    (memory_douta[15:0]              ), //o
    .clkb     (bus_clk                         ), //i
    .enb      (io_byteBus_enable               ), //i
    .web      (io_byteBus_write                ), //i
    .addrb    (io_byteBus_address[8:0]         ), //i
    .dinb     (io_byteBus_dataFromMaster[7:0]  ), //i
    .doutb    (memory_doutb[7:0]               )  //o
  );
  assign io_wideBus_dataToMaster = memory_douta;
  always @(*) begin
    if(io_byteBus_enable_delay_1) begin
      io_byteBus_dataToMaster = memory_doutb;
    end else begin
      io_byteBus_dataToMaster = 8'h0;
    end
  end

  always @(posedge bus_clk) begin
    io_byteBus_enable_delay_1 <= io_byteBus_enable;
  end


endmodule

module SpinalAttributeMemory (
  input               bus_clk,
  input               io_wideBus_enable,
  output     [15:0]   io_wideBus_dataToMaster,
  input      [11:0]   io_wideBus_address,
  input               io_byteBus_enable,
  input               io_byteBus_write,
  input      [7:0]    io_byteBus_dataFromMaster,
  output reg [7:0]    io_byteBus_dataToMaster,
  input      [12:0]   io_byteBus_address,
  input               bus_reset
);

  wire       [15:0]   memory_douta;
  wire       [7:0]    memory_doutb;
  reg                 io_byteBus_enable_delay_1;

  AttributeMemory memory (
    .clka     (bus_clk                         ), //i
    .ena      (io_wideBus_enable               ), //i
    .wea      (2'b00                           ), //i
    .addra    (io_wideBus_address[11:0]        ), //i
    .dina     (16'h0                           ), //i
    .douta    (memory_douta[15:0]              ), //o
    .clkb     (bus_clk                         ), //i
    .enb      (io_byteBus_enable               ), //i
    .web      (io_byteBus_write                ), //i
    .addrb    (io_byteBus_address[12:0]        ), //i
    .dinb     (io_byteBus_dataFromMaster[7:0]  ), //i
    .doutb    (memory_doutb[7:0]               )  //o
  );
  assign io_wideBus_dataToMaster = memory_douta;
  always @(*) begin
    if(io_byteBus_enable_delay_1) begin
      io_byteBus_dataToMaster = memory_doutb;
    end else begin
      io_byteBus_dataToMaster = 8'h0;
    end
  end

  always @(posedge bus_clk) begin
    io_byteBus_enable_delay_1 <= io_byteBus_enable;
  end


endmodule

module VideoGenerator (
  output reg [4:0]    io_red,
  output reg [4:0]    io_green,
  output reg [4:0]    io_blue,
  output              io_hSync,
  output              io_vSync,
  output              io_hBlanking,
  output              io_vBlanking,
  output reg [4:0]    io_dblRed,
  output reg [4:0]    io_dblGreen,
  output reg [4:0]    io_dblBlue,
  output              io_dblHSync,
  output              io_dblVSync,
  output              io_dblBlank,
  output              io_attrBus_enable,
  input      [15:0]   io_attrBus_dataToMaster,
  output     [11:0]   io_attrBus_address,
  output              io_paletteBus_enable,
  input      [15:0]   io_paletteBus_dataToMaster,
  output     [7:0]    io_paletteBus_address,
  output              io_memBus_enable,
  input      [7:0]    io_memBus_dataToMaster,
  output     [15:0]   io_memBus_address,
  output     [0:0]    io_memBusSource,
  input      [3:0]    io_memBusCycle,
  input               io_regBus_enable,
  input               io_regBus_write,
  input      [7:0]    io_regBus_dataFromMaster,
  output     [7:0]    io_regBus_dataToMaster,
  input      [7:0]    io_regBus_address,
  input               bus_clk,
  input               dbl_clk,
  input               bus_reset,
  input               dbl_reset
);
  localparam MapSource_cpu = 1'd0;
  localparam MapSource_chipsetCharGen = 1'd1;
  localparam Register_7_control = 4'd0;
  localparam Register_7_vPos = 4'd1;
  localparam Register_7_unused02 = 4'd2;
  localparam Register_7_unused03 = 4'd3;
  localparam Register_7_unused04 = 4'd4;
  localparam Register_7_unused05 = 4'd5;
  localparam Register_7_unused06 = 4'd6;
  localparam Register_7_unused07 = 4'd7;
  localparam Register_7_unused08 = 4'd8;
  localparam Register_7_unused09 = 4'd9;
  localparam Register_7_unused0A = 4'd10;
  localparam Register_7_unused0B = 4'd11;
  localparam Register_7_unused0C = 4'd12;
  localparam Register_7_unused0D = 4'd13;
  localparam Register_7_unused0E = 4'd14;
  localparam Register_7_debug = 4'd15;

  wire       [7:0]    scanDoubler_1_io_vPosIn;
  wire                plane0_io_regBus_enable;
  wire       [3:0]    plane0_io_regBus_address;
  wire                native_sync_io_hSync;
  wire                native_sync_io_vSync;
  wire                native_sync_io_hBlanking;
  wire                native_sync_io_vBlanking;
  wire       [10:0]   native_sync_io_hPos;
  wire       [8:0]    native_sync_io_vPos;
  wire                native_sync_io_pixelEnable;
  wire                double_sync_io_hSync;
  wire                double_sync_io_vSync;
  wire                double_sync_io_hBlanking;
  wire                double_sync_io_vBlanking;
  wire       [10:0]   double_sync_io_hPos;
  wire       [8:0]    double_sync_io_vPos;
  wire                double_sync_io_pixelEnable;
  wire       [4:0]    scanDoubler_1_io_redOut;
  wire       [4:0]    scanDoubler_1_io_greenOut;
  wire       [4:0]    scanDoubler_1_io_blueOut;
  wire       [7:0]    plane0_io_indexedColor;
  wire                plane0_io_attrBus_enable;
  wire       [11:0]   plane0_io_attrBus_address;
  wire                plane0_io_memBus_enable;
  wire       [15:0]   plane0_io_memBus_address;
  wire       [7:0]    plane0_io_regBus_dataToMaster;
  wire       [7:0]    frameMode_io_indexedColor;
  wire       [3:0]    _zz__zz_switch_VideoGenerator_l200;
  wire       [1:0]    _zz__zz_regData;
  wire       [8:0]    _zz__zz_regData_1;
  wire       [0:0]    _zz__zz_regData_2;
  reg                 native_sync_io_hSync_delay_1;
  reg                 native_hSyncOut;
  reg                 native_sync_io_vSync_delay_1;
  reg                 native_vSyncOut;
  reg                 native_hBlankingOut;
  reg                 native_vBlankingOut;
  reg        [10:0]   native_hPosOut;
  reg        [8:0]    native_vPosOut;
  wire                native_pixelEnableOut;
  reg                 double_sync_io_hSync_delay_1;
  reg                 double_sync_io_vSync_delay_1;
  reg                 _zz_io_dblBlank;
  reg                 _zz_io_dblBlank_1;
  reg                 plane0Enable;
  reg                 plane1Enable;
  reg                 frameEnable;
  wire                controlBusEnable;
  wire                plane0BusEnable;
  wire                plane1BusEnable;
  wire                controlBus_enable;
  wire                controlBus_write;
  wire       [7:0]    controlBus_dataFromMaster;
  wire       [7:0]    controlBus_dataToMaster;
  wire       [3:0]    controlBus_address;
  wire                when_VideoGenerator_l197;
  wire       [3:0]    switch_VideoGenerator_l200;
  wire       [3:0]    _zz_switch_VideoGenerator_l200;
  reg        [7:0]    regData;
  wire                when_VideoGenerator_l214;
  wire       [3:0]    switch_Misc_l211;
  wire       [3:0]    _zz_switch_Misc_l211;
  reg        [7:0]    _zz_regData;
  `ifndef SYNTHESIS
  reg [111:0] io_memBusSource_string;
  reg [63:0] switch_VideoGenerator_l200_string;
  reg [63:0] _zz_switch_VideoGenerator_l200_string;
  reg [63:0] switch_Misc_l211_string;
  reg [63:0] _zz_switch_Misc_l211_string;
  `endif


  assign _zz__zz_switch_VideoGenerator_l200 = io_regBus_address[3:0];
  assign _zz__zz_regData = {plane1Enable,plane0Enable};
  assign _zz__zz_regData_1 = native_sync_io_vPos;
  assign _zz__zz_regData_2 = frameEnable;
  VideoSync native_sync (
    .io_hDisp          (11'h2d0                     ), //i
    .io_hSyncStart     (11'h300                     ), //i
    .io_hSyncEnd       (11'h320                     ), //i
    .io_hEnd           (11'h36f                     ), //i
    .io_vDisp          (9'h0f0                      ), //i
    .io_vSyncStart     (9'h0f3                      ), //i
    .io_vSyncEnd       (9'h0f7                      ), //i
    .io_vEnd           (9'h0ff                      ), //i
    .io_hSync          (native_sync_io_hSync        ), //o
    .io_vSync          (native_sync_io_vSync        ), //o
    .io_hBlanking      (native_sync_io_hBlanking    ), //o
    .io_vBlanking      (native_sync_io_vBlanking    ), //o
    .io_hPos           (native_sync_io_hPos[10:0]   ), //o
    .io_vPos           (native_sync_io_vPos[8:0]    ), //o
    .io_pixelEnable    (native_sync_io_pixelEnable  ), //o
    .bus_clk           (bus_clk                     ), //i
    .bus_reset         (bus_reset                   )  //i
  );
  VideoSync_1 double_sync (
    .io_hDisp          (11'h2d0                     ), //i
    .io_hSyncStart     (11'h300                     ), //i
    .io_hSyncEnd       (11'h320                     ), //i
    .io_hEnd           (11'h36f                     ), //i
    .io_vDisp          (9'h1e0                      ), //i
    .io_vSyncStart     (9'h1e9                      ), //i
    .io_vSyncEnd       (9'h1ef                      ), //i
    .io_vEnd           (9'h1ff                      ), //i
    .io_hSync          (double_sync_io_hSync        ), //o
    .io_vSync          (double_sync_io_vSync        ), //o
    .io_hBlanking      (double_sync_io_hBlanking    ), //o
    .io_vBlanking      (double_sync_io_vBlanking    ), //o
    .io_hPos           (double_sync_io_hPos[10:0]   ), //o
    .io_vPos           (double_sync_io_vPos[8:0]    ), //o
    .io_pixelEnable    (double_sync_io_pixelEnable  ), //o
    .dbl_clk           (dbl_clk                     ), //i
    .dbl_reset         (dbl_reset                   )  //i
  );
  ScanDoubler scanDoubler_1 (
    .io_pixelEnableIn    (native_pixelEnableOut           ), //i
    .io_hPosIn           (native_hPosOut[10:0]            ), //i
    .io_vPosIn           (scanDoubler_1_io_vPosIn[7:0]    ), //i
    .io_redIn            (io_red[4:0]                     ), //i
    .io_greenIn          (io_green[4:0]                   ), //i
    .io_blueIn           (io_blue[4:0]                    ), //i
    .io_hPosOut          (double_sync_io_hPos[10:0]       ), //i
    .io_vPosOut          (double_sync_io_vPos[8:0]        ), //i
    .io_redOut           (scanDoubler_1_io_redOut[4:0]    ), //o
    .io_greenOut         (scanDoubler_1_io_greenOut[4:0]  ), //o
    .io_blueOut          (scanDoubler_1_io_blueOut[4:0]   ), //o
    .bus_clk             (bus_clk                         ), //i
    .dbl_clk             (dbl_clk                         )  //i
  );
  VideoTileMode plane0 (
    .io_charGenAddress           (16'h0                               ), //i
    .io_memBusCycle              (io_memBusCycle[3:0]                 ), //i
    .io_vSync                    (native_sync_io_vSync                ), //i
    .io_hSync                    (native_sync_io_hSync                ), //i
    .io_hBlank                   (native_sync_io_hBlanking            ), //i
    .io_pixelEnable              (native_sync_io_pixelEnable          ), //i
    .io_hPos                     (native_sync_io_hPos[10:0]           ), //i
    .io_vPos                     (native_sync_io_vPos[8:0]            ), //i
    .io_indexedColor             (plane0_io_indexedColor[7:0]         ), //o
    .io_attrBus_enable           (plane0_io_attrBus_enable            ), //o
    .io_attrBus_dataToMaster     (io_attrBus_dataToMaster[15:0]       ), //i
    .io_attrBus_address          (plane0_io_attrBus_address[11:0]     ), //o
    .io_memBus_enable            (plane0_io_memBus_enable             ), //o
    .io_memBus_dataToMaster      (io_memBus_dataToMaster[7:0]         ), //i
    .io_memBus_address           (plane0_io_memBus_address[15:0]      ), //o
    .io_regBus_enable            (plane0_io_regBus_enable             ), //i
    .io_regBus_write             (io_regBus_write                     ), //i
    .io_regBus_dataFromMaster    (io_regBus_dataFromMaster[7:0]       ), //i
    .io_regBus_dataToMaster      (plane0_io_regBus_dataToMaster[7:0]  ), //o
    .io_regBus_address           (plane0_io_regBus_address[3:0]       ), //i
    .bus_clk                     (bus_clk                             ), //i
    .bus_reset                   (bus_reset                           )  //i
  );
  VideoFrame frameMode (
    .io_pixelEnable     (native_sync_io_pixelEnable      ), //i
    .io_hPos            (native_sync_io_hPos[10:0]       ), //i
    .io_vPos            (native_sync_io_vPos[8:0]        ), //i
    .io_indexedColor    (frameMode_io_indexedColor[7:0]  )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_memBusSource)
      MapSource_cpu : io_memBusSource_string = "cpu           ";
      MapSource_chipsetCharGen : io_memBusSource_string = "chipsetCharGen";
      default : io_memBusSource_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(switch_VideoGenerator_l200)
      Register_7_control : switch_VideoGenerator_l200_string = "control ";
      Register_7_vPos : switch_VideoGenerator_l200_string = "vPos    ";
      Register_7_unused02 : switch_VideoGenerator_l200_string = "unused02";
      Register_7_unused03 : switch_VideoGenerator_l200_string = "unused03";
      Register_7_unused04 : switch_VideoGenerator_l200_string = "unused04";
      Register_7_unused05 : switch_VideoGenerator_l200_string = "unused05";
      Register_7_unused06 : switch_VideoGenerator_l200_string = "unused06";
      Register_7_unused07 : switch_VideoGenerator_l200_string = "unused07";
      Register_7_unused08 : switch_VideoGenerator_l200_string = "unused08";
      Register_7_unused09 : switch_VideoGenerator_l200_string = "unused09";
      Register_7_unused0A : switch_VideoGenerator_l200_string = "unused0A";
      Register_7_unused0B : switch_VideoGenerator_l200_string = "unused0B";
      Register_7_unused0C : switch_VideoGenerator_l200_string = "unused0C";
      Register_7_unused0D : switch_VideoGenerator_l200_string = "unused0D";
      Register_7_unused0E : switch_VideoGenerator_l200_string = "unused0E";
      Register_7_debug : switch_VideoGenerator_l200_string = "debug   ";
      default : switch_VideoGenerator_l200_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_switch_VideoGenerator_l200)
      Register_7_control : _zz_switch_VideoGenerator_l200_string = "control ";
      Register_7_vPos : _zz_switch_VideoGenerator_l200_string = "vPos    ";
      Register_7_unused02 : _zz_switch_VideoGenerator_l200_string = "unused02";
      Register_7_unused03 : _zz_switch_VideoGenerator_l200_string = "unused03";
      Register_7_unused04 : _zz_switch_VideoGenerator_l200_string = "unused04";
      Register_7_unused05 : _zz_switch_VideoGenerator_l200_string = "unused05";
      Register_7_unused06 : _zz_switch_VideoGenerator_l200_string = "unused06";
      Register_7_unused07 : _zz_switch_VideoGenerator_l200_string = "unused07";
      Register_7_unused08 : _zz_switch_VideoGenerator_l200_string = "unused08";
      Register_7_unused09 : _zz_switch_VideoGenerator_l200_string = "unused09";
      Register_7_unused0A : _zz_switch_VideoGenerator_l200_string = "unused0A";
      Register_7_unused0B : _zz_switch_VideoGenerator_l200_string = "unused0B";
      Register_7_unused0C : _zz_switch_VideoGenerator_l200_string = "unused0C";
      Register_7_unused0D : _zz_switch_VideoGenerator_l200_string = "unused0D";
      Register_7_unused0E : _zz_switch_VideoGenerator_l200_string = "unused0E";
      Register_7_debug : _zz_switch_VideoGenerator_l200_string = "debug   ";
      default : _zz_switch_VideoGenerator_l200_string = "????????";
    endcase
  end
  always @(*) begin
    case(switch_Misc_l211)
      Register_7_control : switch_Misc_l211_string = "control ";
      Register_7_vPos : switch_Misc_l211_string = "vPos    ";
      Register_7_unused02 : switch_Misc_l211_string = "unused02";
      Register_7_unused03 : switch_Misc_l211_string = "unused03";
      Register_7_unused04 : switch_Misc_l211_string = "unused04";
      Register_7_unused05 : switch_Misc_l211_string = "unused05";
      Register_7_unused06 : switch_Misc_l211_string = "unused06";
      Register_7_unused07 : switch_Misc_l211_string = "unused07";
      Register_7_unused08 : switch_Misc_l211_string = "unused08";
      Register_7_unused09 : switch_Misc_l211_string = "unused09";
      Register_7_unused0A : switch_Misc_l211_string = "unused0A";
      Register_7_unused0B : switch_Misc_l211_string = "unused0B";
      Register_7_unused0C : switch_Misc_l211_string = "unused0C";
      Register_7_unused0D : switch_Misc_l211_string = "unused0D";
      Register_7_unused0E : switch_Misc_l211_string = "unused0E";
      Register_7_debug : switch_Misc_l211_string = "debug   ";
      default : switch_Misc_l211_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_switch_Misc_l211)
      Register_7_control : _zz_switch_Misc_l211_string = "control ";
      Register_7_vPos : _zz_switch_Misc_l211_string = "vPos    ";
      Register_7_unused02 : _zz_switch_Misc_l211_string = "unused02";
      Register_7_unused03 : _zz_switch_Misc_l211_string = "unused03";
      Register_7_unused04 : _zz_switch_Misc_l211_string = "unused04";
      Register_7_unused05 : _zz_switch_Misc_l211_string = "unused05";
      Register_7_unused06 : _zz_switch_Misc_l211_string = "unused06";
      Register_7_unused07 : _zz_switch_Misc_l211_string = "unused07";
      Register_7_unused08 : _zz_switch_Misc_l211_string = "unused08";
      Register_7_unused09 : _zz_switch_Misc_l211_string = "unused09";
      Register_7_unused0A : _zz_switch_Misc_l211_string = "unused0A";
      Register_7_unused0B : _zz_switch_Misc_l211_string = "unused0B";
      Register_7_unused0C : _zz_switch_Misc_l211_string = "unused0C";
      Register_7_unused0D : _zz_switch_Misc_l211_string = "unused0D";
      Register_7_unused0E : _zz_switch_Misc_l211_string = "unused0E";
      Register_7_debug : _zz_switch_Misc_l211_string = "debug   ";
      default : _zz_switch_Misc_l211_string = "????????";
    endcase
  end
  `endif

  assign native_pixelEnableOut = (! (native_hBlankingOut || native_vBlankingOut));
  assign io_hSync = native_hSyncOut;
  assign io_vSync = native_vSyncOut;
  assign io_hBlanking = native_hBlankingOut;
  assign io_vBlanking = native_vBlankingOut;
  assign io_dblHSync = double_sync_io_hSync_delay_1;
  assign io_dblVSync = double_sync_io_vSync_delay_1;
  assign io_dblBlank = _zz_io_dblBlank_1;
  assign scanDoubler_1_io_vPosIn = native_vPosOut[7 : 0];
  always @(*) begin
    if(io_dblBlank) begin
      io_dblRed = 5'h0;
    end else begin
      io_dblRed = scanDoubler_1_io_redOut;
    end
  end

  always @(*) begin
    if(io_dblBlank) begin
      io_dblGreen = 5'h0;
    end else begin
      io_dblGreen = scanDoubler_1_io_greenOut;
    end
  end

  always @(*) begin
    if(io_dblBlank) begin
      io_dblBlue = 5'h0;
    end else begin
      io_dblBlue = scanDoubler_1_io_blueOut;
    end
  end

  assign io_attrBus_enable = plane0_io_attrBus_enable;
  assign io_attrBus_address = plane0_io_attrBus_address;
  assign io_memBus_enable = plane0_io_memBus_enable;
  assign io_memBus_address = plane0_io_memBus_address;
  assign io_memBusSource = MapSource_chipsetCharGen;
  assign io_paletteBus_enable = 1'b1;
  assign io_paletteBus_address = ((frameEnable && (frameMode_io_indexedColor != 8'h0)) ? frameMode_io_indexedColor : plane0_io_indexedColor);
  always @(*) begin
    if(native_pixelEnableOut) begin
      io_red = io_paletteBus_dataToMaster[14 : 10];
    end else begin
      io_red = 5'h0;
    end
  end

  always @(*) begin
    if(native_pixelEnableOut) begin
      io_green = io_paletteBus_dataToMaster[9 : 5];
    end else begin
      io_green = 5'h0;
    end
  end

  always @(*) begin
    if(native_pixelEnableOut) begin
      io_blue = io_paletteBus_dataToMaster[4 : 0];
    end else begin
      io_blue = 5'h0;
    end
  end

  assign controlBusEnable = (io_regBus_enable && ((io_regBus_address & 8'hf0) == 8'h0));
  assign plane0BusEnable = (io_regBus_enable && ((io_regBus_address & 8'hf0) == 8'h10));
  assign plane1BusEnable = (io_regBus_enable && ((io_regBus_address & 8'hf0) == 8'h20));
  assign when_VideoGenerator_l197 = (controlBus_enable && controlBus_write);
  assign _zz_switch_VideoGenerator_l200 = _zz__zz_switch_VideoGenerator_l200;
  assign switch_VideoGenerator_l200 = _zz_switch_VideoGenerator_l200;
  assign controlBus_dataToMaster = regData;
  assign when_VideoGenerator_l214 = (controlBus_enable && (! controlBus_write));
  assign _zz_switch_Misc_l211 = controlBus_address;
  assign switch_Misc_l211 = _zz_switch_Misc_l211;
  always @(*) begin
    case(switch_Misc_l211)
      Register_7_control : begin
        _zz_regData = {6'd0, _zz__zz_regData};
      end
      Register_7_vPos : begin
        _zz_regData = _zz__zz_regData_1[7 : 0];
      end
      Register_7_debug : begin
        _zz_regData = {7'd0, _zz__zz_regData_2};
      end
      default : begin
        _zz_regData = 8'h0;
      end
    endcase
  end

  assign controlBus_enable = (io_regBus_enable && controlBusEnable);
  assign controlBus_write = io_regBus_write;
  assign controlBus_dataFromMaster = io_regBus_dataFromMaster;
  assign controlBus_address = io_regBus_address[3:0];
  assign plane0_io_regBus_enable = (io_regBus_enable && plane0BusEnable);
  assign plane0_io_regBus_address = io_regBus_address[3:0];
  assign io_regBus_dataToMaster = (controlBus_dataToMaster | plane0_io_regBus_dataToMaster);
  always @(posedge bus_clk) begin
    native_sync_io_hSync_delay_1 <= native_sync_io_hSync;
    native_hSyncOut <= native_sync_io_hSync_delay_1;
    native_sync_io_vSync_delay_1 <= native_sync_io_vSync;
    native_vSyncOut <= native_sync_io_vSync_delay_1;
    native_hBlankingOut <= native_sync_io_hBlanking;
    native_vBlankingOut <= native_sync_io_vBlanking;
    native_hPosOut <= native_sync_io_hPos;
    native_vPosOut <= native_sync_io_vPos;
    if(when_VideoGenerator_l214) begin
      regData <= _zz_regData;
    end else begin
      regData <= 8'h0;
    end
  end

  always @(posedge dbl_clk) begin
    double_sync_io_hSync_delay_1 <= double_sync_io_hSync;
    double_sync_io_vSync_delay_1 <= double_sync_io_vSync;
    _zz_io_dblBlank <= (! double_sync_io_pixelEnable);
    _zz_io_dblBlank_1 <= _zz_io_dblBlank;
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      plane0Enable <= 1'b1;
      plane1Enable <= 1'b0;
      frameEnable <= 1'b0;
    end else begin
      if(when_VideoGenerator_l197) begin
        case(switch_VideoGenerator_l200)
          Register_7_control : begin
            plane1Enable <= io_regBus_dataFromMaster[1];
            plane0Enable <= io_regBus_dataFromMaster[0];
          end
          Register_7_debug : begin
            frameEnable <= io_regBus_dataFromMaster[0];
          end
          default : begin
          end
        endcase
      end
    end
  end


endmodule

module SD (
  input               io_bus_enable,
  input               io_bus_write,
  input      [7:0]    io_bus_dataFromMaster,
  output     [7:0]    io_bus_dataToMaster,
  input      [0:0]    io_bus_address,
  output     [1:0]    io_sd_cs,
  output              io_sd_clock,
  output reg          io_sd_di,
  input               io_sd_do,
  input               bus_clk,
  input               bus_reset
);
  localparam Register_6_data = 1'd0;
  localparam Register_6_status = 1'd1;

  wire       [4:0]    _zz__zz_ioDataOut;
  reg        [1:0]    cardSelect;
  reg                 inDataEnabled;
  reg                 inDataProcessing;
  reg                 outDataProcessing;
  reg        [7:0]    spiDataIn;
  reg        [8:0]    spiDataOut;
  reg        [3:0]    count;
  wire                processing;
  reg                 slowClock;
  reg        [5:0]    clockCount;
  reg                 sdClock;
  reg                 shiftDataOut;
  reg                 shiftDataIn;
  wire                when_SD_l57;
  wire                when_SD_l58;
  wire                when_SD_l66;
  reg        [7:0]    ioDataOut;
  wire       [0:0]    busRegister;
  wire       [0:0]    _zz_busRegister;
  wire                when_SD_l93;
  reg        [7:0]    _zz_ioDataOut;
  wire                when_SD_l99;
  wire                when_SD_l107;
  wire                _zz_inDataEnabled;
  wire                when_SD_l120;
  `ifndef SYNTHESIS
  reg [47:0] busRegister_string;
  reg [47:0] _zz_busRegister_string;
  `endif


  assign _zz__zz_ioDataOut = {{{slowClock,cardSelect},outDataProcessing},inDataEnabled};
  `ifndef SYNTHESIS
  always @(*) begin
    case(busRegister)
      Register_6_data : busRegister_string = "data  ";
      Register_6_status : busRegister_string = "status";
      default : busRegister_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_busRegister)
      Register_6_data : _zz_busRegister_string = "data  ";
      Register_6_status : _zz_busRegister_string = "status";
      default : _zz_busRegister_string = "??????";
    endcase
  end
  `endif

  assign processing = (inDataProcessing || outDataProcessing);
  assign io_sd_cs = (~ cardSelect);
  assign io_sd_clock = sdClock;
  assign when_SD_l57 = (processing && shiftDataOut);
  assign when_SD_l58 = (count == 4'b1000);
  assign when_SD_l66 = (inDataProcessing && shiftDataIn);
  always @(*) begin
    if(outDataProcessing) begin
      io_sd_di = spiDataOut[8];
    end else begin
      io_sd_di = 1'b0;
    end
  end

  assign io_bus_dataToMaster = ioDataOut;
  assign _zz_busRegister = io_bus_address;
  assign busRegister = _zz_busRegister;
  assign when_SD_l93 = (io_bus_enable && (! io_bus_write));
  always @(*) begin
    case(busRegister)
      Register_6_data : begin
        _zz_ioDataOut = spiDataIn;
      end
      default : begin
        _zz_ioDataOut = {3'd0, _zz__zz_ioDataOut};
      end
    endcase
  end

  assign when_SD_l99 = (busRegister == Register_6_data);
  assign when_SD_l107 = (io_bus_enable && io_bus_write);
  assign _zz_inDataEnabled = io_bus_dataFromMaster[0];
  assign when_SD_l120 = (_zz_inDataEnabled && (! inDataEnabled));
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      cardSelect <= 2'b00;
      inDataEnabled <= 1'b0;
      inDataProcessing <= 1'b0;
      outDataProcessing <= 1'b0;
      spiDataIn <= 8'h0;
      spiDataOut <= 9'h0;
      count <= 4'b0000;
      slowClock <= 1'b1;
      clockCount <= 6'h0;
      sdClock <= 1'b0;
      shiftDataOut <= 1'b0;
      shiftDataIn <= 1'b0;
    end else begin
      clockCount <= (clockCount + 6'h01);
      if(processing) begin
        if(slowClock) begin
          sdClock <= clockCount[5];
          shiftDataOut <= (clockCount[5 : 0] == 6'h0f);
          shiftDataIn <= (clockCount[5 : 0] == 6'h2f);
        end else begin
          sdClock <= clockCount[1];
          shiftDataOut <= (clockCount[1 : 0] == 2'b00);
          shiftDataIn <= (clockCount[1 : 0] == 2'b10);
        end
      end else begin
        sdClock <= 1'b0;
        shiftDataIn <= 1'b0;
        shiftDataOut <= 1'b0;
      end
      if(when_SD_l57) begin
        if(when_SD_l58) begin
          inDataProcessing <= 1'b0;
          outDataProcessing <= 1'b0;
        end else begin
          count <= (count + 4'b0001);
        end
      end
      if(when_SD_l66) begin
        spiDataIn <= {spiDataIn[6 : 0],io_sd_do};
      end
      if(outDataProcessing) begin
        if(shiftDataOut) begin
          spiDataOut <= {spiDataOut[7 : 0],1'b0};
        end
      end
      if(when_SD_l93) begin
        if(when_SD_l99) begin
          inDataProcessing <= inDataEnabled;
          clockCount <= 6'h0;
          count <= 4'b0000;
          shiftDataIn <= 1'b0;
          shiftDataOut <= 1'b0;
        end
      end
      if(when_SD_l107) begin
        case(busRegister)
          Register_6_data : begin
            spiDataOut[7 : 0] <= io_bus_dataFromMaster;
            spiDataOut[8] <= io_bus_dataFromMaster[7];
            outDataProcessing <= 1'b1;
            clockCount <= 6'h0;
            count <= 4'b0000;
            shiftDataIn <= 1'b0;
            shiftDataOut <= 1'b0;
          end
          default : begin
            slowClock <= io_bus_dataFromMaster[4];
            cardSelect <= io_bus_dataFromMaster[3 : 2];
            if(when_SD_l120) begin
              inDataProcessing <= 1'b1;
              clockCount <= 6'h0;
              count <= 4'b0000;
              shiftDataIn <= 1'b0;
              shiftDataOut <= 1'b0;
            end
            inDataEnabled <= _zz_inDataEnabled;
          end
        endcase
      end
    end
  end

  always @(posedge bus_clk) begin
    if(when_SD_l93) begin
      ioDataOut <= _zz_ioDataOut;
    end else begin
      ioDataOut <= 8'h0;
    end
  end


endmodule

module UART (
  input               io_bus_enable,
  input               io_bus_write,
  input      [7:0]    io_bus_dataFromMaster,
  output     [7:0]    io_bus_dataToMaster,
  input      [0:0]    io_bus_address,
  output              io_uart_txd,
  input               io_uart_rxd,
  input               bus_clk,
  input               bus_reset
);
  localparam Register_5_data = 1'd0;
  localparam Register_5_status = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;

  reg                 uartCtrl_1_io_read_ready;
  wire                outFifo_io_push_valid;
  reg                 outFifo_io_pop_ready;
  wire                uartCtrl_1_io_write_ready;
  wire                uartCtrl_1_io_read_valid;
  wire       [7:0]    uartCtrl_1_io_read_payload;
  wire                uartCtrl_1_io_uart_txd;
  wire                uartCtrl_1_io_readError;
  wire                uartCtrl_1_io_readBreak;
  wire                inFifo_io_push_ready;
  wire                inFifo_io_pop_valid;
  wire       [7:0]    inFifo_io_pop_payload;
  wire       [4:0]    inFifo_io_occupancy;
  wire       [4:0]    inFifo_io_availability;
  wire                outFifo_io_push_ready;
  wire                outFifo_io_pop_valid;
  wire       [7:0]    outFifo_io_pop_payload;
  wire       [4:0]    outFifo_io_occupancy;
  wire       [4:0]    outFifo_io_availability;
  wire       [1:0]    _zz__zz_ioDataOut;
  wire       [0:0]    busRegister;
  wire       [0:0]    _zz_busRegister;
  wire                readingData;
  wire                uartCtrl_1_io_read_m2sPipe_valid;
  wire                uartCtrl_1_io_read_m2sPipe_ready;
  wire       [7:0]    uartCtrl_1_io_read_m2sPipe_payload;
  reg                 uartCtrl_1_io_read_rValid;
  reg        [7:0]    uartCtrl_1_io_read_rData;
  wire                when_Stream_l342;
  reg                 io_bus_enable_regNext;
  wire                outFifo_io_pop_m2sPipe_valid;
  wire                outFifo_io_pop_m2sPipe_ready;
  wire       [7:0]    outFifo_io_pop_m2sPipe_payload;
  reg                 outFifo_io_pop_rValid;
  reg        [7:0]    outFifo_io_pop_rData;
  wire                when_Stream_l342_1;
  reg        [7:0]    uartDataIn;
  reg                 uartDataInConsumed;
  reg                 readingData_regNext;
  wire                when_UART_l40;
  wire                _zz_getNextValue;
  reg                 _zz_getNextValue_regNext;
  wire                getNextValue;
  reg        [7:0]    ioDataOut;
  reg        [7:0]    _zz_ioDataOut;
  `ifndef SYNTHESIS
  reg [47:0] busRegister_string;
  reg [47:0] _zz_busRegister_string;
  `endif


  assign _zz__zz_ioDataOut = {outFifo_io_push_ready,(! uartDataInConsumed)};
  UartCtrl uartCtrl_1 (
    .io_config_frame_dataLength    (3'b111                               ), //i
    .io_config_frame_stop          (UartStopType_ONE                     ), //i
    .io_config_frame_parity        (UartParityType_NONE                  ), //i
    .io_config_clockDivider        (20'h0001c                            ), //i
    .io_write_valid                (outFifo_io_pop_m2sPipe_valid         ), //i
    .io_write_ready                (uartCtrl_1_io_write_ready            ), //o
    .io_write_payload              (outFifo_io_pop_m2sPipe_payload[7:0]  ), //i
    .io_read_valid                 (uartCtrl_1_io_read_valid             ), //o
    .io_read_ready                 (uartCtrl_1_io_read_ready             ), //i
    .io_read_payload               (uartCtrl_1_io_read_payload[7:0]      ), //o
    .io_uart_txd                   (uartCtrl_1_io_uart_txd               ), //o
    .io_uart_rxd                   (io_uart_rxd                          ), //i
    .io_readError                  (uartCtrl_1_io_readError              ), //o
    .io_writeBreak                 (1'b0                                 ), //i
    .io_readBreak                  (uartCtrl_1_io_readBreak              ), //o
    .bus_clk                       (bus_clk                              ), //i
    .bus_reset                     (bus_reset                            )  //i
  );
  StreamFifo_1 inFifo (
    .io_push_valid      (uartCtrl_1_io_read_m2sPipe_valid         ), //i
    .io_push_ready      (inFifo_io_push_ready                     ), //o
    .io_push_payload    (uartCtrl_1_io_read_m2sPipe_payload[7:0]  ), //i
    .io_pop_valid       (inFifo_io_pop_valid                      ), //o
    .io_pop_ready       (getNextValue                             ), //i
    .io_pop_payload     (inFifo_io_pop_payload[7:0]               ), //o
    .io_flush           (1'b0                                     ), //i
    .io_occupancy       (inFifo_io_occupancy[4:0]                 ), //o
    .io_availability    (inFifo_io_availability[4:0]              ), //o
    .bus_clk            (bus_clk                                  ), //i
    .bus_reset          (bus_reset                                )  //i
  );
  StreamFifo_1 outFifo (
    .io_push_valid      (outFifo_io_push_valid         ), //i
    .io_push_ready      (outFifo_io_push_ready         ), //o
    .io_push_payload    (io_bus_dataFromMaster[7:0]    ), //i
    .io_pop_valid       (outFifo_io_pop_valid          ), //o
    .io_pop_ready       (outFifo_io_pop_ready          ), //i
    .io_pop_payload     (outFifo_io_pop_payload[7:0]   ), //o
    .io_flush           (1'b0                          ), //i
    .io_occupancy       (outFifo_io_occupancy[4:0]     ), //o
    .io_availability    (outFifo_io_availability[4:0]  ), //o
    .bus_clk            (bus_clk                       ), //i
    .bus_reset          (bus_reset                     )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(busRegister)
      Register_5_data : busRegister_string = "data  ";
      Register_5_status : busRegister_string = "status";
      default : busRegister_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_busRegister)
      Register_5_data : _zz_busRegister_string = "data  ";
      Register_5_status : _zz_busRegister_string = "status";
      default : _zz_busRegister_string = "??????";
    endcase
  end
  `endif

  assign _zz_busRegister = io_bus_address;
  assign busRegister = _zz_busRegister;
  assign io_uart_txd = uartCtrl_1_io_uart_txd;
  assign readingData = ((io_bus_enable && (! io_bus_write)) && (busRegister == Register_5_data));
  always @(*) begin
    uartCtrl_1_io_read_ready = uartCtrl_1_io_read_m2sPipe_ready;
    if(when_Stream_l342) begin
      uartCtrl_1_io_read_ready = 1'b1;
    end
  end

  assign when_Stream_l342 = (! uartCtrl_1_io_read_m2sPipe_valid);
  assign uartCtrl_1_io_read_m2sPipe_valid = uartCtrl_1_io_read_rValid;
  assign uartCtrl_1_io_read_m2sPipe_payload = uartCtrl_1_io_read_rData;
  assign uartCtrl_1_io_read_m2sPipe_ready = inFifo_io_push_ready;
  assign outFifo_io_push_valid = (((io_bus_enable && (! io_bus_enable_regNext)) && io_bus_write) && (busRegister == Register_5_data));
  always @(*) begin
    outFifo_io_pop_ready = outFifo_io_pop_m2sPipe_ready;
    if(when_Stream_l342_1) begin
      outFifo_io_pop_ready = 1'b1;
    end
  end

  assign when_Stream_l342_1 = (! outFifo_io_pop_m2sPipe_valid);
  assign outFifo_io_pop_m2sPipe_valid = outFifo_io_pop_rValid;
  assign outFifo_io_pop_m2sPipe_payload = outFifo_io_pop_rData;
  assign outFifo_io_pop_m2sPipe_ready = uartCtrl_1_io_write_ready;
  assign when_UART_l40 = (readingData && (! readingData_regNext));
  assign _zz_getNextValue = (inFifo_io_pop_valid && uartDataInConsumed);
  assign getNextValue = (_zz_getNextValue && (! _zz_getNextValue_regNext));
  assign io_bus_dataToMaster = ioDataOut;
  always @(*) begin
    case(busRegister)
      Register_5_data : begin
        _zz_ioDataOut = uartDataIn;
      end
      default : begin
        _zz_ioDataOut = {6'd0, _zz__zz_ioDataOut};
      end
    endcase
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      uartCtrl_1_io_read_rValid <= 1'b0;
      outFifo_io_pop_rValid <= 1'b0;
      uartDataInConsumed <= 1'b1;
    end else begin
      if(uartCtrl_1_io_read_ready) begin
        uartCtrl_1_io_read_rValid <= uartCtrl_1_io_read_valid;
      end
      if(outFifo_io_pop_ready) begin
        outFifo_io_pop_rValid <= outFifo_io_pop_valid;
      end
      if(when_UART_l40) begin
        uartDataInConsumed <= 1'b1;
      end
      if(getNextValue) begin
        uartDataInConsumed <= 1'b0;
      end
    end
  end

  always @(posedge bus_clk) begin
    if(uartCtrl_1_io_read_ready) begin
      uartCtrl_1_io_read_rData <= uartCtrl_1_io_read_payload;
    end
    io_bus_enable_regNext <= io_bus_enable;
    if(outFifo_io_pop_ready) begin
      outFifo_io_pop_rData <= outFifo_io_pop_payload;
    end
    readingData_regNext <= readingData;
    _zz_getNextValue_regNext <= _zz_getNextValue;
    if(getNextValue) begin
      uartDataIn <= inFifo_io_pop_payload;
    end
    if(io_bus_enable) begin
      ioDataOut <= _zz_ioDataOut;
    end else begin
      ioDataOut <= 8'h0;
    end
  end


endmodule

module Font (
  input               io_enable,
  output reg [7:0]    io_dataToMaster,
  input      [13:0]   io_address,
  input               bus_clk,
  input               bus_reset
);

  reg        [7:0]    _zz_memory_port0;
  wire       [11:0]   _zz_memory_port;
  wire       [11:0]   _zz_dataOut_1;
  wire       [13:0]   _zz_dataOut;
  wire       [7:0]    dataOut;
  reg                 io_enable_delay_1;
  reg [7:0] memory [0:4095];

  assign _zz_dataOut_1 = _zz_dataOut[11:0];
  initial begin
    $readmemb("hc800_mega65.v_toplevel_memoryArea_font_memory.bin",memory);
  end
  always @(posedge bus_clk) begin
    if(io_enable) begin
      _zz_memory_port0 <= memory[_zz_dataOut_1];
    end
  end

  assign _zz_dataOut = io_address;
  assign dataOut = _zz_memory_port0;
  always @(*) begin
    if(io_enable_delay_1) begin
      io_dataToMaster = dataOut;
    end else begin
      io_dataToMaster = 8'h0;
    end
  end

  always @(posedge bus_clk) begin
    io_enable_delay_1 <= io_enable;
  end


endmodule

module RAM (
  input               io_enable,
  input               io_write,
  input      [7:0]    io_dataFromMaster,
  output reg [7:0]    io_dataToMaster,
  input      [13:0]   io_address,
  input               bus_clk,
  input               bus_reset
);

  reg        [7:0]    _zz_memory_port0;
  wire       [7:0]    _zz_dataOut;
  wire       [7:0]    dataOut;
  reg                 io_enable_delay_1;
  reg [7:0] memory [0:16383];

  initial begin
    $readmemb("hc800_mega65.v_toplevel_memoryArea_kernel_memory.bin",memory);
  end
  always @(posedge bus_clk) begin
    if(io_enable) begin
      _zz_memory_port0 <= memory[io_address];
    end
  end

  always @(posedge bus_clk) begin
    if(io_enable && io_write ) begin
      memory[io_address] <= _zz_dataOut;
    end
  end

  assign _zz_dataOut = io_dataFromMaster;
  assign dataOut = _zz_memory_port0;
  always @(*) begin
    if(io_enable_delay_1) begin
      io_dataToMaster = dataOut;
    end else begin
      io_dataToMaster = 8'h0;
    end
  end

  always @(posedge bus_clk) begin
    io_enable_delay_1 <= io_enable;
  end


endmodule

module BootROM (
  input               io_enable,
  output reg [7:0]    io_dataToMaster,
  input      [10:0]   io_address,
  input               bus_clk,
  input               bus_reset
);

  reg        [7:0]    _zz_memory_port0;
  wire       [7:0]    dataOut;
  reg                 io_enable_delay_1;
  reg [7:0] memory [0:2047];

  initial begin
    $readmemb("hc800_mega65.v_toplevel_memoryArea_bootROM_memory.bin",memory);
  end
  always @(posedge bus_clk) begin
    if(io_enable) begin
      _zz_memory_port0 <= memory[io_address];
    end
  end

  assign dataOut = _zz_memory_port0;
  always @(*) begin
    if(io_enable_delay_1) begin
      io_dataToMaster = dataOut;
    end else begin
      io_dataToMaster = 8'h0;
    end
  end

  always @(posedge bus_clk) begin
    io_enable_delay_1 <= io_enable;
  end


endmodule

module Math (
  input               io_enable,
  input               io_write,
  input      [7:0]    io_dataFromMaster,
  output     [7:0]    io_dataToMaster,
  input      [2:0]    io_address,
  input               bus_clk,
  input               bus_reset
);
  localparam Operation_signedMultiply = 2'd0;
  localparam Operation_unsignedMultiply = 2'd1;
  localparam Operation_signedDivision = 2'd2;
  localparam Operation_unsignedDivision = 2'd3;
  localparam Register_4_status = 3'd0;
  localparam Register_4_operation = 3'd1;
  localparam Register_4_x = 3'd2;
  localparam Register_4_y = 3'd3;
  localparam Register_4_z = 3'd4;

  wire                multiplier_io_signed;
  wire                divider_io_signed;
  wire       [63:0]   multiplier_io_result;
  wire                multiplier_io_ready;
  wire       [31:0]   divider_io_quotient;
  wire       [31:0]   divider_io_remainder;
  wire                divider_io_ready;
  wire       [1:0]    _zz__zz_dataOut;
  wire       [0:0]    _zz__zz_dataOut_1;
  reg        [31:0]   registerX;
  reg        [31:0]   registerY;
  reg        [63:0]   registerZ;
  reg                 ready;
  reg                 restart;
  reg        [1:0]    operation_1;
  wire                when_Math_l39;
  reg                 multiplier_io_ready_regNext;
  wire                when_Math_l40;
  wire                when_Math_l46;
  reg                 divider_io_ready_regNext;
  wire                when_Math_l47;
  wire       [2:0]    address;
  wire       [2:0]    _zz_address;
  reg        [7:0]    dataOut;
  reg        [7:0]    _zz_dataOut;
  reg                 io_enable_regNext;
  wire                when_Math_l72;
  wire       [1:0]    _zz_operation;
  wire       [1:0]    _zz_operation_1;
  reg                 io_enable_regNext_1;
  wire                when_Math_l82;
  `ifndef SYNTHESIS
  reg [127:0] operation_1_string;
  reg [71:0] address_string;
  reg [71:0] _zz_address_string;
  reg [127:0] _zz_operation_string;
  reg [127:0] _zz_operation_1_string;
  `endif


  assign _zz__zz_dataOut = operation_1;
  assign _zz__zz_dataOut_1 = ready;
  MultiplierUnit32x32 multiplier (
    .io_signed      (multiplier_io_signed        ), //i
    .io_restart     (restart                     ), //i
    .io_operand1    (registerX[31:0]             ), //i
    .io_operand2    (registerY[31:0]             ), //i
    .io_result      (multiplier_io_result[63:0]  ), //o
    .io_ready       (multiplier_io_ready         ), //o
    .bus_clk        (bus_clk                     ), //i
    .bus_reset      (bus_reset                   )  //i
  );
  DividerUnit32x32 divider (
    .io_signed       (divider_io_signed           ), //i
    .io_restart      (restart                     ), //i
    .io_dividend     (registerZ[63:0]             ), //i
    .io_divisor      (registerY[31:0]             ), //i
    .io_quotient     (divider_io_quotient[31:0]   ), //o
    .io_remainder    (divider_io_remainder[31:0]  ), //o
    .io_ready        (divider_io_ready            ), //o
    .bus_clk         (bus_clk                     ), //i
    .bus_reset       (bus_reset                   )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(operation_1)
      Operation_signedMultiply : operation_1_string = "signedMultiply  ";
      Operation_unsignedMultiply : operation_1_string = "unsignedMultiply";
      Operation_signedDivision : operation_1_string = "signedDivision  ";
      Operation_unsignedDivision : operation_1_string = "unsignedDivision";
      default : operation_1_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(address)
      Register_4_status : address_string = "status   ";
      Register_4_operation : address_string = "operation";
      Register_4_x : address_string = "x        ";
      Register_4_y : address_string = "y        ";
      Register_4_z : address_string = "z        ";
      default : address_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_address)
      Register_4_status : _zz_address_string = "status   ";
      Register_4_operation : _zz_address_string = "operation";
      Register_4_x : _zz_address_string = "x        ";
      Register_4_y : _zz_address_string = "y        ";
      Register_4_z : _zz_address_string = "z        ";
      default : _zz_address_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_operation)
      Operation_signedMultiply : _zz_operation_string = "signedMultiply  ";
      Operation_unsignedMultiply : _zz_operation_string = "unsignedMultiply";
      Operation_signedDivision : _zz_operation_string = "signedDivision  ";
      Operation_unsignedDivision : _zz_operation_string = "unsignedDivision";
      default : _zz_operation_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(_zz_operation_1)
      Operation_signedMultiply : _zz_operation_1_string = "signedMultiply  ";
      Operation_unsignedMultiply : _zz_operation_1_string = "unsignedMultiply";
      Operation_signedDivision : _zz_operation_1_string = "signedDivision  ";
      Operation_unsignedDivision : _zz_operation_1_string = "unsignedDivision";
      default : _zz_operation_1_string = "????????????????";
    endcase
  end
  `endif

  assign multiplier_io_signed = (operation_1 == Operation_signedMultiply);
  assign divider_io_signed = (operation_1 == Operation_signedDivision);
  assign when_Math_l39 = ((operation_1 == Operation_signedMultiply) || (operation_1 == Operation_unsignedMultiply));
  assign when_Math_l40 = (multiplier_io_ready && (! multiplier_io_ready_regNext));
  assign when_Math_l46 = ((operation_1 == Operation_signedDivision) || (operation_1 == Operation_unsignedDivision));
  assign when_Math_l47 = (divider_io_ready && (! divider_io_ready_regNext));
  assign _zz_address = io_address;
  assign address = _zz_address;
  assign io_dataToMaster = dataOut;
  always @(*) begin
    case(address)
      Register_4_operation : begin
        _zz_dataOut = {6'd0, _zz__zz_dataOut};
      end
      Register_4_status : begin
        _zz_dataOut = {7'd0, _zz__zz_dataOut_1};
      end
      Register_4_x : begin
        _zz_dataOut = registerX[7 : 0];
      end
      Register_4_y : begin
        _zz_dataOut = registerY[7 : 0];
      end
      default : begin
        _zz_dataOut = registerZ[7 : 0];
      end
    endcase
  end

  assign when_Math_l72 = ((io_enable && (! io_enable_regNext)) && io_write);
  assign _zz_operation_1 = io_dataFromMaster[1 : 0];
  assign _zz_operation = _zz_operation_1;
  assign when_Math_l82 = ((io_enable && (! io_enable_regNext_1)) && (! io_write));
  always @(posedge bus_clk) begin
    restart <= 1'b0;
    if(when_Math_l39) begin
      if(when_Math_l40) begin
        ready <= 1'b1;
        registerZ <= multiplier_io_result;
      end
    end
    if(when_Math_l46) begin
      if(when_Math_l47) begin
        ready <= 1'b1;
        registerX <= divider_io_quotient;
        registerY <= divider_io_remainder;
      end
    end
    if(io_enable) begin
      dataOut <= _zz_dataOut;
    end else begin
      dataOut <= 8'h0;
    end
    io_enable_regNext <= io_enable;
    if(when_Math_l72) begin
      case(address)
        Register_4_operation : begin
          ready <= 1'b0;
          restart <= 1'b1;
          operation_1 <= _zz_operation;
        end
        Register_4_x : begin
          registerX <= {registerX[23 : 0],io_dataFromMaster};
        end
        Register_4_y : begin
          registerY <= {registerY[23 : 0],io_dataFromMaster};
        end
        Register_4_z : begin
          registerZ <= {registerZ[55 : 0],io_dataFromMaster};
        end
        default : begin
        end
      endcase
    end
    io_enable_regNext_1 <= io_enable;
    if(when_Math_l82) begin
      case(address)
        Register_4_x : begin
          registerX <= {8'h0,registerX[31 : 8]};
        end
        Register_4_y : begin
          registerY <= {8'h0,registerY[31 : 8]};
        end
        Register_4_z : begin
          registerZ <= {8'h0,registerZ[63 : 8]};
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge bus_clk) begin
    multiplier_io_ready_regNext <= multiplier_io_ready;
  end

  always @(posedge bus_clk) begin
    divider_io_ready_regNext <= divider_io_ready;
  end


endmodule

module InterruptController (
  input      [6:0]    io_inRequest,
  output              io_outRequest,
  input               io_regBus_enable,
  input               io_regBus_write,
  input      [7:0]    io_regBus_dataFromMaster,
  output     [7:0]    io_regBus_dataToMaster,
  input      [1:0]    io_regBus_address,
  input               bus_clk,
  input               bus_reset
);
  localparam Register_3_enable = 2'd0;
  localparam Register_3_request = 2'd1;
  localparam Register_3_handle = 2'd2;

  wire                _zz_request_8;
  wire                _zz_request_9;
  wire                _zz_request_10;
  reg        [6:0]    enable;
  reg        [6:0]    request;
  wire       [6:0]    handle;
  wire                _zz_request;
  reg                 _zz_request_regNext;
  wire                _zz_request_1;
  reg                 _zz_request_1_regNext;
  wire                _zz_request_2;
  reg                 _zz_request_2_regNext;
  wire                _zz_request_3;
  reg                 _zz_request_3_regNext;
  wire                _zz_request_4;
  reg                 _zz_request_4_regNext;
  wire                _zz_request_5;
  reg                 _zz_request_5_regNext;
  wire                _zz_request_6;
  reg                 _zz_request_6_regNext;
  wire                when_InterruptController_l32;
  wire       [1:0]    switch_InterruptController_l35;
  wire       [1:0]    _zz_switch_InterruptController_l35;
  wire       [6:0]    _zz_enable;
  wire       [6:0]    _zz_request_7;
  reg        [7:0]    regDataOut;
  wire                when_InterruptController_l44;
  wire       [1:0]    switch_Misc_l211;
  wire       [1:0]    _zz_switch_Misc_l211;
  reg        [7:0]    _zz_regDataOut;
  `ifndef SYNTHESIS
  reg [55:0] switch_InterruptController_l35_string;
  reg [55:0] _zz_switch_InterruptController_l35_string;
  reg [55:0] switch_Misc_l211_string;
  reg [55:0] _zz_switch_Misc_l211_string;
  `endif


  assign _zz_request_8 = (! _zz_request_2_regNext);
  assign _zz_request_9 = (_zz_request_1 && (! _zz_request_1_regNext));
  assign _zz_request_10 = (_zz_request && (! _zz_request_regNext));
  `ifndef SYNTHESIS
  always @(*) begin
    case(switch_InterruptController_l35)
      Register_3_enable : switch_InterruptController_l35_string = "enable ";
      Register_3_request : switch_InterruptController_l35_string = "request";
      Register_3_handle : switch_InterruptController_l35_string = "handle ";
      default : switch_InterruptController_l35_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_switch_InterruptController_l35)
      Register_3_enable : _zz_switch_InterruptController_l35_string = "enable ";
      Register_3_request : _zz_switch_InterruptController_l35_string = "request";
      Register_3_handle : _zz_switch_InterruptController_l35_string = "handle ";
      default : _zz_switch_InterruptController_l35_string = "???????";
    endcase
  end
  always @(*) begin
    case(switch_Misc_l211)
      Register_3_enable : switch_Misc_l211_string = "enable ";
      Register_3_request : switch_Misc_l211_string = "request";
      Register_3_handle : switch_Misc_l211_string = "handle ";
      default : switch_Misc_l211_string = "???????";
    endcase
  end
  always @(*) begin
    case(_zz_switch_Misc_l211)
      Register_3_enable : _zz_switch_Misc_l211_string = "enable ";
      Register_3_request : _zz_switch_Misc_l211_string = "request";
      Register_3_handle : _zz_switch_Misc_l211_string = "handle ";
      default : _zz_switch_Misc_l211_string = "???????";
    endcase
  end
  `endif

  assign handle = (enable & request);
  assign _zz_request = io_inRequest[0];
  assign _zz_request_1 = io_inRequest[1];
  assign _zz_request_2 = io_inRequest[2];
  assign _zz_request_3 = io_inRequest[3];
  assign _zz_request_4 = io_inRequest[4];
  assign _zz_request_5 = io_inRequest[5];
  assign _zz_request_6 = io_inRequest[6];
  assign io_outRequest = (|handle);
  assign when_InterruptController_l32 = (io_regBus_enable && io_regBus_write);
  assign _zz_switch_InterruptController_l35 = io_regBus_address;
  assign switch_InterruptController_l35 = _zz_switch_InterruptController_l35;
  assign _zz_enable = io_regBus_dataFromMaster[6 : 0];
  assign _zz_request_7 = io_regBus_dataFromMaster[6 : 0];
  assign io_regBus_dataToMaster = regDataOut;
  assign when_InterruptController_l44 = (io_regBus_enable && (! io_regBus_write));
  assign _zz_switch_Misc_l211 = io_regBus_address;
  assign switch_Misc_l211 = _zz_switch_Misc_l211;
  always @(*) begin
    case(switch_Misc_l211)
      Register_3_enable : begin
        _zz_regDataOut = {1'd0, enable};
      end
      Register_3_request : begin
        _zz_regDataOut = {1'd0, request};
      end
      default : begin
        _zz_regDataOut = {1'd0, handle};
      end
    endcase
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      enable <= 7'h0;
      request <= 7'h0;
      _zz_request_regNext <= 1'b0;
      _zz_request_1_regNext <= 1'b0;
      _zz_request_2_regNext <= 1'b0;
      _zz_request_3_regNext <= 1'b0;
      _zz_request_4_regNext <= 1'b0;
      _zz_request_5_regNext <= 1'b0;
      _zz_request_6_regNext <= 1'b0;
    end else begin
      _zz_request_regNext <= _zz_request;
      _zz_request_1_regNext <= _zz_request_1;
      _zz_request_2_regNext <= _zz_request_2;
      _zz_request_3_regNext <= _zz_request_3;
      _zz_request_4_regNext <= _zz_request_4;
      _zz_request_5_regNext <= _zz_request_5;
      _zz_request_6_regNext <= _zz_request_6;
      request <= (request | {(_zz_request_6 && (! _zz_request_6_regNext)),{(_zz_request_5 && (! _zz_request_5_regNext)),{(_zz_request_4 && (! _zz_request_4_regNext)),{(_zz_request_3 && (! _zz_request_3_regNext)),{(_zz_request_2 && _zz_request_8),{_zz_request_9,_zz_request_10}}}}}});
      if(when_InterruptController_l32) begin
        case(switch_InterruptController_l35)
          Register_3_enable : begin
            enable <= (io_regBus_dataFromMaster[7] ? (enable | _zz_enable) : (enable & (~ _zz_enable)));
          end
          Register_3_request : begin
            request <= (io_regBus_dataFromMaster[7] ? (request | _zz_request_7) : (request & (~ _zz_request_7)));
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(posedge bus_clk) begin
    if(when_InterruptController_l44) begin
      regDataOut <= _zz_regDataOut;
    end else begin
      regDataOut <= 8'h0;
    end
  end


endmodule

module NullKeyboard (
  input               io_bus_enable,
  output     [7:0]    io_bus_dataToMaster,
  input      [0:0]    io_bus_address,
  input               bus_clk,
  input               bus_reset
);
  localparam Register_2_data = 1'd0;
  localparam Register_2_status = 1'd1;

  wire                fifo_io_push_ready;
  wire                fifo_io_pop_valid;
  wire       [7:0]    fifo_io_pop_payload;
  wire       [2:0]    fifo_io_occupancy;
  wire       [2:0]    fifo_io_availability;
  wire       [0:0]    _zz__zz_busDataOut;
  wire       [0:0]    busRegister;
  wire       [0:0]    _zz_busRegister;
  wire                readingData;
  reg        [7:0]    keyCode;
  reg                 keyCodeReady;
  reg                 readingData_regNext;
  wire                when_Keyboard_l26;
  wire                _zz_getNextValue;
  reg                 _zz_getNextValue_regNext;
  wire                getNextValue;
  reg        [7:0]    busDataOut;
  reg        [7:0]    _zz_busDataOut;
  `ifndef SYNTHESIS
  reg [47:0] busRegister_string;
  reg [47:0] _zz_busRegister_string;
  `endif


  assign _zz__zz_busDataOut = keyCodeReady;
  StreamFifo fifo (
    .io_push_valid      (1'b0                       ), //i
    .io_push_ready      (fifo_io_push_ready         ), //o
    .io_push_payload    (8'h0                       ), //i
    .io_pop_valid       (fifo_io_pop_valid          ), //o
    .io_pop_ready       (getNextValue               ), //i
    .io_pop_payload     (fifo_io_pop_payload[7:0]   ), //o
    .io_flush           (1'b0                       ), //i
    .io_occupancy       (fifo_io_occupancy[2:0]     ), //o
    .io_availability    (fifo_io_availability[2:0]  ), //o
    .bus_clk            (bus_clk                    ), //i
    .bus_reset          (bus_reset                  )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(busRegister)
      Register_2_data : busRegister_string = "data  ";
      Register_2_status : busRegister_string = "status";
      default : busRegister_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_busRegister)
      Register_2_data : _zz_busRegister_string = "data  ";
      Register_2_status : _zz_busRegister_string = "status";
      default : _zz_busRegister_string = "??????";
    endcase
  end
  `endif

  assign _zz_busRegister = io_bus_address;
  assign busRegister = _zz_busRegister;
  assign readingData = (io_bus_enable && (busRegister == Register_2_data));
  assign when_Keyboard_l26 = (readingData && (! readingData_regNext));
  assign _zz_getNextValue = (fifo_io_pop_valid && (! keyCodeReady));
  assign getNextValue = (_zz_getNextValue && (! _zz_getNextValue_regNext));
  assign io_bus_dataToMaster = busDataOut;
  always @(*) begin
    case(busRegister)
      Register_2_data : begin
        _zz_busDataOut = keyCode;
      end
      default : begin
        _zz_busDataOut = {7'd0, _zz__zz_busDataOut};
      end
    endcase
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      keyCodeReady <= 1'b0;
    end else begin
      if(when_Keyboard_l26) begin
        keyCodeReady <= 1'b0;
      end
      if(getNextValue) begin
        keyCodeReady <= 1'b1;
      end
    end
  end

  always @(posedge bus_clk) begin
    readingData_regNext <= readingData;
    _zz_getNextValue_regNext <= _zz_getNextValue;
    if(getNextValue) begin
      keyCode <= fifo_io_pop_payload;
    end
    if(io_bus_enable) begin
      busDataOut <= _zz_busDataOut;
    end else begin
      busDataOut <= 8'h0;
    end
  end


endmodule

module BoardId (
  input               enable,
  output     [7:0]    dataToMaster,
  input      [0:0]    address,
  input               bus_clk,
  input               bus_reset
);

  reg        [2:0]    counter;
  reg        [7:0]    dataOutR;

  assign dataToMaster = dataOutR;
  always @(posedge bus_clk) begin
    if(enable) begin
      case(address)
        1'b0 : begin
          dataOutR <= 8'h04;
        end
        default : begin
          case(counter)
            3'b000 : begin
              dataOutR <= 8'h87;
            end
            3'b001 : begin
              dataOutR <= 8'h55;
            end
            3'b010 : begin
              dataOutR <= 8'h6e;
            end
            3'b011 : begin
              dataOutR <= 8'h6b;
            end
            3'b100 : begin
              dataOutR <= 8'h6e;
            end
            3'b101 : begin
              dataOutR <= 8'h6f;
            end
            3'b110 : begin
              dataOutR <= 8'h77;
            end
            default : begin
              dataOutR <= 8'h6e;
            end
          endcase
          counter <= (counter + 3'b001);
        end
      endcase
    end else begin
      dataOutR <= 8'h0;
    end
  end


endmodule

module MMU (
  input               io_regBus_enable,
  input               io_regBus_write,
  input      [7:0]    io_regBus_dataFromMaster,
  output     [7:0]    io_regBus_dataToMaster,
  input      [3:0]    io_regBus_address,
  input      [0:0]    io_mapSource,
  input               io_mapCode,
  input               io_mapSystem,
  input               io_mapIo,
  input      [15:0]   io_mapAddressIn,
  output reg [21:0]   io_mapAddressOut,
  input               bus_clk,
  input               bus_reset
);
  localparam MapSource_cpu = 1'd0;
  localparam MapSource_chipsetCharGen = 1'd1;
  localparam UpperSizeConfig_size16 = 2'd0;
  localparam UpperSizeConfig_size32 = 2'd1;
  localparam UpperSizeConfig_size48 = 2'd2;
  localparam UpperSizeConfig_size64 = 2'd3;
  localparam Register_1_updateIndex = 4'd0;
  localparam Register_1_configBits = 4'd1;
  localparam Register_1_codeBank0 = 4'd2;
  localparam Register_1_codeBank1 = 4'd3;
  localparam Register_1_codeBank2 = 4'd4;
  localparam Register_1_codeBank3 = 4'd5;
  localparam Register_1_dataBank0 = 4'd6;
  localparam Register_1_dataBank1 = 4'd7;
  localparam Register_1_dataBank2 = 4'd8;
  localparam Register_1_dataBank3 = 4'd9;
  localparam Register_1_systemCodeBank = 4'd10;
  localparam Register_1_systemDataBank = 4'd11;
  localparam Register_1_activeIndex = 4'd12;
  localparam Register_1_chipsetCharGen = 4'd13;

  reg        [7:0]    _zz_mapArea_config_userCode_0;
  reg        [7:0]    _zz_mapArea_config_userCode_1;
  reg        [7:0]    _zz_mapArea_config_userCode_2;
  reg        [7:0]    _zz_mapArea_config_userCode_3;
  reg        [7:0]    _zz_mapArea_config_userData_0;
  reg        [7:0]    _zz_mapArea_config_userData_1;
  reg        [7:0]    _zz_mapArea_config_userData_2;
  reg        [7:0]    _zz_mapArea_config_userData_3;
  reg                 _zz_mapArea_config_userHarvard;
  reg        [1:0]    _zz_mapArea_config_userCodeUpperSize;
  reg        [1:0]    _zz_mapArea_config_userDataUpperSize;
  reg        [7:0]    _zz_mapArea_config_systemCode;
  reg        [7:0]    _zz_mapArea_config_systemData;
  reg                 _zz_mapArea_config_systemHarvard;
  wire       [1:0]    _zz__zz_io_mapAddressOut;
  wire       [1:0]    _zz__zz_io_mapAddressOut_1;
  reg        [7:0]    _zz__zz_io_mapAddressOut_2;
  reg        [7:0]    _zz_io_mapAddressOut_3;
  wire       [13:0]   _zz_io_mapAddressOut_4;
  wire       [21:0]   _zz_io_mapAddressOut_5;
  reg        [7:0]    _zz_ioArea_config_userCode_0;
  reg        [7:0]    _zz_ioArea_config_userCode_1;
  reg        [7:0]    _zz_ioArea_config_userCode_2;
  reg        [7:0]    _zz_ioArea_config_userCode_3;
  reg        [7:0]    _zz_ioArea_config_userData_0;
  reg        [7:0]    _zz_ioArea_config_userData_1;
  reg        [7:0]    _zz_ioArea_config_userData_2;
  reg        [7:0]    _zz_ioArea_config_userData_3;
  reg                 _zz_ioArea_config_userHarvard;
  reg        [1:0]    _zz_ioArea_config_userCodeUpperSize;
  reg        [1:0]    _zz_ioArea_config_userDataUpperSize;
  reg        [7:0]    _zz_ioArea_config_systemCode;
  reg        [7:0]    _zz_ioArea_config_systemData;
  reg                 _zz_ioArea_config_systemHarvard;
  wire       [7:0]    _zz__zz_ioArea_regData;
  wire       [5:0]    _zz__zz_ioArea_regData_1;
  wire       [7:0]    _zz__zz_ioArea_regData_2;
  wire       [7:0]    ioBank;
  reg        [7:0]    configurationStack;
  reg        [7:0]    configurationVec_0_userCode_0;
  reg        [7:0]    configurationVec_0_userCode_1;
  reg        [7:0]    configurationVec_0_userCode_2;
  reg        [7:0]    configurationVec_0_userCode_3;
  reg        [7:0]    configurationVec_0_userData_0;
  reg        [7:0]    configurationVec_0_userData_1;
  reg        [7:0]    configurationVec_0_userData_2;
  reg        [7:0]    configurationVec_0_userData_3;
  reg                 configurationVec_0_userHarvard;
  reg        [1:0]    configurationVec_0_userCodeUpperSize;
  reg        [1:0]    configurationVec_0_userDataUpperSize;
  reg        [7:0]    configurationVec_0_systemCode;
  reg        [7:0]    configurationVec_0_systemData;
  reg                 configurationVec_0_systemHarvard;
  reg        [7:0]    configurationVec_1_userCode_0;
  reg        [7:0]    configurationVec_1_userCode_1;
  reg        [7:0]    configurationVec_1_userCode_2;
  reg        [7:0]    configurationVec_1_userCode_3;
  reg        [7:0]    configurationVec_1_userData_0;
  reg        [7:0]    configurationVec_1_userData_1;
  reg        [7:0]    configurationVec_1_userData_2;
  reg        [7:0]    configurationVec_1_userData_3;
  reg                 configurationVec_1_userHarvard;
  reg        [1:0]    configurationVec_1_userCodeUpperSize;
  reg        [1:0]    configurationVec_1_userDataUpperSize;
  reg        [7:0]    configurationVec_1_systemCode;
  reg        [7:0]    configurationVec_1_systemData;
  reg                 configurationVec_1_systemHarvard;
  reg        [7:0]    configurationVec_2_userCode_0;
  reg        [7:0]    configurationVec_2_userCode_1;
  reg        [7:0]    configurationVec_2_userCode_2;
  reg        [7:0]    configurationVec_2_userCode_3;
  reg        [7:0]    configurationVec_2_userData_0;
  reg        [7:0]    configurationVec_2_userData_1;
  reg        [7:0]    configurationVec_2_userData_2;
  reg        [7:0]    configurationVec_2_userData_3;
  reg                 configurationVec_2_userHarvard;
  reg        [1:0]    configurationVec_2_userCodeUpperSize;
  reg        [1:0]    configurationVec_2_userDataUpperSize;
  reg        [7:0]    configurationVec_2_systemCode;
  reg        [7:0]    configurationVec_2_systemData;
  reg                 configurationVec_2_systemHarvard;
  reg        [7:0]    configurationVec_3_userCode_0;
  reg        [7:0]    configurationVec_3_userCode_1;
  reg        [7:0]    configurationVec_3_userCode_2;
  reg        [7:0]    configurationVec_3_userCode_3;
  reg        [7:0]    configurationVec_3_userData_0;
  reg        [7:0]    configurationVec_3_userData_1;
  reg        [7:0]    configurationVec_3_userData_2;
  reg        [7:0]    configurationVec_3_userData_3;
  reg                 configurationVec_3_userHarvard;
  reg        [1:0]    configurationVec_3_userCodeUpperSize;
  reg        [1:0]    configurationVec_3_userDataUpperSize;
  reg        [7:0]    configurationVec_3_systemCode;
  reg        [7:0]    configurationVec_3_systemData;
  reg                 configurationVec_3_systemHarvard;
  reg        [1:0]    updateIndex;
  reg        [1:0]    activeIndex;
  reg        [7:0]    chipsetCharGen;
  wire       [7:0]    mapArea_config_userCode_0;
  wire       [7:0]    mapArea_config_userCode_1;
  wire       [7:0]    mapArea_config_userCode_2;
  wire       [7:0]    mapArea_config_userCode_3;
  wire       [7:0]    mapArea_config_userData_0;
  wire       [7:0]    mapArea_config_userData_1;
  wire       [7:0]    mapArea_config_userData_2;
  wire       [7:0]    mapArea_config_userData_3;
  wire                mapArea_config_userHarvard;
  wire       [1:0]    mapArea_config_userCodeUpperSize;
  wire       [1:0]    mapArea_config_userDataUpperSize;
  wire       [7:0]    mapArea_config_systemCode;
  wire       [7:0]    mapArea_config_systemData;
  wire                mapArea_config_systemHarvard;
  wire                when_MMU_l90;
  wire       [1:0]    switch_Misc_l211;
  reg        [1:0]    _zz_io_mapAddressOut;
  reg        [1:0]    _zz_io_mapAddressOut_1;
  wire       [7:0]    _zz_io_mapAddressOut_2;
  wire                when_MMU_l109;
  wire       [7:0]    ioArea_config_userCode_0;
  wire       [7:0]    ioArea_config_userCode_1;
  wire       [7:0]    ioArea_config_userCode_2;
  wire       [7:0]    ioArea_config_userCode_3;
  wire       [7:0]    ioArea_config_userData_0;
  wire       [7:0]    ioArea_config_userData_1;
  wire       [7:0]    ioArea_config_userData_2;
  wire       [7:0]    ioArea_config_userData_3;
  wire                ioArea_config_userHarvard;
  wire       [1:0]    ioArea_config_userCodeUpperSize;
  wire       [1:0]    ioArea_config_userDataUpperSize;
  wire       [7:0]    ioArea_config_systemCode;
  wire       [7:0]    ioArea_config_systemData;
  wire                ioArea_config_systemHarvard;
  wire       [3:0]    _zz_1;
  wire                _zz_2;
  wire                _zz_3;
  wire                _zz_4;
  wire                _zz_5;
  wire       [3:0]    ioArea_reg;
  wire       [3:0]    _zz_ioArea_reg;
  wire                when_MMU_l121;
  wire                _zz_configurationVec_0_userHarvard;
  wire                _zz_configurationVec_0_systemHarvard;
  wire       [1:0]    _zz_configurationVec_0_userCodeUpperSize;
  wire       [1:0]    _zz_configurationVec_0_userCodeUpperSize_1;
  wire       [1:0]    _zz_configurationVec_0_userDataUpperSize;
  wire       [1:0]    _zz_configurationVec_0_userDataUpperSize_1;
  wire                when_MMU_l141;
  wire                when_MMU_l146;
  reg        [7:0]    ioArea_regData;
  wire                when_MMU_l161;
  reg        [7:0]    _zz_ioArea_regData;
  `ifndef SYNTHESIS
  reg [111:0] io_mapSource_string;
  reg [47:0] configurationVec_0_userCodeUpperSize_string;
  reg [47:0] configurationVec_0_userDataUpperSize_string;
  reg [47:0] configurationVec_1_userCodeUpperSize_string;
  reg [47:0] configurationVec_1_userDataUpperSize_string;
  reg [47:0] configurationVec_2_userCodeUpperSize_string;
  reg [47:0] configurationVec_2_userDataUpperSize_string;
  reg [47:0] configurationVec_3_userCodeUpperSize_string;
  reg [47:0] configurationVec_3_userDataUpperSize_string;
  reg [47:0] mapArea_config_userCodeUpperSize_string;
  reg [47:0] mapArea_config_userDataUpperSize_string;
  reg [47:0] ioArea_config_userCodeUpperSize_string;
  reg [47:0] ioArea_config_userDataUpperSize_string;
  reg [111:0] ioArea_reg_string;
  reg [111:0] _zz_ioArea_reg_string;
  reg [47:0] _zz_configurationVec_0_userCodeUpperSize_string;
  reg [47:0] _zz_configurationVec_0_userCodeUpperSize_1_string;
  reg [47:0] _zz_configurationVec_0_userDataUpperSize_string;
  reg [47:0] _zz_configurationVec_0_userDataUpperSize_1_string;
  `endif


  assign _zz__zz_io_mapAddressOut = mapArea_config_userCodeUpperSize;
  assign _zz__zz_io_mapAddressOut_1 = mapArea_config_userDataUpperSize;
  assign _zz_io_mapAddressOut_4 = io_mapAddressIn[13:0];
  assign _zz_io_mapAddressOut_5 = {6'd0, io_mapAddressIn};
  assign _zz__zz_ioArea_regData = {6'd0, updateIndex};
  assign _zz__zz_ioArea_regData_1 = {{{ioArea_config_userDataUpperSize,ioArea_config_userCodeUpperSize},ioArea_config_systemHarvard},ioArea_config_userHarvard};
  assign _zz__zz_ioArea_regData_2 = {6'd0, activeIndex};
  always @(*) begin
    case(activeIndex)
      2'b00 : begin
        _zz_mapArea_config_userCode_0 = configurationVec_0_userCode_0;
        _zz_mapArea_config_userCode_1 = configurationVec_0_userCode_1;
        _zz_mapArea_config_userCode_2 = configurationVec_0_userCode_2;
        _zz_mapArea_config_userCode_3 = configurationVec_0_userCode_3;
        _zz_mapArea_config_userData_0 = configurationVec_0_userData_0;
        _zz_mapArea_config_userData_1 = configurationVec_0_userData_1;
        _zz_mapArea_config_userData_2 = configurationVec_0_userData_2;
        _zz_mapArea_config_userData_3 = configurationVec_0_userData_3;
        _zz_mapArea_config_userHarvard = configurationVec_0_userHarvard;
        _zz_mapArea_config_userCodeUpperSize = configurationVec_0_userCodeUpperSize;
        _zz_mapArea_config_userDataUpperSize = configurationVec_0_userDataUpperSize;
        _zz_mapArea_config_systemCode = configurationVec_0_systemCode;
        _zz_mapArea_config_systemData = configurationVec_0_systemData;
        _zz_mapArea_config_systemHarvard = configurationVec_0_systemHarvard;
      end
      2'b01 : begin
        _zz_mapArea_config_userCode_0 = configurationVec_1_userCode_0;
        _zz_mapArea_config_userCode_1 = configurationVec_1_userCode_1;
        _zz_mapArea_config_userCode_2 = configurationVec_1_userCode_2;
        _zz_mapArea_config_userCode_3 = configurationVec_1_userCode_3;
        _zz_mapArea_config_userData_0 = configurationVec_1_userData_0;
        _zz_mapArea_config_userData_1 = configurationVec_1_userData_1;
        _zz_mapArea_config_userData_2 = configurationVec_1_userData_2;
        _zz_mapArea_config_userData_3 = configurationVec_1_userData_3;
        _zz_mapArea_config_userHarvard = configurationVec_1_userHarvard;
        _zz_mapArea_config_userCodeUpperSize = configurationVec_1_userCodeUpperSize;
        _zz_mapArea_config_userDataUpperSize = configurationVec_1_userDataUpperSize;
        _zz_mapArea_config_systemCode = configurationVec_1_systemCode;
        _zz_mapArea_config_systemData = configurationVec_1_systemData;
        _zz_mapArea_config_systemHarvard = configurationVec_1_systemHarvard;
      end
      2'b10 : begin
        _zz_mapArea_config_userCode_0 = configurationVec_2_userCode_0;
        _zz_mapArea_config_userCode_1 = configurationVec_2_userCode_1;
        _zz_mapArea_config_userCode_2 = configurationVec_2_userCode_2;
        _zz_mapArea_config_userCode_3 = configurationVec_2_userCode_3;
        _zz_mapArea_config_userData_0 = configurationVec_2_userData_0;
        _zz_mapArea_config_userData_1 = configurationVec_2_userData_1;
        _zz_mapArea_config_userData_2 = configurationVec_2_userData_2;
        _zz_mapArea_config_userData_3 = configurationVec_2_userData_3;
        _zz_mapArea_config_userHarvard = configurationVec_2_userHarvard;
        _zz_mapArea_config_userCodeUpperSize = configurationVec_2_userCodeUpperSize;
        _zz_mapArea_config_userDataUpperSize = configurationVec_2_userDataUpperSize;
        _zz_mapArea_config_systemCode = configurationVec_2_systemCode;
        _zz_mapArea_config_systemData = configurationVec_2_systemData;
        _zz_mapArea_config_systemHarvard = configurationVec_2_systemHarvard;
      end
      default : begin
        _zz_mapArea_config_userCode_0 = configurationVec_3_userCode_0;
        _zz_mapArea_config_userCode_1 = configurationVec_3_userCode_1;
        _zz_mapArea_config_userCode_2 = configurationVec_3_userCode_2;
        _zz_mapArea_config_userCode_3 = configurationVec_3_userCode_3;
        _zz_mapArea_config_userData_0 = configurationVec_3_userData_0;
        _zz_mapArea_config_userData_1 = configurationVec_3_userData_1;
        _zz_mapArea_config_userData_2 = configurationVec_3_userData_2;
        _zz_mapArea_config_userData_3 = configurationVec_3_userData_3;
        _zz_mapArea_config_userHarvard = configurationVec_3_userHarvard;
        _zz_mapArea_config_userCodeUpperSize = configurationVec_3_userCodeUpperSize;
        _zz_mapArea_config_userDataUpperSize = configurationVec_3_userDataUpperSize;
        _zz_mapArea_config_systemCode = configurationVec_3_systemCode;
        _zz_mapArea_config_systemData = configurationVec_3_systemData;
        _zz_mapArea_config_systemHarvard = configurationVec_3_systemHarvard;
      end
    endcase
  end

  always @(*) begin
    case(_zz_io_mapAddressOut)
      2'b00 : _zz__zz_io_mapAddressOut_2 = mapArea_config_userCode_0;
      2'b01 : _zz__zz_io_mapAddressOut_2 = mapArea_config_userCode_1;
      2'b10 : _zz__zz_io_mapAddressOut_2 = mapArea_config_userCode_2;
      default : _zz__zz_io_mapAddressOut_2 = mapArea_config_userCode_3;
    endcase
  end

  always @(*) begin
    case(_zz_io_mapAddressOut_1)
      2'b00 : _zz_io_mapAddressOut_3 = mapArea_config_userData_0;
      2'b01 : _zz_io_mapAddressOut_3 = mapArea_config_userData_1;
      2'b10 : _zz_io_mapAddressOut_3 = mapArea_config_userData_2;
      default : _zz_io_mapAddressOut_3 = mapArea_config_userData_3;
    endcase
  end

  always @(*) begin
    case(updateIndex)
      2'b00 : begin
        _zz_ioArea_config_userCode_0 = configurationVec_0_userCode_0;
        _zz_ioArea_config_userCode_1 = configurationVec_0_userCode_1;
        _zz_ioArea_config_userCode_2 = configurationVec_0_userCode_2;
        _zz_ioArea_config_userCode_3 = configurationVec_0_userCode_3;
        _zz_ioArea_config_userData_0 = configurationVec_0_userData_0;
        _zz_ioArea_config_userData_1 = configurationVec_0_userData_1;
        _zz_ioArea_config_userData_2 = configurationVec_0_userData_2;
        _zz_ioArea_config_userData_3 = configurationVec_0_userData_3;
        _zz_ioArea_config_userHarvard = configurationVec_0_userHarvard;
        _zz_ioArea_config_userCodeUpperSize = configurationVec_0_userCodeUpperSize;
        _zz_ioArea_config_userDataUpperSize = configurationVec_0_userDataUpperSize;
        _zz_ioArea_config_systemCode = configurationVec_0_systemCode;
        _zz_ioArea_config_systemData = configurationVec_0_systemData;
        _zz_ioArea_config_systemHarvard = configurationVec_0_systemHarvard;
      end
      2'b01 : begin
        _zz_ioArea_config_userCode_0 = configurationVec_1_userCode_0;
        _zz_ioArea_config_userCode_1 = configurationVec_1_userCode_1;
        _zz_ioArea_config_userCode_2 = configurationVec_1_userCode_2;
        _zz_ioArea_config_userCode_3 = configurationVec_1_userCode_3;
        _zz_ioArea_config_userData_0 = configurationVec_1_userData_0;
        _zz_ioArea_config_userData_1 = configurationVec_1_userData_1;
        _zz_ioArea_config_userData_2 = configurationVec_1_userData_2;
        _zz_ioArea_config_userData_3 = configurationVec_1_userData_3;
        _zz_ioArea_config_userHarvard = configurationVec_1_userHarvard;
        _zz_ioArea_config_userCodeUpperSize = configurationVec_1_userCodeUpperSize;
        _zz_ioArea_config_userDataUpperSize = configurationVec_1_userDataUpperSize;
        _zz_ioArea_config_systemCode = configurationVec_1_systemCode;
        _zz_ioArea_config_systemData = configurationVec_1_systemData;
        _zz_ioArea_config_systemHarvard = configurationVec_1_systemHarvard;
      end
      2'b10 : begin
        _zz_ioArea_config_userCode_0 = configurationVec_2_userCode_0;
        _zz_ioArea_config_userCode_1 = configurationVec_2_userCode_1;
        _zz_ioArea_config_userCode_2 = configurationVec_2_userCode_2;
        _zz_ioArea_config_userCode_3 = configurationVec_2_userCode_3;
        _zz_ioArea_config_userData_0 = configurationVec_2_userData_0;
        _zz_ioArea_config_userData_1 = configurationVec_2_userData_1;
        _zz_ioArea_config_userData_2 = configurationVec_2_userData_2;
        _zz_ioArea_config_userData_3 = configurationVec_2_userData_3;
        _zz_ioArea_config_userHarvard = configurationVec_2_userHarvard;
        _zz_ioArea_config_userCodeUpperSize = configurationVec_2_userCodeUpperSize;
        _zz_ioArea_config_userDataUpperSize = configurationVec_2_userDataUpperSize;
        _zz_ioArea_config_systemCode = configurationVec_2_systemCode;
        _zz_ioArea_config_systemData = configurationVec_2_systemData;
        _zz_ioArea_config_systemHarvard = configurationVec_2_systemHarvard;
      end
      default : begin
        _zz_ioArea_config_userCode_0 = configurationVec_3_userCode_0;
        _zz_ioArea_config_userCode_1 = configurationVec_3_userCode_1;
        _zz_ioArea_config_userCode_2 = configurationVec_3_userCode_2;
        _zz_ioArea_config_userCode_3 = configurationVec_3_userCode_3;
        _zz_ioArea_config_userData_0 = configurationVec_3_userData_0;
        _zz_ioArea_config_userData_1 = configurationVec_3_userData_1;
        _zz_ioArea_config_userData_2 = configurationVec_3_userData_2;
        _zz_ioArea_config_userData_3 = configurationVec_3_userData_3;
        _zz_ioArea_config_userHarvard = configurationVec_3_userHarvard;
        _zz_ioArea_config_userCodeUpperSize = configurationVec_3_userCodeUpperSize;
        _zz_ioArea_config_userDataUpperSize = configurationVec_3_userDataUpperSize;
        _zz_ioArea_config_systemCode = configurationVec_3_systemCode;
        _zz_ioArea_config_systemData = configurationVec_3_systemData;
        _zz_ioArea_config_systemHarvard = configurationVec_3_systemHarvard;
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_mapSource)
      MapSource_cpu : io_mapSource_string = "cpu           ";
      MapSource_chipsetCharGen : io_mapSource_string = "chipsetCharGen";
      default : io_mapSource_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(configurationVec_0_userCodeUpperSize)
      UpperSizeConfig_size16 : configurationVec_0_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_0_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_0_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_0_userCodeUpperSize_string = "size64";
      default : configurationVec_0_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_0_userDataUpperSize)
      UpperSizeConfig_size16 : configurationVec_0_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_0_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_0_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_0_userDataUpperSize_string = "size64";
      default : configurationVec_0_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_1_userCodeUpperSize)
      UpperSizeConfig_size16 : configurationVec_1_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_1_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_1_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_1_userCodeUpperSize_string = "size64";
      default : configurationVec_1_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_1_userDataUpperSize)
      UpperSizeConfig_size16 : configurationVec_1_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_1_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_1_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_1_userDataUpperSize_string = "size64";
      default : configurationVec_1_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_2_userCodeUpperSize)
      UpperSizeConfig_size16 : configurationVec_2_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_2_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_2_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_2_userCodeUpperSize_string = "size64";
      default : configurationVec_2_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_2_userDataUpperSize)
      UpperSizeConfig_size16 : configurationVec_2_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_2_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_2_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_2_userDataUpperSize_string = "size64";
      default : configurationVec_2_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_3_userCodeUpperSize)
      UpperSizeConfig_size16 : configurationVec_3_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_3_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_3_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_3_userCodeUpperSize_string = "size64";
      default : configurationVec_3_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(configurationVec_3_userDataUpperSize)
      UpperSizeConfig_size16 : configurationVec_3_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : configurationVec_3_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : configurationVec_3_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : configurationVec_3_userDataUpperSize_string = "size64";
      default : configurationVec_3_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(mapArea_config_userCodeUpperSize)
      UpperSizeConfig_size16 : mapArea_config_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : mapArea_config_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : mapArea_config_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : mapArea_config_userCodeUpperSize_string = "size64";
      default : mapArea_config_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(mapArea_config_userDataUpperSize)
      UpperSizeConfig_size16 : mapArea_config_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : mapArea_config_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : mapArea_config_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : mapArea_config_userDataUpperSize_string = "size64";
      default : mapArea_config_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(ioArea_config_userCodeUpperSize)
      UpperSizeConfig_size16 : ioArea_config_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : ioArea_config_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : ioArea_config_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : ioArea_config_userCodeUpperSize_string = "size64";
      default : ioArea_config_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(ioArea_config_userDataUpperSize)
      UpperSizeConfig_size16 : ioArea_config_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : ioArea_config_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : ioArea_config_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : ioArea_config_userDataUpperSize_string = "size64";
      default : ioArea_config_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(ioArea_reg)
      Register_1_updateIndex : ioArea_reg_string = "updateIndex   ";
      Register_1_configBits : ioArea_reg_string = "configBits    ";
      Register_1_codeBank0 : ioArea_reg_string = "codeBank0     ";
      Register_1_codeBank1 : ioArea_reg_string = "codeBank1     ";
      Register_1_codeBank2 : ioArea_reg_string = "codeBank2     ";
      Register_1_codeBank3 : ioArea_reg_string = "codeBank3     ";
      Register_1_dataBank0 : ioArea_reg_string = "dataBank0     ";
      Register_1_dataBank1 : ioArea_reg_string = "dataBank1     ";
      Register_1_dataBank2 : ioArea_reg_string = "dataBank2     ";
      Register_1_dataBank3 : ioArea_reg_string = "dataBank3     ";
      Register_1_systemCodeBank : ioArea_reg_string = "systemCodeBank";
      Register_1_systemDataBank : ioArea_reg_string = "systemDataBank";
      Register_1_activeIndex : ioArea_reg_string = "activeIndex   ";
      Register_1_chipsetCharGen : ioArea_reg_string = "chipsetCharGen";
      default : ioArea_reg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(_zz_ioArea_reg)
      Register_1_updateIndex : _zz_ioArea_reg_string = "updateIndex   ";
      Register_1_configBits : _zz_ioArea_reg_string = "configBits    ";
      Register_1_codeBank0 : _zz_ioArea_reg_string = "codeBank0     ";
      Register_1_codeBank1 : _zz_ioArea_reg_string = "codeBank1     ";
      Register_1_codeBank2 : _zz_ioArea_reg_string = "codeBank2     ";
      Register_1_codeBank3 : _zz_ioArea_reg_string = "codeBank3     ";
      Register_1_dataBank0 : _zz_ioArea_reg_string = "dataBank0     ";
      Register_1_dataBank1 : _zz_ioArea_reg_string = "dataBank1     ";
      Register_1_dataBank2 : _zz_ioArea_reg_string = "dataBank2     ";
      Register_1_dataBank3 : _zz_ioArea_reg_string = "dataBank3     ";
      Register_1_systemCodeBank : _zz_ioArea_reg_string = "systemCodeBank";
      Register_1_systemDataBank : _zz_ioArea_reg_string = "systemDataBank";
      Register_1_activeIndex : _zz_ioArea_reg_string = "activeIndex   ";
      Register_1_chipsetCharGen : _zz_ioArea_reg_string = "chipsetCharGen";
      default : _zz_ioArea_reg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(_zz_configurationVec_0_userCodeUpperSize)
      UpperSizeConfig_size16 : _zz_configurationVec_0_userCodeUpperSize_string = "size16";
      UpperSizeConfig_size32 : _zz_configurationVec_0_userCodeUpperSize_string = "size32";
      UpperSizeConfig_size48 : _zz_configurationVec_0_userCodeUpperSize_string = "size48";
      UpperSizeConfig_size64 : _zz_configurationVec_0_userCodeUpperSize_string = "size64";
      default : _zz_configurationVec_0_userCodeUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_configurationVec_0_userCodeUpperSize_1)
      UpperSizeConfig_size16 : _zz_configurationVec_0_userCodeUpperSize_1_string = "size16";
      UpperSizeConfig_size32 : _zz_configurationVec_0_userCodeUpperSize_1_string = "size32";
      UpperSizeConfig_size48 : _zz_configurationVec_0_userCodeUpperSize_1_string = "size48";
      UpperSizeConfig_size64 : _zz_configurationVec_0_userCodeUpperSize_1_string = "size64";
      default : _zz_configurationVec_0_userCodeUpperSize_1_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_configurationVec_0_userDataUpperSize)
      UpperSizeConfig_size16 : _zz_configurationVec_0_userDataUpperSize_string = "size16";
      UpperSizeConfig_size32 : _zz_configurationVec_0_userDataUpperSize_string = "size32";
      UpperSizeConfig_size48 : _zz_configurationVec_0_userDataUpperSize_string = "size48";
      UpperSizeConfig_size64 : _zz_configurationVec_0_userDataUpperSize_string = "size64";
      default : _zz_configurationVec_0_userDataUpperSize_string = "??????";
    endcase
  end
  always @(*) begin
    case(_zz_configurationVec_0_userDataUpperSize_1)
      UpperSizeConfig_size16 : _zz_configurationVec_0_userDataUpperSize_1_string = "size16";
      UpperSizeConfig_size32 : _zz_configurationVec_0_userDataUpperSize_1_string = "size32";
      UpperSizeConfig_size48 : _zz_configurationVec_0_userDataUpperSize_1_string = "size48";
      UpperSizeConfig_size64 : _zz_configurationVec_0_userDataUpperSize_1_string = "size64";
      default : _zz_configurationVec_0_userDataUpperSize_1_string = "??????";
    endcase
  end
  `endif

  assign ioBank = 8'h40;
  assign mapArea_config_userCode_0 = _zz_mapArea_config_userCode_0;
  assign mapArea_config_userCode_1 = _zz_mapArea_config_userCode_1;
  assign mapArea_config_userCode_2 = _zz_mapArea_config_userCode_2;
  assign mapArea_config_userCode_3 = _zz_mapArea_config_userCode_3;
  assign mapArea_config_userData_0 = _zz_mapArea_config_userData_0;
  assign mapArea_config_userData_1 = _zz_mapArea_config_userData_1;
  assign mapArea_config_userData_2 = _zz_mapArea_config_userData_2;
  assign mapArea_config_userData_3 = _zz_mapArea_config_userData_3;
  assign mapArea_config_userHarvard = _zz_mapArea_config_userHarvard;
  assign mapArea_config_userCodeUpperSize = _zz_mapArea_config_userCodeUpperSize;
  assign mapArea_config_userDataUpperSize = _zz_mapArea_config_userDataUpperSize;
  assign mapArea_config_systemCode = _zz_mapArea_config_systemCode;
  assign mapArea_config_systemData = _zz_mapArea_config_systemData;
  assign mapArea_config_systemHarvard = _zz_mapArea_config_systemHarvard;
  assign when_MMU_l90 = (io_mapSource == MapSource_cpu);
  always @(*) begin
    if(when_MMU_l90) begin
      if(io_mapIo) begin
        io_mapAddressOut = {ioBank[7 : 2],io_mapAddressIn};
      end else begin
        io_mapAddressOut = {((io_mapSystem && (switch_Misc_l211 == 2'b00)) ? (io_mapCode ? mapArea_config_systemCode : (mapArea_config_systemHarvard ? mapArea_config_systemData : mapArea_config_systemCode)) : (io_mapCode ? _zz_io_mapAddressOut_2 : (mapArea_config_userHarvard ? _zz_io_mapAddressOut_3 : _zz_io_mapAddressOut_2))),_zz_io_mapAddressOut_4};
      end
    end else begin
      if(when_MMU_l109) begin
        io_mapAddressOut = ({chipsetCharGen,14'h0} + _zz_io_mapAddressOut_5);
      end else begin
        io_mapAddressOut = 22'h0;
      end
    end
  end

  assign switch_Misc_l211 = io_mapAddressIn[15 : 14];
  always @(*) begin
    case(switch_Misc_l211)
      2'b00 : begin
        _zz_io_mapAddressOut = ((&mapArea_config_userCodeUpperSize) ? 2'b11 : 2'b00);
      end
      2'b01 : begin
        _zz_io_mapAddressOut = (_zz__zz_io_mapAddressOut[1] ? 2'b11 : 2'b01);
      end
      2'b10 : begin
        _zz_io_mapAddressOut = ((|mapArea_config_userCodeUpperSize) ? 2'b11 : 2'b10);
      end
      default : begin
        _zz_io_mapAddressOut = 2'b11;
      end
    endcase
  end

  always @(*) begin
    case(switch_Misc_l211)
      2'b00 : begin
        _zz_io_mapAddressOut_1 = ((&mapArea_config_userDataUpperSize) ? 2'b11 : 2'b00);
      end
      2'b01 : begin
        _zz_io_mapAddressOut_1 = (_zz__zz_io_mapAddressOut_1[1] ? 2'b11 : 2'b01);
      end
      2'b10 : begin
        _zz_io_mapAddressOut_1 = ((|mapArea_config_userDataUpperSize) ? 2'b11 : 2'b10);
      end
      default : begin
        _zz_io_mapAddressOut_1 = 2'b11;
      end
    endcase
  end

  assign _zz_io_mapAddressOut_2 = _zz__zz_io_mapAddressOut_2;
  assign when_MMU_l109 = (io_mapSource == MapSource_chipsetCharGen);
  assign ioArea_config_userCode_0 = _zz_ioArea_config_userCode_0;
  assign ioArea_config_userCode_1 = _zz_ioArea_config_userCode_1;
  assign ioArea_config_userCode_2 = _zz_ioArea_config_userCode_2;
  assign ioArea_config_userCode_3 = _zz_ioArea_config_userCode_3;
  assign ioArea_config_userData_0 = _zz_ioArea_config_userData_0;
  assign ioArea_config_userData_1 = _zz_ioArea_config_userData_1;
  assign ioArea_config_userData_2 = _zz_ioArea_config_userData_2;
  assign ioArea_config_userData_3 = _zz_ioArea_config_userData_3;
  assign ioArea_config_userHarvard = _zz_ioArea_config_userHarvard;
  assign ioArea_config_userCodeUpperSize = _zz_ioArea_config_userCodeUpperSize;
  assign ioArea_config_userDataUpperSize = _zz_ioArea_config_userDataUpperSize;
  assign ioArea_config_systemCode = _zz_ioArea_config_systemCode;
  assign ioArea_config_systemData = _zz_ioArea_config_systemData;
  assign ioArea_config_systemHarvard = _zz_ioArea_config_systemHarvard;
  assign _zz_1 = ({3'd0,1'b1} <<< updateIndex);
  assign _zz_2 = _zz_1[0];
  assign _zz_3 = _zz_1[1];
  assign _zz_4 = _zz_1[2];
  assign _zz_5 = _zz_1[3];
  assign _zz_ioArea_reg = io_regBus_address;
  assign ioArea_reg = _zz_ioArea_reg;
  assign when_MMU_l121 = (io_regBus_enable && io_regBus_write);
  assign _zz_configurationVec_0_userHarvard = io_regBus_dataFromMaster[0];
  assign _zz_configurationVec_0_systemHarvard = io_regBus_dataFromMaster[1];
  assign _zz_configurationVec_0_userCodeUpperSize_1 = io_regBus_dataFromMaster[3 : 2];
  assign _zz_configurationVec_0_userCodeUpperSize = _zz_configurationVec_0_userCodeUpperSize_1;
  assign _zz_configurationVec_0_userDataUpperSize_1 = io_regBus_dataFromMaster[5 : 4];
  assign _zz_configurationVec_0_userDataUpperSize = _zz_configurationVec_0_userDataUpperSize_1;
  assign when_MMU_l141 = io_regBus_dataFromMaster[7];
  assign when_MMU_l146 = io_regBus_dataFromMaster[6];
  assign io_regBus_dataToMaster = ioArea_regData;
  assign when_MMU_l161 = (io_regBus_enable && (! io_regBus_write));
  always @(*) begin
    case(ioArea_reg)
      Register_1_updateIndex : begin
        _zz_ioArea_regData = _zz__zz_ioArea_regData;
      end
      Register_1_configBits : begin
        _zz_ioArea_regData = {2'd0, _zz__zz_ioArea_regData_1};
      end
      Register_1_codeBank0 : begin
        _zz_ioArea_regData = ioArea_config_userCode_0;
      end
      Register_1_codeBank1 : begin
        _zz_ioArea_regData = ioArea_config_userCode_1;
      end
      Register_1_codeBank2 : begin
        _zz_ioArea_regData = ioArea_config_userCode_2;
      end
      Register_1_codeBank3 : begin
        _zz_ioArea_regData = ioArea_config_userCode_3;
      end
      Register_1_dataBank0 : begin
        _zz_ioArea_regData = ioArea_config_userData_0;
      end
      Register_1_dataBank1 : begin
        _zz_ioArea_regData = ioArea_config_userData_1;
      end
      Register_1_dataBank2 : begin
        _zz_ioArea_regData = ioArea_config_userData_2;
      end
      Register_1_dataBank3 : begin
        _zz_ioArea_regData = ioArea_config_userData_3;
      end
      Register_1_systemCodeBank : begin
        _zz_ioArea_regData = ioArea_config_systemCode;
      end
      Register_1_systemDataBank : begin
        _zz_ioArea_regData = ioArea_config_systemData;
      end
      Register_1_activeIndex : begin
        _zz_ioArea_regData = _zz__zz_ioArea_regData_2;
      end
      default : begin
        _zz_ioArea_regData = chipsetCharGen;
      end
    endcase
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      configurationVec_0_userCode_0 <= 8'h0;
      configurationVec_0_userCode_1 <= 8'h0;
      configurationVec_0_userCode_2 <= 8'h0;
      configurationVec_0_userCode_3 <= 8'h0;
      configurationVec_0_userData_0 <= 8'h0;
      configurationVec_0_userData_1 <= 8'h0;
      configurationVec_0_userData_2 <= 8'h0;
      configurationVec_0_userData_3 <= 8'h0;
      configurationVec_0_userHarvard <= 1'b0;
      configurationVec_0_userCodeUpperSize <= UpperSizeConfig_size16;
      configurationVec_0_userDataUpperSize <= UpperSizeConfig_size16;
      configurationVec_0_systemCode <= 8'h0;
      configurationVec_0_systemData <= 8'h0;
      configurationVec_0_systemHarvard <= 1'b0;
      configurationVec_1_userCode_0 <= 8'h0;
      configurationVec_1_userCode_1 <= 8'h0;
      configurationVec_1_userCode_2 <= 8'h0;
      configurationVec_1_userCode_3 <= 8'h0;
      configurationVec_1_userData_0 <= 8'h0;
      configurationVec_1_userData_1 <= 8'h0;
      configurationVec_1_userData_2 <= 8'h0;
      configurationVec_1_userData_3 <= 8'h0;
      configurationVec_1_userHarvard <= 1'b0;
      configurationVec_1_userCodeUpperSize <= UpperSizeConfig_size16;
      configurationVec_1_userDataUpperSize <= UpperSizeConfig_size16;
      configurationVec_1_systemCode <= 8'h0;
      configurationVec_1_systemData <= 8'h0;
      configurationVec_1_systemHarvard <= 1'b0;
      configurationVec_2_userCode_0 <= 8'h0;
      configurationVec_2_userCode_1 <= 8'h0;
      configurationVec_2_userCode_2 <= 8'h0;
      configurationVec_2_userCode_3 <= 8'h0;
      configurationVec_2_userData_0 <= 8'h0;
      configurationVec_2_userData_1 <= 8'h0;
      configurationVec_2_userData_2 <= 8'h0;
      configurationVec_2_userData_3 <= 8'h0;
      configurationVec_2_userHarvard <= 1'b0;
      configurationVec_2_userCodeUpperSize <= UpperSizeConfig_size16;
      configurationVec_2_userDataUpperSize <= UpperSizeConfig_size16;
      configurationVec_2_systemCode <= 8'h0;
      configurationVec_2_systemData <= 8'h0;
      configurationVec_2_systemHarvard <= 1'b0;
      configurationVec_3_userCode_0 <= 8'h0;
      configurationVec_3_userCode_1 <= 8'h0;
      configurationVec_3_userCode_2 <= 8'h0;
      configurationVec_3_userCode_3 <= 8'h0;
      configurationVec_3_userData_0 <= 8'h0;
      configurationVec_3_userData_1 <= 8'h0;
      configurationVec_3_userData_2 <= 8'h0;
      configurationVec_3_userData_3 <= 8'h0;
      configurationVec_3_userHarvard <= 1'b0;
      configurationVec_3_userCodeUpperSize <= UpperSizeConfig_size16;
      configurationVec_3_userDataUpperSize <= UpperSizeConfig_size16;
      configurationVec_3_systemCode <= 8'h0;
      configurationVec_3_systemData <= 8'h0;
      configurationVec_3_systemHarvard <= 1'b0;
      updateIndex <= 2'b00;
      activeIndex <= 2'b00;
      chipsetCharGen <= 8'h0;
    end else begin
      if(when_MMU_l121) begin
        case(ioArea_reg)
          Register_1_updateIndex : begin
            updateIndex <= io_regBus_dataFromMaster[1 : 0];
          end
          Register_1_configBits : begin
            if(_zz_2) begin
              configurationVec_0_userHarvard <= _zz_configurationVec_0_userHarvard;
            end
            if(_zz_3) begin
              configurationVec_1_userHarvard <= _zz_configurationVec_0_userHarvard;
            end
            if(_zz_4) begin
              configurationVec_2_userHarvard <= _zz_configurationVec_0_userHarvard;
            end
            if(_zz_5) begin
              configurationVec_3_userHarvard <= _zz_configurationVec_0_userHarvard;
            end
            if(_zz_2) begin
              configurationVec_0_systemHarvard <= _zz_configurationVec_0_systemHarvard;
            end
            if(_zz_3) begin
              configurationVec_1_systemHarvard <= _zz_configurationVec_0_systemHarvard;
            end
            if(_zz_4) begin
              configurationVec_2_systemHarvard <= _zz_configurationVec_0_systemHarvard;
            end
            if(_zz_5) begin
              configurationVec_3_systemHarvard <= _zz_configurationVec_0_systemHarvard;
            end
            if(_zz_2) begin
              configurationVec_0_userCodeUpperSize <= _zz_configurationVec_0_userCodeUpperSize;
            end
            if(_zz_3) begin
              configurationVec_1_userCodeUpperSize <= _zz_configurationVec_0_userCodeUpperSize;
            end
            if(_zz_4) begin
              configurationVec_2_userCodeUpperSize <= _zz_configurationVec_0_userCodeUpperSize;
            end
            if(_zz_5) begin
              configurationVec_3_userCodeUpperSize <= _zz_configurationVec_0_userCodeUpperSize;
            end
            if(_zz_2) begin
              configurationVec_0_userDataUpperSize <= _zz_configurationVec_0_userDataUpperSize;
            end
            if(_zz_3) begin
              configurationVec_1_userDataUpperSize <= _zz_configurationVec_0_userDataUpperSize;
            end
            if(_zz_4) begin
              configurationVec_2_userDataUpperSize <= _zz_configurationVec_0_userDataUpperSize;
            end
            if(_zz_5) begin
              configurationVec_3_userDataUpperSize <= _zz_configurationVec_0_userDataUpperSize;
            end
          end
          Register_1_codeBank0 : begin
            if(_zz_2) begin
              configurationVec_0_userCode_0 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userCode_0 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userCode_0 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userCode_0 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_codeBank1 : begin
            if(_zz_2) begin
              configurationVec_0_userCode_1 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userCode_1 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userCode_1 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userCode_1 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_codeBank2 : begin
            if(_zz_2) begin
              configurationVec_0_userCode_2 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userCode_2 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userCode_2 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userCode_2 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_codeBank3 : begin
            if(_zz_2) begin
              configurationVec_0_userCode_3 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userCode_3 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userCode_3 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userCode_3 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_dataBank0 : begin
            if(_zz_2) begin
              configurationVec_0_userData_0 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userData_0 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userData_0 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userData_0 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_dataBank1 : begin
            if(_zz_2) begin
              configurationVec_0_userData_1 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userData_1 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userData_1 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userData_1 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_dataBank2 : begin
            if(_zz_2) begin
              configurationVec_0_userData_2 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userData_2 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userData_2 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userData_2 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_dataBank3 : begin
            if(_zz_2) begin
              configurationVec_0_userData_3 <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_userData_3 <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_userData_3 <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_userData_3 <= io_regBus_dataFromMaster;
            end
          end
          Register_1_systemCodeBank : begin
            if(_zz_2) begin
              configurationVec_0_systemCode <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_systemCode <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_systemCode <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_systemCode <= io_regBus_dataFromMaster;
            end
          end
          Register_1_systemDataBank : begin
            if(_zz_2) begin
              configurationVec_0_systemData <= io_regBus_dataFromMaster;
            end
            if(_zz_3) begin
              configurationVec_1_systemData <= io_regBus_dataFromMaster;
            end
            if(_zz_4) begin
              configurationVec_2_systemData <= io_regBus_dataFromMaster;
            end
            if(_zz_5) begin
              configurationVec_3_systemData <= io_regBus_dataFromMaster;
            end
          end
          Register_1_activeIndex : begin
            if(when_MMU_l141) begin
              activeIndex <= io_regBus_dataFromMaster[1 : 0];
            end else begin
              if(when_MMU_l146) begin
                activeIndex <= configurationStack[7 : 6];
              end else begin
                activeIndex <= io_regBus_dataFromMaster[1 : 0];
              end
            end
          end
          default : begin
            chipsetCharGen <= io_regBus_dataFromMaster;
          end
        endcase
      end
    end
  end

  always @(posedge bus_clk) begin
    if(when_MMU_l121) begin
      case(ioArea_reg)
        Register_1_updateIndex : begin
        end
        Register_1_configBits : begin
        end
        Register_1_codeBank0 : begin
        end
        Register_1_codeBank1 : begin
        end
        Register_1_codeBank2 : begin
        end
        Register_1_codeBank3 : begin
        end
        Register_1_dataBank0 : begin
        end
        Register_1_dataBank1 : begin
        end
        Register_1_dataBank2 : begin
        end
        Register_1_dataBank3 : begin
        end
        Register_1_systemCodeBank : begin
        end
        Register_1_systemDataBank : begin
        end
        Register_1_activeIndex : begin
          if(when_MMU_l141) begin
            configurationStack[5 : 0] <= configurationStack[7 : 2];
            configurationStack[7 : 6] <= activeIndex;
          end else begin
            if(when_MMU_l146) begin
              configurationStack[7 : 2] <= configurationStack[5 : 0];
            end
          end
        end
        default : begin
        end
      endcase
    end
    if(when_MMU_l161) begin
      ioArea_regData <= _zz_ioArea_regData;
    end else begin
      ioArea_regData <= 8'h0;
    end
  end


endmodule

module CPU (
  input               io_irq,
  output              io_bus_enable,
  output              io_bus_write,
  output     [7:0]    io_bus_dataFromMaster,
  input      [7:0]    io_bus_dataToMaster,
  output     [15:0]   io_bus_address,
  output              io_io,
  output              io_code,
  output              io_system,
  input               bus_clk,
  input               bus_reset,
  input               when_ClockDomain_l353_regNext
);

  wire       [7:0]    cpu_1_io_dataOut;
  wire       [15:0]   cpu_1_io_address;
  wire                cpu_1_io_busEnable;
  wire                cpu_1_io_io;
  wire                cpu_1_io_code;
  wire                cpu_1_io_write;
  wire                cpu_1_io_int;

  RC811 cpu_1 (
    .io_nmi                           (1'b0                           ), //i
    .io_irq                           (io_irq                         ), //i
    .io_dataIn                        (io_bus_dataToMaster[7:0]       ), //i
    .io_dataOut                       (cpu_1_io_dataOut[7:0]          ), //o
    .io_address                       (cpu_1_io_address[15:0]         ), //o
    .io_busEnable                     (cpu_1_io_busEnable             ), //o
    .io_io                            (cpu_1_io_io                    ), //o
    .io_code                          (cpu_1_io_code                  ), //o
    .io_write                         (cpu_1_io_write                 ), //o
    .io_int                           (cpu_1_io_int                   ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  assign io_bus_address = cpu_1_io_address;
  assign io_bus_enable = cpu_1_io_busEnable;
  assign io_bus_write = cpu_1_io_write;
  assign io_bus_dataFromMaster = cpu_1_io_dataOut;
  assign io_io = cpu_1_io_io;
  assign io_code = cpu_1_io_code;
  assign io_system = cpu_1_io_int;

endmodule

module VideoFrame (
  input               io_pixelEnable,
  input      [10:0]   io_hPos,
  input      [8:0]    io_vPos,
  output     [7:0]    io_indexedColor
);


  assign io_indexedColor = ((io_pixelEnable && ((((io_hPos == 11'h0) || (io_hPos == 11'h34f)) || (io_vPos == 9'h0)) || (io_vPos == 9'h0ef))) ? 8'h01 : 8'h0);

endmodule

module VideoTileMode (
  input      [15:0]   io_charGenAddress,
  input      [3:0]    io_memBusCycle,
  input               io_vSync,
  input               io_hSync,
  input               io_hBlank,
  input               io_pixelEnable,
  input      [10:0]   io_hPos,
  input      [8:0]    io_vPos,
  output     [7:0]    io_indexedColor,
  output              io_attrBus_enable,
  input      [15:0]   io_attrBus_dataToMaster,
  output     [11:0]   io_attrBus_address,
  output reg          io_memBus_enable,
  input      [7:0]    io_memBus_dataToMaster,
  output reg [15:0]   io_memBus_address,
  input               io_regBus_enable,
  input               io_regBus_write,
  input      [7:0]    io_regBus_dataFromMaster,
  output     [7:0]    io_regBus_dataToMaster,
  input      [3:0]    io_regBus_address,
  input               bus_clk,
  input               bus_reset
);
  localparam Depth_colors2 = 2'd0;
  localparam Depth_colors4 = 2'd1;
  localparam Depth_colors16 = 2'd2;
  localparam Depth_colors256 = 2'd3;
  localparam Register_8_control = 4'd0;
  localparam Register_8_hPosL = 4'd1;
  localparam Register_8_hPosH = 4'd2;
  localparam Register_8_vPosL = 4'd3;
  localparam Register_8_vPosH = 4'd4;
  localparam Register_8_unused05 = 4'd5;
  localparam Register_8_unused06 = 4'd6;
  localparam Register_8_unused07 = 4'd7;
  localparam Register_8_unused08 = 4'd8;
  localparam Register_8_unused09 = 4'd9;
  localparam Register_8_unused0A = 4'd10;
  localparam Register_8_unused0B = 4'd11;
  localparam Register_8_unused0C = 4'd12;
  localparam Register_8_unused0D = 4'd13;
  localparam Register_8_unused0E = 4'd14;
  localparam Register_8_unused0F = 4'd15;

  wire       [8:0]    _zz_attrLine;
  wire       [10:0]   _zz_normalizedHPos;
  wire       [6:0]    _zz_attrXAddressHires;
  wire       [6:0]    _zz_attrXAddressHires_1;
  wire       [5:0]    _zz_attrXAddressLores;
  wire       [6:0]    _zz_attrXAddress;
  wire       [11:0]   _zz_io_attrBus_address;
  wire       [11:0]   _zz_io_attrBus_address_1;
  reg        [7:0]    _zz__zz_io_indexedColor;
  wire       [3:0]    _zz__zz_io_indexedColor_1;
  wire       [15:0]   _zz_io_memBus_address;
  wire       [13:0]   _zz_io_memBus_address_1;
  wire       [10:0]   _zz_io_memBus_address_2;
  wire       [8:0]    _zz_io_memBus_address_3;
  wire       [1:0]    _zz__zz_regData;
  wire       [0:0]    _zz__zz_regData_1;
  reg                 hires;
  reg                 textMode;
  reg        [1:0]    depth_1;
  reg        [1:0]    paletteHigh;
  reg                 io_hSync_regNext;
  wire                hsyncEdge;
  reg        [9:0]    hScrollPos;
  reg        [8:0]    vScrollPos;
  wire       [15:0]   shiftMask;
  wire       [2:0]    switch_Misc_l211;
  reg        [15:0]   fetchMask;
  wire       [15:0]   readyMask;
  wire       [3:0]    maskIndex;
  wire                dataShift;
  wire                dataFetch;
  wire                dataReady;
  reg        [8:0]    attrLine;
  wire       [10:0]   normalizedHPos;
  wire       [6:0]    attrXAddressHires;
  wire       [5:0]    attrXAddressLores;
  wire       [6:0]    attrXAddress;
  reg        [7:0]    attributes;
  reg        [7:0]    nextAttributes;
  reg                 flipx;
  reg                 flipy;
  reg                 priorityInvert;
  reg        [3:0]    colorXor;
  reg        [1:0]    palette;
  wire                hiresLastCharPixel;
  wire                loresLastCharPixel;
  wire                lastCharPixel;
  reg        [7:0]    charData;
  reg        [7:0]    nextCharData;
  wire       [7:0]    pixelData2Color;
  reg        [7:0]    pixelBuffer_0;
  reg        [7:0]    pixelBuffer_1;
  reg        [7:0]    pixelBuffer_2;
  reg        [7:0]    pixelBuffer_3;
  reg        [7:0]    pixelBuffer_4;
  reg        [7:0]    pixelBuffer_5;
  reg        [7:0]    pixelBuffer_6;
  reg        [7:0]    pixelBuffer_7;
  reg        [7:0]    pixelBuffer_8;
  reg        [7:0]    pixelBuffer_9;
  reg        [7:0]    pixelBuffer_10;
  reg        [7:0]    pixelBuffer_11;
  reg        [7:0]    pixelBuffer_12;
  reg        [7:0]    pixelBuffer_13;
  reg        [7:0]    pixelBuffer_14;
  reg        [7:0]    pixelBuffer_15;
  reg        [7:0]    _zz_io_indexedColor;
  reg        [7:0]    incomingCharData;
  reg        [2:0]    charDataSpill;
  reg        [2:0]    charDataSpillReg;
  wire                italic;
  wire                bold;
  wire                underline;
  wire       [7:0]    underlineCharData;
  wire       [8:0]    boldCharData;
  reg        [10:0]   italicCharData;
  wire                when_VideoTileMode_l196;
  wire                when_VideoTileMode_l198;
  wire       [10:0]   finalCharData;
  wire                when_VideoTileMode_l205;
  wire                when_VideoTileMode_l237;
  wire       [3:0]    switch_VideoTileMode_l240;
  wire       [3:0]    _zz_switch_VideoTileMode_l240;
  wire       [1:0]    _zz_depth;
  wire       [1:0]    _zz_depth_1;
  reg        [7:0]    regData;
  wire                when_VideoTileMode_l265;
  wire       [3:0]    switch_Misc_l211_1;
  wire       [3:0]    _zz_switch_Misc_l211;
  reg        [7:0]    _zz_regData;
  `ifndef SYNTHESIS
  reg [71:0] depth_1_string;
  reg [63:0] switch_VideoTileMode_l240_string;
  reg [63:0] _zz_switch_VideoTileMode_l240_string;
  reg [71:0] _zz_depth_string;
  reg [71:0] _zz_depth_1_string;
  reg [63:0] switch_Misc_l211_1_string;
  reg [63:0] _zz_switch_Misc_l211_string;
  `endif


  assign _zz_attrLine = (io_vPos + 9'h001);
  assign _zz_normalizedHPos = (io_hPos - 11'h370);
  assign _zz_attrXAddressHires = (normalizedHPos[9 : 3] + 7'h03);
  assign _zz_attrXAddressHires_1 = ({1'd0,hScrollPos[9 : 4]} <<< 1);
  assign _zz_attrXAddressLores = (normalizedHPos[9 : 4] + 6'h02);
  assign _zz_attrXAddress = {1'd0, attrXAddressLores};
  assign _zz_io_attrBus_address_1 = {attrLine[7 : 3],attrXAddress};
  assign _zz_io_attrBus_address = _zz_io_attrBus_address_1;
  assign _zz_io_memBus_address_1 = {(textMode ? _zz_io_memBus_address_2 : io_attrBus_dataToMaster[10 : 0]),attrLine[2 : 0]};
  assign _zz_io_memBus_address = {2'd0, _zz_io_memBus_address_1};
  assign _zz_io_memBus_address_3 = io_attrBus_dataToMaster[8 : 0];
  assign _zz_io_memBus_address_2 = {2'd0, _zz_io_memBus_address_3};
  assign _zz__zz_regData = hScrollPos[9 : 8];
  assign _zz__zz_regData_1 = vScrollPos[8];
  assign _zz__zz_io_indexedColor_1 = hScrollPos[3 : 0];
  always @(*) begin
    case(_zz__zz_io_indexedColor_1)
      4'b0000 : _zz__zz_io_indexedColor = pixelBuffer_0;
      4'b0001 : _zz__zz_io_indexedColor = pixelBuffer_1;
      4'b0010 : _zz__zz_io_indexedColor = pixelBuffer_2;
      4'b0011 : _zz__zz_io_indexedColor = pixelBuffer_3;
      4'b0100 : _zz__zz_io_indexedColor = pixelBuffer_4;
      4'b0101 : _zz__zz_io_indexedColor = pixelBuffer_5;
      4'b0110 : _zz__zz_io_indexedColor = pixelBuffer_6;
      4'b0111 : _zz__zz_io_indexedColor = pixelBuffer_7;
      4'b1000 : _zz__zz_io_indexedColor = pixelBuffer_8;
      4'b1001 : _zz__zz_io_indexedColor = pixelBuffer_9;
      4'b1010 : _zz__zz_io_indexedColor = pixelBuffer_10;
      4'b1011 : _zz__zz_io_indexedColor = pixelBuffer_11;
      4'b1100 : _zz__zz_io_indexedColor = pixelBuffer_12;
      4'b1101 : _zz__zz_io_indexedColor = pixelBuffer_13;
      4'b1110 : _zz__zz_io_indexedColor = pixelBuffer_14;
      default : _zz__zz_io_indexedColor = pixelBuffer_15;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(depth_1)
      Depth_colors2 : depth_1_string = "colors2  ";
      Depth_colors4 : depth_1_string = "colors4  ";
      Depth_colors16 : depth_1_string = "colors16 ";
      Depth_colors256 : depth_1_string = "colors256";
      default : depth_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(switch_VideoTileMode_l240)
      Register_8_control : switch_VideoTileMode_l240_string = "control ";
      Register_8_hPosL : switch_VideoTileMode_l240_string = "hPosL   ";
      Register_8_hPosH : switch_VideoTileMode_l240_string = "hPosH   ";
      Register_8_vPosL : switch_VideoTileMode_l240_string = "vPosL   ";
      Register_8_vPosH : switch_VideoTileMode_l240_string = "vPosH   ";
      Register_8_unused05 : switch_VideoTileMode_l240_string = "unused05";
      Register_8_unused06 : switch_VideoTileMode_l240_string = "unused06";
      Register_8_unused07 : switch_VideoTileMode_l240_string = "unused07";
      Register_8_unused08 : switch_VideoTileMode_l240_string = "unused08";
      Register_8_unused09 : switch_VideoTileMode_l240_string = "unused09";
      Register_8_unused0A : switch_VideoTileMode_l240_string = "unused0A";
      Register_8_unused0B : switch_VideoTileMode_l240_string = "unused0B";
      Register_8_unused0C : switch_VideoTileMode_l240_string = "unused0C";
      Register_8_unused0D : switch_VideoTileMode_l240_string = "unused0D";
      Register_8_unused0E : switch_VideoTileMode_l240_string = "unused0E";
      Register_8_unused0F : switch_VideoTileMode_l240_string = "unused0F";
      default : switch_VideoTileMode_l240_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_switch_VideoTileMode_l240)
      Register_8_control : _zz_switch_VideoTileMode_l240_string = "control ";
      Register_8_hPosL : _zz_switch_VideoTileMode_l240_string = "hPosL   ";
      Register_8_hPosH : _zz_switch_VideoTileMode_l240_string = "hPosH   ";
      Register_8_vPosL : _zz_switch_VideoTileMode_l240_string = "vPosL   ";
      Register_8_vPosH : _zz_switch_VideoTileMode_l240_string = "vPosH   ";
      Register_8_unused05 : _zz_switch_VideoTileMode_l240_string = "unused05";
      Register_8_unused06 : _zz_switch_VideoTileMode_l240_string = "unused06";
      Register_8_unused07 : _zz_switch_VideoTileMode_l240_string = "unused07";
      Register_8_unused08 : _zz_switch_VideoTileMode_l240_string = "unused08";
      Register_8_unused09 : _zz_switch_VideoTileMode_l240_string = "unused09";
      Register_8_unused0A : _zz_switch_VideoTileMode_l240_string = "unused0A";
      Register_8_unused0B : _zz_switch_VideoTileMode_l240_string = "unused0B";
      Register_8_unused0C : _zz_switch_VideoTileMode_l240_string = "unused0C";
      Register_8_unused0D : _zz_switch_VideoTileMode_l240_string = "unused0D";
      Register_8_unused0E : _zz_switch_VideoTileMode_l240_string = "unused0E";
      Register_8_unused0F : _zz_switch_VideoTileMode_l240_string = "unused0F";
      default : _zz_switch_VideoTileMode_l240_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_depth)
      Depth_colors2 : _zz_depth_string = "colors2  ";
      Depth_colors4 : _zz_depth_string = "colors4  ";
      Depth_colors16 : _zz_depth_string = "colors16 ";
      Depth_colors256 : _zz_depth_string = "colors256";
      default : _zz_depth_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_depth_1)
      Depth_colors2 : _zz_depth_1_string = "colors2  ";
      Depth_colors4 : _zz_depth_1_string = "colors4  ";
      Depth_colors16 : _zz_depth_1_string = "colors16 ";
      Depth_colors256 : _zz_depth_1_string = "colors256";
      default : _zz_depth_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(switch_Misc_l211_1)
      Register_8_control : switch_Misc_l211_1_string = "control ";
      Register_8_hPosL : switch_Misc_l211_1_string = "hPosL   ";
      Register_8_hPosH : switch_Misc_l211_1_string = "hPosH   ";
      Register_8_vPosL : switch_Misc_l211_1_string = "vPosL   ";
      Register_8_vPosH : switch_Misc_l211_1_string = "vPosH   ";
      Register_8_unused05 : switch_Misc_l211_1_string = "unused05";
      Register_8_unused06 : switch_Misc_l211_1_string = "unused06";
      Register_8_unused07 : switch_Misc_l211_1_string = "unused07";
      Register_8_unused08 : switch_Misc_l211_1_string = "unused08";
      Register_8_unused09 : switch_Misc_l211_1_string = "unused09";
      Register_8_unused0A : switch_Misc_l211_1_string = "unused0A";
      Register_8_unused0B : switch_Misc_l211_1_string = "unused0B";
      Register_8_unused0C : switch_Misc_l211_1_string = "unused0C";
      Register_8_unused0D : switch_Misc_l211_1_string = "unused0D";
      Register_8_unused0E : switch_Misc_l211_1_string = "unused0E";
      Register_8_unused0F : switch_Misc_l211_1_string = "unused0F";
      default : switch_Misc_l211_1_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_switch_Misc_l211)
      Register_8_control : _zz_switch_Misc_l211_string = "control ";
      Register_8_hPosL : _zz_switch_Misc_l211_string = "hPosL   ";
      Register_8_hPosH : _zz_switch_Misc_l211_string = "hPosH   ";
      Register_8_vPosL : _zz_switch_Misc_l211_string = "vPosL   ";
      Register_8_vPosH : _zz_switch_Misc_l211_string = "vPosH   ";
      Register_8_unused05 : _zz_switch_Misc_l211_string = "unused05";
      Register_8_unused06 : _zz_switch_Misc_l211_string = "unused06";
      Register_8_unused07 : _zz_switch_Misc_l211_string = "unused07";
      Register_8_unused08 : _zz_switch_Misc_l211_string = "unused08";
      Register_8_unused09 : _zz_switch_Misc_l211_string = "unused09";
      Register_8_unused0A : _zz_switch_Misc_l211_string = "unused0A";
      Register_8_unused0B : _zz_switch_Misc_l211_string = "unused0B";
      Register_8_unused0C : _zz_switch_Misc_l211_string = "unused0C";
      Register_8_unused0D : _zz_switch_Misc_l211_string = "unused0D";
      Register_8_unused0E : _zz_switch_Misc_l211_string = "unused0E";
      Register_8_unused0F : _zz_switch_Misc_l211_string = "unused0F";
      default : _zz_switch_Misc_l211_string = "????????";
    endcase
  end
  `endif

  assign hsyncEdge = (io_hSync && (! io_hSync_regNext));
  assign shiftMask = (hires ? 16'hffff : 16'h5555);
  assign switch_Misc_l211 = {hires,depth_1};
  always @(*) begin
    case(switch_Misc_l211)
      3'b000 : begin
        fetchMask = 16'h4000;
      end
      3'b001 : begin
        fetchMask = 16'h4040;
      end
      3'b010 : begin
        fetchMask = 16'h4444;
      end
      3'b011 : begin
        fetchMask = 16'h5555;
      end
      3'b100 : begin
        fetchMask = 16'h4040;
      end
      3'b101 : begin
        fetchMask = 16'h4444;
      end
      3'b110 : begin
        fetchMask = 16'h5555;
      end
      default : begin
        fetchMask = 16'h0;
      end
    endcase
  end

  assign readyMask = {fetchMask[1 : 0],fetchMask[15 : 2]};
  assign maskIndex = (~ io_memBusCycle);
  assign dataShift = shiftMask[maskIndex];
  assign dataFetch = fetchMask[maskIndex];
  assign dataReady = readyMask[maskIndex];
  assign normalizedHPos = (io_hBlank ? _zz_normalizedHPos : io_hPos);
  assign attrXAddressHires = (_zz_attrXAddressHires + _zz_attrXAddressHires_1);
  assign attrXAddressLores = (_zz_attrXAddressLores + hScrollPos[9 : 4]);
  assign attrXAddress = (hires ? attrXAddressHires : _zz_attrXAddress);
  assign io_attrBus_address = _zz_io_attrBus_address;
  assign io_attrBus_enable = 1'b1;
  always @(*) begin
    if(textMode) begin
      colorXor = attributes[7 : 4];
    end else begin
      colorXor = 4'b0000;
    end
  end

  always @(*) begin
    if(textMode) begin
      palette = 2'b00;
    end else begin
      palette = attributes[7 : 6];
    end
  end

  always @(*) begin
    if(textMode) begin
      flipx = 1'b0;
    end else begin
      flipx = attributes[4];
    end
  end

  always @(*) begin
    if(textMode) begin
      flipy = 1'b0;
    end else begin
      flipy = attributes[5];
    end
  end

  always @(*) begin
    if(textMode) begin
      priorityInvert = 1'b0;
    end else begin
      priorityInvert = attributes[3];
    end
  end

  assign hiresLastCharPixel = (normalizedHPos[2 : 0] == 3'b111);
  assign loresLastCharPixel = (normalizedHPos[3 : 0] == 4'b1111);
  assign lastCharPixel = (hires ? hiresLastCharPixel : loresLastCharPixel);
  assign pixelData2Color = {{paletteHigh,palette},({3'b000,charData[7]} ^ colorXor)};
  always @(*) begin
    case(io_pixelEnable)
      1'b0 : begin
        _zz_io_indexedColor = 8'h0;
      end
      default : begin
        _zz_io_indexedColor = _zz__zz_io_indexedColor;
      end
    endcase
  end

  assign io_indexedColor = _zz_io_indexedColor;
  assign italic = nextAttributes[3];
  assign bold = nextAttributes[2];
  assign underline = nextAttributes[1];
  assign underlineCharData = ((underline && (attrLine[2 : 0] == 3'b111)) ? 8'hff : io_memBus_dataToMaster);
  assign boldCharData = ({underlineCharData,1'b0} | (bold ? {1'b0,underlineCharData} : 9'h0));
  assign when_VideoTileMode_l196 = (italic && (attrLine[2 : 0] <= 3'b010));
  always @(*) begin
    if(when_VideoTileMode_l196) begin
      italicCharData = {2'b00,boldCharData};
    end else begin
      if(when_VideoTileMode_l198) begin
        italicCharData = {{1'b0,boldCharData},1'b0};
      end else begin
        italicCharData = {boldCharData,2'b00};
      end
    end
  end

  assign when_VideoTileMode_l198 = (italic && (attrLine[2 : 0] <= 3'b100));
  assign finalCharData = {(charDataSpillReg | italicCharData[10 : 8]),italicCharData[7 : 0]};
  assign when_VideoTileMode_l205 = (textMode && (depth_1 == Depth_colors2));
  always @(*) begin
    if(when_VideoTileMode_l205) begin
      charDataSpill = finalCharData[2 : 0];
    end else begin
      charDataSpill = 3'b000;
    end
  end

  always @(*) begin
    if(when_VideoTileMode_l205) begin
      incomingCharData = finalCharData[10 : 3];
    end else begin
      incomingCharData = io_memBus_dataToMaster;
    end
  end

  always @(*) begin
    io_memBus_enable = 1'b0;
    if(dataFetch) begin
      io_memBus_enable = 1'b1;
    end
  end

  always @(*) begin
    io_memBus_address = 16'h0;
    if(dataFetch) begin
      io_memBus_address = (io_charGenAddress + _zz_io_memBus_address);
    end
  end

  assign when_VideoTileMode_l237 = (io_regBus_enable && io_regBus_write);
  assign _zz_switch_VideoTileMode_l240 = io_regBus_address;
  assign switch_VideoTileMode_l240 = _zz_switch_VideoTileMode_l240;
  assign _zz_depth_1 = io_regBus_dataFromMaster[7 : 6];
  assign _zz_depth = _zz_depth_1;
  assign io_regBus_dataToMaster = regData;
  assign when_VideoTileMode_l265 = (io_regBus_enable && (! io_regBus_write));
  assign _zz_switch_Misc_l211 = io_regBus_address;
  assign switch_Misc_l211_1 = _zz_switch_Misc_l211;
  always @(*) begin
    case(switch_Misc_l211_1)
      Register_8_control : begin
        _zz_regData = {{{{{depth_1,paletteHigh},1'b0},textMode},hires},1'b0};
      end
      Register_8_hPosL : begin
        _zz_regData = hScrollPos[7 : 0];
      end
      Register_8_hPosH : begin
        _zz_regData = {6'd0, _zz__zz_regData};
      end
      Register_8_vPosL : begin
        _zz_regData = vScrollPos[7 : 0];
      end
      Register_8_vPosH : begin
        _zz_regData = {7'd0, _zz__zz_regData_1};
      end
      default : begin
        _zz_regData = 8'h0;
      end
    endcase
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      hires <= 1'b0;
      textMode <= 1'b1;
      depth_1 <= Depth_colors2;
      io_hSync_regNext <= 1'b0;
      hScrollPos <= 10'h0;
      vScrollPos <= 9'h0;
      attributes <= 8'h0;
      nextAttributes <= 8'h0;
      charData <= 8'h0;
      nextCharData <= 8'h0;
    end else begin
      io_hSync_regNext <= io_hSync;
      if(lastCharPixel) begin
        charData <= nextCharData;
        attributes <= nextAttributes;
      end else begin
        if(dataShift) begin
          charData <= (charData <<< 1);
        end
      end
      if(dataReady) begin
        nextCharData <= incomingCharData;
      end
      if(dataFetch) begin
        nextAttributes <= io_attrBus_dataToMaster[15 : 8];
      end
      if(when_VideoTileMode_l237) begin
        case(switch_VideoTileMode_l240)
          Register_8_control : begin
            depth_1 <= _zz_depth;
            textMode <= io_regBus_dataFromMaster[2];
            hires <= io_regBus_dataFromMaster[1];
          end
          Register_8_hPosL : begin
            hScrollPos[7 : 0] <= io_regBus_dataFromMaster;
          end
          Register_8_hPosH : begin
            hScrollPos[9 : 8] <= io_regBus_dataFromMaster[1 : 0];
          end
          Register_8_vPosL : begin
            vScrollPos[7 : 0] <= io_regBus_dataFromMaster;
          end
          Register_8_vPosH : begin
            vScrollPos[8] <= io_regBus_dataFromMaster[0];
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(posedge bus_clk) begin
    if(hsyncEdge) begin
      attrLine <= (_zz_attrLine + vScrollPos);
    end
    pixelBuffer_0 <= pixelBuffer_1;
    pixelBuffer_1 <= pixelBuffer_2;
    pixelBuffer_2 <= pixelBuffer_3;
    pixelBuffer_3 <= pixelBuffer_4;
    pixelBuffer_4 <= pixelBuffer_5;
    pixelBuffer_5 <= pixelBuffer_6;
    pixelBuffer_6 <= pixelBuffer_7;
    pixelBuffer_7 <= pixelBuffer_8;
    pixelBuffer_8 <= pixelBuffer_9;
    pixelBuffer_9 <= pixelBuffer_10;
    pixelBuffer_10 <= pixelBuffer_11;
    pixelBuffer_11 <= pixelBuffer_12;
    pixelBuffer_12 <= pixelBuffer_13;
    pixelBuffer_13 <= pixelBuffer_14;
    pixelBuffer_14 <= pixelBuffer_15;
    pixelBuffer_15 <= pixelData2Color;
    if(dataReady) begin
      charDataSpillReg <= charDataSpill;
    end
    if(when_VideoTileMode_l237) begin
      case(switch_VideoTileMode_l240)
        Register_8_control : begin
          paletteHigh <= io_regBus_dataFromMaster[5 : 4];
        end
        default : begin
        end
      endcase
    end
    if(when_VideoTileMode_l265) begin
      regData <= _zz_regData;
    end else begin
      regData <= 8'h0;
    end
  end


endmodule

module ScanDoubler (
  input               io_pixelEnableIn,
  input      [10:0]   io_hPosIn,
  input      [7:0]    io_vPosIn,
  input      [4:0]    io_redIn,
  input      [4:0]    io_greenIn,
  input      [4:0]    io_blueIn,
  input      [10:0]   io_hPosOut,
  input      [8:0]    io_vPosOut,
  output     [4:0]    io_redOut,
  output     [4:0]    io_greenOut,
  output     [4:0]    io_blueOut,
  input               bus_clk,
  input               dbl_clk
);

  wire                scanlineBuffer0_ena;
  wire       [9:0]    scanlineBuffer0_addra;
  wire       [14:0]   scanlineBuffer0_dina;
  wire                scanlineBuffer0_enb;
  wire       [9:0]    scanlineBuffer0_addrb;
  wire                scanlineBuffer1_ena;
  wire       [9:0]    scanlineBuffer1_addra;
  wire       [14:0]   scanlineBuffer1_dina;
  wire                scanlineBuffer1_enb;
  wire       [9:0]    scanlineBuffer1_addrb;
  wire       [14:0]   scanlineBuffer0_doutb;
  wire       [14:0]   scanlineBuffer1_doutb;
  wire                writeBuffer;
  wire                readBuffer;
  wire       [14:0]   doubleArea_rgbOut;

  ScanlineMemory scanlineBuffer0 (
    .clka     (bus_clk                      ), //i
    .ena      (scanlineBuffer0_ena          ), //i
    .wea      (io_pixelEnableIn             ), //i
    .addra    (scanlineBuffer0_addra[9:0]   ), //i
    .dina     (scanlineBuffer0_dina[14:0]   ), //i
    .clkb     (dbl_clk                      ), //i
    .enb      (scanlineBuffer0_enb          ), //i
    .addrb    (scanlineBuffer0_addrb[9:0]   ), //i
    .doutb    (scanlineBuffer0_doutb[14:0]  )  //o
  );
  ScanlineMemory scanlineBuffer1 (
    .clka     (bus_clk                      ), //i
    .ena      (scanlineBuffer1_ena          ), //i
    .wea      (io_pixelEnableIn             ), //i
    .addra    (scanlineBuffer1_addra[9:0]   ), //i
    .dina     (scanlineBuffer1_dina[14:0]   ), //i
    .clkb     (dbl_clk                      ), //i
    .enb      (scanlineBuffer1_enb          ), //i
    .addrb    (scanlineBuffer1_addrb[9:0]   ), //i
    .doutb    (scanlineBuffer1_doutb[14:0]  )  //o
  );
  assign writeBuffer = io_vPosIn[0];
  assign readBuffer = io_vPosOut[1];
  assign scanlineBuffer0_ena = (writeBuffer == 1'b1);
  assign scanlineBuffer0_addra = io_hPosIn[9 : 0];
  assign scanlineBuffer0_dina = {{io_redIn,io_greenIn},io_blueIn};
  assign scanlineBuffer1_ena = (writeBuffer == 1'b0);
  assign scanlineBuffer1_addra = io_hPosIn[9 : 0];
  assign scanlineBuffer1_dina = {{io_redIn,io_greenIn},io_blueIn};
  assign scanlineBuffer0_enb = (readBuffer == 1'b1);
  assign scanlineBuffer0_addrb = io_hPosOut[9 : 0];
  assign scanlineBuffer1_enb = (readBuffer == 1'b0);
  assign scanlineBuffer1_addrb = io_hPosOut[9 : 0];
  assign doubleArea_rgbOut = (readBuffer ? scanlineBuffer0_doutb : scanlineBuffer1_doutb);
  assign io_redOut = doubleArea_rgbOut[14 : 10];
  assign io_greenOut = doubleArea_rgbOut[9 : 5];
  assign io_blueOut = doubleArea_rgbOut[4 : 0];

endmodule

module VideoSync_1 (
  input      [10:0]   io_hDisp,
  input      [10:0]   io_hSyncStart,
  input      [10:0]   io_hSyncEnd,
  input      [10:0]   io_hEnd,
  input      [8:0]    io_vDisp,
  input      [8:0]    io_vSyncStart,
  input      [8:0]    io_vSyncEnd,
  input      [8:0]    io_vEnd,
  output              io_hSync,
  output              io_vSync,
  output              io_hBlanking,
  output              io_vBlanking,
  output     [10:0]   io_hPos,
  output     [8:0]    io_vPos,
  output              io_pixelEnable,
  input               dbl_clk,
  input               dbl_reset
);

  reg        [10:0]   hPosReg;
  reg        [8:0]    vPosReg;
  wire                when_VideoSync_l50;
  wire                when_VideoSync_l52;

  assign when_VideoSync_l50 = (hPosReg == io_hEnd);
  assign when_VideoSync_l52 = (vPosReg == io_vEnd);
  assign io_hSync = ((io_hSyncStart <= hPosReg) && (hPosReg < io_hSyncEnd));
  assign io_vSync = ((io_vSyncStart <= vPosReg) && (vPosReg < io_vSyncEnd));
  assign io_hPos = hPosReg;
  assign io_vPos = vPosReg;
  assign io_hBlanking = (io_hDisp <= hPosReg);
  assign io_vBlanking = (io_vDisp <= vPosReg);
  assign io_pixelEnable = (! (io_hBlanking || io_vBlanking));
  always @(posedge dbl_clk or posedge dbl_reset) begin
    if(dbl_reset) begin
      hPosReg <= 11'h36e;
      vPosReg <= 9'h1fd;
    end else begin
      if(when_VideoSync_l50) begin
        hPosReg <= 11'h0;
        if(when_VideoSync_l52) begin
          vPosReg <= 9'h0;
        end else begin
          vPosReg <= (vPosReg + 9'h001);
        end
      end else begin
        hPosReg <= (hPosReg + 11'h001);
      end
    end
  end


endmodule

module VideoSync (
  input      [10:0]   io_hDisp,
  input      [10:0]   io_hSyncStart,
  input      [10:0]   io_hSyncEnd,
  input      [10:0]   io_hEnd,
  input      [8:0]    io_vDisp,
  input      [8:0]    io_vSyncStart,
  input      [8:0]    io_vSyncEnd,
  input      [8:0]    io_vEnd,
  output              io_hSync,
  output              io_vSync,
  output              io_hBlanking,
  output              io_vBlanking,
  output     [10:0]   io_hPos,
  output     [8:0]    io_vPos,
  output              io_pixelEnable,
  input               bus_clk,
  input               bus_reset
);

  reg        [10:0]   hPosReg;
  reg        [8:0]    vPosReg;
  wire                when_VideoSync_l50;
  wire                when_VideoSync_l52;

  assign when_VideoSync_l50 = (hPosReg == io_hEnd);
  assign when_VideoSync_l52 = (vPosReg == io_vEnd);
  assign io_hSync = ((io_hSyncStart <= hPosReg) && (hPosReg < io_hSyncEnd));
  assign io_vSync = ((io_vSyncStart <= vPosReg) && (vPosReg < io_vSyncEnd));
  assign io_hPos = hPosReg;
  assign io_vPos = vPosReg;
  assign io_hBlanking = (io_hDisp <= hPosReg);
  assign io_vBlanking = (io_vDisp <= vPosReg);
  assign io_pixelEnable = (! (io_hBlanking || io_vBlanking));
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      hPosReg <= 11'h0;
      vPosReg <= 9'h0;
    end else begin
      if(when_VideoSync_l50) begin
        hPosReg <= 11'h0;
        if(when_VideoSync_l52) begin
          vPosReg <= 9'h0;
        end else begin
          vPosReg <= (vPosReg + 9'h001);
        end
      end else begin
        hPosReg <= (hPosReg + 11'h001);
      end
    end
  end


endmodule

//StreamFifo_1 replaced by StreamFifo_1

module StreamFifo_1 (
  input               io_push_valid,
  output              io_push_ready,
  input      [7:0]    io_push_payload,
  output              io_pop_valid,
  input               io_pop_ready,
  output     [7:0]    io_pop_payload,
  input               io_flush,
  output     [4:0]    io_occupancy,
  output     [4:0]    io_availability,
  input               bus_clk,
  input               bus_reset
);

  reg        [7:0]    _zz_logic_ram_port0;
  wire       [3:0]    _zz_logic_pushPtr_valueNext;
  wire       [0:0]    _zz_logic_pushPtr_valueNext_1;
  wire       [3:0]    _zz_logic_popPtr_valueNext;
  wire       [0:0]    _zz_logic_popPtr_valueNext_1;
  wire                _zz_logic_ram_port;
  wire                _zz_io_pop_payload;
  wire       [3:0]    _zz_io_availability;
  reg                 _zz_1;
  reg                 logic_pushPtr_willIncrement;
  reg                 logic_pushPtr_willClear;
  reg        [3:0]    logic_pushPtr_valueNext;
  reg        [3:0]    logic_pushPtr_value;
  wire                logic_pushPtr_willOverflowIfInc;
  wire                logic_pushPtr_willOverflow;
  reg                 logic_popPtr_willIncrement;
  reg                 logic_popPtr_willClear;
  reg        [3:0]    logic_popPtr_valueNext;
  reg        [3:0]    logic_popPtr_value;
  wire                logic_popPtr_willOverflowIfInc;
  wire                logic_popPtr_willOverflow;
  wire                logic_ptrMatch;
  reg                 logic_risingOccupancy;
  wire                logic_pushing;
  wire                logic_popping;
  wire                logic_empty;
  wire                logic_full;
  reg                 _zz_io_pop_valid;
  wire                when_Stream_l954;
  wire       [3:0]    logic_ptrDif;
  reg [7:0] logic_ram [0:15];

  assign _zz_logic_pushPtr_valueNext_1 = logic_pushPtr_willIncrement;
  assign _zz_logic_pushPtr_valueNext = {3'd0, _zz_logic_pushPtr_valueNext_1};
  assign _zz_logic_popPtr_valueNext_1 = logic_popPtr_willIncrement;
  assign _zz_logic_popPtr_valueNext = {3'd0, _zz_logic_popPtr_valueNext_1};
  assign _zz_io_availability = (logic_popPtr_value - logic_pushPtr_value);
  assign _zz_io_pop_payload = 1'b1;
  always @(posedge bus_clk) begin
    if(_zz_io_pop_payload) begin
      _zz_logic_ram_port0 <= logic_ram[logic_popPtr_valueNext];
    end
  end

  always @(posedge bus_clk) begin
    if(_zz_1) begin
      logic_ram[logic_pushPtr_value] <= io_push_payload;
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_pushing) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willIncrement = 1'b0;
    if(logic_pushing) begin
      logic_pushPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_pushPtr_willClear = 1'b1;
    end
  end

  assign logic_pushPtr_willOverflowIfInc = (logic_pushPtr_value == 4'b1111);
  assign logic_pushPtr_willOverflow = (logic_pushPtr_willOverflowIfInc && logic_pushPtr_willIncrement);
  always @(*) begin
    logic_pushPtr_valueNext = (logic_pushPtr_value + _zz_logic_pushPtr_valueNext);
    if(logic_pushPtr_willClear) begin
      logic_pushPtr_valueNext = 4'b0000;
    end
  end

  always @(*) begin
    logic_popPtr_willIncrement = 1'b0;
    if(logic_popping) begin
      logic_popPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_popPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_popPtr_willClear = 1'b1;
    end
  end

  assign logic_popPtr_willOverflowIfInc = (logic_popPtr_value == 4'b1111);
  assign logic_popPtr_willOverflow = (logic_popPtr_willOverflowIfInc && logic_popPtr_willIncrement);
  always @(*) begin
    logic_popPtr_valueNext = (logic_popPtr_value + _zz_logic_popPtr_valueNext);
    if(logic_popPtr_willClear) begin
      logic_popPtr_valueNext = 4'b0000;
    end
  end

  assign logic_ptrMatch = (logic_pushPtr_value == logic_popPtr_value);
  assign logic_pushing = (io_push_valid && io_push_ready);
  assign logic_popping = (io_pop_valid && io_pop_ready);
  assign logic_empty = (logic_ptrMatch && (! logic_risingOccupancy));
  assign logic_full = (logic_ptrMatch && logic_risingOccupancy);
  assign io_push_ready = (! logic_full);
  assign io_pop_valid = ((! logic_empty) && (! (_zz_io_pop_valid && (! logic_full))));
  assign io_pop_payload = _zz_logic_ram_port0;
  assign when_Stream_l954 = (logic_pushing != logic_popping);
  assign logic_ptrDif = (logic_pushPtr_value - logic_popPtr_value);
  assign io_occupancy = {(logic_risingOccupancy && logic_ptrMatch),logic_ptrDif};
  assign io_availability = {((! logic_risingOccupancy) && logic_ptrMatch),_zz_io_availability};
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      logic_pushPtr_value <= 4'b0000;
      logic_popPtr_value <= 4'b0000;
      logic_risingOccupancy <= 1'b0;
      _zz_io_pop_valid <= 1'b0;
    end else begin
      logic_pushPtr_value <= logic_pushPtr_valueNext;
      logic_popPtr_value <= logic_popPtr_valueNext;
      _zz_io_pop_valid <= (logic_popPtr_valueNext == logic_pushPtr_value);
      if(when_Stream_l954) begin
        logic_risingOccupancy <= logic_pushing;
      end
      if(io_flush) begin
        logic_risingOccupancy <= 1'b0;
      end
    end
  end


endmodule

module UartCtrl (
  input      [2:0]    io_config_frame_dataLength,
  input      [0:0]    io_config_frame_stop,
  input      [1:0]    io_config_frame_parity,
  input      [19:0]   io_config_clockDivider,
  input               io_write_valid,
  output reg          io_write_ready,
  input      [7:0]    io_write_payload,
  output              io_read_valid,
  input               io_read_ready,
  output     [7:0]    io_read_payload,
  output              io_uart_txd,
  input               io_uart_rxd,
  output              io_readError,
  input               io_writeBreak,
  output              io_readBreak,
  input               bus_clk,
  input               bus_reset
);
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;

  wire                tx_io_write_ready;
  wire                tx_io_txd;
  wire                rx_io_read_valid;
  wire       [7:0]    rx_io_read_payload;
  wire                rx_io_rts;
  wire                rx_io_error;
  wire                rx_io_break;
  reg        [19:0]   clockDivider_counter;
  wire                clockDivider_tick;
  reg                 clockDivider_tickReg;
  reg                 io_write_thrown_valid;
  wire                io_write_thrown_ready;
  wire       [7:0]    io_write_thrown_payload;
  `ifndef SYNTHESIS
  reg [23:0] io_config_frame_stop_string;
  reg [31:0] io_config_frame_parity_string;
  `endif


  UartCtrlTx tx (
    .io_configFrame_dataLength    (io_config_frame_dataLength[2:0]  ), //i
    .io_configFrame_stop          (io_config_frame_stop             ), //i
    .io_configFrame_parity        (io_config_frame_parity[1:0]      ), //i
    .io_samplingTick              (clockDivider_tickReg             ), //i
    .io_write_valid               (io_write_thrown_valid            ), //i
    .io_write_ready               (tx_io_write_ready                ), //o
    .io_write_payload             (io_write_thrown_payload[7:0]     ), //i
    .io_cts                       (1'b0                             ), //i
    .io_txd                       (tx_io_txd                        ), //o
    .io_break                     (io_writeBreak                    ), //i
    .bus_clk                      (bus_clk                          ), //i
    .bus_reset                    (bus_reset                        )  //i
  );
  UartCtrlRx rx (
    .io_configFrame_dataLength    (io_config_frame_dataLength[2:0]  ), //i
    .io_configFrame_stop          (io_config_frame_stop             ), //i
    .io_configFrame_parity        (io_config_frame_parity[1:0]      ), //i
    .io_samplingTick              (clockDivider_tickReg             ), //i
    .io_read_valid                (rx_io_read_valid                 ), //o
    .io_read_ready                (io_read_ready                    ), //i
    .io_read_payload              (rx_io_read_payload[7:0]          ), //o
    .io_rxd                       (io_uart_rxd                      ), //i
    .io_rts                       (rx_io_rts                        ), //o
    .io_error                     (rx_io_error                      ), //o
    .io_break                     (rx_io_break                      ), //o
    .bus_clk                      (bus_clk                          ), //i
    .bus_reset                    (bus_reset                        )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_config_frame_stop)
      UartStopType_ONE : io_config_frame_stop_string = "ONE";
      UartStopType_TWO : io_config_frame_stop_string = "TWO";
      default : io_config_frame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_config_frame_parity)
      UartParityType_NONE : io_config_frame_parity_string = "NONE";
      UartParityType_EVEN : io_config_frame_parity_string = "EVEN";
      UartParityType_ODD : io_config_frame_parity_string = "ODD ";
      default : io_config_frame_parity_string = "????";
    endcase
  end
  `endif

  assign clockDivider_tick = (clockDivider_counter == 20'h0);
  always @(*) begin
    io_write_thrown_valid = io_write_valid;
    if(rx_io_break) begin
      io_write_thrown_valid = 1'b0;
    end
  end

  always @(*) begin
    io_write_ready = io_write_thrown_ready;
    if(rx_io_break) begin
      io_write_ready = 1'b1;
    end
  end

  assign io_write_thrown_payload = io_write_payload;
  assign io_write_thrown_ready = tx_io_write_ready;
  assign io_read_valid = rx_io_read_valid;
  assign io_read_payload = rx_io_read_payload;
  assign io_uart_txd = tx_io_txd;
  assign io_readError = rx_io_error;
  assign io_readBreak = rx_io_break;
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      clockDivider_counter <= 20'h0;
      clockDivider_tickReg <= 1'b0;
    end else begin
      clockDivider_tickReg <= clockDivider_tick;
      clockDivider_counter <= (clockDivider_counter - 20'h00001);
      if(clockDivider_tick) begin
        clockDivider_counter <= io_config_clockDivider;
      end
    end
  end


endmodule

module DividerUnit32x32 (
  input               io_signed,
  input               io_restart,
  input      [63:0]   io_dividend,
  input      [31:0]   io_divisor,
  output     [31:0]   io_quotient,
  output     [31:0]   io_remainder,
  output              io_ready,
  input               bus_clk,
  input               bus_reset
);

  wire       [63:0]   divider_io_dividend;
  wire       [31:0]   divider_io_divisor;
  wire       [31:0]   divider_io_quotient;
  wire       [31:0]   divider_io_remainder;
  wire                divider_io_ready;
  wire       [63:0]   _zz_io_dividend_1;
  wire       [63:0]   _zz_io_dividend_2;
  wire       [63:0]   _zz_io_dividend_3;
  wire       [63:0]   _zz_io_dividend_4;
  wire       [0:0]    _zz_io_dividend_5;
  wire       [31:0]   _zz_io_divisor_1;
  wire       [31:0]   _zz_io_divisor_2;
  wire       [31:0]   _zz_io_divisor_3;
  wire       [31:0]   _zz_io_divisor_4;
  wire       [0:0]    _zz_io_divisor_5;
  wire       [31:0]   _zz_io_quotient;
  wire       [31:0]   _zz_io_quotient_1;
  wire       [31:0]   _zz_io_quotient_2;
  wire       [31:0]   _zz_io_quotient_3;
  wire       [63:0]   _zz_io_dividend;
  wire       [31:0]   _zz_io_divisor;
  wire                negateResult;

  assign _zz_io_dividend_1 = (_zz_io_dividend_2 + _zz_io_dividend_4);
  assign _zz_io_dividend_2 = (_zz_io_dividend[63] ? _zz_io_dividend_3 : _zz_io_dividend);
  assign _zz_io_dividend_3 = (~ _zz_io_dividend);
  assign _zz_io_dividend_5 = _zz_io_dividend[63];
  assign _zz_io_dividend_4 = {63'd0, _zz_io_dividend_5};
  assign _zz_io_divisor_1 = (_zz_io_divisor_2 + _zz_io_divisor_4);
  assign _zz_io_divisor_2 = (_zz_io_divisor[31] ? _zz_io_divisor_3 : _zz_io_divisor);
  assign _zz_io_divisor_3 = (~ _zz_io_divisor);
  assign _zz_io_divisor_5 = _zz_io_divisor[31];
  assign _zz_io_divisor_4 = {31'd0, _zz_io_divisor_5};
  assign _zz_io_quotient = (negateResult ? _zz_io_quotient_1 : _zz_io_quotient_3);
  assign _zz_io_quotient_1 = (- _zz_io_quotient_2);
  assign _zz_io_quotient_2 = divider_io_quotient;
  assign _zz_io_quotient_3 = divider_io_quotient;
  UnsignedDividerUnit32x32 divider (
    .io_restart      (io_restart                  ), //i
    .io_dividend     (divider_io_dividend[63:0]   ), //i
    .io_divisor      (divider_io_divisor[31:0]    ), //i
    .io_quotient     (divider_io_quotient[31:0]   ), //o
    .io_remainder    (divider_io_remainder[31:0]  ), //o
    .io_ready        (divider_io_ready            ), //o
    .bus_clk         (bus_clk                     ), //i
    .bus_reset       (bus_reset                   )  //i
  );
  assign _zz_io_dividend = io_dividend;
  assign divider_io_dividend = (io_signed ? _zz_io_dividend_1 : io_dividend);
  assign _zz_io_divisor = io_divisor;
  assign divider_io_divisor = (io_signed ? _zz_io_divisor_1 : io_divisor);
  assign negateResult = (io_signed && (io_dividend[63] ^ io_divisor[31]));
  assign io_quotient = _zz_io_quotient;
  assign io_remainder = divider_io_remainder;
  assign io_ready = divider_io_ready;

endmodule

module MultiplierUnit32x32 (
  input               io_signed,
  input               io_restart,
  input      [31:0]   io_operand1,
  input      [31:0]   io_operand2,
  output     [63:0]   io_result,
  output              io_ready,
  input               bus_clk,
  input               bus_reset
);

  wire       [31:0]   multiplier_io_operand1;
  wire       [31:0]   multiplier_io_operand2;
  wire       [63:0]   multiplier_io_result;
  wire                multiplier_io_ready;
  wire       [31:0]   _zz_io_operand1_1;
  wire       [31:0]   _zz_io_operand1_2;
  wire       [31:0]   _zz_io_operand1_3;
  wire       [31:0]   _zz_io_operand1_4;
  wire       [0:0]    _zz_io_operand1_5;
  wire       [31:0]   _zz_io_operand2_1;
  wire       [31:0]   _zz_io_operand2_2;
  wire       [31:0]   _zz_io_operand2_3;
  wire       [31:0]   _zz_io_operand2_4;
  wire       [0:0]    _zz_io_operand2_5;
  wire       [63:0]   _zz_io_result;
  wire       [63:0]   _zz_io_result_1;
  wire       [63:0]   _zz_io_result_2;
  wire       [63:0]   _zz_io_result_3;
  wire       [31:0]   _zz_io_operand1;
  wire       [31:0]   _zz_io_operand2;
  wire                negateResult;

  assign _zz_io_operand1_1 = (_zz_io_operand1_2 + _zz_io_operand1_4);
  assign _zz_io_operand1_2 = (_zz_io_operand1[31] ? _zz_io_operand1_3 : _zz_io_operand1);
  assign _zz_io_operand1_3 = (~ _zz_io_operand1);
  assign _zz_io_operand1_5 = _zz_io_operand1[31];
  assign _zz_io_operand1_4 = {31'd0, _zz_io_operand1_5};
  assign _zz_io_operand2_1 = (_zz_io_operand2_2 + _zz_io_operand2_4);
  assign _zz_io_operand2_2 = (_zz_io_operand2[31] ? _zz_io_operand2_3 : _zz_io_operand2);
  assign _zz_io_operand2_3 = (~ _zz_io_operand2);
  assign _zz_io_operand2_5 = _zz_io_operand2[31];
  assign _zz_io_operand2_4 = {31'd0, _zz_io_operand2_5};
  assign _zz_io_result = (negateResult ? _zz_io_result_1 : _zz_io_result_3);
  assign _zz_io_result_1 = (- _zz_io_result_2);
  assign _zz_io_result_2 = multiplier_io_result;
  assign _zz_io_result_3 = multiplier_io_result;
  UnsignedMultiplierUnit32x32 multiplier (
    .io_restart     (io_restart                    ), //i
    .io_operand1    (multiplier_io_operand1[31:0]  ), //i
    .io_operand2    (multiplier_io_operand2[31:0]  ), //i
    .io_result      (multiplier_io_result[63:0]    ), //o
    .io_ready       (multiplier_io_ready           ), //o
    .bus_clk        (bus_clk                       ), //i
    .bus_reset      (bus_reset                     )  //i
  );
  assign _zz_io_operand1 = io_operand1;
  assign multiplier_io_operand1 = (io_signed ? _zz_io_operand1_1 : io_operand1);
  assign _zz_io_operand2 = io_operand2;
  assign multiplier_io_operand2 = (io_signed ? _zz_io_operand2_1 : io_operand2);
  assign negateResult = (io_signed && (io_operand1[31] ^ io_operand2[31]));
  assign io_result = _zz_io_result;
  assign io_ready = multiplier_io_ready;

endmodule

module StreamFifo (
  input               io_push_valid,
  output              io_push_ready,
  input      [7:0]    io_push_payload,
  output              io_pop_valid,
  input               io_pop_ready,
  output     [7:0]    io_pop_payload,
  input               io_flush,
  output     [2:0]    io_occupancy,
  output     [2:0]    io_availability,
  input               bus_clk,
  input               bus_reset
);

  reg        [7:0]    _zz_logic_ram_port0;
  wire       [1:0]    _zz_logic_pushPtr_valueNext;
  wire       [0:0]    _zz_logic_pushPtr_valueNext_1;
  wire       [1:0]    _zz_logic_popPtr_valueNext;
  wire       [0:0]    _zz_logic_popPtr_valueNext_1;
  wire                _zz_logic_ram_port;
  wire                _zz_io_pop_payload;
  wire       [1:0]    _zz_io_availability;
  reg                 _zz_1;
  reg                 logic_pushPtr_willIncrement;
  reg                 logic_pushPtr_willClear;
  reg        [1:0]    logic_pushPtr_valueNext;
  reg        [1:0]    logic_pushPtr_value;
  wire                logic_pushPtr_willOverflowIfInc;
  wire                logic_pushPtr_willOverflow;
  reg                 logic_popPtr_willIncrement;
  reg                 logic_popPtr_willClear;
  reg        [1:0]    logic_popPtr_valueNext;
  reg        [1:0]    logic_popPtr_value;
  wire                logic_popPtr_willOverflowIfInc;
  wire                logic_popPtr_willOverflow;
  wire                logic_ptrMatch;
  reg                 logic_risingOccupancy;
  wire                logic_pushing;
  wire                logic_popping;
  wire                logic_empty;
  wire                logic_full;
  reg                 _zz_io_pop_valid;
  wire                when_Stream_l954;
  wire       [1:0]    logic_ptrDif;
  reg [7:0] logic_ram [0:3];

  assign _zz_logic_pushPtr_valueNext_1 = logic_pushPtr_willIncrement;
  assign _zz_logic_pushPtr_valueNext = {1'd0, _zz_logic_pushPtr_valueNext_1};
  assign _zz_logic_popPtr_valueNext_1 = logic_popPtr_willIncrement;
  assign _zz_logic_popPtr_valueNext = {1'd0, _zz_logic_popPtr_valueNext_1};
  assign _zz_io_availability = (logic_popPtr_value - logic_pushPtr_value);
  assign _zz_io_pop_payload = 1'b1;
  always @(posedge bus_clk) begin
    if(_zz_io_pop_payload) begin
      _zz_logic_ram_port0 <= logic_ram[logic_popPtr_valueNext];
    end
  end

  always @(posedge bus_clk) begin
    if(_zz_1) begin
      logic_ram[logic_pushPtr_value] <= io_push_payload;
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_pushing) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willIncrement = 1'b0;
    if(logic_pushing) begin
      logic_pushPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_pushPtr_willClear = 1'b1;
    end
  end

  assign logic_pushPtr_willOverflowIfInc = (logic_pushPtr_value == 2'b11);
  assign logic_pushPtr_willOverflow = (logic_pushPtr_willOverflowIfInc && logic_pushPtr_willIncrement);
  always @(*) begin
    logic_pushPtr_valueNext = (logic_pushPtr_value + _zz_logic_pushPtr_valueNext);
    if(logic_pushPtr_willClear) begin
      logic_pushPtr_valueNext = 2'b00;
    end
  end

  always @(*) begin
    logic_popPtr_willIncrement = 1'b0;
    if(logic_popping) begin
      logic_popPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_popPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_popPtr_willClear = 1'b1;
    end
  end

  assign logic_popPtr_willOverflowIfInc = (logic_popPtr_value == 2'b11);
  assign logic_popPtr_willOverflow = (logic_popPtr_willOverflowIfInc && logic_popPtr_willIncrement);
  always @(*) begin
    logic_popPtr_valueNext = (logic_popPtr_value + _zz_logic_popPtr_valueNext);
    if(logic_popPtr_willClear) begin
      logic_popPtr_valueNext = 2'b00;
    end
  end

  assign logic_ptrMatch = (logic_pushPtr_value == logic_popPtr_value);
  assign logic_pushing = (io_push_valid && io_push_ready);
  assign logic_popping = (io_pop_valid && io_pop_ready);
  assign logic_empty = (logic_ptrMatch && (! logic_risingOccupancy));
  assign logic_full = (logic_ptrMatch && logic_risingOccupancy);
  assign io_push_ready = (! logic_full);
  assign io_pop_valid = ((! logic_empty) && (! (_zz_io_pop_valid && (! logic_full))));
  assign io_pop_payload = _zz_logic_ram_port0;
  assign when_Stream_l954 = (logic_pushing != logic_popping);
  assign logic_ptrDif = (logic_pushPtr_value - logic_popPtr_value);
  assign io_occupancy = {(logic_risingOccupancy && logic_ptrMatch),logic_ptrDif};
  assign io_availability = {((! logic_risingOccupancy) && logic_ptrMatch),_zz_io_availability};
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      logic_pushPtr_value <= 2'b00;
      logic_popPtr_value <= 2'b00;
      logic_risingOccupancy <= 1'b0;
      _zz_io_pop_valid <= 1'b0;
    end else begin
      logic_pushPtr_value <= logic_pushPtr_valueNext;
      logic_popPtr_value <= logic_popPtr_valueNext;
      _zz_io_pop_valid <= (logic_popPtr_valueNext == logic_pushPtr_value);
      if(when_Stream_l954) begin
        logic_risingOccupancy <= logic_pushing;
      end
      if(io_flush) begin
        logic_risingOccupancy <= 1'b0;
      end
    end
  end


endmodule

module RC811 (
  input               io_nmi,
  input               io_irq,
  input      [7:0]    io_dataIn,
  output reg [7:0]    io_dataOut,
  output reg [15:0]   io_address,
  output reg          io_busEnable,
  output reg          io_io,
  output reg          io_code,
  output reg          io_write,
  output reg          io_int,
  input               bus_clk,
  input               bus_reset,
  input               when_ClockDomain_l353_regNext
);
  localparam RegisterName_f = 4'd0;
  localparam RegisterName_t = 4'd1;
  localparam RegisterName_b = 4'd2;
  localparam RegisterName_c = 4'd3;
  localparam RegisterName_d = 4'd4;
  localparam RegisterName_e = 4'd5;
  localparam RegisterName_h = 4'd6;
  localparam RegisterName_l = 4'd7;
  localparam RegisterName_ft = 4'd8;
  localparam RegisterName_bc = 4'd9;
  localparam RegisterName_de = 4'd10;
  localparam RegisterName_hl = 4'd11;
  localparam MemoryStageAddressSource_register1 = 1'd0;
  localparam MemoryStageAddressSource_pc = 1'd1;
  localparam OperandSource_zero = 3'd0;
  localparam OperandSource_ones = 3'd1;
  localparam OperandSource_register_1 = 3'd2;
  localparam OperandSource_pc = 3'd3;
  localparam OperandSource_memory = 3'd4;
  localparam OperandSource_signed_memory = 3'd5;
  localparam PcCondition_always_1 = 2'd0;
  localparam PcCondition_whenConditionMet = 2'd1;
  localparam PcCondition_whenResultNotZero = 2'd2;
  localparam PcTruePathSource_offsetFromMemory = 3'd0;
  localparam PcTruePathSource_offsetFromDecoder = 3'd1;
  localparam PcTruePathSource_register2 = 3'd2;
  localparam PcTruePathSource_vectorFromMemory = 3'd3;
  localparam PcTruePathSource_vectorFromDecoder = 3'd4;
  localparam AluOperation_add = 4'd0;
  localparam AluOperation_sub = 4'd1;
  localparam AluOperation_compare = 4'd2;
  localparam AluOperation_extend1 = 4'd3;
  localparam AluOperation_and_1 = 4'd4;
  localparam AluOperation_or_1 = 4'd5;
  localparam AluOperation_xor_1 = 4'd6;
  localparam AluOperation_operand1 = 4'd7;
  localparam AluOperation_ls = 4'd8;
  localparam AluOperation_rs = 4'd9;
  localparam AluOperation_rsa = 4'd10;
  localparam AluOperation_swap = 4'd11;
  localparam Condition_le = 4'd0;
  localparam Condition_gt = 4'd1;
  localparam Condition_lt = 4'd2;
  localparam Condition_ge = 4'd3;
  localparam Condition_leu = 4'd4;
  localparam Condition_gtu = 4'd5;
  localparam Condition_ltu = 4'd6;
  localparam Condition_geu = 4'd7;
  localparam Condition_eq = 4'd8;
  localparam Condition_ne = 4'd9;
  localparam Condition_t = 4'd10;
  localparam Condition_f = 4'd11;
  localparam WriteBackValueSource_alu = 1'd0;
  localparam WriteBackValueSource_memory = 1'd1;

  wire       [3:0]    decodeArea_decoderUnit_io_output_stageControl_readStageControl_registers_0;
  wire       [3:0]    decodeArea_decoderUnit_io_output_stageControl_readStageControl_registers_1;
  wire                decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_enable;
  wire                decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_write;
  wire                decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_io;
  wire                decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_code;
  wire                decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_config;
  wire       [0:0]    decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_address;
  wire       [2:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_selection_0;
  wire       [2:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_selection_1;
  wire       [1:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_condition;
  wire       [2:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_truePath;
  wire       [0:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_decodedOffset;
  wire       [2:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_vector;
  wire       [3:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_aluControl_operation;
  wire       [3:0]    decodeArea_decoderUnit_io_output_stageControl_aluStageControl_aluControl_condition;
  wire       [0:0]    decodeArea_decoderUnit_io_output_stageControl_writeStageControl_source;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_write;
  wire       [3:0]    decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeRegister;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeExg;
  wire       [3:0]    decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeExgRegister;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap;
  wire                decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick;
  wire                decodeArea_decoderUnit_io_output_intEnable;
  wire                decodeArea_decoderUnit_io_output_nmiActive;
  wire                decodeArea_decoderUnit_io_output_intActive;
  wire                decodeArea_decoderUnit_io_output_sysActive;
  wire       [15:0]   registers_registers_io_dataOut_0;
  wire       [15:0]   registers_registers_io_dataOut_1;
  wire       [15:0]   aluArea_alu_io_dataOut;
  wire       [15:0]   aluArea_alu_io_nextPc;
  reg        [7:0]    _zz_memoryArea_stackPointer_1;
  reg        [1:0]    stage;
  reg        [15:0]   pc;
  wire       [15:0]   pcPlusOne;
  reg                 intPin;
  reg                 decodeArea_intEnable;
  reg                 decodeArea_nmiActive;
  reg                 decodeArea_intActive;
  reg                 decodeArea_sysActive;
  reg                 decodeArea_resetting;
  wire                when_RC811_l71;
  reg                 decodeArea_strobe;
  wire       [7:0]    decodeArea_opcode;
  reg                 decodeArea_intReq;
  wire                when_RC811_l89;
  wire                when_RC811_l93;
  wire                decodeArea_anyIntActive;
  reg                 registers_writeControl_write;
  reg        [3:0]    registers_writeControl_writeRegister;
  reg                 registers_writeControl_writeExg;
  reg        [3:0]    registers_writeControl_writeExgRegister;
  reg                 registers_writeControl_registerControl_0_push;
  reg                 registers_writeControl_registerControl_0_pop;
  reg                 registers_writeControl_registerControl_0_swap;
  reg                 registers_writeControl_registerControl_0_pick;
  reg                 registers_writeControl_registerControl_1_push;
  reg                 registers_writeControl_registerControl_1_pop;
  reg                 registers_writeControl_registerControl_1_swap;
  reg                 registers_writeControl_registerControl_1_pick;
  reg                 registers_writeControl_registerControl_2_push;
  reg                 registers_writeControl_registerControl_2_pop;
  reg                 registers_writeControl_registerControl_2_swap;
  reg                 registers_writeControl_registerControl_2_pick;
  reg                 registers_writeControl_registerControl_3_push;
  reg                 registers_writeControl_registerControl_3_pop;
  reg                 registers_writeControl_registerControl_3_swap;
  reg                 registers_writeControl_registerControl_3_pick;
  reg        [15:0]   registers_writeData;
  reg        [15:0]   registers_writeDataExg;
  reg        [7:0]    registers_stackPointers_0;
  reg        [7:0]    registers_stackPointers_1;
  reg        [7:0]    registers_stackPointers_2;
  reg        [7:0]    registers_stackPointers_3;
  reg                 memoryArea_control_enable;
  reg                 memoryArea_control_write;
  reg                 memoryArea_control_io;
  reg                 memoryArea_control_code;
  reg                 memoryArea_control_config;
  reg        [0:0]    memoryArea_control_address;
  reg        [7:0]    memoryArea_result;
  reg        [15:0]   memoryArea_memAddress;
  wire       [7:0]    memoryArea_configRegister;
  wire                memoryArea_isStackPointerRegister;
  wire       [1:0]    _zz_memoryArea_stackPointer;
  wire       [7:0]    memoryArea_stackPointer;
  wire       [3:0]    _zz_1;
  wire                when_RC811_l172;
  wire                when_RC811_l173;
  wire                when_RC811_l208;
  wire       [7:0]    _zz_registers_stackPointers_0;
  wire                when_RC811_l226;
  reg        [7:0]    aluArea_memoryIn;
  reg        [2:0]    aluArea_control_selection_0;
  reg        [2:0]    aluArea_control_selection_1;
  reg        [1:0]    aluArea_control_pcControl_condition;
  reg        [2:0]    aluArea_control_pcControl_truePath;
  reg        [0:0]    aluArea_control_pcControl_decodedOffset;
  reg        [2:0]    aluArea_control_pcControl_vector;
  reg        [3:0]    aluArea_control_aluControl_operation;
  reg        [3:0]    aluArea_control_aluControl_condition;
  reg        [15:0]   registers_registers_io_dataOut_regNext_0;
  reg        [15:0]   registers_registers_io_dataOut_regNext_1;
  reg        [0:0]    stage3_control_source;
  reg                 stage3_control_fileControl_write;
  reg        [3:0]    stage3_control_fileControl_writeRegister;
  reg                 stage3_control_fileControl_writeExg;
  reg        [3:0]    stage3_control_fileControl_writeExgRegister;
  reg                 stage3_control_fileControl_registerControl_0_push;
  reg                 stage3_control_fileControl_registerControl_0_pop;
  reg                 stage3_control_fileControl_registerControl_0_swap;
  reg                 stage3_control_fileControl_registerControl_0_pick;
  reg                 stage3_control_fileControl_registerControl_1_push;
  reg                 stage3_control_fileControl_registerControl_1_pop;
  reg                 stage3_control_fileControl_registerControl_1_swap;
  reg                 stage3_control_fileControl_registerControl_1_pick;
  reg                 stage3_control_fileControl_registerControl_2_push;
  reg                 stage3_control_fileControl_registerControl_2_pop;
  reg                 stage3_control_fileControl_registerControl_2_swap;
  reg                 stage3_control_fileControl_registerControl_2_pick;
  reg                 stage3_control_fileControl_registerControl_3_push;
  reg                 stage3_control_fileControl_registerControl_3_pop;
  reg                 stage3_control_fileControl_registerControl_3_swap;
  reg                 stage3_control_fileControl_registerControl_3_pick;
  wire                when_RC811_l268;
  reg        [15:0]   _zz_registers_writeData;
  wire                when_RC811_l273;
  `ifndef SYNTHESIS
  reg [15:0] registers_writeControl_writeRegister_string;
  reg [15:0] registers_writeControl_writeExgRegister_string;
  reg [71:0] memoryArea_control_address_string;
  reg [103:0] aluArea_control_selection_0_string;
  reg [103:0] aluArea_control_selection_1_string;
  reg [135:0] aluArea_control_pcControl_condition_string;
  reg [135:0] aluArea_control_pcControl_truePath_string;
  reg [63:0] aluArea_control_aluControl_operation_string;
  reg [23:0] aluArea_control_aluControl_condition_string;
  reg [47:0] stage3_control_source_string;
  reg [15:0] stage3_control_fileControl_writeRegister_string;
  reg [15:0] stage3_control_fileControl_writeExgRegister_string;
  `endif


  Decoder decodeArea_decoderUnit (
    .io_strobe                                                                      (decodeArea_strobe                                                                                   ), //i
    .io_opcodeAsync                                                                 (decodeArea_opcode[7:0]                                                                              ), //i
    .io_nmiReq                                                                      (1'b0                                                                                                ), //i
    .io_intReq                                                                      (decodeArea_intReq                                                                                   ), //i
    .io_intEnable                                                                   (decodeArea_intEnable                                                                                ), //i
    .io_nmiActive                                                                   (decodeArea_nmiActive                                                                                ), //i
    .io_intActive                                                                   (decodeArea_intActive                                                                                ), //i
    .io_sysActive                                                                   (decodeArea_sysActive                                                                                ), //i
    .io_output_stageControl_readStageControl_registers_0                            (decodeArea_decoderUnit_io_output_stageControl_readStageControl_registers_0[3:0]                     ), //o
    .io_output_stageControl_readStageControl_registers_1                            (decodeArea_decoderUnit_io_output_stageControl_readStageControl_registers_1[3:0]                     ), //o
    .io_output_stageControl_memoryStageControl_enable                               (decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_enable                             ), //o
    .io_output_stageControl_memoryStageControl_write                                (decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_write                              ), //o
    .io_output_stageControl_memoryStageControl_io                                   (decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_io                                 ), //o
    .io_output_stageControl_memoryStageControl_code                                 (decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_code                               ), //o
    .io_output_stageControl_memoryStageControl_config                               (decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_config                             ), //o
    .io_output_stageControl_memoryStageControl_address                              (decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_address                            ), //o
    .io_output_stageControl_aluStageControl_selection_0                             (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_selection_0[2:0]                      ), //o
    .io_output_stageControl_aluStageControl_selection_1                             (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_selection_1[2:0]                      ), //o
    .io_output_stageControl_aluStageControl_pcControl_condition                     (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_condition[1:0]              ), //o
    .io_output_stageControl_aluStageControl_pcControl_truePath                      (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_truePath[2:0]               ), //o
    .io_output_stageControl_aluStageControl_pcControl_decodedOffset                 (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_decodedOffset               ), //o
    .io_output_stageControl_aluStageControl_pcControl_vector                        (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_vector[2:0]                 ), //o
    .io_output_stageControl_aluStageControl_aluControl_operation                    (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_aluControl_operation[3:0]             ), //o
    .io_output_stageControl_aluStageControl_aluControl_condition                    (decodeArea_decoderUnit_io_output_stageControl_aluStageControl_aluControl_condition[3:0]             ), //o
    .io_output_stageControl_writeStageControl_source                                (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_source                              ), //o
    .io_output_stageControl_writeStageControl_fileControl_write                     (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_write                   ), //o
    .io_output_stageControl_writeStageControl_fileControl_writeRegister             (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeRegister[3:0]      ), //o
    .io_output_stageControl_writeStageControl_fileControl_writeExg                  (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeExg                ), //o
    .io_output_stageControl_writeStageControl_fileControl_writeExgRegister          (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeExgRegister[3:0]   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_push    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop     (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_push    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop     (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_push    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop     (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_push    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop     (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick    (decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick  ), //o
    .io_output_intEnable                                                            (decodeArea_decoderUnit_io_output_intEnable                                                          ), //o
    .io_output_nmiActive                                                            (decodeArea_decoderUnit_io_output_nmiActive                                                          ), //o
    .io_output_intActive                                                            (decodeArea_decoderUnit_io_output_intActive                                                          ), //o
    .io_output_sysActive                                                            (decodeArea_decoderUnit_io_output_sysActive                                                          ), //o
    .bus_clk                                                                        (bus_clk                                                                                             ), //i
    .bus_reset                                                                      (bus_reset                                                                                           ), //i
    .when_ClockDomain_l353_regNext                                                  (when_ClockDomain_l353_regNext                                                                       )  //i
  );
  RegisterFile registers_registers (
    .io_readRegisters_0                   (decodeArea_decoderUnit_io_output_stageControl_readStageControl_registers_0[3:0]  ), //i
    .io_readRegisters_1                   (decodeArea_decoderUnit_io_output_stageControl_readStageControl_registers_1[3:0]  ), //i
    .io_dataOut_0                         (registers_registers_io_dataOut_0[15:0]                                           ), //o
    .io_dataOut_1                         (registers_registers_io_dataOut_1[15:0]                                           ), //o
    .io_pointers_0                        (registers_stackPointers_0[7:0]                                                   ), //i
    .io_pointers_1                        (registers_stackPointers_1[7:0]                                                   ), //i
    .io_pointers_2                        (registers_stackPointers_2[7:0]                                                   ), //i
    .io_pointers_3                        (registers_stackPointers_3[7:0]                                                   ), //i
    .io_control_write                     (registers_writeControl_write                                                     ), //i
    .io_control_writeRegister             (registers_writeControl_writeRegister[3:0]                                        ), //i
    .io_control_writeExg                  (registers_writeControl_writeExg                                                  ), //i
    .io_control_writeExgRegister          (registers_writeControl_writeExgRegister[3:0]                                     ), //i
    .io_control_registerControl_0_push    (registers_writeControl_registerControl_0_push                                    ), //i
    .io_control_registerControl_0_pop     (registers_writeControl_registerControl_0_pop                                     ), //i
    .io_control_registerControl_0_swap    (registers_writeControl_registerControl_0_swap                                    ), //i
    .io_control_registerControl_0_pick    (registers_writeControl_registerControl_0_pick                                    ), //i
    .io_control_registerControl_1_push    (registers_writeControl_registerControl_1_push                                    ), //i
    .io_control_registerControl_1_pop     (registers_writeControl_registerControl_1_pop                                     ), //i
    .io_control_registerControl_1_swap    (registers_writeControl_registerControl_1_swap                                    ), //i
    .io_control_registerControl_1_pick    (registers_writeControl_registerControl_1_pick                                    ), //i
    .io_control_registerControl_2_push    (registers_writeControl_registerControl_2_push                                    ), //i
    .io_control_registerControl_2_pop     (registers_writeControl_registerControl_2_pop                                     ), //i
    .io_control_registerControl_2_swap    (registers_writeControl_registerControl_2_swap                                    ), //i
    .io_control_registerControl_2_pick    (registers_writeControl_registerControl_2_pick                                    ), //i
    .io_control_registerControl_3_push    (registers_writeControl_registerControl_3_push                                    ), //i
    .io_control_registerControl_3_pop     (registers_writeControl_registerControl_3_pop                                     ), //i
    .io_control_registerControl_3_swap    (registers_writeControl_registerControl_3_swap                                    ), //i
    .io_control_registerControl_3_pick    (registers_writeControl_registerControl_3_pick                                    ), //i
    .io_dataIn                            (registers_writeData[15:0]                                                        ), //i
    .io_dataInExg                         (registers_writeDataExg[15:0]                                                     ), //i
    .bus_clk                              (bus_clk                                                                          ), //i
    .bus_reset                            (bus_reset                                                                        ), //i
    .when_ClockDomain_l353_regNext        (when_ClockDomain_l353_regNext                                                    )  //i
  );
  AluStage aluArea_alu (
    .io_control_selection_0                (aluArea_control_selection_0[2:0]                ), //i
    .io_control_selection_1                (aluArea_control_selection_1[2:0]                ), //i
    .io_control_pcControl_condition        (aluArea_control_pcControl_condition[1:0]        ), //i
    .io_control_pcControl_truePath         (aluArea_control_pcControl_truePath[2:0]         ), //i
    .io_control_pcControl_decodedOffset    (aluArea_control_pcControl_decodedOffset         ), //i
    .io_control_pcControl_vector           (aluArea_control_pcControl_vector[2:0]           ), //i
    .io_control_aluControl_operation       (aluArea_control_aluControl_operation[3:0]       ), //i
    .io_control_aluControl_condition       (aluArea_control_aluControl_condition[3:0]       ), //i
    .io_registers_0                        (registers_registers_io_dataOut_regNext_0[15:0]  ), //i
    .io_registers_1                        (registers_registers_io_dataOut_regNext_1[15:0]  ), //i
    .io_pc                                 (pcPlusOne[15:0]                                 ), //i
    .io_memory                             (aluArea_memoryIn[7:0]                           ), //i
    .io_dataOut                            (aluArea_alu_io_dataOut[15:0]                    ), //o
    .io_nextPc                             (aluArea_alu_io_nextPc[15:0]                     )  //o
  );
  always @(*) begin
    case(_zz_memoryArea_stackPointer)
      2'b00 : _zz_memoryArea_stackPointer_1 = registers_stackPointers_0;
      2'b01 : _zz_memoryArea_stackPointer_1 = registers_stackPointers_1;
      2'b10 : _zz_memoryArea_stackPointer_1 = registers_stackPointers_2;
      default : _zz_memoryArea_stackPointer_1 = registers_stackPointers_3;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(registers_writeControl_writeRegister)
      RegisterName_f : registers_writeControl_writeRegister_string = "f ";
      RegisterName_t : registers_writeControl_writeRegister_string = "t ";
      RegisterName_b : registers_writeControl_writeRegister_string = "b ";
      RegisterName_c : registers_writeControl_writeRegister_string = "c ";
      RegisterName_d : registers_writeControl_writeRegister_string = "d ";
      RegisterName_e : registers_writeControl_writeRegister_string = "e ";
      RegisterName_h : registers_writeControl_writeRegister_string = "h ";
      RegisterName_l : registers_writeControl_writeRegister_string = "l ";
      RegisterName_ft : registers_writeControl_writeRegister_string = "ft";
      RegisterName_bc : registers_writeControl_writeRegister_string = "bc";
      RegisterName_de : registers_writeControl_writeRegister_string = "de";
      RegisterName_hl : registers_writeControl_writeRegister_string = "hl";
      default : registers_writeControl_writeRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(registers_writeControl_writeExgRegister)
      RegisterName_f : registers_writeControl_writeExgRegister_string = "f ";
      RegisterName_t : registers_writeControl_writeExgRegister_string = "t ";
      RegisterName_b : registers_writeControl_writeExgRegister_string = "b ";
      RegisterName_c : registers_writeControl_writeExgRegister_string = "c ";
      RegisterName_d : registers_writeControl_writeExgRegister_string = "d ";
      RegisterName_e : registers_writeControl_writeExgRegister_string = "e ";
      RegisterName_h : registers_writeControl_writeExgRegister_string = "h ";
      RegisterName_l : registers_writeControl_writeExgRegister_string = "l ";
      RegisterName_ft : registers_writeControl_writeExgRegister_string = "ft";
      RegisterName_bc : registers_writeControl_writeExgRegister_string = "bc";
      RegisterName_de : registers_writeControl_writeExgRegister_string = "de";
      RegisterName_hl : registers_writeControl_writeExgRegister_string = "hl";
      default : registers_writeControl_writeExgRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(memoryArea_control_address)
      MemoryStageAddressSource_register1 : memoryArea_control_address_string = "register1";
      MemoryStageAddressSource_pc : memoryArea_control_address_string = "pc       ";
      default : memoryArea_control_address_string = "?????????";
    endcase
  end
  always @(*) begin
    case(aluArea_control_selection_0)
      OperandSource_zero : aluArea_control_selection_0_string = "zero         ";
      OperandSource_ones : aluArea_control_selection_0_string = "ones         ";
      OperandSource_register_1 : aluArea_control_selection_0_string = "register_1   ";
      OperandSource_pc : aluArea_control_selection_0_string = "pc           ";
      OperandSource_memory : aluArea_control_selection_0_string = "memory       ";
      OperandSource_signed_memory : aluArea_control_selection_0_string = "signed_memory";
      default : aluArea_control_selection_0_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(aluArea_control_selection_1)
      OperandSource_zero : aluArea_control_selection_1_string = "zero         ";
      OperandSource_ones : aluArea_control_selection_1_string = "ones         ";
      OperandSource_register_1 : aluArea_control_selection_1_string = "register_1   ";
      OperandSource_pc : aluArea_control_selection_1_string = "pc           ";
      OperandSource_memory : aluArea_control_selection_1_string = "memory       ";
      OperandSource_signed_memory : aluArea_control_selection_1_string = "signed_memory";
      default : aluArea_control_selection_1_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(aluArea_control_pcControl_condition)
      PcCondition_always_1 : aluArea_control_pcControl_condition_string = "always_1         ";
      PcCondition_whenConditionMet : aluArea_control_pcControl_condition_string = "whenConditionMet ";
      PcCondition_whenResultNotZero : aluArea_control_pcControl_condition_string = "whenResultNotZero";
      default : aluArea_control_pcControl_condition_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(aluArea_control_pcControl_truePath)
      PcTruePathSource_offsetFromMemory : aluArea_control_pcControl_truePath_string = "offsetFromMemory ";
      PcTruePathSource_offsetFromDecoder : aluArea_control_pcControl_truePath_string = "offsetFromDecoder";
      PcTruePathSource_register2 : aluArea_control_pcControl_truePath_string = "register2        ";
      PcTruePathSource_vectorFromMemory : aluArea_control_pcControl_truePath_string = "vectorFromMemory ";
      PcTruePathSource_vectorFromDecoder : aluArea_control_pcControl_truePath_string = "vectorFromDecoder";
      default : aluArea_control_pcControl_truePath_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(aluArea_control_aluControl_operation)
      AluOperation_add : aluArea_control_aluControl_operation_string = "add     ";
      AluOperation_sub : aluArea_control_aluControl_operation_string = "sub     ";
      AluOperation_compare : aluArea_control_aluControl_operation_string = "compare ";
      AluOperation_extend1 : aluArea_control_aluControl_operation_string = "extend1 ";
      AluOperation_and_1 : aluArea_control_aluControl_operation_string = "and_1   ";
      AluOperation_or_1 : aluArea_control_aluControl_operation_string = "or_1    ";
      AluOperation_xor_1 : aluArea_control_aluControl_operation_string = "xor_1   ";
      AluOperation_operand1 : aluArea_control_aluControl_operation_string = "operand1";
      AluOperation_ls : aluArea_control_aluControl_operation_string = "ls      ";
      AluOperation_rs : aluArea_control_aluControl_operation_string = "rs      ";
      AluOperation_rsa : aluArea_control_aluControl_operation_string = "rsa     ";
      AluOperation_swap : aluArea_control_aluControl_operation_string = "swap    ";
      default : aluArea_control_aluControl_operation_string = "????????";
    endcase
  end
  always @(*) begin
    case(aluArea_control_aluControl_condition)
      Condition_le : aluArea_control_aluControl_condition_string = "le ";
      Condition_gt : aluArea_control_aluControl_condition_string = "gt ";
      Condition_lt : aluArea_control_aluControl_condition_string = "lt ";
      Condition_ge : aluArea_control_aluControl_condition_string = "ge ";
      Condition_leu : aluArea_control_aluControl_condition_string = "leu";
      Condition_gtu : aluArea_control_aluControl_condition_string = "gtu";
      Condition_ltu : aluArea_control_aluControl_condition_string = "ltu";
      Condition_geu : aluArea_control_aluControl_condition_string = "geu";
      Condition_eq : aluArea_control_aluControl_condition_string = "eq ";
      Condition_ne : aluArea_control_aluControl_condition_string = "ne ";
      Condition_t : aluArea_control_aluControl_condition_string = "t  ";
      Condition_f : aluArea_control_aluControl_condition_string = "f  ";
      default : aluArea_control_aluControl_condition_string = "???";
    endcase
  end
  always @(*) begin
    case(stage3_control_source)
      WriteBackValueSource_alu : stage3_control_source_string = "alu   ";
      WriteBackValueSource_memory : stage3_control_source_string = "memory";
      default : stage3_control_source_string = "??????";
    endcase
  end
  always @(*) begin
    case(stage3_control_fileControl_writeRegister)
      RegisterName_f : stage3_control_fileControl_writeRegister_string = "f ";
      RegisterName_t : stage3_control_fileControl_writeRegister_string = "t ";
      RegisterName_b : stage3_control_fileControl_writeRegister_string = "b ";
      RegisterName_c : stage3_control_fileControl_writeRegister_string = "c ";
      RegisterName_d : stage3_control_fileControl_writeRegister_string = "d ";
      RegisterName_e : stage3_control_fileControl_writeRegister_string = "e ";
      RegisterName_h : stage3_control_fileControl_writeRegister_string = "h ";
      RegisterName_l : stage3_control_fileControl_writeRegister_string = "l ";
      RegisterName_ft : stage3_control_fileControl_writeRegister_string = "ft";
      RegisterName_bc : stage3_control_fileControl_writeRegister_string = "bc";
      RegisterName_de : stage3_control_fileControl_writeRegister_string = "de";
      RegisterName_hl : stage3_control_fileControl_writeRegister_string = "hl";
      default : stage3_control_fileControl_writeRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(stage3_control_fileControl_writeExgRegister)
      RegisterName_f : stage3_control_fileControl_writeExgRegister_string = "f ";
      RegisterName_t : stage3_control_fileControl_writeExgRegister_string = "t ";
      RegisterName_b : stage3_control_fileControl_writeExgRegister_string = "b ";
      RegisterName_c : stage3_control_fileControl_writeExgRegister_string = "c ";
      RegisterName_d : stage3_control_fileControl_writeExgRegister_string = "d ";
      RegisterName_e : stage3_control_fileControl_writeExgRegister_string = "e ";
      RegisterName_h : stage3_control_fileControl_writeExgRegister_string = "h ";
      RegisterName_l : stage3_control_fileControl_writeExgRegister_string = "l ";
      RegisterName_ft : stage3_control_fileControl_writeExgRegister_string = "ft";
      RegisterName_bc : stage3_control_fileControl_writeExgRegister_string = "bc";
      RegisterName_de : stage3_control_fileControl_writeExgRegister_string = "de";
      RegisterName_hl : stage3_control_fileControl_writeExgRegister_string = "hl";
      default : stage3_control_fileControl_writeExgRegister_string = "??";
    endcase
  end
  `endif

  assign pcPlusOne = (pc + 16'h0001);
  always @(*) begin
    io_busEnable = 1'b0;
    if(when_RC811_l208) begin
      if(memoryArea_control_enable) begin
        if(!memoryArea_control_config) begin
          io_busEnable = memoryArea_control_enable;
        end
      end
    end
    if(!when_RC811_l268) begin
      if(when_RC811_l273) begin
        io_busEnable = 1'b1;
      end
    end
  end

  always @(*) begin
    io_write = 1'b0;
    if(when_RC811_l208) begin
      if(memoryArea_control_enable) begin
        if(!memoryArea_control_config) begin
          io_write = memoryArea_control_write;
        end
      end
    end
    if(!when_RC811_l268) begin
      if(when_RC811_l273) begin
        io_write = 1'b0;
      end
    end
  end

  always @(*) begin
    io_io = 1'b0;
    if(when_RC811_l208) begin
      if(memoryArea_control_enable) begin
        if(!memoryArea_control_config) begin
          io_io = memoryArea_control_io;
        end
      end
    end
    if(!when_RC811_l268) begin
      if(when_RC811_l273) begin
        io_io = 1'b0;
      end
    end
  end

  always @(*) begin
    io_code = 1'b0;
    if(when_RC811_l208) begin
      if(memoryArea_control_enable) begin
        if(!memoryArea_control_config) begin
          io_code = memoryArea_control_code;
        end
      end
    end
    if(!when_RC811_l268) begin
      if(when_RC811_l273) begin
        io_code = 1'b1;
      end
    end
  end

  always @(*) begin
    io_int = intPin;
    if(!when_RC811_l268) begin
      if(when_RC811_l273) begin
        io_int = decodeArea_anyIntActive;
      end
    end
  end

  always @(*) begin
    io_address = 16'h0;
    if(when_RC811_l208) begin
      if(memoryArea_control_enable) begin
        if(!memoryArea_control_config) begin
          io_address = memoryArea_memAddress;
        end
      end
    end
    if(!when_RC811_l268) begin
      if(when_RC811_l273) begin
        io_address = aluArea_alu_io_nextPc;
      end
    end
  end

  always @(*) begin
    io_dataOut = 8'h0;
    if(when_RC811_l208) begin
      if(memoryArea_control_enable) begin
        if(!memoryArea_control_config) begin
          io_dataOut = registers_registers_io_dataOut_1[15 : 8];
        end
      end
    end
  end

  assign when_RC811_l71 = (stage == 2'b10);
  always @(*) begin
    decodeArea_strobe = 1'b0;
    if(when_RC811_l89) begin
      decodeArea_strobe = 1'b1;
    end
  end

  assign decodeArea_opcode = (decodeArea_resetting ? 8'h0 : io_dataIn);
  assign when_RC811_l89 = (stage == 2'b00);
  assign when_RC811_l93 = (stage == 2'b11);
  assign decodeArea_anyIntActive = ((decodeArea_decoderUnit_io_output_nmiActive || decodeArea_decoderUnit_io_output_intActive) || decodeArea_decoderUnit_io_output_sysActive);
  always @(*) begin
    case(memoryArea_control_address)
      MemoryStageAddressSource_register1 : begin
        memoryArea_memAddress = registers_registers_io_dataOut_0;
      end
      default : begin
        memoryArea_memAddress = pcPlusOne;
      end
    endcase
  end

  assign memoryArea_configRegister = memoryArea_memAddress[15 : 8];
  assign memoryArea_isStackPointerRegister = ((memoryArea_configRegister & 8'hfc) == 8'h0);
  assign _zz_memoryArea_stackPointer = memoryArea_configRegister[1 : 0];
  assign memoryArea_stackPointer = _zz_memoryArea_stackPointer_1;
  assign _zz_1 = ({3'd0,1'b1} <<< _zz_memoryArea_stackPointer);
  assign when_RC811_l172 = (stage == 2'b10);
  assign when_RC811_l173 = (memoryArea_control_config && memoryArea_isStackPointerRegister);
  assign when_RC811_l208 = (stage == 2'b01);
  assign _zz_registers_stackPointers_0 = registers_registers_io_dataOut_1[15 : 8];
  assign when_RC811_l226 = (stage == 2'b10);
  assign when_RC811_l268 = (stage == 2'b10);
  always @(*) begin
    case(stage3_control_source)
      WriteBackValueSource_alu : begin
        _zz_registers_writeData = aluArea_alu_io_dataOut;
      end
      default : begin
        _zz_registers_writeData = ({8'd0,memoryArea_result} <<< 8);
      end
    endcase
  end

  assign when_RC811_l273 = (stage == 2'b11);
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      stage <= 2'b00;
      pc <= 16'hffff;
      intPin <= 1'b0;
      decodeArea_intEnable <= 1'b0;
      decodeArea_nmiActive <= 1'b0;
      decodeArea_intActive <= 1'b0;
      decodeArea_sysActive <= 1'b0;
      decodeArea_resetting <= 1'b1;
      decodeArea_intReq <= 1'b0;
      registers_stackPointers_0 <= 8'hff;
      registers_stackPointers_1 <= 8'hff;
      registers_stackPointers_2 <= 8'hff;
      registers_stackPointers_3 <= 8'hff;
      registers_writeControl_write <= 1'b0;
      registers_writeControl_writeExg <= 1'b0;
      registers_writeControl_registerControl_0_push <= 1'b0;
      registers_writeControl_registerControl_0_pop <= 1'b0;
      registers_writeControl_registerControl_0_swap <= 1'b0;
      registers_writeControl_registerControl_1_push <= 1'b0;
      registers_writeControl_registerControl_1_pop <= 1'b0;
      registers_writeControl_registerControl_1_swap <= 1'b0;
      registers_writeControl_registerControl_2_push <= 1'b0;
      registers_writeControl_registerControl_2_pop <= 1'b0;
      registers_writeControl_registerControl_2_swap <= 1'b0;
      registers_writeControl_registerControl_3_push <= 1'b0;
      registers_writeControl_registerControl_3_pop <= 1'b0;
      registers_writeControl_registerControl_3_swap <= 1'b0;
      memoryArea_result <= 8'h0;
    end else begin
      if(when_ClockDomain_l353_regNext) begin
        stage <= (stage + 2'b01);
        if(when_RC811_l71) begin
          decodeArea_resetting <= 1'b0;
        end
        if(when_RC811_l93) begin
          decodeArea_intReq <= io_irq;
          decodeArea_intEnable <= decodeArea_decoderUnit_io_output_intEnable;
          decodeArea_nmiActive <= decodeArea_decoderUnit_io_output_nmiActive;
          decodeArea_intActive <= decodeArea_decoderUnit_io_output_intActive;
          decodeArea_sysActive <= decodeArea_decoderUnit_io_output_sysActive;
        end
        if(when_RC811_l172) begin
          if(when_RC811_l173) begin
            memoryArea_result <= memoryArea_stackPointer;
          end else begin
            memoryArea_result <= io_dataIn;
          end
        end
        if(when_RC811_l208) begin
          if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push) begin
            registers_stackPointers_0 <= (registers_stackPointers_0 - 8'h01);
          end else begin
            if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop) begin
              registers_stackPointers_0 <= (registers_stackPointers_0 + 8'h01);
            end
          end
          if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push) begin
            registers_stackPointers_1 <= (registers_stackPointers_1 - 8'h01);
          end else begin
            if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop) begin
              registers_stackPointers_1 <= (registers_stackPointers_1 + 8'h01);
            end
          end
          if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push) begin
            registers_stackPointers_2 <= (registers_stackPointers_2 - 8'h01);
          end else begin
            if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop) begin
              registers_stackPointers_2 <= (registers_stackPointers_2 + 8'h01);
            end
          end
          if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push) begin
            registers_stackPointers_3 <= (registers_stackPointers_3 - 8'h01);
          end else begin
            if(decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop) begin
              registers_stackPointers_3 <= (registers_stackPointers_3 + 8'h01);
            end
          end
          if(memoryArea_control_enable) begin
            if(memoryArea_control_config) begin
              if(memoryArea_isStackPointerRegister) begin
                if(memoryArea_control_write) begin
                  if(_zz_1[0]) begin
                    registers_stackPointers_0 <= _zz_registers_stackPointers_0;
                  end
                  if(_zz_1[1]) begin
                    registers_stackPointers_1 <= _zz_registers_stackPointers_0;
                  end
                  if(_zz_1[2]) begin
                    registers_stackPointers_2 <= _zz_registers_stackPointers_0;
                  end
                  if(_zz_1[3]) begin
                    registers_stackPointers_3 <= _zz_registers_stackPointers_0;
                  end
                end
              end
            end
          end
        end
        registers_writeControl_write <= 1'b0;
        registers_writeControl_writeExg <= 1'b0;
        registers_writeControl_registerControl_0_push <= 1'b0;
        registers_writeControl_registerControl_0_pop <= 1'b0;
        registers_writeControl_registerControl_0_swap <= 1'b0;
        registers_writeControl_registerControl_1_push <= 1'b0;
        registers_writeControl_registerControl_1_pop <= 1'b0;
        registers_writeControl_registerControl_1_swap <= 1'b0;
        registers_writeControl_registerControl_2_push <= 1'b0;
        registers_writeControl_registerControl_2_pop <= 1'b0;
        registers_writeControl_registerControl_2_swap <= 1'b0;
        registers_writeControl_registerControl_3_push <= 1'b0;
        registers_writeControl_registerControl_3_pop <= 1'b0;
        registers_writeControl_registerControl_3_swap <= 1'b0;
        if(!when_RC811_l268) begin
          if(when_RC811_l273) begin
            registers_writeControl_write <= stage3_control_fileControl_write;
            registers_writeControl_writeExg <= stage3_control_fileControl_writeExg;
            registers_writeControl_registerControl_0_push <= stage3_control_fileControl_registerControl_0_push;
            registers_writeControl_registerControl_0_pop <= stage3_control_fileControl_registerControl_0_pop;
            registers_writeControl_registerControl_0_swap <= stage3_control_fileControl_registerControl_0_swap;
            registers_writeControl_registerControl_1_push <= stage3_control_fileControl_registerControl_1_push;
            registers_writeControl_registerControl_1_pop <= stage3_control_fileControl_registerControl_1_pop;
            registers_writeControl_registerControl_1_swap <= stage3_control_fileControl_registerControl_1_swap;
            registers_writeControl_registerControl_2_push <= stage3_control_fileControl_registerControl_2_push;
            registers_writeControl_registerControl_2_pop <= stage3_control_fileControl_registerControl_2_pop;
            registers_writeControl_registerControl_2_swap <= stage3_control_fileControl_registerControl_2_swap;
            registers_writeControl_registerControl_3_push <= stage3_control_fileControl_registerControl_3_push;
            registers_writeControl_registerControl_3_pop <= stage3_control_fileControl_registerControl_3_pop;
            registers_writeControl_registerControl_3_swap <= stage3_control_fileControl_registerControl_3_swap;
            pc <= aluArea_alu_io_nextPc;
            intPin <= decodeArea_anyIntActive;
          end
        end
      end
    end
  end

  always @(posedge bus_clk) begin
    if(when_ClockDomain_l353_regNext) begin
      memoryArea_control_enable <= decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_enable;
      memoryArea_control_write <= decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_write;
      memoryArea_control_io <= decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_io;
      memoryArea_control_code <= decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_code;
      memoryArea_control_config <= decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_config;
      memoryArea_control_address <= decodeArea_decoderUnit_io_output_stageControl_memoryStageControl_address;
      if(when_RC811_l226) begin
        aluArea_memoryIn <= io_dataIn;
      end
      aluArea_control_selection_0 <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_selection_0;
      aluArea_control_selection_1 <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_selection_1;
      aluArea_control_pcControl_condition <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_condition;
      aluArea_control_pcControl_truePath <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_truePath;
      aluArea_control_pcControl_decodedOffset <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_decodedOffset;
      aluArea_control_pcControl_vector <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_pcControl_vector;
      aluArea_control_aluControl_operation <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_aluControl_operation;
      aluArea_control_aluControl_condition <= decodeArea_decoderUnit_io_output_stageControl_aluStageControl_aluControl_condition;
      registers_registers_io_dataOut_regNext_0 <= registers_registers_io_dataOut_0;
      registers_registers_io_dataOut_regNext_1 <= registers_registers_io_dataOut_1;
      stage3_control_source <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_source;
      stage3_control_fileControl_write <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_write;
      stage3_control_fileControl_writeRegister <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeRegister;
      stage3_control_fileControl_writeExg <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeExg;
      stage3_control_fileControl_writeExgRegister <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_writeExgRegister;
      stage3_control_fileControl_registerControl_0_push <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push;
      stage3_control_fileControl_registerControl_0_pop <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop;
      stage3_control_fileControl_registerControl_0_swap <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap;
      stage3_control_fileControl_registerControl_0_pick <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick;
      stage3_control_fileControl_registerControl_1_push <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push;
      stage3_control_fileControl_registerControl_1_pop <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop;
      stage3_control_fileControl_registerControl_1_swap <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap;
      stage3_control_fileControl_registerControl_1_pick <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick;
      stage3_control_fileControl_registerControl_2_push <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push;
      stage3_control_fileControl_registerControl_2_pop <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop;
      stage3_control_fileControl_registerControl_2_swap <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap;
      stage3_control_fileControl_registerControl_2_pick <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick;
      stage3_control_fileControl_registerControl_3_push <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push;
      stage3_control_fileControl_registerControl_3_pop <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop;
      stage3_control_fileControl_registerControl_3_swap <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap;
      stage3_control_fileControl_registerControl_3_pick <= decodeArea_decoderUnit_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick;
      registers_writeControl_registerControl_0_pick <= 1'b0;
      registers_writeControl_registerControl_1_pick <= 1'b0;
      registers_writeControl_registerControl_2_pick <= 1'b0;
      registers_writeControl_registerControl_3_pick <= 1'b0;
      if(when_RC811_l268) begin
        registers_writeControl_registerControl_0_pick <= stage3_control_fileControl_registerControl_0_pick;
        registers_writeControl_registerControl_1_pick <= stage3_control_fileControl_registerControl_1_pick;
        registers_writeControl_registerControl_2_pick <= stage3_control_fileControl_registerControl_2_pick;
        registers_writeControl_registerControl_3_pick <= stage3_control_fileControl_registerControl_3_pick;
      end else begin
        if(when_RC811_l273) begin
          registers_writeControl_writeRegister <= stage3_control_fileControl_writeRegister;
          registers_writeControl_writeExgRegister <= stage3_control_fileControl_writeExgRegister;
          registers_writeControl_registerControl_0_pick <= stage3_control_fileControl_registerControl_0_pick;
          registers_writeControl_registerControl_1_pick <= stage3_control_fileControl_registerControl_1_pick;
          registers_writeControl_registerControl_2_pick <= stage3_control_fileControl_registerControl_2_pick;
          registers_writeControl_registerControl_3_pick <= stage3_control_fileControl_registerControl_3_pick;
          registers_writeData <= _zz_registers_writeData;
          registers_writeDataExg <= registers_registers_io_dataOut_1;
        end
      end
    end
  end


endmodule

module UartCtrlRx (
  input      [2:0]    io_configFrame_dataLength,
  input      [0:0]    io_configFrame_stop,
  input      [1:0]    io_configFrame_parity,
  input               io_samplingTick,
  output              io_read_valid,
  input               io_read_ready,
  output     [7:0]    io_read_payload,
  input               io_rxd,
  output              io_rts,
  output reg          io_error,
  output              io_break,
  input               bus_clk,
  input               bus_reset
);
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;
  localparam UartCtrlRxState_IDLE = 3'd0;
  localparam UartCtrlRxState_START = 3'd1;
  localparam UartCtrlRxState_DATA = 3'd2;
  localparam UartCtrlRxState_PARITY = 3'd3;
  localparam UartCtrlRxState_STOP = 3'd4;

  wire                io_rxd_buffercc_io_dataOut;
  wire                _zz_sampler_value;
  wire                _zz_sampler_value_1;
  wire                _zz_sampler_value_2;
  wire                _zz_sampler_value_3;
  wire                _zz_sampler_value_4;
  wire                _zz_sampler_value_5;
  wire                _zz_sampler_value_6;
  wire       [2:0]    _zz_when_UartCtrlRx_l139;
  wire       [0:0]    _zz_when_UartCtrlRx_l139_1;
  reg                 _zz_io_rts;
  wire                sampler_synchroniser;
  wire                sampler_samples_0;
  reg                 sampler_samples_1;
  reg                 sampler_samples_2;
  reg                 sampler_samples_3;
  reg                 sampler_samples_4;
  reg                 sampler_value;
  reg                 sampler_tick;
  reg        [2:0]    bitTimer_counter;
  reg                 bitTimer_tick;
  wire                when_UartCtrlRx_l43;
  reg        [2:0]    bitCounter_value;
  reg        [6:0]    break_counter;
  wire                break_valid;
  wire                when_UartCtrlRx_l69;
  reg        [2:0]    stateMachine_state;
  reg                 stateMachine_parity;
  reg        [7:0]    stateMachine_shifter;
  reg                 stateMachine_validReg;
  wire                when_UartCtrlRx_l93;
  wire                when_UartCtrlRx_l103;
  wire                when_UartCtrlRx_l111;
  wire                when_UartCtrlRx_l113;
  wire                when_UartCtrlRx_l125;
  wire                when_UartCtrlRx_l136;
  wire                when_UartCtrlRx_l139;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  `endif


  assign _zz_when_UartCtrlRx_l139_1 = ((io_configFrame_stop == UartStopType_ONE) ? 1'b0 : 1'b1);
  assign _zz_when_UartCtrlRx_l139 = {2'd0, _zz_when_UartCtrlRx_l139_1};
  assign _zz_sampler_value = ((((1'b0 || ((_zz_sampler_value_1 && sampler_samples_1) && sampler_samples_2)) || (((_zz_sampler_value_2 && sampler_samples_0) && sampler_samples_1) && sampler_samples_3)) || (((1'b1 && sampler_samples_0) && sampler_samples_2) && sampler_samples_3)) || (((1'b1 && sampler_samples_1) && sampler_samples_2) && sampler_samples_3));
  assign _zz_sampler_value_3 = (((1'b1 && sampler_samples_0) && sampler_samples_1) && sampler_samples_4);
  assign _zz_sampler_value_4 = ((1'b1 && sampler_samples_0) && sampler_samples_2);
  assign _zz_sampler_value_5 = (1'b1 && sampler_samples_1);
  assign _zz_sampler_value_6 = 1'b1;
  assign _zz_sampler_value_1 = (1'b1 && sampler_samples_0);
  assign _zz_sampler_value_2 = 1'b1;
  BufferCC io_rxd_buffercc (
    .io_dataIn     (io_rxd                      ), //i
    .io_dataOut    (io_rxd_buffercc_io_dataOut  ), //o
    .bus_clk       (bus_clk                     ), //i
    .bus_reset     (bus_reset                   )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      UartStopType_ONE : io_configFrame_stop_string = "ONE";
      UartStopType_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      UartParityType_NONE : io_configFrame_parity_string = "NONE";
      UartParityType_EVEN : io_configFrame_parity_string = "EVEN";
      UartParityType_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      UartCtrlRxState_IDLE : stateMachine_state_string = "IDLE  ";
      UartCtrlRxState_START : stateMachine_state_string = "START ";
      UartCtrlRxState_DATA : stateMachine_state_string = "DATA  ";
      UartCtrlRxState_PARITY : stateMachine_state_string = "PARITY";
      UartCtrlRxState_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    io_error = 1'b0;
    case(stateMachine_state)
      UartCtrlRxState_IDLE : begin
      end
      UartCtrlRxState_START : begin
      end
      UartCtrlRxState_DATA : begin
      end
      UartCtrlRxState_PARITY : begin
        if(bitTimer_tick) begin
          if(!when_UartCtrlRx_l125) begin
            io_error = 1'b1;
          end
        end
      end
      default : begin
        if(bitTimer_tick) begin
          if(when_UartCtrlRx_l136) begin
            io_error = 1'b1;
          end
        end
      end
    endcase
  end

  assign io_rts = _zz_io_rts;
  assign sampler_synchroniser = io_rxd_buffercc_io_dataOut;
  assign sampler_samples_0 = sampler_synchroniser;
  always @(*) begin
    bitTimer_tick = 1'b0;
    if(sampler_tick) begin
      if(when_UartCtrlRx_l43) begin
        bitTimer_tick = 1'b1;
      end
    end
  end

  assign when_UartCtrlRx_l43 = (bitTimer_counter == 3'b000);
  assign break_valid = (break_counter == 7'h68);
  assign when_UartCtrlRx_l69 = (io_samplingTick && (! break_valid));
  assign io_break = break_valid;
  assign io_read_valid = stateMachine_validReg;
  assign when_UartCtrlRx_l93 = ((sampler_tick && (! sampler_value)) && (! break_valid));
  assign when_UartCtrlRx_l103 = (sampler_value == 1'b1);
  assign when_UartCtrlRx_l111 = (bitCounter_value == io_configFrame_dataLength);
  assign when_UartCtrlRx_l113 = (io_configFrame_parity == UartParityType_NONE);
  assign when_UartCtrlRx_l125 = (stateMachine_parity == sampler_value);
  assign when_UartCtrlRx_l136 = (! sampler_value);
  assign when_UartCtrlRx_l139 = (bitCounter_value == _zz_when_UartCtrlRx_l139);
  assign io_read_payload = stateMachine_shifter;
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      _zz_io_rts <= 1'b0;
      sampler_samples_1 <= 1'b1;
      sampler_samples_2 <= 1'b1;
      sampler_samples_3 <= 1'b1;
      sampler_samples_4 <= 1'b1;
      sampler_value <= 1'b1;
      sampler_tick <= 1'b0;
      break_counter <= 7'h0;
      stateMachine_state <= UartCtrlRxState_IDLE;
      stateMachine_validReg <= 1'b0;
    end else begin
      _zz_io_rts <= (! io_read_ready);
      if(io_samplingTick) begin
        sampler_samples_1 <= sampler_samples_0;
      end
      if(io_samplingTick) begin
        sampler_samples_2 <= sampler_samples_1;
      end
      if(io_samplingTick) begin
        sampler_samples_3 <= sampler_samples_2;
      end
      if(io_samplingTick) begin
        sampler_samples_4 <= sampler_samples_3;
      end
      sampler_value <= ((((((_zz_sampler_value || _zz_sampler_value_3) || (_zz_sampler_value_4 && sampler_samples_4)) || ((_zz_sampler_value_5 && sampler_samples_2) && sampler_samples_4)) || (((_zz_sampler_value_6 && sampler_samples_0) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_1) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_2) && sampler_samples_3) && sampler_samples_4));
      sampler_tick <= io_samplingTick;
      if(sampler_value) begin
        break_counter <= 7'h0;
      end else begin
        if(when_UartCtrlRx_l69) begin
          break_counter <= (break_counter + 7'h01);
        end
      end
      stateMachine_validReg <= 1'b0;
      case(stateMachine_state)
        UartCtrlRxState_IDLE : begin
          if(when_UartCtrlRx_l93) begin
            stateMachine_state <= UartCtrlRxState_START;
          end
        end
        UartCtrlRxState_START : begin
          if(bitTimer_tick) begin
            stateMachine_state <= UartCtrlRxState_DATA;
            if(when_UartCtrlRx_l103) begin
              stateMachine_state <= UartCtrlRxState_IDLE;
            end
          end
        end
        UartCtrlRxState_DATA : begin
          if(bitTimer_tick) begin
            if(when_UartCtrlRx_l111) begin
              if(when_UartCtrlRx_l113) begin
                stateMachine_state <= UartCtrlRxState_STOP;
                stateMachine_validReg <= 1'b1;
              end else begin
                stateMachine_state <= UartCtrlRxState_PARITY;
              end
            end
          end
        end
        UartCtrlRxState_PARITY : begin
          if(bitTimer_tick) begin
            if(when_UartCtrlRx_l125) begin
              stateMachine_state <= UartCtrlRxState_STOP;
              stateMachine_validReg <= 1'b1;
            end else begin
              stateMachine_state <= UartCtrlRxState_IDLE;
            end
          end
        end
        default : begin
          if(bitTimer_tick) begin
            if(when_UartCtrlRx_l136) begin
              stateMachine_state <= UartCtrlRxState_IDLE;
            end else begin
              if(when_UartCtrlRx_l139) begin
                stateMachine_state <= UartCtrlRxState_IDLE;
              end
            end
          end
        end
      endcase
    end
  end

  always @(posedge bus_clk) begin
    if(sampler_tick) begin
      bitTimer_counter <= (bitTimer_counter - 3'b001);
    end
    if(bitTimer_tick) begin
      bitCounter_value <= (bitCounter_value + 3'b001);
    end
    if(bitTimer_tick) begin
      stateMachine_parity <= (stateMachine_parity ^ sampler_value);
    end
    case(stateMachine_state)
      UartCtrlRxState_IDLE : begin
        if(when_UartCtrlRx_l93) begin
          bitTimer_counter <= 3'b010;
        end
      end
      UartCtrlRxState_START : begin
        if(bitTimer_tick) begin
          bitCounter_value <= 3'b000;
          stateMachine_parity <= (io_configFrame_parity == UartParityType_ODD);
        end
      end
      UartCtrlRxState_DATA : begin
        if(bitTimer_tick) begin
          stateMachine_shifter[bitCounter_value] <= sampler_value;
          if(when_UartCtrlRx_l111) begin
            bitCounter_value <= 3'b000;
          end
        end
      end
      UartCtrlRxState_PARITY : begin
        if(bitTimer_tick) begin
          bitCounter_value <= 3'b000;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module UartCtrlTx (
  input      [2:0]    io_configFrame_dataLength,
  input      [0:0]    io_configFrame_stop,
  input      [1:0]    io_configFrame_parity,
  input               io_samplingTick,
  input               io_write_valid,
  output reg          io_write_ready,
  input      [7:0]    io_write_payload,
  input               io_cts,
  output              io_txd,
  input               io_break,
  input               bus_clk,
  input               bus_reset
);
  localparam UartStopType_ONE = 1'd0;
  localparam UartStopType_TWO = 1'd1;
  localparam UartParityType_NONE = 2'd0;
  localparam UartParityType_EVEN = 2'd1;
  localparam UartParityType_ODD = 2'd2;
  localparam UartCtrlTxState_IDLE = 3'd0;
  localparam UartCtrlTxState_START = 3'd1;
  localparam UartCtrlTxState_DATA = 3'd2;
  localparam UartCtrlTxState_PARITY = 3'd3;
  localparam UartCtrlTxState_STOP = 3'd4;

  wire       [2:0]    _zz_clockDivider_counter_valueNext;
  wire       [0:0]    _zz_clockDivider_counter_valueNext_1;
  wire       [2:0]    _zz_when_UartCtrlTx_l93;
  wire       [0:0]    _zz_when_UartCtrlTx_l93_1;
  reg                 clockDivider_counter_willIncrement;
  wire                clockDivider_counter_willClear;
  reg        [2:0]    clockDivider_counter_valueNext;
  reg        [2:0]    clockDivider_counter_value;
  wire                clockDivider_counter_willOverflowIfInc;
  wire                clockDivider_counter_willOverflow;
  reg        [2:0]    tickCounter_value;
  reg        [2:0]    stateMachine_state;
  reg                 stateMachine_parity;
  reg                 stateMachine_txd;
  wire                when_UartCtrlTx_l58;
  wire                when_UartCtrlTx_l73;
  wire                when_UartCtrlTx_l76;
  wire                when_UartCtrlTx_l93;
  reg                 _zz_io_txd;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  `endif


  assign _zz_clockDivider_counter_valueNext_1 = clockDivider_counter_willIncrement;
  assign _zz_clockDivider_counter_valueNext = {2'd0, _zz_clockDivider_counter_valueNext_1};
  assign _zz_when_UartCtrlTx_l93_1 = ((io_configFrame_stop == UartStopType_ONE) ? 1'b0 : 1'b1);
  assign _zz_when_UartCtrlTx_l93 = {2'd0, _zz_when_UartCtrlTx_l93_1};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      UartStopType_ONE : io_configFrame_stop_string = "ONE";
      UartStopType_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      UartParityType_NONE : io_configFrame_parity_string = "NONE";
      UartParityType_EVEN : io_configFrame_parity_string = "EVEN";
      UartParityType_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      UartCtrlTxState_IDLE : stateMachine_state_string = "IDLE  ";
      UartCtrlTxState_START : stateMachine_state_string = "START ";
      UartCtrlTxState_DATA : stateMachine_state_string = "DATA  ";
      UartCtrlTxState_PARITY : stateMachine_state_string = "PARITY";
      UartCtrlTxState_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @(*) begin
    clockDivider_counter_willIncrement = 1'b0;
    if(io_samplingTick) begin
      clockDivider_counter_willIncrement = 1'b1;
    end
  end

  assign clockDivider_counter_willClear = 1'b0;
  assign clockDivider_counter_willOverflowIfInc = (clockDivider_counter_value == 3'b111);
  assign clockDivider_counter_willOverflow = (clockDivider_counter_willOverflowIfInc && clockDivider_counter_willIncrement);
  always @(*) begin
    clockDivider_counter_valueNext = (clockDivider_counter_value + _zz_clockDivider_counter_valueNext);
    if(clockDivider_counter_willClear) begin
      clockDivider_counter_valueNext = 3'b000;
    end
  end

  always @(*) begin
    stateMachine_txd = 1'b1;
    case(stateMachine_state)
      UartCtrlTxState_IDLE : begin
      end
      UartCtrlTxState_START : begin
        stateMachine_txd = 1'b0;
      end
      UartCtrlTxState_DATA : begin
        stateMachine_txd = io_write_payload[tickCounter_value];
      end
      UartCtrlTxState_PARITY : begin
        stateMachine_txd = stateMachine_parity;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_write_ready = io_break;
    case(stateMachine_state)
      UartCtrlTxState_IDLE : begin
      end
      UartCtrlTxState_START : begin
      end
      UartCtrlTxState_DATA : begin
        if(clockDivider_counter_willOverflow) begin
          if(when_UartCtrlTx_l73) begin
            io_write_ready = 1'b1;
          end
        end
      end
      UartCtrlTxState_PARITY : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UartCtrlTx_l58 = ((io_write_valid && (! io_cts)) && clockDivider_counter_willOverflow);
  assign when_UartCtrlTx_l73 = (tickCounter_value == io_configFrame_dataLength);
  assign when_UartCtrlTx_l76 = (io_configFrame_parity == UartParityType_NONE);
  assign when_UartCtrlTx_l93 = (tickCounter_value == _zz_when_UartCtrlTx_l93);
  assign io_txd = _zz_io_txd;
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      clockDivider_counter_value <= 3'b000;
      stateMachine_state <= UartCtrlTxState_IDLE;
      _zz_io_txd <= 1'b1;
    end else begin
      clockDivider_counter_value <= clockDivider_counter_valueNext;
      case(stateMachine_state)
        UartCtrlTxState_IDLE : begin
          if(when_UartCtrlTx_l58) begin
            stateMachine_state <= UartCtrlTxState_START;
          end
        end
        UartCtrlTxState_START : begin
          if(clockDivider_counter_willOverflow) begin
            stateMachine_state <= UartCtrlTxState_DATA;
          end
        end
        UartCtrlTxState_DATA : begin
          if(clockDivider_counter_willOverflow) begin
            if(when_UartCtrlTx_l73) begin
              if(when_UartCtrlTx_l76) begin
                stateMachine_state <= UartCtrlTxState_STOP;
              end else begin
                stateMachine_state <= UartCtrlTxState_PARITY;
              end
            end
          end
        end
        UartCtrlTxState_PARITY : begin
          if(clockDivider_counter_willOverflow) begin
            stateMachine_state <= UartCtrlTxState_STOP;
          end
        end
        default : begin
          if(clockDivider_counter_willOverflow) begin
            if(when_UartCtrlTx_l93) begin
              stateMachine_state <= (io_write_valid ? UartCtrlTxState_START : UartCtrlTxState_IDLE);
            end
          end
        end
      endcase
      _zz_io_txd <= (stateMachine_txd && (! io_break));
    end
  end

  always @(posedge bus_clk) begin
    if(clockDivider_counter_willOverflow) begin
      tickCounter_value <= (tickCounter_value + 3'b001);
    end
    if(clockDivider_counter_willOverflow) begin
      stateMachine_parity <= (stateMachine_parity ^ stateMachine_txd);
    end
    case(stateMachine_state)
      UartCtrlTxState_IDLE : begin
      end
      UartCtrlTxState_START : begin
        if(clockDivider_counter_willOverflow) begin
          stateMachine_parity <= (io_configFrame_parity == UartParityType_ODD);
          tickCounter_value <= 3'b000;
        end
      end
      UartCtrlTxState_DATA : begin
        if(clockDivider_counter_willOverflow) begin
          if(when_UartCtrlTx_l73) begin
            tickCounter_value <= 3'b000;
          end
        end
      end
      UartCtrlTxState_PARITY : begin
        if(clockDivider_counter_willOverflow) begin
          tickCounter_value <= 3'b000;
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module UnsignedDividerUnit32x32 (
  input               io_restart,
  input      [63:0]   io_dividend,
  input      [31:0]   io_divisor,
  output     [31:0]   io_quotient,
  output     [31:0]   io_remainder,
  output              io_ready,
  input               bus_clk,
  input               bus_reset
);

  reg                 io_restart_regNext;
  wire                restartEdge;
  reg        [5:0]    counter;
  wire                timeout;
  wire                when_Divider_l24;
  reg        [63:0]   accumulator;
  wire       [63:0]   workAccumulator;
  wire       [31:0]   subtractedQuotient;
  wire                couldSubtract;
  wire       [31:0]   nextRemainder;
  wire                when_Divider_l35;
  wire                when_Divider_l36;

  assign restartEdge = (io_restart && (! io_restart_regNext));
  assign timeout = counter[5];
  assign when_Divider_l24 = (! timeout);
  assign workAccumulator = (restartEdge ? io_dividend : accumulator);
  assign subtractedQuotient = (workAccumulator[63 : 32] - io_divisor);
  assign couldSubtract = (! subtractedQuotient[31]);
  assign nextRemainder = (couldSubtract ? subtractedQuotient[31 : 0] : workAccumulator[63 : 32]);
  assign when_Divider_l35 = (restartEdge || (! timeout));
  assign when_Divider_l36 = (counter != 6'h1f);
  assign io_quotient = accumulator[31 : 0];
  assign io_remainder = accumulator[63 : 32];
  assign io_ready = (timeout && (! restartEdge));
  always @(posedge bus_clk) begin
    io_restart_regNext <= io_restart;
    if(when_Divider_l35) begin
      if(when_Divider_l36) begin
        accumulator <= {{nextRemainder[30 : 0],workAccumulator[31 : 0]},couldSubtract};
      end else begin
        accumulator <= {{nextRemainder[31 : 0],workAccumulator[30 : 0]},couldSubtract};
      end
    end
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      counter <= 6'h20;
    end else begin
      if(restartEdge) begin
        counter <= 6'h0;
      end else begin
        if(when_Divider_l24) begin
          counter <= (counter + 6'h01);
        end
      end
    end
  end


endmodule

module UnsignedMultiplierUnit32x32 (
  input               io_restart,
  input      [31:0]   io_operand1,
  input      [31:0]   io_operand2,
  output     [63:0]   io_result,
  output              io_ready,
  input               bus_clk,
  input               bus_reset
);

  wire       [63:0]   _zz_newAccumulator;
  wire       [31:0]   _zz_newMultiplier;
  wire       [63:0]   _zz_accumulator;
  wire       [62:0]   _zz_accumulator_1;
  reg                 io_restart_regNext;
  wire                restartEdge;
  reg        [5:0]    counter;
  wire                timeout;
  wire                when_Multiplier_l24;
  reg        [63:0]   accumulator;
  reg        [30:0]   multiplier;
  wire       [63:0]   newAccumulator;
  wire       [31:0]   newMultiplier;
  wire       [31:0]   partialProduct;
  wire                when_Multiplier_l36;

  assign _zz_newAccumulator = (accumulator >>> 1);
  assign _zz_newMultiplier = {1'd0, multiplier};
  assign _zz_accumulator_1 = ({31'd0,partialProduct} <<< 31);
  assign _zz_accumulator = {1'd0, _zz_accumulator_1};
  assign restartEdge = (io_restart && (! io_restart_regNext));
  assign timeout = counter[5];
  assign when_Multiplier_l24 = (! timeout);
  assign newAccumulator = (restartEdge ? 64'h0 : _zz_newAccumulator);
  assign newMultiplier = (restartEdge ? io_operand1 : _zz_newMultiplier);
  assign partialProduct = (newMultiplier[0] ? io_operand2 : 32'h0);
  assign when_Multiplier_l36 = (restartEdge || (! timeout));
  assign io_result = accumulator;
  assign io_ready = (timeout && (! restartEdge));
  always @(posedge bus_clk) begin
    io_restart_regNext <= io_restart;
    if(when_Multiplier_l36) begin
      accumulator <= (newAccumulator + _zz_accumulator);
      multiplier <= (newMultiplier >>> 1);
    end
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      counter <= 6'h20;
    end else begin
      if(restartEdge) begin
        counter <= 6'h01;
      end else begin
        if(when_Multiplier_l24) begin
          counter <= (counter + 6'h01);
        end
      end
    end
  end


endmodule

module AluStage (
  input      [2:0]    io_control_selection_0,
  input      [2:0]    io_control_selection_1,
  input      [1:0]    io_control_pcControl_condition,
  input      [2:0]    io_control_pcControl_truePath,
  input      [0:0]    io_control_pcControl_decodedOffset,
  input      [2:0]    io_control_pcControl_vector,
  input      [3:0]    io_control_aluControl_operation,
  input      [3:0]    io_control_aluControl_condition,
  input      [15:0]   io_registers_0,
  input      [15:0]   io_registers_1,
  input      [15:0]   io_pc,
  input      [7:0]    io_memory,
  output     [15:0]   io_dataOut,
  output     [15:0]   io_nextPc
);
  localparam OperandSource_zero = 3'd0;
  localparam OperandSource_ones = 3'd1;
  localparam OperandSource_register_1 = 3'd2;
  localparam OperandSource_pc = 3'd3;
  localparam OperandSource_memory = 3'd4;
  localparam OperandSource_signed_memory = 3'd5;
  localparam PcCondition_always_1 = 2'd0;
  localparam PcCondition_whenConditionMet = 2'd1;
  localparam PcCondition_whenResultNotZero = 2'd2;
  localparam PcTruePathSource_offsetFromMemory = 3'd0;
  localparam PcTruePathSource_offsetFromDecoder = 3'd1;
  localparam PcTruePathSource_register2 = 3'd2;
  localparam PcTruePathSource_vectorFromMemory = 3'd3;
  localparam PcTruePathSource_vectorFromDecoder = 3'd4;
  localparam AluOperation_add = 4'd0;
  localparam AluOperation_sub = 4'd1;
  localparam AluOperation_compare = 4'd2;
  localparam AluOperation_extend1 = 4'd3;
  localparam AluOperation_and_1 = 4'd4;
  localparam AluOperation_or_1 = 4'd5;
  localparam AluOperation_xor_1 = 4'd6;
  localparam AluOperation_operand1 = 4'd7;
  localparam AluOperation_ls = 4'd8;
  localparam AluOperation_rs = 4'd9;
  localparam AluOperation_rsa = 4'd10;
  localparam AluOperation_swap = 4'd11;
  localparam Condition_le = 4'd0;
  localparam Condition_gt = 4'd1;
  localparam Condition_lt = 4'd2;
  localparam Condition_ge = 4'd3;
  localparam Condition_leu = 4'd4;
  localparam Condition_gtu = 4'd5;
  localparam Condition_ltu = 4'd6;
  localparam Condition_geu = 4'd7;
  localparam Condition_eq = 4'd8;
  localparam Condition_ne = 4'd9;
  localparam Condition_t = 4'd10;
  localparam Condition_f = 4'd11;

  wire       [15:0]   alu_1_io_operand1;
  wire       [15:0]   alu_1_io_operand2;
  wire       [15:0]   pcCalc_1_io_operand2;
  wire       [15:0]   selectors_0_io_dataOut;
  wire       [15:0]   selectors_1_io_dataOut;
  wire       [15:0]   alu_1_io_dataOut;
  wire                alu_1_io_conditionMet;
  wire                alu_1_io_highByteZero;
  wire       [15:0]   pcCalc_1_io_nextPc;
  `ifndef SYNTHESIS
  reg [103:0] io_control_selection_0_string;
  reg [103:0] io_control_selection_1_string;
  reg [135:0] io_control_pcControl_condition_string;
  reg [135:0] io_control_pcControl_truePath_string;
  reg [63:0] io_control_aluControl_operation_string;
  reg [23:0] io_control_aluControl_condition_string;
  `endif


  OperandSelector selectors_0 (
    .io_selection    (io_control_selection_0[2:0]   ), //i
    .io_register     (io_registers_0[15:0]          ), //i
    .io_pc           (io_pc[15:0]                   ), //i
    .io_memory       (io_memory[7:0]                ), //i
    .io_dataOut      (selectors_0_io_dataOut[15:0]  )  //o
  );
  OperandSelector selectors_1 (
    .io_selection    (io_control_selection_1[2:0]   ), //i
    .io_register     (io_registers_1[15:0]          ), //i
    .io_pc           (io_pc[15:0]                   ), //i
    .io_memory       (io_memory[7:0]                ), //i
    .io_dataOut      (selectors_1_io_dataOut[15:0]  )  //o
  );
  Alu alu_1 (
    .io_operand1             (alu_1_io_operand1[15:0]               ), //i
    .io_operand2             (alu_1_io_operand2[15:0]               ), //i
    .io_control_operation    (io_control_aluControl_operation[3:0]  ), //i
    .io_control_condition    (io_control_aluControl_condition[3:0]  ), //i
    .io_dataOut              (alu_1_io_dataOut[15:0]                ), //o
    .io_conditionMet         (alu_1_io_conditionMet                 ), //o
    .io_highByteZero         (alu_1_io_highByteZero                 )  //o
  );
  PcCalc pcCalc_1 (
    .io_pc                       (io_pc[15:0]                          ), //i
    .io_operand2                 (pcCalc_1_io_operand2[15:0]           ), //i
    .io_memory                   (io_memory[7:0]                       ), //i
    .io_conditionMet             (alu_1_io_conditionMet                ), //i
    .io_resultZero               (alu_1_io_highByteZero                ), //i
    .io_control_condition        (io_control_pcControl_condition[1:0]  ), //i
    .io_control_truePath         (io_control_pcControl_truePath[2:0]   ), //i
    .io_control_decodedOffset    (io_control_pcControl_decodedOffset   ), //i
    .io_control_vector           (io_control_pcControl_vector[2:0]     ), //i
    .io_nextPc                   (pcCalc_1_io_nextPc[15:0]             )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_control_selection_0)
      OperandSource_zero : io_control_selection_0_string = "zero         ";
      OperandSource_ones : io_control_selection_0_string = "ones         ";
      OperandSource_register_1 : io_control_selection_0_string = "register_1   ";
      OperandSource_pc : io_control_selection_0_string = "pc           ";
      OperandSource_memory : io_control_selection_0_string = "memory       ";
      OperandSource_signed_memory : io_control_selection_0_string = "signed_memory";
      default : io_control_selection_0_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(io_control_selection_1)
      OperandSource_zero : io_control_selection_1_string = "zero         ";
      OperandSource_ones : io_control_selection_1_string = "ones         ";
      OperandSource_register_1 : io_control_selection_1_string = "register_1   ";
      OperandSource_pc : io_control_selection_1_string = "pc           ";
      OperandSource_memory : io_control_selection_1_string = "memory       ";
      OperandSource_signed_memory : io_control_selection_1_string = "signed_memory";
      default : io_control_selection_1_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(io_control_pcControl_condition)
      PcCondition_always_1 : io_control_pcControl_condition_string = "always_1         ";
      PcCondition_whenConditionMet : io_control_pcControl_condition_string = "whenConditionMet ";
      PcCondition_whenResultNotZero : io_control_pcControl_condition_string = "whenResultNotZero";
      default : io_control_pcControl_condition_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_control_pcControl_truePath)
      PcTruePathSource_offsetFromMemory : io_control_pcControl_truePath_string = "offsetFromMemory ";
      PcTruePathSource_offsetFromDecoder : io_control_pcControl_truePath_string = "offsetFromDecoder";
      PcTruePathSource_register2 : io_control_pcControl_truePath_string = "register2        ";
      PcTruePathSource_vectorFromMemory : io_control_pcControl_truePath_string = "vectorFromMemory ";
      PcTruePathSource_vectorFromDecoder : io_control_pcControl_truePath_string = "vectorFromDecoder";
      default : io_control_pcControl_truePath_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_control_aluControl_operation)
      AluOperation_add : io_control_aluControl_operation_string = "add     ";
      AluOperation_sub : io_control_aluControl_operation_string = "sub     ";
      AluOperation_compare : io_control_aluControl_operation_string = "compare ";
      AluOperation_extend1 : io_control_aluControl_operation_string = "extend1 ";
      AluOperation_and_1 : io_control_aluControl_operation_string = "and_1   ";
      AluOperation_or_1 : io_control_aluControl_operation_string = "or_1    ";
      AluOperation_xor_1 : io_control_aluControl_operation_string = "xor_1   ";
      AluOperation_operand1 : io_control_aluControl_operation_string = "operand1";
      AluOperation_ls : io_control_aluControl_operation_string = "ls      ";
      AluOperation_rs : io_control_aluControl_operation_string = "rs      ";
      AluOperation_rsa : io_control_aluControl_operation_string = "rsa     ";
      AluOperation_swap : io_control_aluControl_operation_string = "swap    ";
      default : io_control_aluControl_operation_string = "????????";
    endcase
  end
  always @(*) begin
    case(io_control_aluControl_condition)
      Condition_le : io_control_aluControl_condition_string = "le ";
      Condition_gt : io_control_aluControl_condition_string = "gt ";
      Condition_lt : io_control_aluControl_condition_string = "lt ";
      Condition_ge : io_control_aluControl_condition_string = "ge ";
      Condition_leu : io_control_aluControl_condition_string = "leu";
      Condition_gtu : io_control_aluControl_condition_string = "gtu";
      Condition_ltu : io_control_aluControl_condition_string = "ltu";
      Condition_geu : io_control_aluControl_condition_string = "geu";
      Condition_eq : io_control_aluControl_condition_string = "eq ";
      Condition_ne : io_control_aluControl_condition_string = "ne ";
      Condition_t : io_control_aluControl_condition_string = "t  ";
      Condition_f : io_control_aluControl_condition_string = "f  ";
      default : io_control_aluControl_condition_string = "???";
    endcase
  end
  `endif

  assign alu_1_io_operand1 = selectors_0_io_dataOut;
  assign alu_1_io_operand2 = selectors_1_io_dataOut;
  assign pcCalc_1_io_operand2 = selectors_1_io_dataOut;
  assign io_dataOut = alu_1_io_dataOut;
  assign io_nextPc = pcCalc_1_io_nextPc;

endmodule

module RegisterFile (
  input      [3:0]    io_readRegisters_0,
  input      [3:0]    io_readRegisters_1,
  output     [15:0]   io_dataOut_0,
  output     [15:0]   io_dataOut_1,
  input      [7:0]    io_pointers_0,
  input      [7:0]    io_pointers_1,
  input      [7:0]    io_pointers_2,
  input      [7:0]    io_pointers_3,
  input               io_control_write,
  input      [3:0]    io_control_writeRegister,
  input               io_control_writeExg,
  input      [3:0]    io_control_writeExgRegister,
  input               io_control_registerControl_0_push,
  input               io_control_registerControl_0_pop,
  input               io_control_registerControl_0_swap,
  input               io_control_registerControl_0_pick,
  input               io_control_registerControl_1_push,
  input               io_control_registerControl_1_pop,
  input               io_control_registerControl_1_swap,
  input               io_control_registerControl_1_pick,
  input               io_control_registerControl_2_push,
  input               io_control_registerControl_2_pop,
  input               io_control_registerControl_2_swap,
  input               io_control_registerControl_2_pick,
  input               io_control_registerControl_3_push,
  input               io_control_registerControl_3_pop,
  input               io_control_registerControl_3_swap,
  input               io_control_registerControl_3_pick,
  input      [15:0]   io_dataIn,
  input      [15:0]   io_dataInExg,
  input               bus_clk,
  input               bus_reset,
  input               when_ClockDomain_l353_regNext
);
  localparam RegisterName_f = 4'd0;
  localparam RegisterName_t = 4'd1;
  localparam RegisterName_b = 4'd2;
  localparam RegisterName_c = 4'd3;
  localparam RegisterName_d = 4'd4;
  localparam RegisterName_e = 4'd5;
  localparam RegisterName_h = 4'd6;
  localparam RegisterName_l = 4'd7;
  localparam RegisterName_ft = 4'd8;
  localparam RegisterName_bc = 4'd9;
  localparam RegisterName_de = 4'd10;
  localparam RegisterName_hl = 4'd11;

  wire       [7:0]    registers_0_io_dataIn;
  wire       [7:0]    registers_0_io_dataInExg;
  wire                registers_0_io_write;
  wire                registers_0_io_writeExg;
  wire       [7:0]    registers_0_io_pick;
  wire       [7:0]    registers_1_io_dataIn;
  wire       [7:0]    registers_1_io_dataInExg;
  wire                registers_1_io_write;
  wire                registers_1_io_writeExg;
  wire       [7:0]    registers_1_io_pick;
  wire       [7:0]    registers_2_io_dataIn;
  wire       [7:0]    registers_2_io_dataInExg;
  wire                registers_2_io_write;
  wire                registers_2_io_writeExg;
  wire       [7:0]    registers_2_io_pick;
  wire       [7:0]    registers_3_io_dataIn;
  wire       [7:0]    registers_3_io_dataInExg;
  wire                registers_3_io_write;
  wire                registers_3_io_writeExg;
  wire       [7:0]    registers_3_io_pick;
  wire       [7:0]    registers_4_io_dataIn;
  wire       [7:0]    registers_4_io_dataInExg;
  wire                registers_4_io_write;
  wire                registers_4_io_writeExg;
  wire       [7:0]    registers_4_io_pick;
  wire       [7:0]    registers_5_io_dataIn;
  wire       [7:0]    registers_5_io_dataInExg;
  wire                registers_5_io_write;
  wire                registers_5_io_writeExg;
  wire       [7:0]    registers_5_io_pick;
  wire       [7:0]    registers_6_io_dataIn;
  wire       [7:0]    registers_6_io_dataInExg;
  wire                registers_6_io_write;
  wire                registers_6_io_writeExg;
  wire       [7:0]    registers_6_io_pick;
  wire       [7:0]    registers_7_io_dataIn;
  wire       [7:0]    registers_7_io_dataInExg;
  wire                registers_7_io_write;
  wire                registers_7_io_writeExg;
  wire       [7:0]    registers_7_io_pick;
  wire       [7:0]    registers_0_io_dataOut;
  wire       [7:0]    registers_1_io_dataOut;
  wire       [7:0]    registers_2_io_dataOut;
  wire       [7:0]    registers_3_io_dataOut;
  wire       [7:0]    registers_4_io_dataOut;
  wire       [7:0]    registers_5_io_dataOut;
  wire       [7:0]    registers_6_io_dataOut;
  wire       [7:0]    registers_7_io_dataOut;
  wire       [3:0]    _zz__zz_io_control_push;
  reg        [7:0]    _zz__zz_io_pointer;
  reg                 _zz__zz_io_control_push_1;
  reg                 _zz__zz_io_control_pop;
  reg                 _zz__zz_io_control_swap;
  reg                 _zz__zz_io_control_pick;
  wire       [3:0]    _zz__zz_io_dataIn;
  wire       [3:0]    _zz__zz_io_control_push_2;
  reg        [7:0]    _zz__zz_io_pointer_1;
  reg                 _zz__zz_io_control_push_3;
  reg                 _zz__zz_io_control_pop_1;
  reg                 _zz__zz_io_control_swap_1;
  reg                 _zz__zz_io_control_pick_1;
  wire       [3:0]    _zz__zz_io_dataIn_1;
  wire       [3:0]    _zz__zz_io_control_push_4;
  reg        [7:0]    _zz__zz_io_pointer_2;
  reg                 _zz__zz_io_control_push_5;
  reg                 _zz__zz_io_control_pop_2;
  reg                 _zz__zz_io_control_swap_2;
  reg                 _zz__zz_io_control_pick_2;
  wire       [3:0]    _zz__zz_io_dataIn_2;
  wire       [3:0]    _zz__zz_io_control_push_6;
  reg        [7:0]    _zz__zz_io_pointer_3;
  reg                 _zz__zz_io_control_push_7;
  reg                 _zz__zz_io_control_pop_3;
  reg                 _zz__zz_io_control_swap_3;
  reg                 _zz__zz_io_control_pick_3;
  wire       [3:0]    _zz__zz_io_dataIn_3;
  wire       [1:0]    _zz_io_control_push;
  wire       [7:0]    _zz_io_pointer;
  wire                _zz_io_control_push_1;
  wire                _zz_io_control_pop;
  wire                _zz_io_control_swap;
  wire                _zz_io_control_pick;
  wire                _zz_io_dataIn;
  wire       [1:0]    _zz_io_control_push_2;
  wire       [7:0]    _zz_io_pointer_1;
  wire                _zz_io_control_push_3;
  wire                _zz_io_control_pop_1;
  wire                _zz_io_control_swap_1;
  wire                _zz_io_control_pick_1;
  wire                _zz_io_dataIn_1;
  wire       [1:0]    _zz_io_control_push_4;
  wire       [7:0]    _zz_io_pointer_2;
  wire                _zz_io_control_push_5;
  wire                _zz_io_control_pop_2;
  wire                _zz_io_control_swap_2;
  wire                _zz_io_control_pick_2;
  wire                _zz_io_dataIn_2;
  wire       [1:0]    _zz_io_control_push_6;
  wire       [7:0]    _zz_io_pointer_3;
  wire                _zz_io_control_push_7;
  wire                _zz_io_control_pop_3;
  wire                _zz_io_control_swap_3;
  wire                _zz_io_control_pick_3;
  wire                _zz_io_dataIn_3;
  reg        [15:0]   _zz_io_dataOut_0;
  reg        [15:0]   _zz_io_dataOut_1;
  `ifndef SYNTHESIS
  reg [15:0] io_readRegisters_0_string;
  reg [15:0] io_readRegisters_1_string;
  reg [15:0] io_control_writeRegister_string;
  reg [15:0] io_control_writeExgRegister_string;
  `endif


  assign _zz__zz_io_control_push = RegisterName_ft;
  assign _zz__zz_io_dataIn = io_control_writeRegister;
  assign _zz__zz_io_control_push_2 = RegisterName_bc;
  assign _zz__zz_io_dataIn_1 = io_control_writeRegister;
  assign _zz__zz_io_control_push_4 = RegisterName_de;
  assign _zz__zz_io_dataIn_2 = io_control_writeRegister;
  assign _zz__zz_io_control_push_6 = RegisterName_hl;
  assign _zz__zz_io_dataIn_3 = io_control_writeRegister;
  Register_9 registers_0 (
    .io_dataIn                        (registers_0_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_0_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_1          ), //i
    .io_control_pop                   (_zz_io_control_pop             ), //i
    .io_control_swap                  (_zz_io_control_swap            ), //i
    .io_control_pick                  (_zz_io_control_pick            ), //i
    .io_write                         (registers_0_io_write           ), //i
    .io_writeExg                      (registers_0_io_writeExg        ), //i
    .io_pick                          (registers_0_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer[7:0]            ), //i
    .io_dataOut                       (registers_0_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_1 (
    .io_dataIn                        (registers_1_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_1_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_1          ), //i
    .io_control_pop                   (_zz_io_control_pop             ), //i
    .io_control_swap                  (_zz_io_control_swap            ), //i
    .io_control_pick                  (_zz_io_control_pick            ), //i
    .io_write                         (registers_1_io_write           ), //i
    .io_writeExg                      (registers_1_io_writeExg        ), //i
    .io_pick                          (registers_1_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer[7:0]            ), //i
    .io_dataOut                       (registers_1_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_2 (
    .io_dataIn                        (registers_2_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_2_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_3          ), //i
    .io_control_pop                   (_zz_io_control_pop_1           ), //i
    .io_control_swap                  (_zz_io_control_swap_1          ), //i
    .io_control_pick                  (_zz_io_control_pick_1          ), //i
    .io_write                         (registers_2_io_write           ), //i
    .io_writeExg                      (registers_2_io_writeExg        ), //i
    .io_pick                          (registers_2_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer_1[7:0]          ), //i
    .io_dataOut                       (registers_2_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_3 (
    .io_dataIn                        (registers_3_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_3_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_3          ), //i
    .io_control_pop                   (_zz_io_control_pop_1           ), //i
    .io_control_swap                  (_zz_io_control_swap_1          ), //i
    .io_control_pick                  (_zz_io_control_pick_1          ), //i
    .io_write                         (registers_3_io_write           ), //i
    .io_writeExg                      (registers_3_io_writeExg        ), //i
    .io_pick                          (registers_3_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer_1[7:0]          ), //i
    .io_dataOut                       (registers_3_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_4 (
    .io_dataIn                        (registers_4_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_4_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_5          ), //i
    .io_control_pop                   (_zz_io_control_pop_2           ), //i
    .io_control_swap                  (_zz_io_control_swap_2          ), //i
    .io_control_pick                  (_zz_io_control_pick_2          ), //i
    .io_write                         (registers_4_io_write           ), //i
    .io_writeExg                      (registers_4_io_writeExg        ), //i
    .io_pick                          (registers_4_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer_2[7:0]          ), //i
    .io_dataOut                       (registers_4_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_5 (
    .io_dataIn                        (registers_5_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_5_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_5          ), //i
    .io_control_pop                   (_zz_io_control_pop_2           ), //i
    .io_control_swap                  (_zz_io_control_swap_2          ), //i
    .io_control_pick                  (_zz_io_control_pick_2          ), //i
    .io_write                         (registers_5_io_write           ), //i
    .io_writeExg                      (registers_5_io_writeExg        ), //i
    .io_pick                          (registers_5_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer_2[7:0]          ), //i
    .io_dataOut                       (registers_5_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_6 (
    .io_dataIn                        (registers_6_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_6_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_7          ), //i
    .io_control_pop                   (_zz_io_control_pop_3           ), //i
    .io_control_swap                  (_zz_io_control_swap_3          ), //i
    .io_control_pick                  (_zz_io_control_pick_3          ), //i
    .io_write                         (registers_6_io_write           ), //i
    .io_writeExg                      (registers_6_io_writeExg        ), //i
    .io_pick                          (registers_6_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer_3[7:0]          ), //i
    .io_dataOut                       (registers_6_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  Register_9 registers_7 (
    .io_dataIn                        (registers_7_io_dataIn[7:0]     ), //i
    .io_dataInExg                     (registers_7_io_dataInExg[7:0]  ), //i
    .io_control_push                  (_zz_io_control_push_7          ), //i
    .io_control_pop                   (_zz_io_control_pop_3           ), //i
    .io_control_swap                  (_zz_io_control_swap_3          ), //i
    .io_control_pick                  (_zz_io_control_pick_3          ), //i
    .io_write                         (registers_7_io_write           ), //i
    .io_writeExg                      (registers_7_io_writeExg        ), //i
    .io_pick                          (registers_7_io_pick[7:0]       ), //i
    .io_pointer                       (_zz_io_pointer_3[7:0]          ), //i
    .io_dataOut                       (registers_7_io_dataOut[7:0]    ), //o
    .bus_clk                          (bus_clk                        ), //i
    .bus_reset                        (bus_reset                      ), //i
    .when_ClockDomain_l353_regNext    (when_ClockDomain_l353_regNext  )  //i
  );
  always @(*) begin
    case(_zz_io_control_push)
      2'b00 : begin
        _zz__zz_io_pointer = io_pointers_0;
        _zz__zz_io_control_push_1 = io_control_registerControl_0_push;
        _zz__zz_io_control_pop = io_control_registerControl_0_pop;
        _zz__zz_io_control_swap = io_control_registerControl_0_swap;
        _zz__zz_io_control_pick = io_control_registerControl_0_pick;
      end
      2'b01 : begin
        _zz__zz_io_pointer = io_pointers_1;
        _zz__zz_io_control_push_1 = io_control_registerControl_1_push;
        _zz__zz_io_control_pop = io_control_registerControl_1_pop;
        _zz__zz_io_control_swap = io_control_registerControl_1_swap;
        _zz__zz_io_control_pick = io_control_registerControl_1_pick;
      end
      2'b10 : begin
        _zz__zz_io_pointer = io_pointers_2;
        _zz__zz_io_control_push_1 = io_control_registerControl_2_push;
        _zz__zz_io_control_pop = io_control_registerControl_2_pop;
        _zz__zz_io_control_swap = io_control_registerControl_2_swap;
        _zz__zz_io_control_pick = io_control_registerControl_2_pick;
      end
      default : begin
        _zz__zz_io_pointer = io_pointers_3;
        _zz__zz_io_control_push_1 = io_control_registerControl_3_push;
        _zz__zz_io_control_pop = io_control_registerControl_3_pop;
        _zz__zz_io_control_swap = io_control_registerControl_3_swap;
        _zz__zz_io_control_pick = io_control_registerControl_3_pick;
      end
    endcase
  end

  always @(*) begin
    case(_zz_io_control_push_2)
      2'b00 : begin
        _zz__zz_io_pointer_1 = io_pointers_0;
        _zz__zz_io_control_push_3 = io_control_registerControl_0_push;
        _zz__zz_io_control_pop_1 = io_control_registerControl_0_pop;
        _zz__zz_io_control_swap_1 = io_control_registerControl_0_swap;
        _zz__zz_io_control_pick_1 = io_control_registerControl_0_pick;
      end
      2'b01 : begin
        _zz__zz_io_pointer_1 = io_pointers_1;
        _zz__zz_io_control_push_3 = io_control_registerControl_1_push;
        _zz__zz_io_control_pop_1 = io_control_registerControl_1_pop;
        _zz__zz_io_control_swap_1 = io_control_registerControl_1_swap;
        _zz__zz_io_control_pick_1 = io_control_registerControl_1_pick;
      end
      2'b10 : begin
        _zz__zz_io_pointer_1 = io_pointers_2;
        _zz__zz_io_control_push_3 = io_control_registerControl_2_push;
        _zz__zz_io_control_pop_1 = io_control_registerControl_2_pop;
        _zz__zz_io_control_swap_1 = io_control_registerControl_2_swap;
        _zz__zz_io_control_pick_1 = io_control_registerControl_2_pick;
      end
      default : begin
        _zz__zz_io_pointer_1 = io_pointers_3;
        _zz__zz_io_control_push_3 = io_control_registerControl_3_push;
        _zz__zz_io_control_pop_1 = io_control_registerControl_3_pop;
        _zz__zz_io_control_swap_1 = io_control_registerControl_3_swap;
        _zz__zz_io_control_pick_1 = io_control_registerControl_3_pick;
      end
    endcase
  end

  always @(*) begin
    case(_zz_io_control_push_4)
      2'b00 : begin
        _zz__zz_io_pointer_2 = io_pointers_0;
        _zz__zz_io_control_push_5 = io_control_registerControl_0_push;
        _zz__zz_io_control_pop_2 = io_control_registerControl_0_pop;
        _zz__zz_io_control_swap_2 = io_control_registerControl_0_swap;
        _zz__zz_io_control_pick_2 = io_control_registerControl_0_pick;
      end
      2'b01 : begin
        _zz__zz_io_pointer_2 = io_pointers_1;
        _zz__zz_io_control_push_5 = io_control_registerControl_1_push;
        _zz__zz_io_control_pop_2 = io_control_registerControl_1_pop;
        _zz__zz_io_control_swap_2 = io_control_registerControl_1_swap;
        _zz__zz_io_control_pick_2 = io_control_registerControl_1_pick;
      end
      2'b10 : begin
        _zz__zz_io_pointer_2 = io_pointers_2;
        _zz__zz_io_control_push_5 = io_control_registerControl_2_push;
        _zz__zz_io_control_pop_2 = io_control_registerControl_2_pop;
        _zz__zz_io_control_swap_2 = io_control_registerControl_2_swap;
        _zz__zz_io_control_pick_2 = io_control_registerControl_2_pick;
      end
      default : begin
        _zz__zz_io_pointer_2 = io_pointers_3;
        _zz__zz_io_control_push_5 = io_control_registerControl_3_push;
        _zz__zz_io_control_pop_2 = io_control_registerControl_3_pop;
        _zz__zz_io_control_swap_2 = io_control_registerControl_3_swap;
        _zz__zz_io_control_pick_2 = io_control_registerControl_3_pick;
      end
    endcase
  end

  always @(*) begin
    case(_zz_io_control_push_6)
      2'b00 : begin
        _zz__zz_io_pointer_3 = io_pointers_0;
        _zz__zz_io_control_push_7 = io_control_registerControl_0_push;
        _zz__zz_io_control_pop_3 = io_control_registerControl_0_pop;
        _zz__zz_io_control_swap_3 = io_control_registerControl_0_swap;
        _zz__zz_io_control_pick_3 = io_control_registerControl_0_pick;
      end
      2'b01 : begin
        _zz__zz_io_pointer_3 = io_pointers_1;
        _zz__zz_io_control_push_7 = io_control_registerControl_1_push;
        _zz__zz_io_control_pop_3 = io_control_registerControl_1_pop;
        _zz__zz_io_control_swap_3 = io_control_registerControl_1_swap;
        _zz__zz_io_control_pick_3 = io_control_registerControl_1_pick;
      end
      2'b10 : begin
        _zz__zz_io_pointer_3 = io_pointers_2;
        _zz__zz_io_control_push_7 = io_control_registerControl_2_push;
        _zz__zz_io_control_pop_3 = io_control_registerControl_2_pop;
        _zz__zz_io_control_swap_3 = io_control_registerControl_2_swap;
        _zz__zz_io_control_pick_3 = io_control_registerControl_2_pick;
      end
      default : begin
        _zz__zz_io_pointer_3 = io_pointers_3;
        _zz__zz_io_control_push_7 = io_control_registerControl_3_push;
        _zz__zz_io_control_pop_3 = io_control_registerControl_3_pop;
        _zz__zz_io_control_swap_3 = io_control_registerControl_3_swap;
        _zz__zz_io_control_pick_3 = io_control_registerControl_3_pick;
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_readRegisters_0)
      RegisterName_f : io_readRegisters_0_string = "f ";
      RegisterName_t : io_readRegisters_0_string = "t ";
      RegisterName_b : io_readRegisters_0_string = "b ";
      RegisterName_c : io_readRegisters_0_string = "c ";
      RegisterName_d : io_readRegisters_0_string = "d ";
      RegisterName_e : io_readRegisters_0_string = "e ";
      RegisterName_h : io_readRegisters_0_string = "h ";
      RegisterName_l : io_readRegisters_0_string = "l ";
      RegisterName_ft : io_readRegisters_0_string = "ft";
      RegisterName_bc : io_readRegisters_0_string = "bc";
      RegisterName_de : io_readRegisters_0_string = "de";
      RegisterName_hl : io_readRegisters_0_string = "hl";
      default : io_readRegisters_0_string = "??";
    endcase
  end
  always @(*) begin
    case(io_readRegisters_1)
      RegisterName_f : io_readRegisters_1_string = "f ";
      RegisterName_t : io_readRegisters_1_string = "t ";
      RegisterName_b : io_readRegisters_1_string = "b ";
      RegisterName_c : io_readRegisters_1_string = "c ";
      RegisterName_d : io_readRegisters_1_string = "d ";
      RegisterName_e : io_readRegisters_1_string = "e ";
      RegisterName_h : io_readRegisters_1_string = "h ";
      RegisterName_l : io_readRegisters_1_string = "l ";
      RegisterName_ft : io_readRegisters_1_string = "ft";
      RegisterName_bc : io_readRegisters_1_string = "bc";
      RegisterName_de : io_readRegisters_1_string = "de";
      RegisterName_hl : io_readRegisters_1_string = "hl";
      default : io_readRegisters_1_string = "??";
    endcase
  end
  always @(*) begin
    case(io_control_writeRegister)
      RegisterName_f : io_control_writeRegister_string = "f ";
      RegisterName_t : io_control_writeRegister_string = "t ";
      RegisterName_b : io_control_writeRegister_string = "b ";
      RegisterName_c : io_control_writeRegister_string = "c ";
      RegisterName_d : io_control_writeRegister_string = "d ";
      RegisterName_e : io_control_writeRegister_string = "e ";
      RegisterName_h : io_control_writeRegister_string = "h ";
      RegisterName_l : io_control_writeRegister_string = "l ";
      RegisterName_ft : io_control_writeRegister_string = "ft";
      RegisterName_bc : io_control_writeRegister_string = "bc";
      RegisterName_de : io_control_writeRegister_string = "de";
      RegisterName_hl : io_control_writeRegister_string = "hl";
      default : io_control_writeRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(io_control_writeExgRegister)
      RegisterName_f : io_control_writeExgRegister_string = "f ";
      RegisterName_t : io_control_writeExgRegister_string = "t ";
      RegisterName_b : io_control_writeExgRegister_string = "b ";
      RegisterName_c : io_control_writeExgRegister_string = "c ";
      RegisterName_d : io_control_writeExgRegister_string = "d ";
      RegisterName_e : io_control_writeExgRegister_string = "e ";
      RegisterName_h : io_control_writeExgRegister_string = "h ";
      RegisterName_l : io_control_writeExgRegister_string = "l ";
      RegisterName_ft : io_control_writeExgRegister_string = "ft";
      RegisterName_bc : io_control_writeExgRegister_string = "bc";
      RegisterName_de : io_control_writeExgRegister_string = "de";
      RegisterName_hl : io_control_writeExgRegister_string = "hl";
      default : io_control_writeExgRegister_string = "??";
    endcase
  end
  `endif

  assign _zz_io_control_push = _zz__zz_io_control_push[1 : 0];
  assign _zz_io_pointer = _zz__zz_io_pointer;
  assign _zz_io_control_push_1 = _zz__zz_io_control_push_1;
  assign _zz_io_control_pop = _zz__zz_io_control_pop;
  assign _zz_io_control_swap = _zz__zz_io_control_swap;
  assign _zz_io_control_pick = _zz__zz_io_control_pick;
  assign _zz_io_dataIn = _zz__zz_io_dataIn[3];
  assign registers_0_io_pick = registers_1_io_dataOut;
  assign registers_0_io_dataIn = io_dataIn[15 : 8];
  assign registers_0_io_dataInExg = io_dataInExg[15 : 8];
  assign registers_0_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_f) || (RegisterName_ft == io_control_writeRegister)));
  assign registers_0_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_f) || (RegisterName_ft == io_control_writeExgRegister)));
  assign registers_1_io_pick = registers_1_io_dataOut;
  assign registers_1_io_dataIn = (_zz_io_dataIn ? io_dataIn[7 : 0] : io_dataIn[15 : 8]);
  assign registers_1_io_dataInExg = (_zz_io_dataIn ? io_dataInExg[7 : 0] : io_dataInExg[15 : 8]);
  assign registers_1_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_t) || (RegisterName_ft == io_control_writeRegister)));
  assign registers_1_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_t) || (RegisterName_ft == io_control_writeExgRegister)));
  assign _zz_io_control_push_2 = _zz__zz_io_control_push_2[1 : 0];
  assign _zz_io_pointer_1 = _zz__zz_io_pointer_1;
  assign _zz_io_control_push_3 = _zz__zz_io_control_push_3;
  assign _zz_io_control_pop_1 = _zz__zz_io_control_pop_1;
  assign _zz_io_control_swap_1 = _zz__zz_io_control_swap_1;
  assign _zz_io_control_pick_1 = _zz__zz_io_control_pick_1;
  assign _zz_io_dataIn_1 = _zz__zz_io_dataIn_1[3];
  assign registers_2_io_pick = registers_3_io_dataOut;
  assign registers_2_io_dataIn = io_dataIn[15 : 8];
  assign registers_2_io_dataInExg = io_dataInExg[15 : 8];
  assign registers_2_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_b) || (RegisterName_bc == io_control_writeRegister)));
  assign registers_2_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_b) || (RegisterName_bc == io_control_writeExgRegister)));
  assign registers_3_io_pick = registers_3_io_dataOut;
  assign registers_3_io_dataIn = (_zz_io_dataIn_1 ? io_dataIn[7 : 0] : io_dataIn[15 : 8]);
  assign registers_3_io_dataInExg = (_zz_io_dataIn_1 ? io_dataInExg[7 : 0] : io_dataInExg[15 : 8]);
  assign registers_3_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_c) || (RegisterName_bc == io_control_writeRegister)));
  assign registers_3_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_c) || (RegisterName_bc == io_control_writeExgRegister)));
  assign _zz_io_control_push_4 = _zz__zz_io_control_push_4[1 : 0];
  assign _zz_io_pointer_2 = _zz__zz_io_pointer_2;
  assign _zz_io_control_push_5 = _zz__zz_io_control_push_5;
  assign _zz_io_control_pop_2 = _zz__zz_io_control_pop_2;
  assign _zz_io_control_swap_2 = _zz__zz_io_control_swap_2;
  assign _zz_io_control_pick_2 = _zz__zz_io_control_pick_2;
  assign _zz_io_dataIn_2 = _zz__zz_io_dataIn_2[3];
  assign registers_4_io_pick = registers_5_io_dataOut;
  assign registers_4_io_dataIn = io_dataIn[15 : 8];
  assign registers_4_io_dataInExg = io_dataInExg[15 : 8];
  assign registers_4_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_d) || (RegisterName_de == io_control_writeRegister)));
  assign registers_4_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_d) || (RegisterName_de == io_control_writeExgRegister)));
  assign registers_5_io_pick = registers_5_io_dataOut;
  assign registers_5_io_dataIn = (_zz_io_dataIn_2 ? io_dataIn[7 : 0] : io_dataIn[15 : 8]);
  assign registers_5_io_dataInExg = (_zz_io_dataIn_2 ? io_dataInExg[7 : 0] : io_dataInExg[15 : 8]);
  assign registers_5_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_e) || (RegisterName_de == io_control_writeRegister)));
  assign registers_5_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_e) || (RegisterName_de == io_control_writeExgRegister)));
  assign _zz_io_control_push_6 = _zz__zz_io_control_push_6[1 : 0];
  assign _zz_io_pointer_3 = _zz__zz_io_pointer_3;
  assign _zz_io_control_push_7 = _zz__zz_io_control_push_7;
  assign _zz_io_control_pop_3 = _zz__zz_io_control_pop_3;
  assign _zz_io_control_swap_3 = _zz__zz_io_control_swap_3;
  assign _zz_io_control_pick_3 = _zz__zz_io_control_pick_3;
  assign _zz_io_dataIn_3 = _zz__zz_io_dataIn_3[3];
  assign registers_6_io_pick = registers_7_io_dataOut;
  assign registers_6_io_dataIn = io_dataIn[15 : 8];
  assign registers_6_io_dataInExg = io_dataInExg[15 : 8];
  assign registers_6_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_h) || (RegisterName_hl == io_control_writeRegister)));
  assign registers_6_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_h) || (RegisterName_hl == io_control_writeExgRegister)));
  assign registers_7_io_pick = registers_7_io_dataOut;
  assign registers_7_io_dataIn = (_zz_io_dataIn_3 ? io_dataIn[7 : 0] : io_dataIn[15 : 8]);
  assign registers_7_io_dataInExg = (_zz_io_dataIn_3 ? io_dataInExg[7 : 0] : io_dataInExg[15 : 8]);
  assign registers_7_io_write = (io_control_write && ((io_control_writeRegister == RegisterName_l) || (RegisterName_hl == io_control_writeRegister)));
  assign registers_7_io_writeExg = (io_control_writeExg && ((io_control_writeExgRegister == RegisterName_l) || (RegisterName_hl == io_control_writeExgRegister)));
  always @(*) begin
    case(io_readRegisters_0)
      RegisterName_f : begin
        _zz_io_dataOut_0 = {registers_0_io_dataOut,8'h0};
      end
      RegisterName_t : begin
        _zz_io_dataOut_0 = {registers_1_io_dataOut,8'h0};
      end
      RegisterName_b : begin
        _zz_io_dataOut_0 = {registers_2_io_dataOut,8'h0};
      end
      RegisterName_c : begin
        _zz_io_dataOut_0 = {registers_3_io_dataOut,8'h0};
      end
      RegisterName_d : begin
        _zz_io_dataOut_0 = {registers_4_io_dataOut,8'h0};
      end
      RegisterName_e : begin
        _zz_io_dataOut_0 = {registers_5_io_dataOut,8'h0};
      end
      RegisterName_h : begin
        _zz_io_dataOut_0 = {registers_6_io_dataOut,8'h0};
      end
      RegisterName_l : begin
        _zz_io_dataOut_0 = {registers_7_io_dataOut,8'h0};
      end
      RegisterName_ft : begin
        _zz_io_dataOut_0 = {registers_0_io_dataOut,registers_1_io_dataOut};
      end
      RegisterName_bc : begin
        _zz_io_dataOut_0 = {registers_2_io_dataOut,registers_3_io_dataOut};
      end
      RegisterName_de : begin
        _zz_io_dataOut_0 = {registers_4_io_dataOut,registers_5_io_dataOut};
      end
      default : begin
        _zz_io_dataOut_0 = {registers_6_io_dataOut,registers_7_io_dataOut};
      end
    endcase
  end

  assign io_dataOut_0 = _zz_io_dataOut_0;
  always @(*) begin
    case(io_readRegisters_1)
      RegisterName_f : begin
        _zz_io_dataOut_1 = {registers_0_io_dataOut,8'h0};
      end
      RegisterName_t : begin
        _zz_io_dataOut_1 = {registers_1_io_dataOut,8'h0};
      end
      RegisterName_b : begin
        _zz_io_dataOut_1 = {registers_2_io_dataOut,8'h0};
      end
      RegisterName_c : begin
        _zz_io_dataOut_1 = {registers_3_io_dataOut,8'h0};
      end
      RegisterName_d : begin
        _zz_io_dataOut_1 = {registers_4_io_dataOut,8'h0};
      end
      RegisterName_e : begin
        _zz_io_dataOut_1 = {registers_5_io_dataOut,8'h0};
      end
      RegisterName_h : begin
        _zz_io_dataOut_1 = {registers_6_io_dataOut,8'h0};
      end
      RegisterName_l : begin
        _zz_io_dataOut_1 = {registers_7_io_dataOut,8'h0};
      end
      RegisterName_ft : begin
        _zz_io_dataOut_1 = {registers_0_io_dataOut,registers_1_io_dataOut};
      end
      RegisterName_bc : begin
        _zz_io_dataOut_1 = {registers_2_io_dataOut,registers_3_io_dataOut};
      end
      RegisterName_de : begin
        _zz_io_dataOut_1 = {registers_4_io_dataOut,registers_5_io_dataOut};
      end
      default : begin
        _zz_io_dataOut_1 = {registers_6_io_dataOut,registers_7_io_dataOut};
      end
    endcase
  end

  assign io_dataOut_1 = _zz_io_dataOut_1;

endmodule

module Decoder (
  input               io_strobe,
  input      [7:0]    io_opcodeAsync,
  input               io_nmiReq,
  input               io_intReq,
  input               io_intEnable,
  input               io_nmiActive,
  input               io_intActive,
  input               io_sysActive,
  output reg [3:0]    io_output_stageControl_readStageControl_registers_0,
  output reg [3:0]    io_output_stageControl_readStageControl_registers_1,
  output reg          io_output_stageControl_memoryStageControl_enable,
  output              io_output_stageControl_memoryStageControl_write,
  output              io_output_stageControl_memoryStageControl_io,
  output              io_output_stageControl_memoryStageControl_code,
  output              io_output_stageControl_memoryStageControl_config,
  output     [0:0]    io_output_stageControl_memoryStageControl_address,
  output reg [2:0]    io_output_stageControl_aluStageControl_selection_0,
  output reg [2:0]    io_output_stageControl_aluStageControl_selection_1,
  output     [1:0]    io_output_stageControl_aluStageControl_pcControl_condition,
  output reg [2:0]    io_output_stageControl_aluStageControl_pcControl_truePath,
  output     [0:0]    io_output_stageControl_aluStageControl_pcControl_decodedOffset,
  output reg [2:0]    io_output_stageControl_aluStageControl_pcControl_vector,
  output reg [3:0]    io_output_stageControl_aluStageControl_aluControl_operation,
  output     [3:0]    io_output_stageControl_aluStageControl_aluControl_condition,
  output reg [0:0]    io_output_stageControl_writeStageControl_source,
  output reg          io_output_stageControl_writeStageControl_fileControl_write,
  output reg [3:0]    io_output_stageControl_writeStageControl_fileControl_writeRegister,
  output              io_output_stageControl_writeStageControl_fileControl_writeExg,
  output     [3:0]    io_output_stageControl_writeStageControl_fileControl_writeExgRegister,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_0_push,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_1_push,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_2_push,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_3_push,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap,
  output              io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick,
  output reg          io_output_intEnable,
  output reg          io_output_nmiActive,
  output reg          io_output_intActive,
  output reg          io_output_sysActive,
  input               bus_clk,
  input               bus_reset,
  input               when_ClockDomain_l353_regNext
);
  localparam RegisterName_f = 4'd0;
  localparam RegisterName_t = 4'd1;
  localparam RegisterName_b = 4'd2;
  localparam RegisterName_c = 4'd3;
  localparam RegisterName_d = 4'd4;
  localparam RegisterName_e = 4'd5;
  localparam RegisterName_h = 4'd6;
  localparam RegisterName_l = 4'd7;
  localparam RegisterName_ft = 4'd8;
  localparam RegisterName_bc = 4'd9;
  localparam RegisterName_de = 4'd10;
  localparam RegisterName_hl = 4'd11;
  localparam MemoryStageAddressSource_register1 = 1'd0;
  localparam MemoryStageAddressSource_pc = 1'd1;
  localparam OperandSource_zero = 3'd0;
  localparam OperandSource_ones = 3'd1;
  localparam OperandSource_register_1 = 3'd2;
  localparam OperandSource_pc = 3'd3;
  localparam OperandSource_memory = 3'd4;
  localparam OperandSource_signed_memory = 3'd5;
  localparam PcCondition_always_1 = 2'd0;
  localparam PcCondition_whenConditionMet = 2'd1;
  localparam PcCondition_whenResultNotZero = 2'd2;
  localparam PcTruePathSource_offsetFromMemory = 3'd0;
  localparam PcTruePathSource_offsetFromDecoder = 3'd1;
  localparam PcTruePathSource_register2 = 3'd2;
  localparam PcTruePathSource_vectorFromMemory = 3'd3;
  localparam PcTruePathSource_vectorFromDecoder = 3'd4;
  localparam AluOperation_add = 4'd0;
  localparam AluOperation_sub = 4'd1;
  localparam AluOperation_compare = 4'd2;
  localparam AluOperation_extend1 = 4'd3;
  localparam AluOperation_and_1 = 4'd4;
  localparam AluOperation_or_1 = 4'd5;
  localparam AluOperation_xor_1 = 4'd6;
  localparam AluOperation_operand1 = 4'd7;
  localparam AluOperation_ls = 4'd8;
  localparam AluOperation_rs = 4'd9;
  localparam AluOperation_rsa = 4'd10;
  localparam AluOperation_swap = 4'd11;
  localparam Condition_le = 4'd0;
  localparam Condition_gt = 4'd1;
  localparam Condition_lt = 4'd2;
  localparam Condition_ge = 4'd3;
  localparam Condition_leu = 4'd4;
  localparam Condition_gtu = 4'd5;
  localparam Condition_ltu = 4'd6;
  localparam Condition_geu = 4'd7;
  localparam Condition_eq = 4'd8;
  localparam Condition_ne = 4'd9;
  localparam Condition_t = 4'd10;
  localparam Condition_f = 4'd11;
  localparam WriteBackValueSource_alu = 1'd0;
  localparam WriteBackValueSource_memory = 1'd1;

  wire       [3:0]    decoder_1_io_output_stageControl_readStageControl_registers_0;
  wire       [3:0]    decoder_1_io_output_stageControl_readStageControl_registers_1;
  wire                decoder_1_io_output_stageControl_memoryStageControl_enable;
  wire                decoder_1_io_output_stageControl_memoryStageControl_write;
  wire                decoder_1_io_output_stageControl_memoryStageControl_io;
  wire                decoder_1_io_output_stageControl_memoryStageControl_code;
  wire                decoder_1_io_output_stageControl_memoryStageControl_config;
  wire       [0:0]    decoder_1_io_output_stageControl_memoryStageControl_address;
  wire       [2:0]    decoder_1_io_output_stageControl_aluStageControl_selection_0;
  wire       [2:0]    decoder_1_io_output_stageControl_aluStageControl_selection_1;
  wire       [1:0]    decoder_1_io_output_stageControl_aluStageControl_pcControl_condition;
  wire       [2:0]    decoder_1_io_output_stageControl_aluStageControl_pcControl_truePath;
  wire       [0:0]    decoder_1_io_output_stageControl_aluStageControl_pcControl_decodedOffset;
  wire       [2:0]    decoder_1_io_output_stageControl_aluStageControl_pcControl_vector;
  wire       [3:0]    decoder_1_io_output_stageControl_aluStageControl_aluControl_operation;
  wire       [3:0]    decoder_1_io_output_stageControl_aluStageControl_aluControl_condition;
  wire       [0:0]    decoder_1_io_output_stageControl_writeStageControl_source;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_write;
  wire       [3:0]    decoder_1_io_output_stageControl_writeStageControl_fileControl_writeRegister;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_writeExg;
  wire       [3:0]    decoder_1_io_output_stageControl_writeStageControl_fileControl_writeExgRegister;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap;
  wire                decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick;
  wire                decoder_1_io_output_illegal;
  wire       [3:0]    _zz__zz_1;
  reg        [7:0]    opcodeIn;
  wire       [7:0]    opcode;
  reg        [7:0]    opcodeOut;
  wire                decoderIllegal;
  wire                anyActive;
  wire                reqExtInt;
  reg                 performInterrupt;
  reg        [2:0]    interruptVector;
  wire       [3:0]    _zz_1;
  `ifndef SYNTHESIS
  reg [15:0] io_output_stageControl_readStageControl_registers_0_string;
  reg [15:0] io_output_stageControl_readStageControl_registers_1_string;
  reg [71:0] io_output_stageControl_memoryStageControl_address_string;
  reg [103:0] io_output_stageControl_aluStageControl_selection_0_string;
  reg [103:0] io_output_stageControl_aluStageControl_selection_1_string;
  reg [135:0] io_output_stageControl_aluStageControl_pcControl_condition_string;
  reg [135:0] io_output_stageControl_aluStageControl_pcControl_truePath_string;
  reg [63:0] io_output_stageControl_aluStageControl_aluControl_operation_string;
  reg [23:0] io_output_stageControl_aluStageControl_aluControl_condition_string;
  reg [47:0] io_output_stageControl_writeStageControl_source_string;
  reg [15:0] io_output_stageControl_writeStageControl_fileControl_writeRegister_string;
  reg [15:0] io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string;
  `endif


  assign _zz__zz_1 = RegisterName_hl;
  OpcodeDecoder decoder_1 (
    .io_opcode                                                                      (opcodeOut[7:0]                                                                         ), //i
    .io_output_stageControl_readStageControl_registers_0                            (decoder_1_io_output_stageControl_readStageControl_registers_0[3:0]                     ), //o
    .io_output_stageControl_readStageControl_registers_1                            (decoder_1_io_output_stageControl_readStageControl_registers_1[3:0]                     ), //o
    .io_output_stageControl_memoryStageControl_enable                               (decoder_1_io_output_stageControl_memoryStageControl_enable                             ), //o
    .io_output_stageControl_memoryStageControl_write                                (decoder_1_io_output_stageControl_memoryStageControl_write                              ), //o
    .io_output_stageControl_memoryStageControl_io                                   (decoder_1_io_output_stageControl_memoryStageControl_io                                 ), //o
    .io_output_stageControl_memoryStageControl_code                                 (decoder_1_io_output_stageControl_memoryStageControl_code                               ), //o
    .io_output_stageControl_memoryStageControl_config                               (decoder_1_io_output_stageControl_memoryStageControl_config                             ), //o
    .io_output_stageControl_memoryStageControl_address                              (decoder_1_io_output_stageControl_memoryStageControl_address                            ), //o
    .io_output_stageControl_aluStageControl_selection_0                             (decoder_1_io_output_stageControl_aluStageControl_selection_0[2:0]                      ), //o
    .io_output_stageControl_aluStageControl_selection_1                             (decoder_1_io_output_stageControl_aluStageControl_selection_1[2:0]                      ), //o
    .io_output_stageControl_aluStageControl_pcControl_condition                     (decoder_1_io_output_stageControl_aluStageControl_pcControl_condition[1:0]              ), //o
    .io_output_stageControl_aluStageControl_pcControl_truePath                      (decoder_1_io_output_stageControl_aluStageControl_pcControl_truePath[2:0]               ), //o
    .io_output_stageControl_aluStageControl_pcControl_decodedOffset                 (decoder_1_io_output_stageControl_aluStageControl_pcControl_decodedOffset               ), //o
    .io_output_stageControl_aluStageControl_pcControl_vector                        (decoder_1_io_output_stageControl_aluStageControl_pcControl_vector[2:0]                 ), //o
    .io_output_stageControl_aluStageControl_aluControl_operation                    (decoder_1_io_output_stageControl_aluStageControl_aluControl_operation[3:0]             ), //o
    .io_output_stageControl_aluStageControl_aluControl_condition                    (decoder_1_io_output_stageControl_aluStageControl_aluControl_condition[3:0]             ), //o
    .io_output_stageControl_writeStageControl_source                                (decoder_1_io_output_stageControl_writeStageControl_source                              ), //o
    .io_output_stageControl_writeStageControl_fileControl_write                     (decoder_1_io_output_stageControl_writeStageControl_fileControl_write                   ), //o
    .io_output_stageControl_writeStageControl_fileControl_writeRegister             (decoder_1_io_output_stageControl_writeStageControl_fileControl_writeRegister[3:0]      ), //o
    .io_output_stageControl_writeStageControl_fileControl_writeExg                  (decoder_1_io_output_stageControl_writeStageControl_fileControl_writeExg                ), //o
    .io_output_stageControl_writeStageControl_fileControl_writeExgRegister          (decoder_1_io_output_stageControl_writeStageControl_fileControl_writeExgRegister[3:0]   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_push    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop     (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_push    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop     (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_push    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop     (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_push    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop     (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop   ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap  ), //o
    .io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick    (decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick  ), //o
    .io_output_illegal                                                              (decoder_1_io_output_illegal                                                            )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_output_stageControl_readStageControl_registers_0)
      RegisterName_f : io_output_stageControl_readStageControl_registers_0_string = "f ";
      RegisterName_t : io_output_stageControl_readStageControl_registers_0_string = "t ";
      RegisterName_b : io_output_stageControl_readStageControl_registers_0_string = "b ";
      RegisterName_c : io_output_stageControl_readStageControl_registers_0_string = "c ";
      RegisterName_d : io_output_stageControl_readStageControl_registers_0_string = "d ";
      RegisterName_e : io_output_stageControl_readStageControl_registers_0_string = "e ";
      RegisterName_h : io_output_stageControl_readStageControl_registers_0_string = "h ";
      RegisterName_l : io_output_stageControl_readStageControl_registers_0_string = "l ";
      RegisterName_ft : io_output_stageControl_readStageControl_registers_0_string = "ft";
      RegisterName_bc : io_output_stageControl_readStageControl_registers_0_string = "bc";
      RegisterName_de : io_output_stageControl_readStageControl_registers_0_string = "de";
      RegisterName_hl : io_output_stageControl_readStageControl_registers_0_string = "hl";
      default : io_output_stageControl_readStageControl_registers_0_string = "??";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_readStageControl_registers_1)
      RegisterName_f : io_output_stageControl_readStageControl_registers_1_string = "f ";
      RegisterName_t : io_output_stageControl_readStageControl_registers_1_string = "t ";
      RegisterName_b : io_output_stageControl_readStageControl_registers_1_string = "b ";
      RegisterName_c : io_output_stageControl_readStageControl_registers_1_string = "c ";
      RegisterName_d : io_output_stageControl_readStageControl_registers_1_string = "d ";
      RegisterName_e : io_output_stageControl_readStageControl_registers_1_string = "e ";
      RegisterName_h : io_output_stageControl_readStageControl_registers_1_string = "h ";
      RegisterName_l : io_output_stageControl_readStageControl_registers_1_string = "l ";
      RegisterName_ft : io_output_stageControl_readStageControl_registers_1_string = "ft";
      RegisterName_bc : io_output_stageControl_readStageControl_registers_1_string = "bc";
      RegisterName_de : io_output_stageControl_readStageControl_registers_1_string = "de";
      RegisterName_hl : io_output_stageControl_readStageControl_registers_1_string = "hl";
      default : io_output_stageControl_readStageControl_registers_1_string = "??";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_memoryStageControl_address)
      MemoryStageAddressSource_register1 : io_output_stageControl_memoryStageControl_address_string = "register1";
      MemoryStageAddressSource_pc : io_output_stageControl_memoryStageControl_address_string = "pc       ";
      default : io_output_stageControl_memoryStageControl_address_string = "?????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_selection_0)
      OperandSource_zero : io_output_stageControl_aluStageControl_selection_0_string = "zero         ";
      OperandSource_ones : io_output_stageControl_aluStageControl_selection_0_string = "ones         ";
      OperandSource_register_1 : io_output_stageControl_aluStageControl_selection_0_string = "register_1   ";
      OperandSource_pc : io_output_stageControl_aluStageControl_selection_0_string = "pc           ";
      OperandSource_memory : io_output_stageControl_aluStageControl_selection_0_string = "memory       ";
      OperandSource_signed_memory : io_output_stageControl_aluStageControl_selection_0_string = "signed_memory";
      default : io_output_stageControl_aluStageControl_selection_0_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_selection_1)
      OperandSource_zero : io_output_stageControl_aluStageControl_selection_1_string = "zero         ";
      OperandSource_ones : io_output_stageControl_aluStageControl_selection_1_string = "ones         ";
      OperandSource_register_1 : io_output_stageControl_aluStageControl_selection_1_string = "register_1   ";
      OperandSource_pc : io_output_stageControl_aluStageControl_selection_1_string = "pc           ";
      OperandSource_memory : io_output_stageControl_aluStageControl_selection_1_string = "memory       ";
      OperandSource_signed_memory : io_output_stageControl_aluStageControl_selection_1_string = "signed_memory";
      default : io_output_stageControl_aluStageControl_selection_1_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_pcControl_condition)
      PcCondition_always_1 : io_output_stageControl_aluStageControl_pcControl_condition_string = "always_1         ";
      PcCondition_whenConditionMet : io_output_stageControl_aluStageControl_pcControl_condition_string = "whenConditionMet ";
      PcCondition_whenResultNotZero : io_output_stageControl_aluStageControl_pcControl_condition_string = "whenResultNotZero";
      default : io_output_stageControl_aluStageControl_pcControl_condition_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_pcControl_truePath)
      PcTruePathSource_offsetFromMemory : io_output_stageControl_aluStageControl_pcControl_truePath_string = "offsetFromMemory ";
      PcTruePathSource_offsetFromDecoder : io_output_stageControl_aluStageControl_pcControl_truePath_string = "offsetFromDecoder";
      PcTruePathSource_register2 : io_output_stageControl_aluStageControl_pcControl_truePath_string = "register2        ";
      PcTruePathSource_vectorFromMemory : io_output_stageControl_aluStageControl_pcControl_truePath_string = "vectorFromMemory ";
      PcTruePathSource_vectorFromDecoder : io_output_stageControl_aluStageControl_pcControl_truePath_string = "vectorFromDecoder";
      default : io_output_stageControl_aluStageControl_pcControl_truePath_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_aluControl_operation)
      AluOperation_add : io_output_stageControl_aluStageControl_aluControl_operation_string = "add     ";
      AluOperation_sub : io_output_stageControl_aluStageControl_aluControl_operation_string = "sub     ";
      AluOperation_compare : io_output_stageControl_aluStageControl_aluControl_operation_string = "compare ";
      AluOperation_extend1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "extend1 ";
      AluOperation_and_1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "and_1   ";
      AluOperation_or_1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "or_1    ";
      AluOperation_xor_1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "xor_1   ";
      AluOperation_operand1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "operand1";
      AluOperation_ls : io_output_stageControl_aluStageControl_aluControl_operation_string = "ls      ";
      AluOperation_rs : io_output_stageControl_aluStageControl_aluControl_operation_string = "rs      ";
      AluOperation_rsa : io_output_stageControl_aluStageControl_aluControl_operation_string = "rsa     ";
      AluOperation_swap : io_output_stageControl_aluStageControl_aluControl_operation_string = "swap    ";
      default : io_output_stageControl_aluStageControl_aluControl_operation_string = "????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_aluControl_condition)
      Condition_le : io_output_stageControl_aluStageControl_aluControl_condition_string = "le ";
      Condition_gt : io_output_stageControl_aluStageControl_aluControl_condition_string = "gt ";
      Condition_lt : io_output_stageControl_aluStageControl_aluControl_condition_string = "lt ";
      Condition_ge : io_output_stageControl_aluStageControl_aluControl_condition_string = "ge ";
      Condition_leu : io_output_stageControl_aluStageControl_aluControl_condition_string = "leu";
      Condition_gtu : io_output_stageControl_aluStageControl_aluControl_condition_string = "gtu";
      Condition_ltu : io_output_stageControl_aluStageControl_aluControl_condition_string = "ltu";
      Condition_geu : io_output_stageControl_aluStageControl_aluControl_condition_string = "geu";
      Condition_eq : io_output_stageControl_aluStageControl_aluControl_condition_string = "eq ";
      Condition_ne : io_output_stageControl_aluStageControl_aluControl_condition_string = "ne ";
      Condition_t : io_output_stageControl_aluStageControl_aluControl_condition_string = "t  ";
      Condition_f : io_output_stageControl_aluStageControl_aluControl_condition_string = "f  ";
      default : io_output_stageControl_aluStageControl_aluControl_condition_string = "???";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_writeStageControl_source)
      WriteBackValueSource_alu : io_output_stageControl_writeStageControl_source_string = "alu   ";
      WriteBackValueSource_memory : io_output_stageControl_writeStageControl_source_string = "memory";
      default : io_output_stageControl_writeStageControl_source_string = "??????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_writeStageControl_fileControl_writeRegister)
      RegisterName_f : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "f ";
      RegisterName_t : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "t ";
      RegisterName_b : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "b ";
      RegisterName_c : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "c ";
      RegisterName_d : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "d ";
      RegisterName_e : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "e ";
      RegisterName_h : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "h ";
      RegisterName_l : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "l ";
      RegisterName_ft : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "ft";
      RegisterName_bc : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "bc";
      RegisterName_de : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "de";
      RegisterName_hl : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "hl";
      default : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_writeStageControl_fileControl_writeExgRegister)
      RegisterName_f : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "f ";
      RegisterName_t : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "t ";
      RegisterName_b : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "b ";
      RegisterName_c : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "c ";
      RegisterName_d : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "d ";
      RegisterName_e : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "e ";
      RegisterName_h : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "h ";
      RegisterName_l : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "l ";
      RegisterName_ft : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "ft";
      RegisterName_bc : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "bc";
      RegisterName_de : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "de";
      RegisterName_hl : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "hl";
      default : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "??";
    endcase
  end
  `endif

  assign opcode = (io_strobe ? io_opcodeAsync : opcodeIn);
  always @(*) begin
    opcodeOut = opcode;
    if(io_nmiReq) begin
      opcodeOut = 8'h0;
    end else begin
      if(reqExtInt) begin
        opcodeOut = 8'h0;
      end else begin
        casez(opcode)
          8'b01011001 : begin
            if(!anyActive) begin
              opcodeOut = 8'h0;
            end
          end
          8'b10011011 : begin
            if(anyActive) begin
              opcodeOut = 8'h0;
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    io_output_stageControl_readStageControl_registers_0 = decoder_1_io_output_stageControl_readStageControl_registers_0;
    if(performInterrupt) begin
      io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
    end
  end

  always @(*) begin
    io_output_stageControl_readStageControl_registers_1 = decoder_1_io_output_stageControl_readStageControl_registers_1;
    if(performInterrupt) begin
      io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_enable = decoder_1_io_output_stageControl_memoryStageControl_enable;
    if(performInterrupt) begin
      io_output_stageControl_memoryStageControl_enable = 1'b0;
    end
  end

  assign io_output_stageControl_memoryStageControl_write = decoder_1_io_output_stageControl_memoryStageControl_write;
  assign io_output_stageControl_memoryStageControl_io = decoder_1_io_output_stageControl_memoryStageControl_io;
  assign io_output_stageControl_memoryStageControl_code = decoder_1_io_output_stageControl_memoryStageControl_code;
  assign io_output_stageControl_memoryStageControl_config = decoder_1_io_output_stageControl_memoryStageControl_config;
  assign io_output_stageControl_memoryStageControl_address = decoder_1_io_output_stageControl_memoryStageControl_address;
  always @(*) begin
    io_output_stageControl_aluStageControl_selection_0 = decoder_1_io_output_stageControl_aluStageControl_selection_0;
    if(performInterrupt) begin
      io_output_stageControl_aluStageControl_selection_0 = OperandSource_pc;
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_selection_1 = decoder_1_io_output_stageControl_aluStageControl_selection_1;
    if(performInterrupt) begin
      io_output_stageControl_aluStageControl_selection_1 = OperandSource_ones;
    end
  end

  assign io_output_stageControl_aluStageControl_pcControl_condition = decoder_1_io_output_stageControl_aluStageControl_pcControl_condition;
  always @(*) begin
    io_output_stageControl_aluStageControl_pcControl_truePath = decoder_1_io_output_stageControl_aluStageControl_pcControl_truePath;
    if(performInterrupt) begin
      io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_vectorFromDecoder;
    end
  end

  assign io_output_stageControl_aluStageControl_pcControl_decodedOffset = decoder_1_io_output_stageControl_aluStageControl_pcControl_decodedOffset;
  always @(*) begin
    io_output_stageControl_aluStageControl_pcControl_vector = decoder_1_io_output_stageControl_aluStageControl_pcControl_vector;
    if(performInterrupt) begin
      io_output_stageControl_aluStageControl_pcControl_vector = interruptVector;
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_aluControl_operation = decoder_1_io_output_stageControl_aluStageControl_aluControl_operation;
    if(performInterrupt) begin
      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
    end
  end

  assign io_output_stageControl_aluStageControl_aluControl_condition = decoder_1_io_output_stageControl_aluStageControl_aluControl_condition;
  always @(*) begin
    io_output_stageControl_writeStageControl_source = decoder_1_io_output_stageControl_writeStageControl_source;
    if(performInterrupt) begin
      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_write = decoder_1_io_output_stageControl_writeStageControl_fileControl_write;
    if(performInterrupt) begin
      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_writeRegister = decoder_1_io_output_stageControl_writeStageControl_fileControl_writeRegister;
    if(performInterrupt) begin
      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_hl;
    end
  end

  assign io_output_stageControl_writeStageControl_fileControl_writeExg = decoder_1_io_output_stageControl_writeStageControl_fileControl_writeExg;
  assign io_output_stageControl_writeStageControl_fileControl_writeExgRegister = decoder_1_io_output_stageControl_writeStageControl_fileControl_writeExgRegister;
  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_push;
    if(performInterrupt) begin
      if(_zz_1[0]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = 1'b1;
      end
    end
  end

  assign io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick;
  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_push;
    if(performInterrupt) begin
      if(_zz_1[1]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = 1'b1;
      end
    end
  end

  assign io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick;
  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_push;
    if(performInterrupt) begin
      if(_zz_1[2]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = 1'b1;
      end
    end
  end

  assign io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick;
  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_push;
    if(performInterrupt) begin
      if(_zz_1[3]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = 1'b1;
      end
    end
  end

  assign io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap;
  assign io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick = decoder_1_io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick;
  assign decoderIllegal = decoder_1_io_output_illegal;
  assign anyActive = ((io_nmiActive || io_intActive) || io_sysActive);
  assign reqExtInt = (((io_intReq && io_intEnable) && (! io_intActive)) && (! io_nmiActive));
  always @(*) begin
    io_output_intEnable = io_intEnable;
    if(!io_nmiReq) begin
      if(!reqExtInt) begin
        casez(opcode)
          8'b00011011 : begin
            io_output_intEnable = 1'b0;
          end
          8'b00011010 : begin
            io_output_intEnable = 1'b1;
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    io_output_nmiActive = (io_nmiActive || decoderIllegal);
    if(io_nmiReq) begin
      io_output_nmiActive = 1'b1;
    end else begin
      if(!reqExtInt) begin
        casez(opcode)
          8'b01011001 : begin
            if(anyActive) begin
              if(io_nmiActive) begin
                io_output_nmiActive = 1'b0;
              end
            end else begin
              io_output_nmiActive = 1'b1;
            end
          end
          8'b10011011 : begin
            if(anyActive) begin
              io_output_nmiActive = 1'b1;
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    io_output_intActive = io_intActive;
    if(!io_nmiReq) begin
      if(reqExtInt) begin
        io_output_intActive = 1'b1;
      end else begin
        casez(opcode)
          8'b01011001 : begin
            if(anyActive) begin
              if(!io_nmiActive) begin
                if(io_intActive) begin
                  io_output_intActive = 1'b0;
                end
              end
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    io_output_sysActive = io_sysActive;
    if(!io_nmiReq) begin
      if(!reqExtInt) begin
        casez(opcode)
          8'b01011001 : begin
            if(anyActive) begin
              if(!io_nmiActive) begin
                if(!io_intActive) begin
                  io_output_sysActive = 1'b0;
                end
              end
            end
          end
          8'b10011011 : begin
            if(!anyActive) begin
              io_output_sysActive = 1'b1;
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    performInterrupt = 1'b0;
    if(io_nmiReq) begin
      performInterrupt = 1'b1;
    end else begin
      if(reqExtInt) begin
        performInterrupt = 1'b1;
      end else begin
        casez(opcode)
          8'b01011001 : begin
            if(!anyActive) begin
              performInterrupt = 1'b1;
            end
          end
          8'b10011011 : begin
            if(anyActive) begin
              performInterrupt = 1'b1;
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    interruptVector = 3'b000;
    if(io_nmiReq) begin
      interruptVector = 3'b001;
    end else begin
      if(reqExtInt) begin
        interruptVector = 3'b101;
      end else begin
        casez(opcode)
          8'b01011001 : begin
            if(!anyActive) begin
              interruptVector = 3'b010;
            end
          end
          8'b10011011 : begin
            if(anyActive) begin
              interruptVector = 3'b010;
            end
          end
          default : begin
          end
        endcase
      end
    end
  end

  assign _zz_1 = ({3'd0,1'b1} <<< _zz__zz_1[1 : 0]);
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      opcodeIn <= 8'h0;
    end else begin
      if(when_ClockDomain_l353_regNext) begin
        if(io_strobe) begin
          opcodeIn <= io_opcodeAsync;
        end
      end
    end
  end


endmodule

module BufferCC (
  input               io_dataIn,
  output              io_dataOut,
  input               bus_clk,
  input               bus_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module PcCalc (
  input      [15:0]   io_pc,
  input      [15:0]   io_operand2,
  input      [7:0]    io_memory,
  input               io_conditionMet,
  input               io_resultZero,
  input      [1:0]    io_control_condition,
  input      [2:0]    io_control_truePath,
  input      [0:0]    io_control_decodedOffset,
  input      [2:0]    io_control_vector,
  output reg [15:0]   io_nextPc
);
  localparam PcCondition_always_1 = 2'd0;
  localparam PcCondition_whenConditionMet = 2'd1;
  localparam PcCondition_whenResultNotZero = 2'd2;
  localparam PcTruePathSource_offsetFromMemory = 3'd0;
  localparam PcTruePathSource_offsetFromDecoder = 3'd1;
  localparam PcTruePathSource_register2 = 3'd2;
  localparam PcTruePathSource_vectorFromMemory = 3'd3;
  localparam PcTruePathSource_vectorFromDecoder = 3'd4;

  wire       [15:0]   _zz_offsetFromMemory;
  wire       [7:0]    _zz_offsetFromMemory_1;
  wire       [5:0]    _zz_io_nextPc;
  wire       [15:0]   _zz_io_nextPc_1;
  wire       [10:0]   _zz_io_nextPc_2;
  reg                 takeTruePath;
  wire       [15:0]   offsetFromMemory;
  wire       [15:0]   offsetFromDecoder;
  wire       [15:0]   truePathOffset;
  wire       [15:0]   offset;
  `ifndef SYNTHESIS
  reg [135:0] io_control_condition_string;
  reg [135:0] io_control_truePath_string;
  `endif


  assign _zz_offsetFromMemory_1 = io_memory;
  assign _zz_offsetFromMemory = {{8{_zz_offsetFromMemory_1[7]}}, _zz_offsetFromMemory_1};
  assign _zz_io_nextPc = ({3'd0,io_control_vector} <<< 3);
  assign _zz_io_nextPc_2 = ({3'd0,io_memory} <<< 3);
  assign _zz_io_nextPc_1 = {5'd0, _zz_io_nextPc_2};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_control_condition)
      PcCondition_always_1 : io_control_condition_string = "always_1         ";
      PcCondition_whenConditionMet : io_control_condition_string = "whenConditionMet ";
      PcCondition_whenResultNotZero : io_control_condition_string = "whenResultNotZero";
      default : io_control_condition_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_control_truePath)
      PcTruePathSource_offsetFromMemory : io_control_truePath_string = "offsetFromMemory ";
      PcTruePathSource_offsetFromDecoder : io_control_truePath_string = "offsetFromDecoder";
      PcTruePathSource_register2 : io_control_truePath_string = "register2        ";
      PcTruePathSource_vectorFromMemory : io_control_truePath_string = "vectorFromMemory ";
      PcTruePathSource_vectorFromDecoder : io_control_truePath_string = "vectorFromDecoder";
      default : io_control_truePath_string = "?????????????????";
    endcase
  end
  `endif

  always @(*) begin
    case(io_control_condition)
      PcCondition_always_1 : begin
        takeTruePath = 1'b1;
      end
      PcCondition_whenConditionMet : begin
        takeTruePath = io_conditionMet;
      end
      default : begin
        takeTruePath = (! io_resultZero);
      end
    endcase
  end

  assign offsetFromMemory = _zz_offsetFromMemory;
  assign offsetFromDecoder = {15'd0, io_control_decodedOffset};
  assign truePathOffset = ((io_control_truePath == PcTruePathSource_offsetFromMemory) ? offsetFromMemory : offsetFromDecoder);
  assign offset = (takeTruePath ? truePathOffset : 16'h0001);
  always @(*) begin
    io_nextPc = (io_pc + offset);
    if(takeTruePath) begin
      case(io_control_truePath)
        PcTruePathSource_register2 : begin
          io_nextPc = io_operand2;
        end
        PcTruePathSource_vectorFromDecoder : begin
          io_nextPc = {10'd0, _zz_io_nextPc};
        end
        PcTruePathSource_vectorFromMemory : begin
          io_nextPc = _zz_io_nextPc_1;
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module Alu (
  input      [15:0]   io_operand1,
  input      [15:0]   io_operand2,
  input      [3:0]    io_control_operation,
  input      [3:0]    io_control_condition,
  output     [15:0]   io_dataOut,
  output              io_conditionMet,
  output              io_highByteZero
);
  localparam AluOperation_add = 4'd0;
  localparam AluOperation_sub = 4'd1;
  localparam AluOperation_compare = 4'd2;
  localparam AluOperation_extend1 = 4'd3;
  localparam AluOperation_and_1 = 4'd4;
  localparam AluOperation_or_1 = 4'd5;
  localparam AluOperation_xor_1 = 4'd6;
  localparam AluOperation_operand1 = 4'd7;
  localparam AluOperation_ls = 4'd8;
  localparam AluOperation_rs = 4'd9;
  localparam AluOperation_rsa = 4'd10;
  localparam AluOperation_swap = 4'd11;
  localparam Condition_le = 4'd0;
  localparam Condition_gt = 4'd1;
  localparam Condition_lt = 4'd2;
  localparam Condition_ge = 4'd3;
  localparam Condition_leu = 4'd4;
  localparam Condition_gtu = 4'd5;
  localparam Condition_ltu = 4'd6;
  localparam Condition_geu = 4'd7;
  localparam Condition_eq = 4'd8;
  localparam Condition_ne = 4'd9;
  localparam Condition_t = 4'd10;
  localparam Condition_f = 4'd11;
  localparam ShiftOperation_ls = 2'd0;
  localparam ShiftOperation_rs = 2'd1;
  localparam ShiftOperation_rsa = 2'd2;
  localparam ShiftOperation_swap = 2'd3;

  wire       [3:0]    shifter_1_io_amount;
  wire       [15:0]   subtract_io_dataa;
  wire       [15:0]   subtract_io_datab;
  wire                subtract_io_add_sub;
  wire       [15:0]   shifter_1_io_result;
  wire       [15:0]   subtract_io_result;
  wire                subtract_io_cout;
  wire       [1:0]    _zz__zz_io_operation_1;
  wire       [3:0]    _zz__zz_io_operation_1_1;
  wire       [3:0]    _zz_isShift;
  wire       [3:0]    _zz_switch_Misc_l211;
  wire       [2:0]    _zz_1;
  wire       [3:0]    _zz_2;
  wire       [2:0]    _zz_3;
  wire       [3:0]    _zz_4;
  wire       [2:0]    _zz_5;
  wire       [3:0]    _zz_6;
  wire       [2:0]    _zz_7;
  wire       [3:0]    _zz_8;
  wire       [2:0]    _zz_9;
  wire       [3:0]    _zz_10;
  wire       [1:0]    _zz_io_operation;
  wire       [1:0]    _zz_io_operation_1;
  wire                condition_overflow;
  wire                condition_negative;
  wire                condition_zero;
  wire                condition_carry;
  wire                condition_cc_le;
  wire                condition_cc_lt;
  wire                condition_cc_leu;
  reg                 condition_met;
  wire                isShift;
  wire       [2:0]    switch_Misc_l211;
  reg        [15:0]   _zz_result;
  wire       [15:0]   result;
  wire                flags_overflow;
  wire                flags_negative;
  wire                flags_carry;
  wire                flags_zero;
  wire       [15:0]   flags_out;
  wire                selectFlags;
  `ifndef SYNTHESIS
  reg [63:0] io_control_operation_string;
  reg [23:0] io_control_condition_string;
  reg [31:0] _zz_io_operation_string;
  reg [31:0] _zz_io_operation_1_string;
  `endif


  assign _zz__zz_io_operation_1_1 = io_control_operation;
  assign _zz__zz_io_operation_1 = _zz__zz_io_operation_1_1[1:0];
  assign _zz_isShift = io_control_operation;
  assign _zz_switch_Misc_l211 = io_control_operation;
  assign _zz_2 = AluOperation_and_1;
  assign _zz_1 = _zz_2[2:0];
  assign _zz_4 = AluOperation_or_1;
  assign _zz_3 = _zz_4[2:0];
  assign _zz_6 = AluOperation_xor_1;
  assign _zz_5 = _zz_6[2:0];
  assign _zz_8 = AluOperation_extend1;
  assign _zz_7 = _zz_8[2:0];
  assign _zz_10 = AluOperation_operand1;
  assign _zz_9 = _zz_10[2:0];
  Shifter shifter_1 (
    .io_operand      (io_operand1[15:0]          ), //i
    .io_amount       (shifter_1_io_amount[3:0]   ), //i
    .io_operation    (_zz_io_operation[1:0]      ), //i
    .io_result       (shifter_1_io_result[15:0]  )  //o
  );
  AddSub subtract (
    .io_dataa      (subtract_io_dataa[15:0]   ), //i
    .io_datab      (subtract_io_datab[15:0]   ), //i
    .io_add_sub    (subtract_io_add_sub       ), //i
    .io_result     (subtract_io_result[15:0]  ), //o
    .io_cout       (subtract_io_cout          )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_control_operation)
      AluOperation_add : io_control_operation_string = "add     ";
      AluOperation_sub : io_control_operation_string = "sub     ";
      AluOperation_compare : io_control_operation_string = "compare ";
      AluOperation_extend1 : io_control_operation_string = "extend1 ";
      AluOperation_and_1 : io_control_operation_string = "and_1   ";
      AluOperation_or_1 : io_control_operation_string = "or_1    ";
      AluOperation_xor_1 : io_control_operation_string = "xor_1   ";
      AluOperation_operand1 : io_control_operation_string = "operand1";
      AluOperation_ls : io_control_operation_string = "ls      ";
      AluOperation_rs : io_control_operation_string = "rs      ";
      AluOperation_rsa : io_control_operation_string = "rsa     ";
      AluOperation_swap : io_control_operation_string = "swap    ";
      default : io_control_operation_string = "????????";
    endcase
  end
  always @(*) begin
    case(io_control_condition)
      Condition_le : io_control_condition_string = "le ";
      Condition_gt : io_control_condition_string = "gt ";
      Condition_lt : io_control_condition_string = "lt ";
      Condition_ge : io_control_condition_string = "ge ";
      Condition_leu : io_control_condition_string = "leu";
      Condition_gtu : io_control_condition_string = "gtu";
      Condition_ltu : io_control_condition_string = "ltu";
      Condition_geu : io_control_condition_string = "geu";
      Condition_eq : io_control_condition_string = "eq ";
      Condition_ne : io_control_condition_string = "ne ";
      Condition_t : io_control_condition_string = "t  ";
      Condition_f : io_control_condition_string = "f  ";
      default : io_control_condition_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_io_operation)
      ShiftOperation_ls : _zz_io_operation_string = "ls  ";
      ShiftOperation_rs : _zz_io_operation_string = "rs  ";
      ShiftOperation_rsa : _zz_io_operation_string = "rsa ";
      ShiftOperation_swap : _zz_io_operation_string = "swap";
      default : _zz_io_operation_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_io_operation_1)
      ShiftOperation_ls : _zz_io_operation_1_string = "ls  ";
      ShiftOperation_rs : _zz_io_operation_1_string = "rs  ";
      ShiftOperation_rsa : _zz_io_operation_1_string = "rsa ";
      ShiftOperation_swap : _zz_io_operation_1_string = "swap";
      default : _zz_io_operation_1_string = "????";
    endcase
  end
  `endif

  assign shifter_1_io_amount = io_operand2[11 : 8];
  assign _zz_io_operation_1 = _zz__zz_io_operation_1;
  assign _zz_io_operation = _zz_io_operation_1;
  assign condition_overflow = io_operand1[11];
  assign condition_negative = io_operand1[10];
  assign condition_zero = io_operand1[9];
  assign condition_carry = io_operand1[8];
  assign condition_cc_le = ((condition_overflow ^ condition_negative) || condition_zero);
  assign condition_cc_lt = (condition_overflow ^ condition_negative);
  assign condition_cc_leu = (condition_carry || condition_zero);
  always @(*) begin
    case(io_control_condition)
      Condition_le : begin
        condition_met = condition_cc_le;
      end
      Condition_gt : begin
        condition_met = (! condition_cc_le);
      end
      Condition_lt : begin
        condition_met = condition_cc_lt;
      end
      Condition_ge : begin
        condition_met = (! condition_cc_lt);
      end
      Condition_leu : begin
        condition_met = condition_cc_leu;
      end
      Condition_gtu : begin
        condition_met = (! condition_cc_leu);
      end
      Condition_ltu : begin
        condition_met = condition_carry;
      end
      Condition_geu : begin
        condition_met = (! condition_carry);
      end
      Condition_eq : begin
        condition_met = condition_zero;
      end
      Condition_ne : begin
        condition_met = (! condition_zero);
      end
      Condition_t : begin
        condition_met = 1'b1;
      end
      default : begin
        condition_met = 1'b0;
      end
    endcase
  end

  assign subtract_io_add_sub = (io_control_operation == AluOperation_add);
  assign subtract_io_dataa = io_operand1;
  assign subtract_io_datab = io_operand2;
  assign isShift = _zz_isShift[3];
  assign switch_Misc_l211 = _zz_switch_Misc_l211[2:0];
  always @(*) begin
    if((switch_Misc_l211 == _zz_1)) begin
        _zz_result = (io_operand1 & io_operand2);
    end else if((switch_Misc_l211 == _zz_3)) begin
        _zz_result = (io_operand1 | io_operand2);
    end else if((switch_Misc_l211 == _zz_5)) begin
        _zz_result = (io_operand1 ^ io_operand2);
    end else if((switch_Misc_l211 == _zz_7)) begin
        _zz_result = (io_operand1[15] ? 16'hffff : 16'h0);
    end else if((switch_Misc_l211 == _zz_9)) begin
        _zz_result = io_operand1;
    end else begin
        _zz_result = subtract_io_result;
    end
  end

  assign result = (isShift ? shifter_1_io_result : _zz_result);
  assign flags_overflow = ((result[15] == io_operand2[15]) && (io_operand1[15] != io_operand2[15]));
  assign flags_negative = result[15];
  assign flags_carry = (! subtract_io_cout);
  assign flags_zero = (result == 16'h0);
  assign io_highByteZero = (result[15 : 8] == 8'h0);
  assign flags_out = {{{{{4'b0000,flags_overflow},flags_negative},flags_zero},flags_carry},8'h0};
  assign selectFlags = (io_control_operation == AluOperation_compare);
  assign io_dataOut = (selectFlags ? flags_out : result);
  assign io_conditionMet = condition_met;

endmodule

//OperandSelector replaced by OperandSelector

module OperandSelector (
  input      [2:0]    io_selection,
  input      [15:0]   io_register,
  input      [15:0]   io_pc,
  input      [7:0]    io_memory,
  output     [15:0]   io_dataOut
);
  localparam OperandSource_zero = 3'd0;
  localparam OperandSource_ones = 3'd1;
  localparam OperandSource_register_1 = 3'd2;
  localparam OperandSource_pc = 3'd3;
  localparam OperandSource_memory = 3'd4;
  localparam OperandSource_signed_memory = 3'd5;

  wire       [15:0]   _zz__zz_io_dataOut;
  wire       [7:0]    _zz__zz_io_dataOut_1;
  reg        [15:0]   _zz_io_dataOut;
  `ifndef SYNTHESIS
  reg [103:0] io_selection_string;
  `endif


  assign _zz__zz_io_dataOut_1 = io_memory;
  assign _zz__zz_io_dataOut = {{8{_zz__zz_io_dataOut_1[7]}}, _zz__zz_io_dataOut_1};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_selection)
      OperandSource_zero : io_selection_string = "zero         ";
      OperandSource_ones : io_selection_string = "ones         ";
      OperandSource_register_1 : io_selection_string = "register_1   ";
      OperandSource_pc : io_selection_string = "pc           ";
      OperandSource_memory : io_selection_string = "memory       ";
      OperandSource_signed_memory : io_selection_string = "signed_memory";
      default : io_selection_string = "?????????????";
    endcase
  end
  `endif

  always @(*) begin
    case(io_selection)
      OperandSource_zero : begin
        _zz_io_dataOut = 16'h0;
      end
      OperandSource_ones : begin
        _zz_io_dataOut = 16'hffff;
      end
      OperandSource_register_1 : begin
        _zz_io_dataOut = io_register;
      end
      OperandSource_pc : begin
        _zz_io_dataOut = io_pc;
      end
      OperandSource_memory : begin
        _zz_io_dataOut = ({8'd0,io_memory} <<< 8);
      end
      default : begin
        _zz_io_dataOut = _zz__zz_io_dataOut;
      end
    endcase
  end

  assign io_dataOut = _zz_io_dataOut;

endmodule

//Register_9 replaced by Register_9

//Register_9 replaced by Register_9

//Register_9 replaced by Register_9

//Register_9 replaced by Register_9

//Register_9 replaced by Register_9

//Register_9 replaced by Register_9

//Register_9 replaced by Register_9

module Register_9 (
  input      [7:0]    io_dataIn,
  input      [7:0]    io_dataInExg,
  input               io_control_push,
  input               io_control_pop,
  input               io_control_swap,
  input               io_control_pick,
  input               io_write,
  input               io_writeExg,
  input      [7:0]    io_pick,
  input      [7:0]    io_pointer,
  output     [7:0]    io_dataOut,
  input               bus_clk,
  input               bus_reset,
  input               when_ClockDomain_l353_regNext
);

  reg        [7:0]    _zz_memory_port0;
  wire                _zz_memory_port;
  wire                _zz_popTop2_1;
  reg        [7:0]    top;
  reg        [7:0]    top1;
  wire       [7:0]    _zz_popTop2;
  wire       [7:0]    popTop2;
  reg        [7:0]    memWriteAddress;
  reg        [7:0]    memWriteData;
  reg                 memWriteEnable;
  reg        [7:0]    _zz_top;
  reg [7:0] memory [0:255];

  assign _zz_popTop2_1 = 1'b1;
  always @(posedge bus_clk) begin
    if(when_ClockDomain_l353_regNext) begin
      if(_zz_popTop2_1) begin
        _zz_memory_port0 <= memory[_zz_popTop2];
      end
    end
  end

  always @(posedge bus_clk) begin
    if(when_ClockDomain_l353_regNext) begin
      if(memWriteEnable) begin
        memory[memWriteAddress] <= memWriteData;
      end
    end
  end

  assign _zz_popTop2 = (io_pointer + (io_control_pick ? io_pick : 8'h01));
  assign popTop2 = _zz_memory_port0;
  assign io_dataOut = top;
  always @(*) begin
    case(io_pick)
      8'h0 : begin
        _zz_top = top;
      end
      8'h01 : begin
        _zz_top = top1;
      end
      default : begin
        _zz_top = popTop2;
      end
    endcase
  end

  always @(posedge bus_clk or posedge bus_reset) begin
    if(bus_reset) begin
      memWriteEnable <= 1'b0;
    end else begin
      if(when_ClockDomain_l353_regNext) begin
        memWriteEnable <= 1'b0;
        if(io_control_push) begin
          memWriteEnable <= 1'b1;
        end
      end
    end
  end

  always @(posedge bus_clk) begin
    if(when_ClockDomain_l353_regNext) begin
      if(io_write) begin
        top <= io_dataIn;
      end else begin
        if(io_writeExg) begin
          top <= io_dataInExg;
        end
      end
      if(io_control_push) begin
        top1 <= top;
        memWriteAddress <= (io_pointer + 8'h02);
        memWriteData <= top1;
      end else begin
        if(io_control_pop) begin
          top <= top1;
          top1 <= popTop2;
        end else begin
          if(io_control_swap) begin
            top <= top1;
            top1 <= top;
          end else begin
            if(io_control_pick) begin
              top <= _zz_top;
            end
          end
        end
      end
    end
  end


endmodule

module OpcodeDecoder (
  input      [7:0]    io_opcode,
  output reg [3:0]    io_output_stageControl_readStageControl_registers_0,
  output reg [3:0]    io_output_stageControl_readStageControl_registers_1,
  output reg          io_output_stageControl_memoryStageControl_enable,
  output reg          io_output_stageControl_memoryStageControl_write,
  output reg          io_output_stageControl_memoryStageControl_io,
  output reg          io_output_stageControl_memoryStageControl_code,
  output reg          io_output_stageControl_memoryStageControl_config,
  output reg [0:0]    io_output_stageControl_memoryStageControl_address,
  output reg [2:0]    io_output_stageControl_aluStageControl_selection_0,
  output reg [2:0]    io_output_stageControl_aluStageControl_selection_1,
  output reg [1:0]    io_output_stageControl_aluStageControl_pcControl_condition,
  output reg [2:0]    io_output_stageControl_aluStageControl_pcControl_truePath,
  output reg [0:0]    io_output_stageControl_aluStageControl_pcControl_decodedOffset,
  output reg [2:0]    io_output_stageControl_aluStageControl_pcControl_vector,
  output reg [3:0]    io_output_stageControl_aluStageControl_aluControl_operation,
  output reg [3:0]    io_output_stageControl_aluStageControl_aluControl_condition,
  output reg [0:0]    io_output_stageControl_writeStageControl_source,
  output reg          io_output_stageControl_writeStageControl_fileControl_write,
  output reg [3:0]    io_output_stageControl_writeStageControl_fileControl_writeRegister,
  output reg          io_output_stageControl_writeStageControl_fileControl_writeExg,
  output reg [3:0]    io_output_stageControl_writeStageControl_fileControl_writeExgRegister,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_0_push,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_1_push,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_2_push,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_3_push,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap,
  output reg          io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick,
  output reg          io_output_illegal
);
  localparam RegisterName_f = 4'd0;
  localparam RegisterName_t = 4'd1;
  localparam RegisterName_b = 4'd2;
  localparam RegisterName_c = 4'd3;
  localparam RegisterName_d = 4'd4;
  localparam RegisterName_e = 4'd5;
  localparam RegisterName_h = 4'd6;
  localparam RegisterName_l = 4'd7;
  localparam RegisterName_ft = 4'd8;
  localparam RegisterName_bc = 4'd9;
  localparam RegisterName_de = 4'd10;
  localparam RegisterName_hl = 4'd11;
  localparam MemoryStageAddressSource_register1 = 1'd0;
  localparam MemoryStageAddressSource_pc = 1'd1;
  localparam OperandSource_zero = 3'd0;
  localparam OperandSource_ones = 3'd1;
  localparam OperandSource_register_1 = 3'd2;
  localparam OperandSource_pc = 3'd3;
  localparam OperandSource_memory = 3'd4;
  localparam OperandSource_signed_memory = 3'd5;
  localparam PcCondition_always_1 = 2'd0;
  localparam PcCondition_whenConditionMet = 2'd1;
  localparam PcCondition_whenResultNotZero = 2'd2;
  localparam PcTruePathSource_offsetFromMemory = 3'd0;
  localparam PcTruePathSource_offsetFromDecoder = 3'd1;
  localparam PcTruePathSource_register2 = 3'd2;
  localparam PcTruePathSource_vectorFromMemory = 3'd3;
  localparam PcTruePathSource_vectorFromDecoder = 3'd4;
  localparam AluOperation_add = 4'd0;
  localparam AluOperation_sub = 4'd1;
  localparam AluOperation_compare = 4'd2;
  localparam AluOperation_extend1 = 4'd3;
  localparam AluOperation_and_1 = 4'd4;
  localparam AluOperation_or_1 = 4'd5;
  localparam AluOperation_xor_1 = 4'd6;
  localparam AluOperation_operand1 = 4'd7;
  localparam AluOperation_ls = 4'd8;
  localparam AluOperation_rs = 4'd9;
  localparam AluOperation_rsa = 4'd10;
  localparam AluOperation_swap = 4'd11;
  localparam Condition_le = 4'd0;
  localparam Condition_gt = 4'd1;
  localparam Condition_lt = 4'd2;
  localparam Condition_ge = 4'd3;
  localparam Condition_leu = 4'd4;
  localparam Condition_gtu = 4'd5;
  localparam Condition_ltu = 4'd6;
  localparam Condition_geu = 4'd7;
  localparam Condition_eq = 4'd8;
  localparam Condition_ne = 4'd9;
  localparam Condition_t = 4'd10;
  localparam Condition_f = 4'd11;
  localparam WriteBackValueSource_alu = 1'd0;
  localparam WriteBackValueSource_memory = 1'd1;

  wire                _zz_when_OpcodeDecoder_l52;
  wire                _zz_when_OpcodeDecoder_l52_1;
  wire                _zz_when_OpcodeDecoder_l52_2;
  wire       [7:0]    _zz_when_OpcodeDecoder_l52_3;
  wire       [7:0]    _zz_when_OpcodeDecoder_l52_4;
  wire       [7:0]    _zz_when_OpcodeDecoder_l52_5;
  wire                _zz_when_OpcodeDecoder_l52_6;
  wire       [7:0]    _zz_when_OpcodeDecoder_l52_7;
  wire       [7:0]    _zz_when_OpcodeDecoder_l52_8;
  wire       [7:0]    _zz_when_OpcodeDecoder_l52_9;
  wire       [3:0]    _zz__zz_1;
  wire       [3:0]    _zz__zz_2;
  wire       [3:0]    _zz__zz_3;
  wire       [3:0]    _zz__zz_4;
  wire       [3:0]    _zz__zz_5;
  wire       [3:0]    _zz__zz_6;
  wire       [3:0]    _zz__zz_7;
  wire       [3:0]    registerPair;
  wire       [3:0]    _zz_registerPair;
  wire       [3:0]    register_17;
  wire       [3:0]    _zz_register;
  wire                when_OpcodeDecoder_l52;
  wire       [3:0]    _zz_1;
  wire                when_OpcodeDecoder_l57;
  wire       [3:0]    _zz_2;
  wire       [3:0]    _zz_3;
  wire       [3:0]    _zz_4;
  wire       [3:0]    _zz_5;
  wire       [3:0]    _zz_6;
  wire       [3:0]    _zz_7;
  wire       [3:0]    _zz_io_output_stageControl_aluStageControl_aluControl_condition;
  wire       [3:0]    _zz_io_output_stageControl_aluStageControl_aluControl_condition_1;
  wire                when_OpcodeDecoder_l58;
  wire                when_OpcodeDecoder_l59;
  wire                when_OpcodeDecoder_l60;
  wire                when_OpcodeDecoder_l61;
  wire                when_OpcodeDecoder_l62;
  wire                when_OpcodeDecoder_l63;
  wire                when_OpcodeDecoder_l64;
  wire                when_OpcodeDecoder_l65;
  wire                when_OpcodeDecoder_l66;
  wire                when_OpcodeDecoder_l67;
  wire                when_OpcodeDecoder_l68;
  wire                when_OpcodeDecoder_l69;
  wire                when_OpcodeDecoder_l70;
  wire                when_OpcodeDecoder_l71;
  wire                when_OpcodeDecoder_l72;
  wire                when_OpcodeDecoder_l73;
  wire                when_OpcodeDecoder_l74;
  wire                when_OpcodeDecoder_l75;
  wire                when_OpcodeDecoder_l76;
  wire                when_OpcodeDecoder_l79;
  wire                when_OpcodeDecoder_l80;
  wire                when_OpcodeDecoder_l81;
  wire                when_OpcodeDecoder_l82;
  wire                when_OpcodeDecoder_l83;
  wire                when_OpcodeDecoder_l84;
  wire                when_OpcodeDecoder_l85;
  wire                when_OpcodeDecoder_l86;
  wire                when_OpcodeDecoder_l87;
  wire                when_OpcodeDecoder_l88;
  wire                when_OpcodeDecoder_l89;
  wire                when_OpcodeDecoder_l90;
  wire                when_OpcodeDecoder_l91;
  wire                when_OpcodeDecoder_l92;
  wire                when_OpcodeDecoder_l93;
  wire                when_OpcodeDecoder_l94;
  wire                when_OpcodeDecoder_l95;
  wire                when_OpcodeDecoder_l96;
  wire                when_OpcodeDecoder_l97;
  wire                when_OpcodeDecoder_l100;
  wire                when_OpcodeDecoder_l101;
  wire                when_OpcodeDecoder_l102;
  wire                when_OpcodeDecoder_l103;
  wire                when_OpcodeDecoder_l104;
  wire                when_OpcodeDecoder_l105;
  wire                when_OpcodeDecoder_l106;
  wire                when_OpcodeDecoder_l107;
  wire                when_OpcodeDecoder_l108;
  wire                when_OpcodeDecoder_l109;
  wire                when_OpcodeDecoder_l110;
  wire                when_OpcodeDecoder_l111;
  wire                when_OpcodeDecoder_l112;
  wire                when_OpcodeDecoder_l113;
  wire                when_OpcodeDecoder_l114;
  wire                when_OpcodeDecoder_l115;
  wire                when_OpcodeDecoder_l116;
  wire                when_OpcodeDecoder_l117;
  wire                when_OpcodeDecoder_l120;
  `ifndef SYNTHESIS
  reg [15:0] io_output_stageControl_readStageControl_registers_0_string;
  reg [15:0] io_output_stageControl_readStageControl_registers_1_string;
  reg [71:0] io_output_stageControl_memoryStageControl_address_string;
  reg [103:0] io_output_stageControl_aluStageControl_selection_0_string;
  reg [103:0] io_output_stageControl_aluStageControl_selection_1_string;
  reg [135:0] io_output_stageControl_aluStageControl_pcControl_condition_string;
  reg [135:0] io_output_stageControl_aluStageControl_pcControl_truePath_string;
  reg [63:0] io_output_stageControl_aluStageControl_aluControl_operation_string;
  reg [23:0] io_output_stageControl_aluStageControl_aluControl_condition_string;
  reg [47:0] io_output_stageControl_writeStageControl_source_string;
  reg [15:0] io_output_stageControl_writeStageControl_fileControl_writeRegister_string;
  reg [15:0] io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string;
  reg [15:0] registerPair_string;
  reg [15:0] _zz_registerPair_string;
  reg [15:0] register_17_string;
  reg [15:0] _zz_register_string;
  reg [23:0] _zz_io_output_stageControl_aluStageControl_aluControl_condition_string;
  reg [23:0] _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string;
  `endif


  assign _zz__zz_1 = RegisterName_hl;
  assign _zz__zz_2 = RegisterName_hl;
  assign _zz__zz_3 = RegisterName_hl;
  assign _zz__zz_4 = registerPair;
  assign _zz__zz_5 = registerPair;
  assign _zz__zz_6 = registerPair;
  assign _zz__zz_7 = registerPair;
  assign _zz_when_OpcodeDecoder_l52 = (((((((_zz_when_OpcodeDecoder_l52_1 || _zz_when_OpcodeDecoder_l52_2) || (_zz_when_OpcodeDecoder_l52_3 == _zz_when_OpcodeDecoder_l52_4)) || ((io_opcode & _zz_when_OpcodeDecoder_l52_5) == 8'h69)) || ((io_opcode & 8'hff) == 8'h71)) || ((io_opcode & 8'hff) == 8'h79)) || ((io_opcode & 8'hfc) == 8'h9c)) || ((io_opcode & 8'hff) == 8'hb3));
  assign _zz_when_OpcodeDecoder_l52_6 = ((io_opcode & 8'hfc) == 8'hb4);
  assign _zz_when_OpcodeDecoder_l52_7 = (io_opcode & 8'hff);
  assign _zz_when_OpcodeDecoder_l52_8 = 8'hba;
  assign _zz_when_OpcodeDecoder_l52_9 = 8'hff;
  assign _zz_when_OpcodeDecoder_l52_1 = ((((((io_opcode & 8'hfe) == 8'h08) || ((io_opcode & 8'hff) == 8'h11)) || ((io_opcode & 8'hff) == 8'h19)) || ((io_opcode & 8'hfe) == 8'h20)) || ((io_opcode & 8'hff) == 8'h29));
  assign _zz_when_OpcodeDecoder_l52_2 = ((io_opcode & 8'hff) == 8'h30);
  assign _zz_when_OpcodeDecoder_l52_3 = (io_opcode & 8'hff);
  assign _zz_when_OpcodeDecoder_l52_4 = 8'h61;
  assign _zz_when_OpcodeDecoder_l52_5 = 8'hff;
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_output_stageControl_readStageControl_registers_0)
      RegisterName_f : io_output_stageControl_readStageControl_registers_0_string = "f ";
      RegisterName_t : io_output_stageControl_readStageControl_registers_0_string = "t ";
      RegisterName_b : io_output_stageControl_readStageControl_registers_0_string = "b ";
      RegisterName_c : io_output_stageControl_readStageControl_registers_0_string = "c ";
      RegisterName_d : io_output_stageControl_readStageControl_registers_0_string = "d ";
      RegisterName_e : io_output_stageControl_readStageControl_registers_0_string = "e ";
      RegisterName_h : io_output_stageControl_readStageControl_registers_0_string = "h ";
      RegisterName_l : io_output_stageControl_readStageControl_registers_0_string = "l ";
      RegisterName_ft : io_output_stageControl_readStageControl_registers_0_string = "ft";
      RegisterName_bc : io_output_stageControl_readStageControl_registers_0_string = "bc";
      RegisterName_de : io_output_stageControl_readStageControl_registers_0_string = "de";
      RegisterName_hl : io_output_stageControl_readStageControl_registers_0_string = "hl";
      default : io_output_stageControl_readStageControl_registers_0_string = "??";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_readStageControl_registers_1)
      RegisterName_f : io_output_stageControl_readStageControl_registers_1_string = "f ";
      RegisterName_t : io_output_stageControl_readStageControl_registers_1_string = "t ";
      RegisterName_b : io_output_stageControl_readStageControl_registers_1_string = "b ";
      RegisterName_c : io_output_stageControl_readStageControl_registers_1_string = "c ";
      RegisterName_d : io_output_stageControl_readStageControl_registers_1_string = "d ";
      RegisterName_e : io_output_stageControl_readStageControl_registers_1_string = "e ";
      RegisterName_h : io_output_stageControl_readStageControl_registers_1_string = "h ";
      RegisterName_l : io_output_stageControl_readStageControl_registers_1_string = "l ";
      RegisterName_ft : io_output_stageControl_readStageControl_registers_1_string = "ft";
      RegisterName_bc : io_output_stageControl_readStageControl_registers_1_string = "bc";
      RegisterName_de : io_output_stageControl_readStageControl_registers_1_string = "de";
      RegisterName_hl : io_output_stageControl_readStageControl_registers_1_string = "hl";
      default : io_output_stageControl_readStageControl_registers_1_string = "??";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_memoryStageControl_address)
      MemoryStageAddressSource_register1 : io_output_stageControl_memoryStageControl_address_string = "register1";
      MemoryStageAddressSource_pc : io_output_stageControl_memoryStageControl_address_string = "pc       ";
      default : io_output_stageControl_memoryStageControl_address_string = "?????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_selection_0)
      OperandSource_zero : io_output_stageControl_aluStageControl_selection_0_string = "zero         ";
      OperandSource_ones : io_output_stageControl_aluStageControl_selection_0_string = "ones         ";
      OperandSource_register_1 : io_output_stageControl_aluStageControl_selection_0_string = "register_1   ";
      OperandSource_pc : io_output_stageControl_aluStageControl_selection_0_string = "pc           ";
      OperandSource_memory : io_output_stageControl_aluStageControl_selection_0_string = "memory       ";
      OperandSource_signed_memory : io_output_stageControl_aluStageControl_selection_0_string = "signed_memory";
      default : io_output_stageControl_aluStageControl_selection_0_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_selection_1)
      OperandSource_zero : io_output_stageControl_aluStageControl_selection_1_string = "zero         ";
      OperandSource_ones : io_output_stageControl_aluStageControl_selection_1_string = "ones         ";
      OperandSource_register_1 : io_output_stageControl_aluStageControl_selection_1_string = "register_1   ";
      OperandSource_pc : io_output_stageControl_aluStageControl_selection_1_string = "pc           ";
      OperandSource_memory : io_output_stageControl_aluStageControl_selection_1_string = "memory       ";
      OperandSource_signed_memory : io_output_stageControl_aluStageControl_selection_1_string = "signed_memory";
      default : io_output_stageControl_aluStageControl_selection_1_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_pcControl_condition)
      PcCondition_always_1 : io_output_stageControl_aluStageControl_pcControl_condition_string = "always_1         ";
      PcCondition_whenConditionMet : io_output_stageControl_aluStageControl_pcControl_condition_string = "whenConditionMet ";
      PcCondition_whenResultNotZero : io_output_stageControl_aluStageControl_pcControl_condition_string = "whenResultNotZero";
      default : io_output_stageControl_aluStageControl_pcControl_condition_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_pcControl_truePath)
      PcTruePathSource_offsetFromMemory : io_output_stageControl_aluStageControl_pcControl_truePath_string = "offsetFromMemory ";
      PcTruePathSource_offsetFromDecoder : io_output_stageControl_aluStageControl_pcControl_truePath_string = "offsetFromDecoder";
      PcTruePathSource_register2 : io_output_stageControl_aluStageControl_pcControl_truePath_string = "register2        ";
      PcTruePathSource_vectorFromMemory : io_output_stageControl_aluStageControl_pcControl_truePath_string = "vectorFromMemory ";
      PcTruePathSource_vectorFromDecoder : io_output_stageControl_aluStageControl_pcControl_truePath_string = "vectorFromDecoder";
      default : io_output_stageControl_aluStageControl_pcControl_truePath_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_aluControl_operation)
      AluOperation_add : io_output_stageControl_aluStageControl_aluControl_operation_string = "add     ";
      AluOperation_sub : io_output_stageControl_aluStageControl_aluControl_operation_string = "sub     ";
      AluOperation_compare : io_output_stageControl_aluStageControl_aluControl_operation_string = "compare ";
      AluOperation_extend1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "extend1 ";
      AluOperation_and_1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "and_1   ";
      AluOperation_or_1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "or_1    ";
      AluOperation_xor_1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "xor_1   ";
      AluOperation_operand1 : io_output_stageControl_aluStageControl_aluControl_operation_string = "operand1";
      AluOperation_ls : io_output_stageControl_aluStageControl_aluControl_operation_string = "ls      ";
      AluOperation_rs : io_output_stageControl_aluStageControl_aluControl_operation_string = "rs      ";
      AluOperation_rsa : io_output_stageControl_aluStageControl_aluControl_operation_string = "rsa     ";
      AluOperation_swap : io_output_stageControl_aluStageControl_aluControl_operation_string = "swap    ";
      default : io_output_stageControl_aluStageControl_aluControl_operation_string = "????????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_aluStageControl_aluControl_condition)
      Condition_le : io_output_stageControl_aluStageControl_aluControl_condition_string = "le ";
      Condition_gt : io_output_stageControl_aluStageControl_aluControl_condition_string = "gt ";
      Condition_lt : io_output_stageControl_aluStageControl_aluControl_condition_string = "lt ";
      Condition_ge : io_output_stageControl_aluStageControl_aluControl_condition_string = "ge ";
      Condition_leu : io_output_stageControl_aluStageControl_aluControl_condition_string = "leu";
      Condition_gtu : io_output_stageControl_aluStageControl_aluControl_condition_string = "gtu";
      Condition_ltu : io_output_stageControl_aluStageControl_aluControl_condition_string = "ltu";
      Condition_geu : io_output_stageControl_aluStageControl_aluControl_condition_string = "geu";
      Condition_eq : io_output_stageControl_aluStageControl_aluControl_condition_string = "eq ";
      Condition_ne : io_output_stageControl_aluStageControl_aluControl_condition_string = "ne ";
      Condition_t : io_output_stageControl_aluStageControl_aluControl_condition_string = "t  ";
      Condition_f : io_output_stageControl_aluStageControl_aluControl_condition_string = "f  ";
      default : io_output_stageControl_aluStageControl_aluControl_condition_string = "???";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_writeStageControl_source)
      WriteBackValueSource_alu : io_output_stageControl_writeStageControl_source_string = "alu   ";
      WriteBackValueSource_memory : io_output_stageControl_writeStageControl_source_string = "memory";
      default : io_output_stageControl_writeStageControl_source_string = "??????";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_writeStageControl_fileControl_writeRegister)
      RegisterName_f : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "f ";
      RegisterName_t : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "t ";
      RegisterName_b : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "b ";
      RegisterName_c : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "c ";
      RegisterName_d : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "d ";
      RegisterName_e : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "e ";
      RegisterName_h : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "h ";
      RegisterName_l : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "l ";
      RegisterName_ft : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "ft";
      RegisterName_bc : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "bc";
      RegisterName_de : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "de";
      RegisterName_hl : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "hl";
      default : io_output_stageControl_writeStageControl_fileControl_writeRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(io_output_stageControl_writeStageControl_fileControl_writeExgRegister)
      RegisterName_f : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "f ";
      RegisterName_t : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "t ";
      RegisterName_b : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "b ";
      RegisterName_c : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "c ";
      RegisterName_d : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "d ";
      RegisterName_e : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "e ";
      RegisterName_h : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "h ";
      RegisterName_l : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "l ";
      RegisterName_ft : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "ft";
      RegisterName_bc : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "bc";
      RegisterName_de : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "de";
      RegisterName_hl : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "hl";
      default : io_output_stageControl_writeStageControl_fileControl_writeExgRegister_string = "??";
    endcase
  end
  always @(*) begin
    case(registerPair)
      RegisterName_f : registerPair_string = "f ";
      RegisterName_t : registerPair_string = "t ";
      RegisterName_b : registerPair_string = "b ";
      RegisterName_c : registerPair_string = "c ";
      RegisterName_d : registerPair_string = "d ";
      RegisterName_e : registerPair_string = "e ";
      RegisterName_h : registerPair_string = "h ";
      RegisterName_l : registerPair_string = "l ";
      RegisterName_ft : registerPair_string = "ft";
      RegisterName_bc : registerPair_string = "bc";
      RegisterName_de : registerPair_string = "de";
      RegisterName_hl : registerPair_string = "hl";
      default : registerPair_string = "??";
    endcase
  end
  always @(*) begin
    case(_zz_registerPair)
      RegisterName_f : _zz_registerPair_string = "f ";
      RegisterName_t : _zz_registerPair_string = "t ";
      RegisterName_b : _zz_registerPair_string = "b ";
      RegisterName_c : _zz_registerPair_string = "c ";
      RegisterName_d : _zz_registerPair_string = "d ";
      RegisterName_e : _zz_registerPair_string = "e ";
      RegisterName_h : _zz_registerPair_string = "h ";
      RegisterName_l : _zz_registerPair_string = "l ";
      RegisterName_ft : _zz_registerPair_string = "ft";
      RegisterName_bc : _zz_registerPair_string = "bc";
      RegisterName_de : _zz_registerPair_string = "de";
      RegisterName_hl : _zz_registerPair_string = "hl";
      default : _zz_registerPair_string = "??";
    endcase
  end
  always @(*) begin
    case(register_17)
      RegisterName_f : register_17_string = "f ";
      RegisterName_t : register_17_string = "t ";
      RegisterName_b : register_17_string = "b ";
      RegisterName_c : register_17_string = "c ";
      RegisterName_d : register_17_string = "d ";
      RegisterName_e : register_17_string = "e ";
      RegisterName_h : register_17_string = "h ";
      RegisterName_l : register_17_string = "l ";
      RegisterName_ft : register_17_string = "ft";
      RegisterName_bc : register_17_string = "bc";
      RegisterName_de : register_17_string = "de";
      RegisterName_hl : register_17_string = "hl";
      default : register_17_string = "??";
    endcase
  end
  always @(*) begin
    case(_zz_register)
      RegisterName_f : _zz_register_string = "f ";
      RegisterName_t : _zz_register_string = "t ";
      RegisterName_b : _zz_register_string = "b ";
      RegisterName_c : _zz_register_string = "c ";
      RegisterName_d : _zz_register_string = "d ";
      RegisterName_e : _zz_register_string = "e ";
      RegisterName_h : _zz_register_string = "h ";
      RegisterName_l : _zz_register_string = "l ";
      RegisterName_ft : _zz_register_string = "ft";
      RegisterName_bc : _zz_register_string = "bc";
      RegisterName_de : _zz_register_string = "de";
      RegisterName_hl : _zz_register_string = "hl";
      default : _zz_register_string = "??";
    endcase
  end
  always @(*) begin
    case(_zz_io_output_stageControl_aluStageControl_aluControl_condition)
      Condition_le : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "le ";
      Condition_gt : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "gt ";
      Condition_lt : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "lt ";
      Condition_ge : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "ge ";
      Condition_leu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "leu";
      Condition_gtu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "gtu";
      Condition_ltu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "ltu";
      Condition_geu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "geu";
      Condition_eq : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "eq ";
      Condition_ne : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "ne ";
      Condition_t : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "t  ";
      Condition_f : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "f  ";
      default : _zz_io_output_stageControl_aluStageControl_aluControl_condition_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_io_output_stageControl_aluStageControl_aluControl_condition_1)
      Condition_le : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "le ";
      Condition_gt : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "gt ";
      Condition_lt : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "lt ";
      Condition_ge : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "ge ";
      Condition_leu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "leu";
      Condition_gtu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "gtu";
      Condition_ltu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "ltu";
      Condition_geu : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "geu";
      Condition_eq : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "eq ";
      Condition_ne : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "ne ";
      Condition_t : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "t  ";
      Condition_f : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "f  ";
      default : _zz_io_output_stageControl_aluStageControl_aluControl_condition_1_string = "???";
    endcase
  end
  `endif

  assign _zz_registerPair = {2'b10,io_opcode[1 : 0]};
  assign registerPair = _zz_registerPair;
  assign _zz_register = {1'b0,io_opcode[2 : 0]};
  assign register_17 = _zz_register;
  always @(*) begin
    io_output_illegal = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      io_output_illegal = 1'b1;
    end
  end

  always @(*) begin
    io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(when_OpcodeDecoder_l60) begin
              io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
            end else begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_readStageControl_registers_0 = RegisterName_c;
              end else begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_readStageControl_registers_0 = RegisterName_c;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                      end else begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(when_OpcodeDecoder_l85) begin
                                                            io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                          end else begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                              end else begin
                                                                if(when_OpcodeDecoder_l88) begin
                                                                  io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                end else begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                      end else begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                        end else begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                          end else begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                            end else begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                              end else begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                                end else begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_readStageControl_registers_0 = registerPair;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_readStageControl_registers_0 = register_17;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_readStageControl_registers_0 = register_17;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_readStageControl_registers_0 = register_17;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_readStageControl_registers_0 = register_17;
                                                                                                end else begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                                                  end else begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                                                      end else begin
                                                                                                        if(when_OpcodeDecoder_l110) begin
                                                                                                          io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                                        end else begin
                                                                                                          if(when_OpcodeDecoder_l111) begin
                                                                                                            io_output_stageControl_readStageControl_registers_0 = register_17;
                                                                                                          end else begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_readStageControl_registers_0 = RegisterName_ft;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_readStageControl_registers_0 = RegisterName_t;
                                                                                                                      end else begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_readStageControl_registers_0 = RegisterName_f;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_readStageControl_registers_1 = RegisterName_t;
              end else begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_readStageControl_registers_1 = RegisterName_t;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_readStageControl_registers_1 = registerPair;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_readStageControl_registers_1 = RegisterName_f;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    io_output_stageControl_readStageControl_registers_1 = RegisterName_hl;
                                  end else begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_readStageControl_registers_1 = registerPair;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_readStageControl_registers_1 = registerPair;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_readStageControl_registers_1 = registerPair;
                                                      end else begin
                                                        if(when_OpcodeDecoder_l84) begin
                                                          io_output_stageControl_readStageControl_registers_1 = registerPair;
                                                        end else begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_readStageControl_registers_1 = RegisterName_t;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_readStageControl_registers_1 = RegisterName_t;
                                                              end else begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                          end else begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                            end else begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_readStageControl_registers_1 = registerPair;
                                                                              end else begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                                end else begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_readStageControl_registers_1 = RegisterName_t;
                                                                                                end else begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                  end else begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(!when_OpcodeDecoder_l109) begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_readStageControl_registers_1 = register_17;
                                                                                                                      end else begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_readStageControl_registers_1 = RegisterName_ft;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_enable = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_memoryStageControl_enable = 1'b0;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_memoryStageControl_enable = 1'b1;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_memoryStageControl_enable = 1'b1;
              end else begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_memoryStageControl_enable = 1'b1;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_memoryStageControl_enable = 1'b1;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_memoryStageControl_enable = 1'b1;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_memoryStageControl_enable = 1'b1;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_memoryStageControl_enable = 1'b1;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_memoryStageControl_enable = 1'b1;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_memoryStageControl_enable = 1'b1;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                              end else begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                                  end else begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                                      end else begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_memoryStageControl_enable = 1'b1;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_write = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_memoryStageControl_write = 1'b0;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_memoryStageControl_write = 1'b1;
              end else begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_memoryStageControl_write = 1'b0;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_memoryStageControl_write = 1'b0;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_memoryStageControl_write = 1'b0;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_memoryStageControl_write = 1'b0;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_memoryStageControl_write = 1'b0;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_memoryStageControl_write = 1'b0;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_memoryStageControl_write = 1'b0;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_memoryStageControl_write = 1'b0;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_memoryStageControl_write = 1'b1;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_memoryStageControl_write = 1'b1;
                                                              end else begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_memoryStageControl_write = 1'b1;
                                                                                                  end else begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                                                      end else begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_memoryStageControl_write = 1'b0;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_io = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_memoryStageControl_io = 1'b0;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_memoryStageControl_io = 1'b0;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_memoryStageControl_io = 1'b0;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_memoryStageControl_io = 1'b0;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_memoryStageControl_io = 1'b0;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_memoryStageControl_io = 1'b0;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_memoryStageControl_io = 1'b0;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_memoryStageControl_io = 1'b0;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_memoryStageControl_io = 1'b1;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_memoryStageControl_io = 1'b0;
                                                              end else begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_memoryStageControl_io = 1'b1;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                                  end else begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                                      end else begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_memoryStageControl_io = 1'b0;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_code = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_memoryStageControl_code = 1'b1;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_memoryStageControl_code = 1'b1;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_memoryStageControl_code = 1'b1;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_memoryStageControl_code = 1'b1;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_memoryStageControl_code = 1'b1;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_memoryStageControl_code = 1'b1;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_memoryStageControl_code = 1'b1;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_memoryStageControl_code = 1'b1;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_memoryStageControl_code = 1'b0;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_memoryStageControl_code = 1'b1;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_memoryStageControl_code = 1'b0;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_memoryStageControl_code = 1'b1;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_memoryStageControl_code = 1'b1;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_memoryStageControl_code = 1'b1;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_memoryStageControl_code = 1'b1;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_memoryStageControl_code = 1'b0;
                                                                                                      end else begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_memoryStageControl_code = 1'b1;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_config = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_memoryStageControl_config = 1'b1;
              end else begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_memoryStageControl_config = 1'b1;
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
    if(!when_OpcodeDecoder_l52) begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
              end else begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                              end else begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                                                                  end else begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_register1;
                                                                                                      end else begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_memoryStageControl_address = MemoryStageAddressSource_pc;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_aluStageControl_selection_0 = OperandSource_pc;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(when_OpcodeDecoder_l60) begin
              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
            end else begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
              end else begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_aluStageControl_selection_0 = OperandSource_zero;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_zero;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_aluStageControl_selection_0 = OperandSource_ones;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_aluStageControl_selection_0 = OperandSource_pc;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_pc;
                                                      end else begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(when_OpcodeDecoder_l85) begin
                                                            io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                          end else begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                              end else begin
                                                                if(when_OpcodeDecoder_l88) begin
                                                                  io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                end else begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                      end else begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                        end else begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                          end else begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                            end else begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                              end else begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                end else begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                end else begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                  end else begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                      end else begin
                                                                                                        if(when_OpcodeDecoder_l110) begin
                                                                                                          io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                        end else begin
                                                                                                          if(when_OpcodeDecoder_l111) begin
                                                                                                            io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                          end else begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                                      end else begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_aluStageControl_selection_0 = OperandSource_register_1;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_aluStageControl_selection_1 = OperandSource_ones;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(when_OpcodeDecoder_l61) begin
                io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
              end else begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                  end else begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_aluStageControl_selection_1 = OperandSource_ones;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_aluStageControl_selection_1 = OperandSource_signed_memory;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                      end else begin
                                                        if(when_OpcodeDecoder_l84) begin
                                                          io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                        end else begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(when_OpcodeDecoder_l86) begin
                                                              io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                            end else begin
                                                              if(when_OpcodeDecoder_l87) begin
                                                                io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                              end else begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            io_output_stageControl_aluStageControl_selection_1 = OperandSource_zero;
                                                                          end else begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              io_output_stageControl_aluStageControl_selection_1 = OperandSource_zero;
                                                                            end else begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                              end else begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  io_output_stageControl_aluStageControl_selection_1 = OperandSource_zero;
                                                                                end else begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_aluStageControl_selection_1 = OperandSource_zero;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_aluStageControl_selection_1 = OperandSource_memory;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_aluStageControl_selection_1 = OperandSource_ones;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                end else begin
                                                                                                  if(when_OpcodeDecoder_l107) begin
                                                                                                    io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                  end else begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(!when_OpcodeDecoder_l109) begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_aluStageControl_selection_1 = OperandSource_register_1;
                                                                                                                      end else begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_aluStageControl_selection_1 = OperandSource_zero;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_and_1;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_and_1;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(when_OpcodeDecoder_l60) begin
              io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_extend1;
            end else begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_ls;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_sub;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_sub;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_xor_1;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_or_1;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_rs;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_rsa;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_sub;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_xor_1;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_compare;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                      end else begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(when_OpcodeDecoder_l85) begin
                                                            io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                          end else begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(when_OpcodeDecoder_l88) begin
                                                                  io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                                end else begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                                        end else begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_or_1;
                                                                          end else begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_or_1;
                                                                            end else begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_sub;
                                                                              end else begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_or_1;
                                                                                end else begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_compare;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_and_1;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_compare;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_compare;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_add;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                                                                end else begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(!when_OpcodeDecoder_l109) begin
                                                                                                        if(when_OpcodeDecoder_l110) begin
                                                                                                          io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                                                                        end else begin
                                                                                                          if(when_OpcodeDecoder_l111) begin
                                                                                                            io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_operand1;
                                                                                                          end else begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_ls;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_or_1;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_rs;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_rsa;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_sub;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_xor_1;
                                                                                                                      end else begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_aluStageControl_aluControl_operation = AluOperation_or_1;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_aluControl_condition = Condition_t;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(!when_OpcodeDecoder_l101) begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(!when_OpcodeDecoder_l103) begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(!when_OpcodeDecoder_l105) begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(!when_OpcodeDecoder_l109) begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_aluStageControl_aluControl_condition = _zz_io_output_stageControl_aluStageControl_aluControl_condition;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(when_OpcodeDecoder_l60) begin
              io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
            end else begin
              if(!when_OpcodeDecoder_l61) begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_writeStageControl_source = WriteBackValueSource_memory;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                      end else begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(when_OpcodeDecoder_l85) begin
                                                            io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                          end else begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(when_OpcodeDecoder_l88) begin
                                                                  io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                end else begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_writeStageControl_source = WriteBackValueSource_memory;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_memory;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_memory;
                                                                      end else begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                        end else begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                          end else begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                            end else begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                              end else begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                end else begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                end else begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_memory;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_memory;
                                                                                                      end else begin
                                                                                                        if(when_OpcodeDecoder_l110) begin
                                                                                                          io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                        end else begin
                                                                                                          if(when_OpcodeDecoder_l111) begin
                                                                                                            io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                          end else begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_writeStageControl_source = WriteBackValueSource_alu;
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_write = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(when_OpcodeDecoder_l60) begin
              io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
            end else begin
              if(!when_OpcodeDecoder_l61) begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                      end else begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(when_OpcodeDecoder_l85) begin
                                                            io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                          end else begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(when_OpcodeDecoder_l88) begin
                                                                  io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                end else begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                              end else begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                end else begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                      end else begin
                                                                                                        if(when_OpcodeDecoder_l110) begin
                                                                                                          io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                        end else begin
                                                                                                          if(when_OpcodeDecoder_l111) begin
                                                                                                            io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                          end else begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_writeStageControl_fileControl_write = 1'b1;
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_hl;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(when_OpcodeDecoder_l60) begin
              io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_f;
            end else begin
              if(!when_OpcodeDecoder_l61) begin
                if(when_OpcodeDecoder_l62) begin
                  io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                end else begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                  end else begin
                    if(when_OpcodeDecoder_l64) begin
                      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                    end else begin
                      if(when_OpcodeDecoder_l65) begin
                        io_output_stageControl_writeStageControl_fileControl_writeRegister = registerPair;
                      end else begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(when_OpcodeDecoder_l67) begin
                            io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_f;
                          end else begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_hl;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                            end else begin
                                              if(when_OpcodeDecoder_l79) begin
                                                io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                              end else begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_writeStageControl_fileControl_writeRegister = registerPair;
                                                end else begin
                                                  if(when_OpcodeDecoder_l81) begin
                                                    io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_f;
                                                  end else begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                                    end else begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_hl;
                                                      end else begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(when_OpcodeDecoder_l85) begin
                                                            io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                                          end else begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(when_OpcodeDecoder_l88) begin
                                                                  io_output_stageControl_writeStageControl_fileControl_writeRegister = registerPair;
                                                                end else begin
                                                                  if(when_OpcodeDecoder_l89) begin
                                                                    io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                  end else begin
                                                                    if(when_OpcodeDecoder_l90) begin
                                                                      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                    end else begin
                                                                      if(when_OpcodeDecoder_l91) begin
                                                                        io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                      end else begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(when_OpcodeDecoder_l95) begin
                                                                                io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                                                              end else begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(when_OpcodeDecoder_l97) begin
                                                                                    io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_f;
                                                                                  end else begin
                                                                                    if(when_OpcodeDecoder_l100) begin
                                                                                      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                    end else begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_writeStageControl_fileControl_writeRegister = register_17;
                                                                                      end else begin
                                                                                        if(when_OpcodeDecoder_l102) begin
                                                                                          io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                        end else begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_f;
                                                                                          end else begin
                                                                                            if(when_OpcodeDecoder_l104) begin
                                                                                              io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_f;
                                                                                            end else begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_writeStageControl_fileControl_writeRegister = register_17;
                                                                                              end else begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                                end else begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_writeStageControl_fileControl_writeRegister = register_17;
                                                                                                    end else begin
                                                                                                      if(when_OpcodeDecoder_l109) begin
                                                                                                        io_output_stageControl_writeStageControl_fileControl_writeRegister = register_17;
                                                                                                      end else begin
                                                                                                        if(when_OpcodeDecoder_l110) begin
                                                                                                          io_output_stageControl_writeStageControl_fileControl_writeRegister = register_17;
                                                                                                        end else begin
                                                                                                          if(when_OpcodeDecoder_l111) begin
                                                                                                            io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                                          end else begin
                                                                                                            if(when_OpcodeDecoder_l112) begin
                                                                                                              io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                                                                                            end else begin
                                                                                                              if(when_OpcodeDecoder_l113) begin
                                                                                                                io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                                              end else begin
                                                                                                                if(when_OpcodeDecoder_l114) begin
                                                                                                                  io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                                                                                                end else begin
                                                                                                                  if(when_OpcodeDecoder_l115) begin
                                                                                                                    io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_ft;
                                                                                                                  end else begin
                                                                                                                    if(when_OpcodeDecoder_l116) begin
                                                                                                                      io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                                                    end else begin
                                                                                                                      if(when_OpcodeDecoder_l117) begin
                                                                                                                        io_output_stageControl_writeStageControl_fileControl_writeRegister = RegisterName_t;
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_writeExg = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_writeStageControl_fileControl_writeExg = 1'b1;
                                                    end else begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(!when_OpcodeDecoder_l101) begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(!when_OpcodeDecoder_l103) begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(!when_OpcodeDecoder_l105) begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_writeStageControl_fileControl_writeExg = 1'b1;
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_writeExgRegister = RegisterName_ft;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(when_OpcodeDecoder_l82) begin
                                                      io_output_stageControl_writeStageControl_fileControl_writeExgRegister = registerPair;
                                                    end else begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(!when_OpcodeDecoder_l101) begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(!when_OpcodeDecoder_l103) begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(!when_OpcodeDecoder_l105) begin
                                                                                                if(when_OpcodeDecoder_l106) begin
                                                                                                  io_output_stageControl_writeStageControl_fileControl_writeExgRegister = register_17;
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      if(_zz_1[0]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = 1'b1;
      end
    end else begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(when_OpcodeDecoder_l70) begin
                                  io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = 1'b1;
                                end else begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            if(_zz_3[0]) begin
                                              io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = 1'b1;
                                            end
                                          end else begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              if(_zz_6[0]) begin
                                                                                io_output_stageControl_writeStageControl_fileControl_registerControl_0_push = 1'b1;
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(when_OpcodeDecoder_l69) begin
                                io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop = 1'b1;
                              end else begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    if(_zz_2[0]) begin
                                      io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop = 1'b1;
                                    end
                                  end else begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            if(_zz_5[0]) begin
                                                                              io_output_stageControl_writeStageControl_fileControl_registerControl_0_pop = 1'b1;
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(when_OpcodeDecoder_l74) begin
                                          io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap = 1'b1;
                                        end else begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  if(_zz_7[0]) begin
                                                                                    io_output_stageControl_writeStageControl_fileControl_registerControl_0_swap = 1'b1;
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          if(_zz_4[0]) begin
                                                                            io_output_stageControl_writeStageControl_fileControl_registerControl_0_pick = 1'b1;
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      if(_zz_1[1]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = 1'b1;
      end
    end else begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(when_OpcodeDecoder_l70) begin
                                  io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = 1'b1;
                                end else begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            if(_zz_3[1]) begin
                                              io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = 1'b1;
                                            end
                                          end else begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              if(_zz_6[1]) begin
                                                                                io_output_stageControl_writeStageControl_fileControl_registerControl_1_push = 1'b1;
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(when_OpcodeDecoder_l69) begin
                                io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop = 1'b1;
                              end else begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    if(_zz_2[1]) begin
                                      io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop = 1'b1;
                                    end
                                  end else begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            if(_zz_5[1]) begin
                                                                              io_output_stageControl_writeStageControl_fileControl_registerControl_1_pop = 1'b1;
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(when_OpcodeDecoder_l74) begin
                                          io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap = 1'b1;
                                        end else begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  if(_zz_7[1]) begin
                                                                                    io_output_stageControl_writeStageControl_fileControl_registerControl_1_swap = 1'b1;
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          if(_zz_4[1]) begin
                                                                            io_output_stageControl_writeStageControl_fileControl_registerControl_1_pick = 1'b1;
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      if(_zz_1[2]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = 1'b1;
      end
    end else begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(when_OpcodeDecoder_l70) begin
                                  io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = 1'b1;
                                end else begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            if(_zz_3[2]) begin
                                              io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = 1'b1;
                                            end
                                          end else begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              if(_zz_6[2]) begin
                                                                                io_output_stageControl_writeStageControl_fileControl_registerControl_2_push = 1'b1;
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(when_OpcodeDecoder_l69) begin
                                io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop = 1'b1;
                              end else begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    if(_zz_2[2]) begin
                                      io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop = 1'b1;
                                    end
                                  end else begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            if(_zz_5[2]) begin
                                                                              io_output_stageControl_writeStageControl_fileControl_registerControl_2_pop = 1'b1;
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(when_OpcodeDecoder_l74) begin
                                          io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap = 1'b1;
                                        end else begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  if(_zz_7[2]) begin
                                                                                    io_output_stageControl_writeStageControl_fileControl_registerControl_2_swap = 1'b1;
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          if(_zz_4[2]) begin
                                                                            io_output_stageControl_writeStageControl_fileControl_registerControl_2_pick = 1'b1;
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = 1'b0;
    if(when_OpcodeDecoder_l52) begin
      if(_zz_1[3]) begin
        io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = 1'b1;
      end
    end else begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(when_OpcodeDecoder_l70) begin
                                  io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = 1'b1;
                                end else begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            if(_zz_3[3]) begin
                                              io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = 1'b1;
                                            end
                                          end else begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(when_OpcodeDecoder_l94) begin
                                                                              if(_zz_6[3]) begin
                                                                                io_output_stageControl_writeStageControl_fileControl_registerControl_3_push = 1'b1;
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(when_OpcodeDecoder_l69) begin
                                io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop = 1'b1;
                              end else begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    if(_zz_2[3]) begin
                                      io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop = 1'b1;
                                    end
                                  end else begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(when_OpcodeDecoder_l93) begin
                                                                            if(_zz_5[3]) begin
                                                                              io_output_stageControl_writeStageControl_fileControl_registerControl_3_pop = 1'b1;
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(when_OpcodeDecoder_l74) begin
                                          io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap = 1'b1;
                                        end else begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(when_OpcodeDecoder_l96) begin
                                                                                  if(_zz_7[3]) begin
                                                                                    io_output_stageControl_writeStageControl_fileControl_registerControl_3_swap = 1'b1;
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(when_OpcodeDecoder_l92) begin
                                                                          if(_zz_4[3]) begin
                                                                            io_output_stageControl_writeStageControl_fileControl_registerControl_3_pick = 1'b1;
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_vectorFromDecoder;
    end else begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(when_OpcodeDecoder_l71) begin
                                    io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_register2;
                                  end else begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(when_OpcodeDecoder_l75) begin
                                            io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_vectorFromMemory;
                                          end else begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(when_OpcodeDecoder_l83) begin
                                                        io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_register2;
                                                      end else begin
                                                        if(when_OpcodeDecoder_l84) begin
                                                          io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_register2;
                                                        end else begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromMemory;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromDecoder;
                                                                                                    end else begin
                                                                                                      if(!when_OpcodeDecoder_l109) begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_aluStageControl_pcControl_truePath = PcTruePathSource_offsetFromMemory;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b0;
    if(!when_OpcodeDecoder_l52) begin
      if(when_OpcodeDecoder_l57) begin
        io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
      end else begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(when_OpcodeDecoder_l63) begin
                    io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                  end else begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(when_OpcodeDecoder_l68) begin
                              io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                            end else begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(when_OpcodeDecoder_l72) begin
                                      io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                    end else begin
                                      if(when_OpcodeDecoder_l73) begin
                                        io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                      end else begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(when_OpcodeDecoder_l76) begin
                                              io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                            end else begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(when_OpcodeDecoder_l80) begin
                                                  io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                                end else begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(when_OpcodeDecoder_l101) begin
                                                                                        io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                                                                      end else begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(when_OpcodeDecoder_l103) begin
                                                                                            io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                                                                          end else begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(!when_OpcodeDecoder_l105) begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(when_OpcodeDecoder_l108) begin
                                                                                                      io_output_stageControl_aluStageControl_pcControl_decodedOffset = 1'b1;
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_pcControl_vector = 3'b000;
    if(when_OpcodeDecoder_l52) begin
      io_output_stageControl_aluStageControl_pcControl_vector = 3'b011;
    end
  end

  always @(*) begin
    io_output_stageControl_aluStageControl_pcControl_condition = PcCondition_always_1;
    if(!when_OpcodeDecoder_l52) begin
      if(!when_OpcodeDecoder_l57) begin
        if(!when_OpcodeDecoder_l58) begin
          if(!when_OpcodeDecoder_l59) begin
            if(!when_OpcodeDecoder_l60) begin
              if(!when_OpcodeDecoder_l61) begin
                if(!when_OpcodeDecoder_l62) begin
                  if(!when_OpcodeDecoder_l63) begin
                    if(!when_OpcodeDecoder_l64) begin
                      if(!when_OpcodeDecoder_l65) begin
                        if(!when_OpcodeDecoder_l66) begin
                          if(!when_OpcodeDecoder_l67) begin
                            if(!when_OpcodeDecoder_l68) begin
                              if(!when_OpcodeDecoder_l69) begin
                                if(!when_OpcodeDecoder_l70) begin
                                  if(!when_OpcodeDecoder_l71) begin
                                    if(!when_OpcodeDecoder_l72) begin
                                      if(!when_OpcodeDecoder_l73) begin
                                        if(!when_OpcodeDecoder_l74) begin
                                          if(!when_OpcodeDecoder_l75) begin
                                            if(!when_OpcodeDecoder_l76) begin
                                              if(!when_OpcodeDecoder_l79) begin
                                                if(!when_OpcodeDecoder_l80) begin
                                                  if(!when_OpcodeDecoder_l81) begin
                                                    if(!when_OpcodeDecoder_l82) begin
                                                      if(!when_OpcodeDecoder_l83) begin
                                                        if(!when_OpcodeDecoder_l84) begin
                                                          if(!when_OpcodeDecoder_l85) begin
                                                            if(!when_OpcodeDecoder_l86) begin
                                                              if(!when_OpcodeDecoder_l87) begin
                                                                if(!when_OpcodeDecoder_l88) begin
                                                                  if(!when_OpcodeDecoder_l89) begin
                                                                    if(!when_OpcodeDecoder_l90) begin
                                                                      if(!when_OpcodeDecoder_l91) begin
                                                                        if(!when_OpcodeDecoder_l92) begin
                                                                          if(!when_OpcodeDecoder_l93) begin
                                                                            if(!when_OpcodeDecoder_l94) begin
                                                                              if(!when_OpcodeDecoder_l95) begin
                                                                                if(!when_OpcodeDecoder_l96) begin
                                                                                  if(!when_OpcodeDecoder_l97) begin
                                                                                    if(!when_OpcodeDecoder_l100) begin
                                                                                      if(!when_OpcodeDecoder_l101) begin
                                                                                        if(!when_OpcodeDecoder_l102) begin
                                                                                          if(!when_OpcodeDecoder_l103) begin
                                                                                            if(!when_OpcodeDecoder_l104) begin
                                                                                              if(when_OpcodeDecoder_l105) begin
                                                                                                io_output_stageControl_aluStageControl_pcControl_condition = PcCondition_whenResultNotZero;
                                                                                              end else begin
                                                                                                if(!when_OpcodeDecoder_l106) begin
                                                                                                  if(!when_OpcodeDecoder_l107) begin
                                                                                                    if(!when_OpcodeDecoder_l108) begin
                                                                                                      if(!when_OpcodeDecoder_l109) begin
                                                                                                        if(!when_OpcodeDecoder_l110) begin
                                                                                                          if(!when_OpcodeDecoder_l111) begin
                                                                                                            if(!when_OpcodeDecoder_l112) begin
                                                                                                              if(!when_OpcodeDecoder_l113) begin
                                                                                                                if(!when_OpcodeDecoder_l114) begin
                                                                                                                  if(!when_OpcodeDecoder_l115) begin
                                                                                                                    if(!when_OpcodeDecoder_l116) begin
                                                                                                                      if(!when_OpcodeDecoder_l117) begin
                                                                                                                        if(when_OpcodeDecoder_l120) begin
                                                                                                                          io_output_stageControl_aluStageControl_pcControl_condition = PcCondition_whenConditionMet;
                                                                                                                        end
                                                                                                                      end
                                                                                                                    end
                                                                                                                  end
                                                                                                                end
                                                                                                              end
                                                                                                            end
                                                                                                          end
                                                                                                        end
                                                                                                      end
                                                                                                    end
                                                                                                  end
                                                                                                end
                                                                                              end
                                                                                            end
                                                                                          end
                                                                                        end
                                                                                      end
                                                                                    end
                                                                                  end
                                                                                end
                                                                              end
                                                                            end
                                                                          end
                                                                        end
                                                                      end
                                                                    end
                                                                  end
                                                                end
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  assign when_OpcodeDecoder_l52 = (((((((_zz_when_OpcodeDecoder_l52 || _zz_when_OpcodeDecoder_l52_6) || (_zz_when_OpcodeDecoder_l52_7 == _zz_when_OpcodeDecoder_l52_8)) || ((io_opcode & _zz_when_OpcodeDecoder_l52_9) == 8'hc8)) || ((io_opcode & 8'hff) == 8'hd0)) || ((io_opcode & 8'hff) == 8'hd8)) || ((io_opcode & 8'hfe) == 8'he0)) || ((io_opcode & 8'hfe) == 8'he8));
  assign _zz_1 = ({3'd0,1'b1} <<< _zz__zz_1[1 : 0]);
  assign when_OpcodeDecoder_l57 = ((io_opcode & 8'hff) == 8'hb1);
  assign _zz_2 = ({3'd0,1'b1} <<< _zz__zz_2[1 : 0]);
  assign _zz_3 = ({3'd0,1'b1} <<< _zz__zz_3[1 : 0]);
  assign _zz_4 = ({3'd0,1'b1} <<< _zz__zz_4[1 : 0]);
  assign _zz_5 = ({3'd0,1'b1} <<< _zz__zz_5[1 : 0]);
  assign _zz_6 = ({3'd0,1'b1} <<< _zz__zz_6[1 : 0]);
  assign _zz_7 = ({3'd0,1'b1} <<< _zz__zz_7[1 : 0]);
  assign _zz_io_output_stageControl_aluStageControl_aluControl_condition_1 = io_opcode[3 : 0];
  assign _zz_io_output_stageControl_aluStageControl_aluControl_condition = _zz_io_output_stageControl_aluStageControl_aluControl_condition_1;
  assign when_OpcodeDecoder_l58 = ((io_opcode & 8'hff) == 8'h1b);
  assign when_OpcodeDecoder_l59 = ((io_opcode & 8'hff) == 8'h1a);
  assign when_OpcodeDecoder_l60 = ((io_opcode & 8'hff) == 8'h49);
  assign when_OpcodeDecoder_l61 = ((io_opcode & 8'hff) == 8'h0a);
  assign when_OpcodeDecoder_l62 = ((io_opcode & 8'hff) == 8'h0b);
  assign when_OpcodeDecoder_l63 = ((io_opcode & 8'hff) == 8'hb8);
  assign when_OpcodeDecoder_l64 = ((io_opcode & 8'hff) == 8'h51);
  assign when_OpcodeDecoder_l65 = ((io_opcode & 8'hff) == 8'hf0);
  assign when_OpcodeDecoder_l66 = ((io_opcode & 8'hff) == 8'h0);
  assign when_OpcodeDecoder_l67 = ((io_opcode & 8'hff) == 8'h18);
  assign when_OpcodeDecoder_l68 = ((io_opcode & 8'hff) == 8'hb0);
  assign when_OpcodeDecoder_l69 = ((io_opcode & 8'hff) == 8'hf9);
  assign when_OpcodeDecoder_l70 = ((io_opcode & 8'hff) == 8'hf8);
  assign when_OpcodeDecoder_l71 = ((io_opcode & 8'hff) == 8'h59);
  assign when_OpcodeDecoder_l72 = ((io_opcode & 8'hff) == 8'hb9);
  assign when_OpcodeDecoder_l73 = ((io_opcode & 8'hff) == 8'hbb);
  assign when_OpcodeDecoder_l74 = ((io_opcode & 8'hff) == 8'hcc);
  assign when_OpcodeDecoder_l75 = ((io_opcode & 8'hff) == 8'h9b);
  assign when_OpcodeDecoder_l76 = ((io_opcode & 8'hff) == 8'hb2);
  assign when_OpcodeDecoder_l79 = ((io_opcode & 8'hfc) == 8'hf4);
  assign when_OpcodeDecoder_l80 = ((io_opcode & 8'hfc) == 8'hbc);
  assign when_OpcodeDecoder_l81 = ((io_opcode & 8'hfc) == 8'hcc);
  assign when_OpcodeDecoder_l82 = ((io_opcode & 8'hfc) == 8'hc8);
  assign when_OpcodeDecoder_l83 = ((io_opcode & 8'hfc) == 8'h38);
  assign when_OpcodeDecoder_l84 = ((io_opcode & 8'hfc) == 8'h3c);
  assign when_OpcodeDecoder_l85 = ((io_opcode & 8'hfc) == 8'hd8);
  assign when_OpcodeDecoder_l86 = ((io_opcode & 8'hfc) == 8'h30);
  assign when_OpcodeDecoder_l87 = ((io_opcode & 8'hfc) == 8'h0);
  assign when_OpcodeDecoder_l88 = ((io_opcode & 8'hfc) == 8'hd0);
  assign when_OpcodeDecoder_l89 = ((io_opcode & 8'hfc) == 8'h34);
  assign when_OpcodeDecoder_l90 = ((io_opcode & 8'hfc) == 8'h0c);
  assign when_OpcodeDecoder_l91 = ((io_opcode & 8'hfc) == 8'h04);
  assign when_OpcodeDecoder_l92 = ((io_opcode & 8'hfc) == 8'h1c);
  assign when_OpcodeDecoder_l93 = ((io_opcode & 8'hfc) == 8'hc4);
  assign when_OpcodeDecoder_l94 = ((io_opcode & 8'hfc) == 8'hc0);
  assign when_OpcodeDecoder_l95 = ((io_opcode & 8'hfc) == 8'hf0);
  assign when_OpcodeDecoder_l96 = ((io_opcode & 8'hfc) == 8'hdc);
  assign when_OpcodeDecoder_l97 = ((io_opcode & 8'hfc) == 8'hd4);
  assign when_OpcodeDecoder_l100 = ((io_opcode & 8'hf8) == 8'h40);
  assign when_OpcodeDecoder_l101 = ((io_opcode & 8'hf8) == 8'ha0);
  assign when_OpcodeDecoder_l102 = ((io_opcode & 8'hf8) == 8'h68);
  assign when_OpcodeDecoder_l103 = ((io_opcode & 8'hf8) == 8'ha8);
  assign when_OpcodeDecoder_l104 = ((io_opcode & 8'hf8) == 8'h48);
  assign when_OpcodeDecoder_l105 = ((io_opcode & 8'hf8) == 8'h88);
  assign when_OpcodeDecoder_l106 = ((io_opcode & 8'hf8) == 8'h10);
  assign when_OpcodeDecoder_l107 = ((io_opcode & 8'hf8) == 8'h20);
  assign when_OpcodeDecoder_l108 = ((io_opcode & 8'hf8) == 8'h80);
  assign when_OpcodeDecoder_l109 = ((io_opcode & 8'hf8) == 8'h28);
  assign when_OpcodeDecoder_l110 = ((io_opcode & 8'hf8) == 8'h78);
  assign when_OpcodeDecoder_l111 = ((io_opcode & 8'hf8) == 8'h58);
  assign when_OpcodeDecoder_l112 = ((io_opcode & 8'hf8) == 8'he0);
  assign when_OpcodeDecoder_l113 = ((io_opcode & 8'hf8) == 8'h60);
  assign when_OpcodeDecoder_l114 = ((io_opcode & 8'hf8) == 8'he8);
  assign when_OpcodeDecoder_l115 = ((io_opcode & 8'hf8) == 8'hf8);
  assign when_OpcodeDecoder_l116 = ((io_opcode & 8'hf8) == 8'h50);
  assign when_OpcodeDecoder_l117 = ((io_opcode & 8'hf8) == 8'h70);
  assign when_OpcodeDecoder_l120 = ((io_opcode & 8'hf0) == 8'h90);

endmodule

module AddSub (
  input      [15:0]   io_dataa,
  input      [15:0]   io_datab,
  input               io_add_sub,
  output     [15:0]   io_result,
  output              io_cout
);

  wire       [16:0]   operand1;
  wire       [16:0]   operand2;
  wire       [17:0]   subResult;
  wire       [15:0]   result;
  wire                carry;

  assign operand1 = {io_dataa,1'b0};
  assign operand2 = {(io_add_sub ? (~ io_datab) : io_datab),io_add_sub};
  assign subResult = ({1'b0,operand1} - {1'b0,operand2});
  assign result = subResult[16 : 1];
  assign carry = subResult[17];
  assign io_cout = (! carry);
  assign io_result = result;

endmodule

module Shifter (
  input      [15:0]   io_operand,
  input      [3:0]    io_amount,
  input      [1:0]    io_operation,
  output     [15:0]   io_result
);
  localparam ShiftOperation_ls = 2'd0;
  localparam ShiftOperation_rs = 2'd1;
  localparam ShiftOperation_rsa = 2'd2;
  localparam ShiftOperation_swap = 2'd3;

  wire       [15:0]   rotater_io_data;
  wire       [15:0]   rotater_io_result;
  wire       [3:0]    _zz__zz_io_distance;
  wire       [3:0]    _zz__zz_io_distance_1;
  reg        [3:0]    _zz_io_distance;
  wire                fillBit;
  wire       [15:0]   fillBits;
  wire       [15:0]   mask;
  reg        [15:0]   _zz_io_result;
  `ifndef SYNTHESIS
  reg [31:0] io_operation_string;
  `endif


  assign _zz__zz_io_distance = (- _zz__zz_io_distance_1);
  assign _zz__zz_io_distance_1 = io_amount;
  CLShift rotater (
    .io_data        (rotater_io_data[15:0]    ), //i
    .io_distance    (_zz_io_distance[3:0]     ), //i
    .io_result      (rotater_io_result[15:0]  )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_operation)
      ShiftOperation_ls : io_operation_string = "ls  ";
      ShiftOperation_rs : io_operation_string = "rs  ";
      ShiftOperation_rsa : io_operation_string = "rsa ";
      ShiftOperation_swap : io_operation_string = "swap";
      default : io_operation_string = "????";
    endcase
  end
  `endif

  assign rotater_io_data = io_operand;
  always @(*) begin
    case(io_operation)
      ShiftOperation_ls : begin
        _zz_io_distance = io_amount;
      end
      ShiftOperation_swap : begin
        _zz_io_distance = 4'b1000;
      end
      default : begin
        _zz_io_distance = _zz__zz_io_distance;
      end
    endcase
  end

  assign fillBit = ((io_operation == ShiftOperation_rsa) ? io_operand[15] : 1'b0);
  assign fillBits = (fillBit ? 16'hffff : 16'h0);
  assign mask = (16'hffff <<< _zz_io_distance);
  always @(*) begin
    case(io_operation)
      ShiftOperation_ls : begin
        _zz_io_result = (rotater_io_result & mask);
      end
      ShiftOperation_swap : begin
        _zz_io_result = rotater_io_result;
      end
      default : begin
        _zz_io_result = ((rotater_io_result & (~ mask)) | (fillBits & mask));
      end
    endcase
  end

  assign io_result = _zz_io_result;

endmodule

module CLShift (
  input      [15:0]   io_data,
  input      [3:0]    io_distance,
  output     [15:0]   io_result
);

  reg        [15:0]   _zz_io_result;
  reg        [15:0]   _zz_io_result_1;
  reg        [15:0]   _zz_io_result_2;
  reg        [15:0]   _zz_io_result_3;
  wire       [15:0]   _zz_io_result_4;

  always @(*) begin
    _zz_io_result = _zz_io_result_1;
    _zz_io_result = (io_distance[3] ? {_zz_io_result_1[7 : 0],_zz_io_result_1[15 : 8]} : _zz_io_result_1);
  end

  always @(*) begin
    _zz_io_result_1 = _zz_io_result_2;
    _zz_io_result_1 = (io_distance[2] ? {_zz_io_result_2[11 : 0],_zz_io_result_2[15 : 12]} : _zz_io_result_2);
  end

  always @(*) begin
    _zz_io_result_2 = _zz_io_result_3;
    _zz_io_result_2 = (io_distance[1] ? {_zz_io_result_3[13 : 0],_zz_io_result_3[15 : 14]} : _zz_io_result_3);
  end

  always @(*) begin
    _zz_io_result_3 = _zz_io_result_4;
    _zz_io_result_3 = (io_distance[0] ? {_zz_io_result_4[14 : 0],_zz_io_result_4[15 : 15]} : _zz_io_result_4);
  end

  assign _zz_io_result_4 = io_data;
  assign io_result = _zz_io_result;

endmodule
