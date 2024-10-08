`timescale 1ns/1ps


module interface#(
    parameter DBIT = 8,                // Data bits
    parameter NB_OP = 6                // Operation bits
)(
    input wire i_clk, i_reset,         // Input clock y reset
    input wire i_rx_done,               //  este es el done del receptor del modulo uart
    input [DBIT-1:0] i_rx_data,       // este es el dato que sale del receptor del modulo uart
    input [DBIT-1:0] i_alu_data,       // esta es la entrada de datos del modulo alu



    //datos para la alu
    output  [DBIT-1:0] o_data_a,     //dato A
    output  [DBIT-1:0] o_data_b,     //dato B
    output  [NB_OP-1:0] o_data_op,   //operacion

    // datos de la interfaz a enviar a tx del modulo uart
    output  o_tx_start,          // start para conversion del modulo uart
    output [DBIT-1:0] o_dout        //dato de salida del resultado de la operacion
);

    // estados
    localparam  [1:0] DATA_A = 2'b00; // estado para recibir dato A
    localparam  [1:0] DATA_B = 2'b01; // estado para recibir dato B
    localparam  [1:0] DATA_OP = 2'b10;     // estado para recibir operacion
    localparam  [1:0] RESPONSE = 2'b11;        // estado para enviar datos

    // registros 
    reg [1:0] state_reg, state_next;   // Registros de estado
    reg [DBIT-1:0] data_a_reg, data_b_reg, data_a_next, data_b_next;      // Registro de datos
    reg [NB_OP-1:0] data_op_reg, data_op_next;            // Registro de operacion
    reg [DBIT-1:0] data_out_reg, data_out_next;            // Registro de salida de datos
    reg tx_start_reg, tx_start_next;                    // Registro de salida de datos

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state_reg <= DATA_A;
            data_a_reg <= 0;
            data_b_reg <= 0;
            data_op_reg <= 0;
            data_out_reg <= 0;
            tx_start_reg <= 0;
        end
        else begin
            state_reg <= state_next;
            data_a_reg <= data_a_next;
            data_b_reg <= data_b_next;
            data_op_reg <= data_op_next;
            data_out_reg <= data_out_next;
            tx_start_reg <= tx_start_next;
        end
    end

    always @(*) begin
        state_next = state_reg;
        data_a_next = data_a_reg;
        data_b_next = data_b_reg;
        data_op_next = data_op_reg;
        data_out_next = data_out_reg;
        tx_start_next = 1'b0;

        case (state_reg)
            DATA_A: begin
                if (i_rx_done) begin
                    data_a_next = i_rx_data;
                    state_next = DATA_B;
                end
            end
            DATA_B: begin
                if (i_rx_done) begin
                    data_b_next = i_rx_data;
                    state_next = DATA_OP;
                end
            end
            DATA_OP: begin
                if (i_rx_done) begin
                    data_op_next = i_rx_data;
                    state_next = RESPONSE;
                end
            end
            RESPONSE: begin
                data_out_next = i_alu_data;
                tx_start_next = 1'b1;
                state_next = DATA_A;
            end
        endcase
    end

    assign o_data_a = data_a_reg;
    assign o_data_b = data_b_reg;
    assign o_data_op = data_op_reg;
    assign o_dout = data_out_reg;
    assign o_tx_start = tx_start_reg;
    
endmodule

    