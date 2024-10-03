
module baud_rate_generator#
(
    parameter FREQ = 50E6,                      // Frecuencia de reloj (creo que por recomendacion eran 50Mhz) ToDo: Verificar
    parameter BAUD_RATE = 19200,                // Tasa de transferencia define cómo de rápido son transmitidos los datos en una línea serie, bits por sec o baudios
                                                // Baud_rate comunes: 2400, 4800, 9600 y 19,200 
    parameter SAMPLE_TIME = 16,                 // Numero de veces que se muestrea el bit
    parameter NB_BITS = 16                      // Numero de bits de la palabra
)
(
    input wire i_clk, i_reset,                  // Entradas
    output wire o_tick                          // Salida
);

/*
    COUNTER: si tenes 50 MHz de frecuencia de reloj y queres transmitir a 19200 baudios, con un muestreo de 16 veces por bit,
    tenes que generar un tick cada 163 ciclos de reloj. Por lo tanto, el contador debe ser 163.
    Para 9600 baudios, el contador debe ser 326.
*/
localparam COUNTER = (FREQ + (BAUD_RATE * SAMPLE_TIME) - 1) / (BAUD_RATE * SAMPLE_TIME);    // Calculo del contador para el generador de BAUD_RATE, 
                                                                                            // redondeo hacia arriba

reg [NB_BITS-1:0] r_counter;                    // Registro para el contador

always @(posedge i_clk ) begin
    if (i_reset || o_tick)
        r_counter <= COUNTER;                   // Si se resetea o se genera un tick, se reinicia el contador
    else
        r_counter <= r_counter - 1'b1;          // Se decrementa el contador
end


assign o_tick = ~(|r_counter);                  // Se genera el tick cuando el contador llega a 0

endmodule