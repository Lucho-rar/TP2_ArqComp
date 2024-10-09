`timescale 1ns/1ps

module tb_interface();

    // Parámetros
    //parameter F_CLOCK  = 50E6;  // RELOJ
    //parameter BAUD_RATE = 9600; // BAUDIOS
    localparam DBIT = 8;         // BITS DE DATOS
    localparam NB_OP = 6;        // BITS DE OPERACION

    reg clk, reset;         // Input clock y reset
    reg rx_done   ;           //  este es el done del receptor del modulo uart
    reg [DBIT-1:0] rx_data ;      // este es el dato que sale del receptor del modulo uart
    wire [DBIT-1:0] alu_data   ;    // esta es la entrada de datos del modulo alu

    wire [DBIT-1:0] data_a, data_b,  data_out;     //datos para la alu
    wire [NB_OP-1:0] data_op;
    wire tx_start;          // start para conversion del modulo uart


    initial begin 
        clk = 0;
        reset = 1;
        rx_done = 0;
        rx_data = 0;

        #50 reset = 0;      //saco el reset

        rx_data = 8'b00000001;  // Le meto un 1                     ///////////////DATO A
        #30 rx_done = 1;        // Le aviso al modulo que ya termino de recibir
        #30 rx_done=0;

        rx_data = 8'b00000001;  // Le meto un 1                     ///////////////DATO B
        #30 rx_done = 1;        // Le aviso al modulo que ya termino de recibir
        #30 rx_done=0;

        rx_data = 6'b100000;  // SUMA                 ///////////////DATO operacion
        #30 rx_done = 1;        // Le aviso al modulo que ya termino de recibir
        #30 rx_done=0;
        
        #60 reset =1;
        $finish;
    end
    
    // reloj
    always #10 clk = ~clk;

    interface #(
        .DBIT(DBIT),
        .NB_OP(NB_OP)
    ) u_interface (
        .i_clk(clk),
        .i_reset(reset),
        .i_rx_done(rx_done),
        .i_rx_data(rx_data),
        .i_alu_data(alu_data),
        .o_data_a(data_a),
        .o_data_b(data_b),
        .o_data_op(data_op),
        .o_tx_start(tx_start),
        .o_dout(data_out)
    );

    alu #(
        .NB_DATA(DBIT),
        .NB_OP(NB_OP)
    ) u_alu (
        .i_data_a(data_a),
        .i_data_b(data_b),
        .i_data_op(data_op),
        .o_data(data_out)         
    );


endmodule