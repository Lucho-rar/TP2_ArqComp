
module baud_rate_generator#
(
    parameter frequency = 50E6, //Frecuencia de reloj (creo que por recomendacion eran 50Mhz) ToDo: Verificar
    parameter baudrate = 9600, // Baudrate
    parameter sampled_times = 16, // Numero de veces que se muestrea el bit
    parameter NB_BITS = 16 // Numero de bits de la palabra
)
(
    input wire i_clk, i_reset,  // Entradas
    output wire o_tick  // Salida
);

localparam counter = frequency / (baudrate * sampled_times); // Calculo del contador para el generador de baudrate

reg [NB_BITS-1:0] r_counter;    // Registro para el contador

always @(posedge i_clk ) begin
    if (i_reset || o_tick)
        r_counter <= counter; // Si se resetea o se genera un tick, se reinicia el contador
    else
        r_counter <= r_counter - 1'b1; // Se decrementa el contador
end


assign o_tick = ~(|r_counter);  // Se genera el tick cuando el contador llega a 0

endmodule