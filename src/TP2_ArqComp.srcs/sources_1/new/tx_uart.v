`timescale 1ns/1ps

module tx_uart
#(
    parameter DBIT = 8,                 // Data bits
    parameter SB_TICK = 16              // Ticks for stop bits, 16 -> 1 stop bit
)
(
    input wire i_clk, i_reset,          // Input clock y reset
    input wire i_tx_start,                    // Input data to be transmitted
    input wire i_s_tick,                // Baud rate generator tick (tick source)
    input wire [DBIT-1:0] i_din,        // Data to be transmitted

    output reg o_tx_done_tick,         // done
    output wire o_tx                   // Transmitted data
);

    localparam IDLE  = 2'b00;   // Lucho: cambie los estados a dos bits en coordinacion de MdE
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state_reg, state_next;   // Registros de estado
    reg [3:0] s_reg, s_next;           // Contador de ticks
    reg [2:0] n_reg, n_next;           // Contador de bits de datos
    reg [DBIT-1:0] b_reg, b_next;      // Registro de datos
    reg         tx_reg, tx_next;       // Registro de salida de datos

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1;
        end
        else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    always @(*) begin
        state_next = state_reg;
        o_tx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        
        case(state_reg)
            IDLE: begin
                tx_next = 1'b1;    // mantengo el tx en uno porque no envio datos 
                if (i_tx_start) begin           // si viene el init pasamos de estado
                    s_next = 0;             
                    state_next = START;
                    b_next = i_din;             //  byte que se va a transmitir 
                end
            end
            START: begin
                tx_next = 1'b0;         //tx cero
                if (i_s_tick) begin 
                    if (s_reg == 15) begin      // el tx cuenta hasta 15 ticks
                        state_next = DATA;      // si es el 15 paso de estado 
                        s_next = 0;
                        n_next = 0;
                    end
                    else begin
                        s_next = s_reg + 1;     
                    end
                end
            end
            DATA: begin
                tx_next = b_reg[0];     // bit 0 
                if (i_s_tick) begin
                    if (s_reg == 15) begin      //si es el ultimo tick vamos al siguiente bit
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg == (DBIT-1)) begin        //si aparte ya se alcanzo el tamano del byte cambiamos de estado
                            state_next = STOP;
                        end
                        else begin
                            n_next = n_reg + 1;     // sino sigo sumando tanto el contador de bits como el de ticks
                        end
                    end
                    else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1;        //en stop pongo el tx en 1 
                if (i_s_tick) begin
                    if (s_reg == (SB_TICK-1)) begin     //tengo que enviarlo 16 veces igualmente 
                        state_next = IDLE;              // cuando termino cambi o den uevo a iddle y pongo seteo DONE
                        o_tx_done_tick = 1'b1;
                    end
                    else begin
                        s_next = s_reg + 1;
                    end
                end
            end
         endcase
    end
    assign o_tx = tx_reg;           //assign de salida
endmodule