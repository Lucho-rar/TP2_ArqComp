`timescale 1ns / 1ps


module tb_tx_uart();

    // Parámetros
    parameter F_CLOCK  = 50E6;  // RELOJ
    parameter BAUD_RATE = 9600; // BAUDIOS
    parameter DBIT = 8;         // BITS DE DATOS
    parameter TICKS = 16;       // TITCKS POR BIT

    // Entradas y salidas
    reg clk, reset, tx_start;
    wire tick, tx_done;
    reg [DBIT-1:0] data_in;
    
    wire tx;



    // Inicialización
    initial begin
        reset = 1;
        clk = 0;
        tx_start = 0;  // TX inactiva

        #50; 
        reset = 0;  // Da de baja el reset

        #104320;
        data_in = 8'b10101010;  // Dato de prueba

        #104320;
        tx_start = 1; 
    
        #104320
        wait ( tx_done == 1) ;
        
        reset = 1;
        
        #50;
      //  if (tx_done) begin
      //      $display("Transmisión completada");
      //  end
      //  else begin
      //      $display("Transmisión fallida");
      //  end
        
        
        // Terminar simulación
        #500000 $finish;
    end

    // reloj
    always #10 clk = ~clk;

    tx_uart #(
        .DBIT(DBIT),
        .SB_TICK(TICKS)
    ) u_tx_uart (
        .i_clk(clk),
        .i_reset(reset),
        .i_tx_start(tx_start),
        .i_s_tick(tick),
        .i_din(data_in),
        .o_tx_done_tick(tx_done),
        .o_tx(tx)
    );

    baud_rate_generator #(
        .FREQ(F_CLOCK),
        .BAUD_RATE(BAUD_RATE),
        .SAMPLE_TIME(TICKS)
    ) u_baud_rate_generator (
        .i_clk(clk),
        .i_reset(reset),
        .o_tick(tick)
    );
endmodule
