`timescale 1ns / 1ps

module rx_uart
#(
    parameter DBIT = 8,                             // Data bits
    parameter SB_TICK = 16,                         // Ticks for stop bits, 16 -> 1 stop bit
)
(
    input wire i_clk, i_reset,                      // Input clock y reset
    input wire i_rx,                                // Input data recived  
    input wire i_s_tick,                            // Baudio generator tick (tick source)

    output wire o_rx_done_tick,                     // Done
    output wire o_dout,                             // Received data processed
);

localparam IDLE     = 4'b0001;
localparam START    = 4'b0010;
localparam DATA     = 4'b0100;
localparam STOP     = 4'b1000;

reg [3:0] state_reg, state_next;
reg [3:0] s_reg, s_next;
reg [2:0] n_reg, n_next;
reg [7:0] b_reg, b_next;

// Finite State Machine with Datapath (FSMD) state & data registers
always @(posedge i_clk, i_reset)begin:update
    if (i_reset) begin                      // On reset all registers are set to 0 and the state machine goes to IDLE
        state_reg <= IDLE;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
    end
    else if (i_clk) begin                   // On each clock cycle the state machine is updated, synchronously
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
    end
end

// next-state logic & data path functional units/routing
always @(*)begin:next_state

    o_rx_done_tick = 1'b0;
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;

    case (state)
        IDLE: begin
            if (i_rx == 1'b0) state_next = START;   // Start bit
            else state_next = IDLE;
        end
        START: begin
            if (i_s_tick == 1'b1) begin
                if (s_reg == 7 ) begin
                    s_next = 0;
                    n_next = 0
                    state_next = DATA;
                end
                else begin
                    s_next = s_reg + 1;
                end
            end
        end
        DATA: begin
            if (i_s_tick == 1'b1) begin
                if (s_reg == 15) begin
                    s_next = 0;

                    b_next = b_reg >> 1;    
                    b_next[7] = i_rx;  

                    if (n_reg == DBIT - 1) begin
                        n_next = 0;
                        state_next = STOP;
                    end
                    else begin
                        n_next = n_reg + 1;
                    end  
                end
                else 
                    s_next = s_reg + 1;    
            end
        end
        STOP: begin
            if (i_s_tick == 1'b1) begin
                if (s_reg == SB_TICK - 1) begin
                    s_next = 0;
                    state_next = IDLE;
                    o_rx_done_tick = 1'b1;
                end
                else
                    s_next = s_reg + 1;
            end
        end
        default: state_next = IDLE;
    endcase
end

// Output data
// Assign the output data to the output port
// o_rx_done_tick will indicate when the data is ready to the interface
assign o_dout = b_reg;

endmodule
