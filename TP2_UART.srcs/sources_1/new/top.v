`timescale 1ns / 1ps

module top
#(
    parameter DBIT =  8,            //bits de datos
    parameter NB_OP = 6,            //bits de operacion 
    parameter SB_TICK = 16,         //ticks de la uart 
    parameter FREQ = 50E6,                  
    parameter BAUD_RATE = 9600,              
    parameter SAMPLE_TIME = 16 
)
(
    input wire i_clk, i_reset,      // Input clock y reset
    input wire i_rx,
    output wire o_tx,
    output wire o_tx_done
);

// entradas / salidas internas
wire [DBIT-1:0]      alu_out;        // alu [o_data] -> interfaz [i_alu_data]
wire [DBIT-1:0]      alu_a;          // interfaz [o_data_a] -> alu [i_data_a]
wire [DBIT-1:0]      alu_b;          // interfaz [o_data_b] -> alu [i_data_b]
wire [NB_OP-1:0]     alu_op;         // interfaz [o_data_op -> alu [i_data_op]
wire                 rx_done;        // rx_uart [o_rx_done_tick] -> interfaz [i_rx_done]
wire [DBIT-1:0]      rx_dout;        // rx_uart [o_dout (receptor)] -> interfaz [i_rx_data]
wire                 tx_start;       // interfaz [o_tx_start] -> tx_uart [i_tx_start]
wire [DBIT-1:0]      tx_din;         // interfaz [o_dout (transmisor)] -> tx_uart [i_din]
wire                 tick;           // generador [o_tick] -> tx_rx_uart [i_s_tick]

// Conexion a las entradas / salidas del top (registros temporales)
wire                 tx_done_tick;   // tx_uart [o_tx_done_tick] -> o_tx_done           
wire [DBIT-1:0]      tx_dout;        // tx_uart [o_tx] -> o_tx       
wire                 clk_cw;

assign o_tx_done = tx_done_tick;
assign o_tx = tx_dout;


clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_w),               // output clk_out1
    // Status and control signals
    .reset(i_reset),                // input reset
    .locked(locked),                // output locked
   // Clock in ports
    .clk_in1(i_clk)                 // input clk_in1
);

tx_uart #(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) u_mod_tx_uart(
    .i_clk(clk_w),
    .i_reset(i_reset),
    .i_din(tx_din),
    .i_tx_start(tx_start),
    .i_s_tick(tick),
    .o_tx_done_tick(tx_done_tick),
    .o_tx(tx_dout)
);

rx_uart #( 
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) u_mod_rx_uart(
    .i_clk(clk_w),
    .i_reset(i_reset),
    .i_rx(i_rx),
    .i_s_tick(tick),
    .o_rx_done_tick(rx_done),
    .o_dout(rx_dout)
);

baud_rate_generator #(
    .FREQ(FREQ),
    .BAUD_RATE(BAUD_RATE),
    .SAMPLE_TIME(SAMPLE_TIME)
) u_mod_baud_rate_generator(
    .i_clk(clk_w),
    .i_reset(i_reset),
    .o_tick(tick)
);

interface #(
    .DBIT(DBIT),
    .NB_OP(NB_OP)
) u_mod_interface(
    .i_clk(clk_w),
    .i_reset(i_reset),
    .i_rx_data(rx_dout),
    .i_alu_data(alu_out),
    .i_rx_done(rx_done),
    .o_data_a(alu_a),
    .o_data_b(alu_b),
    .o_data_op(alu_op),
    .o_tx_start(tx_start),
    .o_dout(tx_din)
);

alu #(
    .NB_DATA(DBIT),
    .NB_OP(NB_OP)
) u_mod_alu(
    .i_data_a(alu_a),
    .i_data_b(alu_b),
    .i_data_op(alu_op),
    .o_data(alu_out)
);

endmodule