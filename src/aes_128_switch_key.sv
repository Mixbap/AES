/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_switch_key.sv                                                          *
 *                                                                                                *
 **************************************************************************************************
 *  History:                                                                                      *
 *      July 2019: D. Kalinin - initial version                                                   *
 **************************************************************************************************                                                                                                *
 *  Description:                                                                                  *
 *      Two key expension switch                                                                  *
 *                                                                                                *
 **************************************************************************************************
 *  SystemVerilog Code                                                                            *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_switch_key
    (
	    input					clk,
	    input					kill,
	    input					en_wr,
	    input   		[63:0]	key_round_wr,
	    input					key_ready,
	    input					switch_key,
	
	    output  		[127:0]	key_round_rd,
	    output	logic			key_idx = 'd0
	);

/**************************************************************************************************
 *      LOCAL PARAMETERS & VARIABLES                                                              *
 **************************************************************************************************/
localparam RAM_DEPTH = 64;
localparam KEY_SET = 22;

logic   [63:0]          ram[RAM_DEPTH-1:0];
logic   [63:0]          ram_out             = 'd0;
logic   [63:0]          key_round_buf       = 'd0;
logic                   key_ready_r         = 'd0;
logic                   flag_addr           = 'd0;
logic                   wr_last             = 'd0;
logic   [5:0]           key_ready_count     = 'd0;
logic                   read_status         = 'd0;

logic	[5:0]			addr_wr				= 'd22;
logic	[5:0]			addr_rd				= 'd0;

/**************************************************************************************************
 *            RAM                                                                                 *
 **************************************************************************************************/
always @(posedge clk)
begin
	if (kill)
		ram_out <= 64'b0;
	else 
	begin
		if (en_wr)
			ram[addr_wr] <= key_round_wr;
		ram_out <= ram[addr_rd];
	end
end

 /**************************************************************************************************
 *            LOGIC                                                                                *
 **************************************************************************************************/
 /* Buffer for a half of a key */
always_ff @(posedge clk) begin
	if (kill)
		key_round_buf <= 64'b0;
	else if (flag_addr)
		key_round_buf <= ram_out;
end

/* Round key formation */
assign key_round_rd[63:0] = (~flag_addr) ? key_round_buf : key_round_rd[63:0];
assign key_round_rd[127:64] =  ram_out; 

/* Flag of switching of the buffer */
always_ff @(posedge clk) begin
	if (kill)
		flag_addr <= 1'b0;
	else if (key_ready | key_ready_r | (addr_rd == 6'b0) | (addr_rd == KEY_SET))
		flag_addr <= 1'b1;
	else 
		flag_addr <= 1'b0;
end

always_ff @(posedge clk) begin
	if (kill)
		addr_rd <= 6'b0;
	else if ((addr_rd == 6'b1) & switch_key)
		addr_rd <= KEY_SET;
	else if ((addr_rd == KEY_SET+1) & switch_key)
		addr_rd <= 6'b0;
	else if ((addr_rd == (2 * KEY_SET)-1) & key_ready & key_idx) 	//addr_rd = (22-44); key_idx = 1
		addr_rd <= KEY_SET;
	else if ((addr_rd == KEY_SET-1) & key_ready & (~key_idx)) 	//addr_rd = (0-22); key_idx = 0 
		addr_rd <= 6'b0;
	else if ((addr_rd == KEY_SET-1) & key_ready & key_idx) 		//addr_rd = (0-22); key_idx = 1 
		addr_rd <= KEY_SET;
	else if ((addr_rd == (2 * KEY_SET)-1) & key_ready & (~key_idx)) 	//addr_rd = (22-44); key_idx = 0
		addr_rd <= 6'b0;
	else if (key_ready | key_ready_r | (addr_rd == 6'b0) | (addr_rd == KEY_SET))
		addr_rd <= addr_rd + 6'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		wr_last <= 1'b0;
	else if ((addr_wr == KEY_SET-2) | (addr_wr == (2 * KEY_SET)-2))
		wr_last <= 1'b1;
	else
		wr_last <= 1'b0;
end
	
always_ff @(posedge clk) begin
	if (kill)
		addr_wr <= KEY_SET;
	else if ((addr_wr == KEY_SET) & switch_key)
		addr_wr <= 6'b0;
	else if ((addr_wr == 6'b0) & switch_key)
		addr_wr <= KEY_SET;
	else if ((addr_wr == (2 * KEY_SET)-1) & key_idx)		//addr_wr = (22-44); key_idx = 1
		addr_wr <= 6'b0;
	else if ((addr_wr == (2 * KEY_SET)-1) & (~key_idx))	//addr_wr = (22-44); key_idx = 0
		addr_wr <= KEY_SET;
	else if ((addr_wr == KEY_SET-1) & key_idx)		//addr_wr = (0-22); key_idx = 1
		addr_wr <= 6'b0;
	else if ((addr_wr == KEY_SET-1) & (~key_idx))		//addr_wr = (0-22); key_idx = 0
		addr_wr <= KEY_SET;
	else if (en_wr)
		addr_wr <= addr_wr + 6'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		key_ready_r <= 1'b0;
	else if (key_ready)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;
end

always_ff @(posedge clk) begin
	if (kill)
		key_ready_count <= 6'b0;
	else if (key_ready_count == KEY_SET/2)
		key_ready_count <= 6'b0;
	else if (key_ready)
		key_ready_count <= key_ready_count + 6'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		read_status <= 1'b0;
	else if (key_ready_count == 6'b0)
		read_status <= 1'b0;
	else
		read_status <= 1'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		key_idx <= 1'b0;
	else if (switch_key)
		key_idx <= ~key_idx;
end

endmodule : aes_128_switch_key