`timescale 1ns / 1ps

module rx_uart
#(
    parameter DBIT = 8,                 // Data bits
    parameter SB_TICK = 16              // Ticks for stop bits, 16 -> 1 stop bit
(
    input wire i_clk, i_reset,          // Input clock y reset
    input wire i_rx,                    // Input data recived  
    input wire i_s_tick,                // Baudio generator tick (tick source)

    output reg o_rx_done_tick,         // done
    output wire [DBIT-1:0] o_dout      // Received data processed
);

    localparam IDLE  = 2'b00;   // Lucho: cambie los estados a dos bits en coordinacion de MdE
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state_reg, state_next;   // Registros de estado
    reg [3:0] s_reg, s_next;           // Contador de ticks
    reg [2:0] n_reg, n_next;           // Contador de bits de datos
    reg [DBIT-1:0] b_reg, b_next;      // Registro de datos
    reg [DBIT-1:0] data_out;           // Registro de salida de datos
    
    // Finite State Machine with Datapath (FSMD) state & data registers
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin             // On reset all registers are set to 0 and the state machine goes to IDLE
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end
        else begin            // On each clock cycle the state machine is updated, synchronously
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end
    
    // next-state logic & data path functional units/routing
    always @(*) begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        o_rx_done_tick = 1'b0;

        case (state_reg)
            IDLE: begin
                if (~i_rx) begin  // Start bit
                    s_next = 0;
                    state_next = START;
                end
            end
            START: begin
                if (i_s_tick) begin
                    if (s_reg == 7) begin
                        s_next = 0;
                        n_next = 0;
                        state_next = DATA;
                    end
                    else
                        s_next = s_reg + 1'b1;
                end
            end
            DATA: begin
                if (i_s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = {i_rx, b_reg[DBIT-1:1]}; //Lucho: cambie lo del desplazamiento
                        if (n_reg == DBIT-1)
                            state_next = STOP;
                        else
                            n_next = n_reg + 1'b1;
                    end
                    else
                        s_next = s_reg + 1'b1;
                end
            end
            STOP: begin
                if (i_s_tick) begin
                    if (s_reg == SB_TICK - 1) begin
                        state_next = IDLE;
                        o_rx_done_tick = 1'b1;
                        data_out = b_reg;       // Lucho: si asignaba b_reg lo hace siempre, queremos q lo asigne cuando entra en el stop
                    end
                    else
                        s_next = s_reg + 1'b1;
                end
            end
        endcase
    end
    
    assign o_dout = data_out;

endmodule