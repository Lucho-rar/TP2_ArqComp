`timescale 1ns / 1ps

module tb_rx_uart();

    // Parámetros
    parameter F_CLOCK  = 50E6;  // RELOJ
    parameter BAUD_RATE = 9600; // BAUDIOS
    parameter DBIT = 8;         // BITS DE DATOS
    parameter TICKS = 16;       // TITCKS POR BIT
    
    // Entradas y salidas
    reg clk, reset, rx; 
    wire tick, rx_done;
    wire [DBIT-1:0] data_out;

    // Inicialización
    initial begin
        reset = 1;
        clk = 0;
        rx = 1;  // RX inactiva

        #50 reset = 0;  // Da de baja el reset

        // Bit de Inicio (104320 ns a 9600 baudios)
        #104320 rx = 0; 

        // Envia 8 bits 
        for (integer i = 0; i < DBIT; i = i + 1) begin
            #104320 rx = 1'b1;  // Dato de prueba
        end

        #104320 rx = 1'b1;  // Bit de stop
        
        // Terminar simulación
        #500000 $finish;
    end

    // Generar reloj
    always #10 clk = ~clk;

    // Instanciar el receptor UART
    rx_uart #(
        .DBIT(DBIT),
        .SB_TICK(TICKS)
    ) u_rx_uart (
        .i_clk(clk),
        .i_reset(reset),
        .i_rx(rx),
        .i_s_tick(tick),
        .o_rx_done_tick(rx_done),
        .o_dout(data_out)
    );

    // Instanciar el generador de baudrate
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
