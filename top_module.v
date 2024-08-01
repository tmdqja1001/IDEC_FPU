/*
Simple FP adder with TB
Designed to meet IEEE 754
*/
module top_module ();
    // A testbench
    reg [31:0] a=0;
    reg [31:0] b=0;
    wire [31:0] out;
    reg [31:0] c1=0;
    reg clk;
    reg reset;

    initial begin
         reset <= 1;
        #10
        reset <= 0;
        
    end
    
    always begin
      #5 clk = ~clk;
      $display("%d ns a signal is %h", $time, a);
      $display("%d ns b signal is %h", $time, b);
      $display("%d ns c1 signal is %h", $time, c1);
      $display("%d ns out signal is %h", $time, out);
    end
    
    initial begin
        //`probe_start;
        clk <= 0;
        #10
        a <= 32'b11000010100111111011101000011000;
        b <= 32'b01000010011111011010111110000100;
        c1 <= 32'b11000001100000111000100101011000;

        #10
        a <= 32'b11000001100101011000000111010100;
        b <= 32'b01000001111011100110010101101000;
        c1 <= 32'b01000001001100011100011100101000;

        #10
        a <= 32'b11000001110110100110001011100000;
        b <= 32'b01000010010111010001100001100100;
        c1 <= 32'b01000001110111111100110111101000;

        #10
        a <= 32'b01000010101000100010111100100010;
        b <= 32'b11000001001000001111110101101000;
        c1 <= 32'b01000010100011100000111101110101;

        #10
        a <= 32'b01000010000010011000101011001100;
        b <= 32'b11000010101100001110001111001010;
        c1 <= 32'b11000010010110000011110011001000;

        #10
        a <= 32'b01000010101000011111110001111000;
        b <= 32'b01000010000001100101100111100000;
        c1 <= 32'b01000010111001010010100101101000;

        #10
        a <= 32'b11000010000110011010010110101110;
        b <= 32'b01000010100011010001100110100010;
        c1 <= 32'b01000010000000001000110110010110;

        #10
        a <= 32'b01000001100101010011000001111100;
        b <= 32'b11000010100111101000011110000011;
        c1 <= 32'b11000010011100100111011011001000;

        #10
        a <= 32'b01000001110110111110001011110100;
        b <= 32'b01000001101011011101110101110100;
        c1 <= 32'b01000010010001001110000000110100;
        
        #10
        a <= 32'b01000010100111011011100110110110;
        b <= 32'b01000010001111111010011111100000;
        c1 <= 32'b01000010111111011000110110100110;
        
        #50 $finish; // Quit the simulation
    end
    adder add(a, b, clk, reset, out); // instance DUT
endmodule

module adder(
    input  [31:0] a,
    input  [31:0] b,
    input         clk,
    input        reset,
    output [31:0] out);

    wire a_sign;
    wire [7:0] a_exponent;
    wire [23:0] a_mantissa;
    
    wire b_sign;
    wire [7:0] b_exponent;
    wire [23:0] b_mantissa;

    wire o_sign;
    wire [7:0] o_exponent;
    wire [24:0] o_mantissa;
    
    wire  [7:0] o_exp;
    wire  [24:0] o_man;
    wire         o_s;

    addition_align align1(
         .a(a),
         .b(b),
         .a_sign_o(a_sign),
         .b_sign_o(b_sign),
         .a_exp_o(a_exponent),
         .b_exp_o(b_exponent),
         .a_man_o(a_mantissa),
         .clk(clk),
         .reset(reset),
         .b_man_o(b_mantissa)        
     );    
    
    addition_excution excute1(
        .a_sign(a_sign),
        .b_sign(b_sign),
        .a_exp(a_exponent),
        .b_exp(b_exponent),
        .a_man(a_mantissa),
        .b_man(b_mantissa),
        .clk(clk),
        .reset(reset),
        .o_sign(o_sign),
        .o_exp(o_exponent),
        .o_man(o_mantissa)
    );
    
    addition_normaliser norm1(
        .in_e(o_exponent),
        .in_m(o_mantissa),
        .in_s(o_sign),
        .clk(clk),
        .reset(reset),
        .out_e_o(o_exp),
        .out_m_o(o_man),
        .out_s_o(o_s)
    );

    assign  out[31] = o_s;
    assign  out[30:23] = o_exp;
    assign  out[22:0] = o_man[22:0];
endmodule

