`ifndef __EX_UTILS_V__
`define __EX_UTILS_V__

`timescale 1ns/1ps

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
    adder_4_bit adder [7:0] (
        .a(a), .b(b), .c_in({c_temp[6:0], c_in}),
        .res(res), .c_out(c_temp)
    );

endmodule

module adder_64_bit(
    input [63:0] a,
    input [63:0] b,
    input c_in,
    output [63:0] res
);
    logic [15:0] c_temp;
    adder_4_bit adder [15:0] (
        .a(a), .b(b), .c_in({c_temp[14:0], c_in}),
        .res(res), .c_out(c_temp)
    );

endmodule

module adder_33_bit(
    input [32:0] a,
    input [32:0] b,
    input c_in,
    output [32:0] res
);
    logic [8:0] c_temp;
    adder_4_bit adder [7:0] (
        .a(a[31:0]), .b(b[31:0]), .c_in({c_temp[6:0], c_in}),
        .res(res[31:0]), .c_out(c_temp[7:0])
    );
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
    logic [2:0] c;
	assign tmp_and = a & b;
	assign tmp_xor = a ^ b;
	assign c[0] = tmp_and[0] |( tmp_xor[0] & c_in);
	assign c[1] = tmp_and[1] | (tmp_xor[1] & tmp_and[0]) | (tmp_xor[1] & tmp_xor[0] & c_in);
	assign c[2] = tmp_and[2] | (tmp_xor[2] & tmp_and[1]) | (tmp_xor[2] & tmp_xor[1] & tmp_and[0]) | (tmp_xor[2] & tmp_xor[1] & tmp_xor[0] & c_in);
	assign c_out = tmp_and[3] | (tmp_xor[3] & tmp_and[2]) | (tmp_xor[3] & tmp_xor[2] & tmp_and[1]) | (tmp_xor[3] & tmp_xor[2] & tmp_xor[1] & tmp_and[0]) | (tmp_xor[3] & tmp_xor[2] & tmp_xor[1] & tmp_xor[0] & c_in);

	assign res = tmp_xor ^ {c, c_in};

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
module mul(
    input [31:0] a,
    input is_signed_a,
    input [31:0] b,
    input is_signed_b,
    output [63:0] res
);
    logic pad_a_bit, pad_b_bit;
    mux_2 mux_a(
        .in_0(1'b0),
        .in_1(a[31]),
        .sl(is_signed_a),
        .out(pad_a_bit)
    );
    mux_2 mux_b(
        .in_0(1'b0),
        .in_1(b[31]),
        .sl(is_signed_b),
        .out(pad_b_bit)
    );

    logic [127:0] pad_a;
    logic [63:0] pad_b;
    assign pad_a = {{32{pad_a_bit}}, a, 63'b0};
    assign pad_b = {{32{pad_b_bit}}, b};
    logic [63:0] tmp_res [64:0];
    assign tmp_res[0] = 64'b0;
    assign res = tmp_res[64];
    generate
        genvar i;
        for (i=0; i<64; i++) begin
            adder_64_bit adder (
                .a(pad_a[126-i:63-i] & {64{pad_b[i]}}),
                .b(tmp_res[i]),
                .c_in(1'b0),
                .res(tmp_res[i+1])
            );
        end
    endgenerate

endmodule

//
// SRL Module
//
// res = a >> b[4:0]
module srl(
    input [31:0] a,
    input [31:0] b,
    output [31:0] res
);
    logic [62:0] pad_a;
    assign pad_a = {31'b0, a};
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            mux_32 mux_32 (
                .in({pad_a[31+i:i]}),
                .sl(b[4:0]),
                .out(res[i])
            );
        end
    endgenerate
endmodule

//
// SLL Module
//
// res = a << b[4:0]
module sll(
    input [31:0] a,
    input [31:0] b,
    output [31:0] res
);
    // integer j;
    logic [62:0] pad_a, reversed_pad_a;
    assign pad_a = {a, 31'b0};

    always @(*) begin
        for (integer j=0;j<63;j++) begin
            reversed_pad_a[j] = pad_a[62-j];
        end
    end

    generate
        genvar i;
        for (i=0; i<32; i++) begin
            mux_32 mux_32 (
                .in({reversed_pad_a[i+31:i]}),
                .sl(b[4:0]),
                .out(res[31-i])
            );
        end
    endgenerate
endmodule

//
// SRA Module
//
// res = a >>> b[4:0]
module sra(
    input [31:0] a,
    input [31:0] b,
    output [31:0] res
);
    logic [62:0] pad_a;
    assign pad_a = {{31{a[31]}}, a};
    generate
        genvar i;
        for (i=0; i<32; i++) begin
            mux_32 mux_32 (
                .in({pad_a[31+i:i]}),
                .sl(b[4:0]),
                .out(res[i])
            );
        end
    endgenerate
endmodule



module mux_2(
    input in_0,
    input in_1,
    input sl,
    output out
);
	logic tmp_1, tmp_2;
	assign tmp_1 = in_0 & (~sl);
	assign tmp_2 = in_1 & sl;
	assign out = tmp_1 | tmp_2;
endmodule

module mux_4(
    input [3:0] in,
    input [1:0] sl,
    output out
);
    logic mux_1_out, mux_2_out;

	mux_2 mux_1(
        .in_0(in[0]),
        .in_1(in[1]),
        .sl(sl[0]),
        .out(mux_1_out)
    );

    mux_2 mux_2(
        .in_0(in[2]),
        .in_1(in[3]),
        .sl(sl[0]),
        .out(mux_2_out)
    );

    mux_2 mux_3(
        .in_0(mux_1_out),
        .in_1(mux_2_out),
        .sl(sl[1]),
        .out(out)
    );

endmodule


module mux_16(
    input [15:0] in,
    input [3:0] sl,
    output out
);

    logic [3:0] tmp_out;
    
	mux_4 mux [3:0] (
        .in(in),
        .sl(sl[1:0]),
        .out(tmp_out)
    );

    mux_4 mux_2(
        .in(tmp_out),
        .sl(sl[3:2]),
        .out(out)
    );

endmodule

module mux_32(
    input [31:0] in,
    input [4:0] sl,
    output out
);

    logic [1:0] tmp_out;
    
	mux_16 mux [1:0] (
        .in(in),
        .sl(sl[3:0]),
        .out(tmp_out)
    );

    mux_2 mux_2(
        .in_0(tmp_out[0]),
        .in_1(tmp_out[1]),
        .sl(sl[4]),
        .out(out)
    );

endmodule

`endif // __EX_UTILS_V__