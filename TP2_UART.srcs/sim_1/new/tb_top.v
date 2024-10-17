`timescale 1ns/1ps

module tb_top();

    localparam  DBIT = 8;
    localparam  NB_OP = 6;
    localparam  FREQ = 50E6;
    localparam  BAUD_RATE = 9600;
    localparam  SAMPLE_TIME = 16;

    reg clk, reset;
    reg rx;
    wire tx, tx_done;

    reg [DBIT-1:0] tx_data;
    reg [DBIT:0] cnt_bits;
    
    initial begin
        clk = 1'b0;
        rx = 1'b1;
        reset = 1'b1;

        #50 reset = 1'b0;

        tx_data = 8'b00000001;

        #104320
        rx = 1'b0;     //inicio                                                        //A

        for (cnt_bits = 0; cnt_bits < 8; cnt_bits = cnt_bits + 1)
            #104320 rx = tx_data[cnt_bits];
  
        #104320 rx = 1'b1;     //fin

        #50 tx_data = 8'b00000010;

        #104320
        rx = 1'b0;     //inicio                                                        //B

        for (cnt_bits = 0; cnt_bits < DBIT; cnt_bits = cnt_bits + 1) begin
            #104320 rx = tx_data[cnt_bits];
        end

        #104320 rx = 1'b1;     //fin

        #50 tx_data = 8'b00100000;

        #104320
        rx = 1'b0;     //inicio                                                        //OP

        for (cnt_bits = 0; cnt_bits < DBIT; cnt_bits = cnt_bits + 1) begin
            #104320 rx = tx_data[cnt_bits];
        end

        #104320 rx = 1'b1;     //fin
        //#5000000;
       // $finish;
    end

    always #10 clk = ~clk;
    
    always @(*)
    begin
        if(tx_done == 1) begin
            $display("fin loco");
            #50000          //para poder ver el tx done
            $finish;
        end
    end

    top #(
        .DBIT(DBIT),
        .NB_OP(NB_OP),
        .FREQ(FREQ),
        .BAUD_RATE(BAUD_RATE),
        .SAMPLE_TIME(SAMPLE_TIME)
    )

    u_mod_top (
        .i_clk(clk),
        .i_reset(reset),
        .i_rx(rx),
        .o_tx(tx),
        .o_tx_done(tx_done)
    );

endmodule