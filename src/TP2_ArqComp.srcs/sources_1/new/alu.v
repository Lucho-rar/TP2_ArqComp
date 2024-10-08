`timescale 1ns / 1ps

module alu #                //parametros
(       
    parameter NB_DATA=  8,  //bits de datos
    parameter NB_OP = 6     //bits de operacion  
)
(
    output signed [NB_DATA-1:0] o_data, //ouput data
    input signed [NB_DATA-1:0] i_data_a, //input A data
    input signed [NB_DATA-1:0] i_data_b, //input B data
    input [NB_OP-1:0] i_data_op // input OP data
    
);

// Operaciones (codificación en binario)
localparam ADD = 6'b100000;
localparam SUB = 6'b100010;
localparam AND = 6'b100100;
localparam OR  = 6'b100101;
localparam XOR = 6'b100110;
localparam SRA = 6'b000011;
localparam SRL = 6'b000010;
localparam NOR = 6'b100111;

reg [NB_DATA-1:0] r_alu_result;     //registro temporal de resultado 

//always
always@(*) begin
    case (i_data_op)                                        //segun la operacion
        ADD: r_alu_result = i_data_a + i_data_b;            //ADD
        SUB: r_alu_result = i_data_a - i_data_b;            //SUB
        AND: r_alu_result = i_data_a & i_data_b;            //AND
        OR: r_alu_result = i_data_a | i_data_b;             //OR
        XOR: r_alu_result = i_data_a ^ i_data_b;            //XOR
        SRA: r_alu_result = i_data_a >>> i_data_b;          //SRL
        SRL: r_alu_result = i_data_a >> i_data_b;           //SRA
        NOR: r_alu_result = ~(i_data_a | i_data_b);         //NOR
        default: r_alu_result =  {NB_DATA{1'b0}};           //default
    endcase
end

assign o_data = r_alu_result;       //asignacion de resultado a output
endmodule