module addition_align(
    input  [31:0] a,
    input  [31:0] b,
    input         clk,
    input         reset,
    output reg a_sign_o,
    output reg b_sign_o,
    output reg [7:0] a_exp_o,
    output reg [7:0] b_exp_o,
    output reg [23:0] a_man_o,
    output reg [23:0] b_man_o);

    always @ (posedge clk) begin        
        if (reset) begin
            a_sign_o <= 0;
            b_sign_o <= 0;
            a_exp_o <= 0;
            b_exp_o <= 0;
            a_man_o <= 0;
            b_man_o <= 0;
        end
        else begin
            // IEEE 754's omitted bit in mantissa (1.E)
            if(a[30:0] > b[30:0]) begin   // abs(A) > abs(B)
                a_sign_o <= a[31];
                if(a[30:23] == 0) begin // Underflow or zero
                    a_exp_o <= 8'h01;
                    a_man_o <= {1'b0, a[22:0]};
                end else begin // Normal case
                    a_exp_o <= a[30:23];
                    a_man_o <= {1'b1, a[22:0]};
                end
                b_sign_o <= b[31];
                if(b[30:23] == 0) begin
                    b_exp_o <= 8'b00000001;
                    b_man_o <= {1'b0, b[22:0]};
                end else begin
                    b_exp_o <= b[30:23];
                    b_man_o <= {1'b1, b[22:0]};
                end
            end else begin
                b_sign_o <= a[31];
                if(a[30:23] == 0) begin // Underflow or zero
                    b_exp_o <= 8'h01;
                    b_man_o <= {1'b0, a[22:0]};
                end else begin // Normal case
                    b_exp_o <= a[30:23];
                    b_man_o <= {1'b1, a[22:0]};
                end
                a_sign_o <= b[31];
                if(b[30:23] == 0) begin
                    a_exp_o <= 8'h01;
                    a_man_o <= {1'b0, b[22:0]};
                end else begin
                    a_exp_o <= b[30:23];
                    a_man_o <= {1'b1, b[22:0]};
                end
            end
        end
    end

endmodule

module addition_excution(
    input a_sign,
    input b_sign,
    input [7:0] a_exp,
    input [7:0] b_exp,
    input [23:0] a_man,
    input [23:0] b_man,
    input         clk,
    input         reset,
    output reg o_sign,
    output reg [7:0] o_exp,
    output reg [24:0] o_man);
    
    wire [7:0] diff;
    wire [23:0] tmp_man;
    
    assign   diff = a_exp - b_exp;
    assign   tmp_man = b_man >> diff;
    
    always @ (posedge clk) begin
        if (reset) begin
            o_sign <= 0;
            o_exp <= 0;
            o_man <= 0;
        end else begin
            o_exp <= a_exp;
            o_sign <= a_sign;
            if(a_sign == b_sign)
                o_man <= a_man + tmp_man;
            else
                o_man <= a_man - tmp_man;
        end
    end
endmodule

module addition_normaliser(
    input [7:0] in_e,
    input [24:0] in_m,
    input         in_s,
    input         clk,
    input         reset,
    output reg      out_s_o,
    output reg [7:0] out_e_o,
    output reg [24:0] out_m_o);

    wire [4:0] lzc;

    LZC_24 lzcnt1( .x(in_m[23:0]) , .cnt_o(lzc));
    
    always @ (posedge clk) begin
        if (reset) begin
            out_s_o <= 0;
            out_e_o <= 0;
            out_m_o <= 0;
        end else if(in_m[24]) begin
            out_s_o <= in_s;
            out_e_o <= in_e + 1;
            out_m_o <= in_m >> 1;
        end else begin
            out_s_o <= in_s;
            out_e_o <= in_e - lzc;
            out_m_o <= in_m << lzc;
        end
     end

endmodule

module LZC_24(
    input [23:0] x,
    output [4:0] cnt_o);
	
    wire [5:0] az_flag;
    wire [11:0] q;
    reg [4:0] cnt;
    
    genvar i;
    generate
        for(i=0; i<=20; i=i+4) begin : gen_blk
            LZC_4 unit(.x(x[i+3:i]), .az_o(az_flag[i/4]), .q_o(q[i/2 + 1:i/2]));
        end
    endgenerate

    always @ (*) begin
        casex(az_flag)
            6'b0xxxxx: cnt = {3'b000, q[11:10]};
            6'b1xxxxx: cnt = {3'b001, q[9:8]};
            6'b11xxxx: cnt = {3'b010, q[7:6]};
            6'b111xxx: cnt = {3'b011, q[5:4]};
            6'b1111xx: cnt = {3'b100, q[3:2]};
            6'b11111x: cnt = {3'b101, q[1:0]};
            6'b111111: cnt = {3'b110, 2'b00};
            default: cnt = 0;
        endcase
    end
    
    assign cnt_o = cnt;

endmodule

module LZC_4(
    input [3:0] x,
    output az_o,
    output [1:0] q_o);

    assign az_o = ~ ( x[3] | x[2] | x[1] | x[0] ); // high when all zero
    assign q_o[1]  = ~ ( x[3] | x[2] );
    assign q_o[0]  = ~x[3] & (~x[1] | x[2]);
endmodule
