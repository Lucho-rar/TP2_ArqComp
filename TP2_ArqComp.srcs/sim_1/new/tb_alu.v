//`timescale 1ns / 1ps

module tb_alu;  

    
    parameter NB_DATA = 8;                  // Parametros
    parameter NB_OP = 6;
    
                                
    localparam ADD = 6'b100000;             // Operaciones 
    localparam SUB = 6'b100010;
    localparam AND = 6'b100100;
    localparam OR = 6'b100101;
    localparam XOR = 6'b100110;
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
    localparam NOR = 6'b100111;
    
    integer i;                              // Entero auxiliar para iteraciones
    reg [NB_OP-1:0] tb_op_codes[0:7];       // Arrays of operations
    

    reg signed [NB_DATA-1:0] tb_i_data_a;   // Input A data
    reg signed [NB_DATA-1:0] tb_i_data_b;   // Input B data
    reg [NB_OP-1:0] tb_i_data_op;           // Input OP data
    wire signed [NB_DATA-1:0] tb_o_data;    // Output data

    reg signed [NB_DATA-1:0] expected_data; // Reg for compare

    // Alu instance
    alu #(.NB_DATA(NB_DATA), .NB_OP(NB_OP)) uut (
        .i_data_a(tb_i_data_a),
        .i_data_b(tb_i_data_b),
        .i_data_op(tb_i_data_op),
        .o_data(tb_o_data)
    );
    
    
    initial begin
        //Llenamos el arreglo con las operaciones
        tb_op_codes[0] = ADD;
        tb_op_codes[1] = SUB;
        tb_op_codes[2] = AND;
        tb_op_codes[3] = OR;
        tb_op_codes[4] = XOR;
        tb_op_codes[5] = SRA;
        tb_op_codes[6] = SRL;
        tb_op_codes[7] = NOR;
        
        $monitor("Time: %0t | A = %d | B = %d | OP = %b | Result = %d | Expected = %d", 
                 $time, tb_i_data_a, tb_i_data_b, tb_i_data_op, tb_o_data, expected_data);
                 
        for (i = 0; i < 8; i = i + 1) begin
            tb_i_data_a = $random % (1 << NB_DATA);  // Randon en rango [-8,7]
            tb_i_data_b = $random % (1 << NB_DATA);  // Randon en rango [-8,7]
            
            tb_i_data_op = tb_op_codes[i];           // Codigo de operacion

            case (tb_i_data_op)
                ADD: expected_data = tb_i_data_a + tb_i_data_b;
                SUB: expected_data = tb_i_data_a - tb_i_data_b;
                AND: expected_data = tb_i_data_a & tb_i_data_b;
                OR: expected_data = tb_i_data_a | tb_i_data_b;
                XOR: expected_data = tb_i_data_a ^ tb_i_data_b;
                SRA: expected_data = tb_i_data_a >>> tb_i_data_b;
                SRL: expected_data = tb_i_data_a >> tb_i_data_b;
                NOR: expected_data = ~(tb_i_data_a | tb_i_data_b);
                default: expected_data = {NB_DATA{1'b0}}; 
            endcase

            #10; // Wait

            if (tb_o_data !== expected_data) begin //Check respuesta
                $display("ERROR: A = %d, B = %d, OP = %b, Esperado = %d, Obtenido = %d",
                         tb_i_data_a, tb_i_data_b, tb_i_data_op, expected_data, tb_o_data);
            end else begin
                $display("OK: A = %d, B = %d, OP = %b, Resultado = %d", 
                         tb_i_data_a, tb_i_data_b, tb_i_data_op, tb_o_data);
            end
        end
        
        $finish;
    end

endmodule