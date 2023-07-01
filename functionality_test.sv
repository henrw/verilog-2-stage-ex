`define HALF_CYCLE 250
`timescale 1ns/1ps

module testbench;
    logic clock;
    logic [31:0] a, b, c, d, add_res, sub_res, srl_res, sll_res, sra_res, mux_2_out, mux_4_out;
    logic unsigned [31:0] a_unsigned, b_unsigned;
    logic slt_res, sltu_res, mux_out;
    logic [4:0] sl;
    logic [31:0] a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17;
    logic [63:0] mult_res, mixed_mul_res, unsigned_mul_res;

    wire signed [31:0] signed_opa, signed_opb;
	wire signed [63:0] signed_mul, mixed_mul;
	wire        [63:0] unsigned_mul;
	assign signed_opa = a;
	assign signed_opb = b;
	assign signed_mul = signed_opa * signed_opb;
	assign unsigned_mul = a * b;
	assign mixed_mul = signed_opa * b;

    wire correct = (add_res == a + b) &
                   (sub_res == a - b) &
                   (slt_res == a < b) &
                   (sltu_res == a_unsigned < b_unsigned) &
                   (srl_res == a >> b[5:0]) &
                   (sll_res == a << b[5:0]) &
                   (sra_res == a >>> b[5:0]) &
                   (mult_res == signed_mul[63:0]) &
                   (mixed_mul_res == mixed_mul[63:0]) &
                   (unsigned_mul_res == unsigned_mul[63:0]); // &
                //    (mult_res == );

    // always @(negedge clock)
	// 	if(!correct) begin 
	// 		$display("Incorrect at time %4.0f",$time);
	// 		$finish;
	// 	end

	always begin
		#`HALF_CYCLE;
		clock=~clock;
        sl = (sl + 1)%16;
	end

    adder add(
        .a(a), .b(b),
        .c_in(1'b0),
        .res(add_res)
    );
    
    substractor sub(
        .a(a), .b(b),
        .res(sub_res)
    );


    slt slt(
        .a(a), .b(b),
        .res(slt_res)
    );

    slt sltu(
        .a(a_unsigned), .b(b_unsigned),
        .res(sltu_res)
    );

    srl srl(
        .a(a),
        .b(b),
        .res(srl_res)
    );

    sll sll(
        .a(a),
        .b(b),
        .res(sll_res)
    );

    sra sra(
        .a(a),
        .b(b),
        .res(sra_res)
    );

    mul mulh(
        .a(signed_opa),
        .is_signed_a(1'b1),
        .b(signed_opb),
        .is_signed_b(1'b1),
        .res(mult_res)
    );

    mul mulhsu(
        .a(signed_opa),
        .is_signed_a(1'b1),
        .b(b),
        .is_signed_b(1'b0),
        .res(mixed_mul_res)
    );
    
    mul mulhu(
        .a(a),
        .is_signed_a(1'b0),
        .b(b),
        .is_signed_b(1'b0),
        .res(unsigned_mul_res)
    );

    mux_2 mux_2 [31:0] (
        .in_0(a),
        .in_1(b),
        .sl(clock),
        .out(mux_2_out)
    );

    mux_4 mux_4 (
        .in({a[0],b[0],c[0],d[0]}),
        .sl(sl),
        .out(mux_out)
    );

    generate
        genvar i;
        for (i=0; i<32; i++) begin
            mux_32 mux_32 (
                .in({a1[i],a2[i],a3[i],a4[i],a5[i],a6[i],a7[i],a8[i],a9[i],a10[i],a11[i],a12[i],a13[i],a14[i],a15[i],a16[i],a17[i],a1[i],a2[i],a3[i],a4[i],a5[i],a6[i],a7[i],a8[i],a9[i],a10[i],a11[i],a12[i],a13[i],a14[i],a15[i]}),
                .sl(sl),
                .out(mux_4_out[i])
            );
        end
    endgenerate

    initial begin
        clock=0;
        #10;
		a = 8;
		b = -2;
        c = 3;
        d = 4;
        a1 = 1;
        a2 = 2;
        a3 = 3;
        a4 = 4;
        a5 = 5;
        a6 = 6;
        a7 = 7;
        a8 = 8;
        a9 = 9;
        a10 = 10;
        a11 = 11;
        a12 = 12;
        a13 = 13;
        a14 = 14;
        a15 = 15;
        a16 = 16;
        a17 = 17;
        b_unsigned = -1;
        a_unsigned = 0;
        sl = 0;
	end

endmodule