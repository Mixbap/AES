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