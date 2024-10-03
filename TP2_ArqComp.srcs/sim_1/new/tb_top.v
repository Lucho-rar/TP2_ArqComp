//`timescale 1ns / 1ps
module tb_top();
    // parametros
    parameter NB_DATA=  8; // Número de bits de los datos
    parameter NB_OP = 6;   // Número de bits de las operaciones
    parameter NB_BITS = 8; // Bits de los switches
    parameter NB_BUTTON = 3; // Bits de los botones

    //variables
    integer i; // Integer para iterar sobre las operaciones
    reg [NB_OP-1:0] op_codes[0:7]; // Arreglo con las operaciones
    reg [NB_DATA-1:0] expected_result; // Resultado esperado
    reg [NB_DATA-1:0] tmp_input_a;
    reg [NB_DATA-1:0] tmp_input_b ;
    
    // Operaciones (codificación en binario)
    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam AND = 6'b100100;
    localparam OR  = 6'b100101;
    localparam XOR = 6'b100110;
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
    localparam NOR = 6'b100111;

    // Botones (A, B, y OP)
    localparam BTN_DATA_A = 3'b001;
    localparam BTN_DATA_B = 3'b010;
    localparam BTN_DATA_OP = 3'b100;

    // Señales
    reg [NB_BITS-1:0] i_switch; // Entrada de switches
    reg [NB_BUTTON-1:0] i_button; // Entrada de botones
    reg i_clk; // Señal de reloj
    wire signed [NB_DATA-1:0] o_leds; // Salida de leds
    
    // Instancia del módulo top
    top
    #(
        .NB_BUTTON(NB_BUTTON),
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA),
        .NB_BITS(NB_BITS)
    )
    top_instance(
        .i_switch(i_switch),
        .i_button(i_button),
        .i_clk(i_clk),
        .o_leds(o_leds)
    );
    
    // Generador del reloj
    //always #10 i_clk = ~i_clk;
    always begin
        i_clk = 1'b0; 
        #10;       // 10 ns a nivel bajo
        i_clk = 1'b1;
        #10;       // 10 ns a nivel alto
    end
    // Bloque inicial
    initial begin 
        // Asignar las operaciones a los códigos
        op_codes[0] = ADD;  
        op_codes[1] = SUB;
        op_codes[2] = AND;
        op_codes[3] = OR;
        op_codes[4] = XOR;
        op_codes[5] = SRA;
        op_codes[6] = SRL;
        op_codes[7] = NOR;

        // Inicializar el reloj
        i_clk = 0;

        // Probar cada operación
        for (i = 0; i < 8; i = i + 1) begin
            // Asignar datos A y B aleatorios
            i_switch = {$urandom} & ((1 << NB_BITS) - 1); // Dato A
            i_button = BTN_DATA_A;  // Seleccionar botón para A
            tmp_input_a = i_switch;
            
            #20;
            i_button = 3'b000;     // Desactivar botón

            i_switch = {$urandom} & ((1 << NB_BITS) - 1); // Dato B
            i_button = BTN_DATA_B;  // Seleccionar botón para B
            tmp_input_b = i_switch;
            
            #20;
            i_button = 3'b000;     // Desactivar botón

            // Asignar operación
            i_switch = op_codes[i]; 
            i_button = BTN_DATA_OP; // Seleccionar botón para OP
            #20;
            i_button = 3'b000;     // Desactivar botón

            // Esperar un ciclo de reloj para ver el resultado
            #50;
            
            case (op_codes[i])
                ADD: expected_result = (tmp_input_a + tmp_input_b);  // A + B
                SUB: expected_result = (tmp_input_a - tmp_input_b);  // A - B
                AND: expected_result = (tmp_input_a & tmp_input_b);  // A & B
                OR:  expected_result = (tmp_input_a | tmp_input_b);  // A | B
                XOR: expected_result = (tmp_input_a ^ tmp_input_b);  // A ^ B
                SRA: expected_result = (tmp_input_a >>> tmp_input_b);            // Shift Right Arithmetic
                SRL: expected_result = (tmp_input_a >> tmp_input_b);             // Shift Right Logical
                NOR: expected_result = ~(tmp_input_a | tmp_input_b); // A NOR B
                default: expected_result = {NB_DATA{1'b0}};
            endcase
            
            if (o_leds !== expected_result) begin
                //$display("TEST FAILED: A = %d '%b' ---- B = %d %b ---- OP = %b", tmp_input_a,tmp_input_a, tmp_input_b,tmp_input_b, op_codes[i]);
            end else begin
                $display("TEST PASS");
                //$display("TEST PASS: A = %d '%b' ---- B = %d %b ---- OP = %b ---- OUT = %d '%b' -> EXPECTED = %d '%b'", tmp_input_a,tmp_input_a, tmp_input_b,tmp_input_b, op_codes[i], o_leds, o_leds, expected_result, expected_result );
            end
        end
        
        $finish; // Terminar la simulación
    end
endmodule
