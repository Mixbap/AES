/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_subbytes_shiftrows.sv                                                  *
 *                                                                                                *
 **************************************************************************************************
 *  History:                                                                                      *
 *      July 2019: D. Kalinin - initial version                                                   *
 **************************************************************************************************                                                                                                *
 *  Description:                                                                                  *
 *      Subbytes and ShiftRows                                                                    *
 *                                                                                                *
 **************************************************************************************************
 *  SystemVerilog Code                                                                            *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_subbytes_shiftrows 
    (
	    input			    clk,
	    input			    kill,
	    input   [127:0]	    in_data,

	    output	[127:0]	    out_data
	);

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
aes_128_sbox

    aes_128_sbox_0 
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[7:0]),
		.addrb(in_data[47:40]),
		.dia(),
		.dib(),
		.doa(out_data[7:0]),
		.dob(out_data[15:8])
    );

aes_128_sbox 

    aes_128_sbox_1 
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[87:80]),
		.addrb(in_data[127:120]),
		.dia(),
		.dib(),
		.doa(out_data[23:16]),
		.dob(out_data[31:24])
    );

aes_128_sbox 

    aes_128_sbox_2 
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[39:32]),
		.addrb(in_data[79:72]),
		.dia(),
		.dib(),
		.doa(out_data[39:32]),
		.dob(out_data[47:40])
    );

aes_128_sbox 

    aes_128_sbox_3 
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[119:112]),
		.addrb(in_data[31:24]),
		.dia(),
		.dib(),
		.doa(out_data[55:48]),
		.dob(out_data[63:56])
    );

aes_128_sbox 

    aes_128_sbox_4 
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[71:64]),
		.addrb(in_data[111:104]),
		.dia(),
		.dib(),
		.doa(out_data[71:64]),
		.dob(out_data[79:72])
    );

aes_128_sbox 

    aes_128_sbox_5 
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[23:16]),
		.addrb(in_data[63:56]),
		.dia(),
		.dib(),
		.doa(out_data[87:80]),
		.dob(out_data[95:88])
    );

aes_128_sbox 

    aes_128_sbox_6
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[103:96]),
		.addrb(in_data[15:8]),
		.dia(),
		.dib(),
		.doa(out_data[103:96]),
		.dob(out_data[111:104])
    );

aes_128_sbox

    aes_128_sbox_7
    (	
        .clka(clk),
		.clkb(clk),
		.kill,
		.wea(1'b0),
		.web(1'b0),
		.addra(in_data[55:48]),
		.addrb(in_data[95:88]),
		.dia(),
		.dib(),
		.doa(out_data[119:112]),
		.dob(out_data[127:120])
    );

endmodule : aes_128_subbytes_shiftrows