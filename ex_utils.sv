`ifndef __EX_UTILS_V__
`define __EX_UTILS_V__

`timescale 1ps/1ps

//
// Adder Module
//
// res = a + b + c_in
module adder(
    input [31:0] a,
    input [31:0] b,
    input c_in,
    output [31:0] res
);
    logic [7:0] c_temp;
    adder_4_bit add1(.a(a[3:0]), .b(b[3:0]), .c_in(c_in), .res(res[3:0]), .c_out(c_temp[0]));
	adder_4_bit add2(.a(a[7:4]), .b(b[7:4]), .c_in(c_temp[0]), .res(res[7:4]), .c_out(c_temp[1]));
    adder_4_bit add3(.a(a[11:8]), .b(b[11:8]), .c_in(c_temp[1]), .res(res[11:8]), .c_out(c_temp[2]));
	adder_4_bit add4(.a(a[15:12]), .b(b[15:12]), .c_in(c_temp[2]), .res(res[15:12]), .c_out(c_temp[3]));
    adder_4_bit add5(.a(a[19:16]), .b(b[19:16]), .c_in(c_temp[3]), .res(res[19:16]), .c_out(c_temp[4]));
	adder_4_bit add6(.a(a[23:20]), .b(b[23:20]), .c_in(c_temp[4]), .res(res[23:20]), .c_out(c_temp[5]));
    adder_4_bit add7(.a(a[27:24]), .b(b[27:24]), .c_in(c_temp[5]), .res(res[27:24]), .c_out(c_temp[6]));
	adder_4_bit add8(.a(a[31:28]), .b(b[31:28]), .c_in(c_temp[6]), .res(res[31:28]), .c_out(c_temp[7]));

endmodule

module adder_33_bit(
    input [32:0] a,
    input [32:0] b,
    input c_in,
    output [32:0] res
);
    logic [8:0] c_temp;
    adder_4_bit add1(.a(a[3:0]), .b(b[3:0]), .c_in(c_in), .res(res[3:0]), .c_out(c_temp[0]));
	adder_4_bit add2(.a(a[7:4]), .b(b[7:4]), .c_in(c_temp[0]), .res(res[7:4]), .c_out(c_temp[1]));
    adder_4_bit add3(.a(a[11:8]), .b(b[11:8]), .c_in(c_temp[1]), .res(res[11:8]), .c_out(c_temp[2]));
	adder_4_bit add4(.a(a[15:12]), .b(b[15:12]), .c_in(c_temp[2]), .res(res[15:12]), .c_out(c_temp[3]));
    adder_4_bit add5(.a(a[19:16]), .b(b[19:16]), .c_in(c_temp[3]), .res(res[19:16]), .c_out(c_temp[4]));
	adder_4_bit add6(.a(a[23:20]), .b(b[23:20]), .c_in(c_temp[4]), .res(res[23:20]), .c_out(c_temp[5]));
    adder_4_bit add7(.a(a[27:24]), .b(b[27:24]), .c_in(c_temp[5]), .res(res[27:24]), .c_out(c_temp[6]));
	adder_4_bit add8(.a(a[31:28]), .b(b[31:28]), .c_in(c_temp[6]), .res(res[31:28]), .c_out(c_temp[7]));
    assign res[32] = (a[32]^b[32]) ^ c_temp[7];
endmodule


module adder_4_bit(
    input [3:0] a,
    input [3:0] b,
    input c_in,
    output [3:0]res,
    output c_out
);
	logic [3:0] tmp_and, tmp_xor;
	assign tmp_and = a & b;
	assign tmp_xor = a ^ b;
	assign c0 = tmp_and[0] |( tmp_xor[0] & c_in);
	assign c1 = tmp_and[1] | (tmp_xor[1] & tmp_and[0]) | (tmp_xor[1] & tmp_xor[0] & c_in);
	assign c2 = tmp_and[2] | (tmp_xor[2] & tmp_and[1]) | (tmp_xor[2] & tmp_xor[1] & tmp_and[0]) | (tmp_xor[2] & tmp_xor[1] & tmp_xor[0] & c_in);
	assign c_out = tmp_and[3] | (tmp_xor[3] & tmp_and[2]) | (tmp_xor[3] & tmp_xor[2] & tmp_and[1]) | (tmp_xor[3] & tmp_xor[2] & tmp_xor[1] & tmp_and[0]) | (tmp_xor[3] & tmp_xor[2] & tmp_xor[1] & tmp_xor[0] & c_in);

	assign res = tmp_xor ^ {c2, c1, c0, c_in};

endmodule


//
// Substractor Module
//
// res = a - b
// Using 2's complement; may exist overflow
module substractor(
    input [31:0] a,
    input [31:0] b,
    output [31:0] res
);
    adder add(.a(a), .b(~b), .c_in(1'b1), .res(res));
endmodule

module substractor_33_bit(
    input [32:0] a,
    input [32:0] b,
    output [32:0] res
);
    adder_33_bit add(.a(a), .b(~b), .c_in(1'b1), .res(res));
endmodule

//
// SLT (signed) Module
//
// res = (a < b)
module slt(
    input [31:0] a,
    input [31:0] b,
    output res
);
    logic [31:0] tmp_res;
    substractor sub(.a(a), .b(b), .res(tmp_res));
    // ToOptimize
    // logic tmp_xor;
    // assign tmp_xor = a ^ b;
    // assign res = (b[31] & tmp_xor[31]) | (~b[31] & (|(tmp_xor[30:0] & b[30:0]))) | (b[31] & (|(tmp_xor[30:0] & a[30:0])))
    assign res = (b[31] & (a[31]^b[31])) | (~(a[31]^b[31]) & tmp_res[31]);

endmodule

//
// SLTU (unsigned) Module
//
// res = (a < b)
module sltu(
    input [31:0] a,
    input [31:0] b,
    output res
);

    logic [32:0] tmp_res;
    substractor sub(.a({1'b0, a}), .b({1'b0, b}), .res(tmp_res));
    assign res = tmp_res[32];

endmodule

//
// Multiplication Module
//
// res = a * b
// Overflow?
module multiply(
    input [31:0] a,
    input [31:0] b,
    output [31:0] res
);
    // logic [63:0] total;
    // assign res = total[31:0];
    // adder add0(.a({31'b0,a[0]}), .b({31'b{b[31]}}))
    // assign res[31] = (~(|b[4:0]) & a[31]);
    // assign res[30] = (~(|b[4:0]) & a[31]);

endmodule

//
// SRL Module
//
// res = a >> b[4:0]
module sltu(
    input [31:0] a,
    input [31:0] b,
    output [31:0] res
);

    assign res[31] = (~(|b[4:0]) & a[31]);
    assign res[30] = (~(|b[4:0]) & a[31]);

endmodule

//
//
`endif // __EX_UTILS_V__