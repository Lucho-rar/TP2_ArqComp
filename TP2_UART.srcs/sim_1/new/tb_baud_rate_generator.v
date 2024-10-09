`timescale 1ns / 1ps

module tb_baud_rate_generator();

    reg clk, reset;               // Entradas
    wire tick;                    // Salida
    
    baud_rate_generator #(      //instancia
        .FREQ(50E6),
        .BAUD_RATE(9600),
        .SAMPLE_TIME(16)
    ) u_baud_rate_generator (
        .i_clk(clk),
        .i_reset(reset),
        .o_tick(tick)
    );
    
    // reloj
    initial begin
        clk = 0;
        forever #10 clk = ~clk;    // Reloj con periodo de 20 ns (50 MHz)
    end
    
    // Inicio
    initial begin
        reset = 1;                  //reset en 1 es decir inactivo
        #100 reset = 0;           // Desactiva el reset después de 100 ns
        
        #50000 $finish;           // Termina la simulación después de 50,000 ns
    end
    
    // Monitor de eventos
    initial begin
        $monitor("Time: %0d ns, o_tick: %b", $time, tick);
    end

endmodule
