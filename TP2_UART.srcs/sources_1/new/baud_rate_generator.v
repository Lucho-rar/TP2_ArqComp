`timescale 1ns / 1ps

module baud_rate_generator#
(
    parameter FREQ = 50E6,                  // Frecuencia de reloj (creo que por recomendacion eran 50Mhz) ToDo: Verificar
    parameter BAUD_RATE = 9600,              // Tasa de transferencia define cómo de rápido son transmitidos los datos en una línea serie, bits por sec o baudios
                                                // Baud_rate comunes: 2400, 4800, 9600 y 19,200 
    parameter SAMPLE_TIME = 16              // Número de veces que se muestrea el bit
)
(
    input wire i_clk, i_reset,              // Entradas: reloj y reset
    output wire o_tick                      // Salida: tick
);
    
    /*
    COUNTER: si tenes 50 MHz de frecuencia de reloj y queres transmitir a 19200 baudios, con un muestreo de 16 veces por bit,
    tenes que generar un tick cada 163 ciclos de reloj. Por lo tanto, el contador debe ser 163.
    Para 9600 baudios, el contador debe ser 326.
    */
    localparam COUNTER = FREQ / (BAUD_RATE * SAMPLE_TIME);  // Cálculo del contador
    localparam N_BITS_COUNTER = $clog2(COUNTER);                   // Bits necesarios para el contador

    reg [N_BITS_COUNTER-1:0] r_counter;                            // Registro para el contador

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset)
            r_counter <= COUNTER - 1;                      // Reinicia el contador en reset
        else if (r_counter == 0)
            r_counter <= COUNTER - 1;                      // Reinicia cuando llega a 0
        else
            r_counter <= r_counter - 1;                    // Decrementa el contador
    end

    assign o_tick = (r_counter == 0);                      // Genera el tick cuando llega a 0

endmodule
