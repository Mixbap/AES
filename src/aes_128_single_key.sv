/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_single_key.sv                                                          *
 *                                                                                                *
 **************************************************************************************************
 *  History:                                                                                      *
 *      July 2019: D. Kalinin - initial version                                                   *
 **************************************************************************************************                                                                                                *
 *  Description:                                                                                  *
 *      Single key expension                                                                      *
 *                                                                                                *
 **************************************************************************************************
 *  SystemVerilog Code                                                                            *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_single_key
	(
		input					clk,
		input					kill,
		input					key_ready,
		input					en_wr,
		input			[127:0]	key_round_wr,

		output	logic	[127:0]	key_round_rd
	);

/**************************************************************************************************
 *      LOCAL PARAMETERS & VARIABLES                                                              *
 **************************************************************************************************/
localparam RAM_DEPTH = 16;
localparam KEY_SET = 11;

logic	[127:0]					ram [RAM_DEPTH-1:0];
logic	[3:0]					addr_0 = 4'b0;
logic	[3:0]					addr_1 = 4'b1;
logic	[3:0]					addr_wr = 4'b0;
logic	[3:0]					addr;
logic	[3:0]					addr_rd;

/**************************************************************************************************
 *            INITIAL                                                                             *
 **************************************************************************************************/
initial
begin
	ram[0] <= 128'h0f0e0d0c0b0a09080706050403020100;
	ram[1] <= 128'hfe76abd6f178a6dafa72afd2fd74aad6;
	ram[2] <= 128'hfeb3306800c59bbef1bd3d640bcf92b6;
	ram[3] <= 128'h41bf6904bf0c596cbfc9c2d24e74ffb6;
	ram[4] <= 128'hfd8d05fdbc326cf9033e3595bcf7f747;
	ram[5] <= 128'haa22f6ad57aff350eb9d9fa9e8a3aa3c;
	ram[6] <= 128'h6b1fa30ac13d55a79692a6f77d0f395e;
	ram[7] <= 128'h26c0a94e4ddf0a448ce25fe31a70f914;
	ram[8] <= 128'hd27abfaef4ba16e0b9651ca435874347;
	ram[9] <= 128'h4e972cbe9ced9310685785f0d1329954;
	ram[10] <= 128'hc5302b4d8ba707f3174a94e37f1d1113;	
end

/**************************************************************************************************
 *      RAM                                                                                       *
 **************************************************************************************************/
always @(posedge clk) begin
	if (kill)
		key_round_rd <= 128'b0;
	else 
		begin
			if (en_wr)
				ram[addr] <= key_round_wr;
			key_round_rd <= ram[addr];
		end
end

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
assign addr = (en_wr) ? addr_wr : addr_rd;
assign addr_rd = (key_ready) ? addr_1 : addr_0;

always_ff @(posedge clk) begin
	if (kill)
		addr_0 <= 4'b0;
	else if ((addr_rd == KEY_SET) & key_ready)
		addr_0 <= 4'b0;
	else if (key_ready)
		addr_0 <= addr_0 + 4'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		addr_1 <= 4'b1;
	else if ((addr_rd == KEY_SET) & key_ready)
		addr_1 <= 4'b1;
	else if (key_ready)
		addr_1 <= addr_1 + 4'b1;
end
	
always_ff @(posedge clk) begin
	if (kill)
		addr_wr <= 4'b0;
	else if (key_ready)
		addr_wr <= 4'b0;
	else if (en_wr)
		addr_wr <= addr_wr + 4'b1;
end

endmodule : aes_128_single_key