/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_control_3clk.sv                                                        *
 *                                                                                                *
 **************************************************************************************************
 *  History:                                                                                      *
 *      July 2019: D. Kalinin - initial version                                                   *
 **************************************************************************************************                                                                                                *
 *  Description:                                                                                  *
 *      Control aes core (3 clock per round)                                                      *
 *                                                                                                *
 **************************************************************************************************
 *  SystemVerilog Code                                                                            *
 **************************************************************************************************/

 (* keep_hierarchy = "yes" *)

module aes_128_control_3clk
    (
	    input			    clk,
	    input			    kill,
	    input			    in_en,

	    output			    start,
	    output	logic		en_mixcol 					= 'd0,
	    output			    key_ready,
	    output	logic		idle 						= 'd0,
	    output	logic		out_en 						= 'd0,
	    output	logic		in_en_collision_irq_pulse 	= 'd0
	);

/**************************************************************************************************
 *      LOCAL PARAMETERS & VARIABLES                                                              *
 **************************************************************************************************/
logic                       start_r 			= 'd0;
logic						start_r1			= 'd0;
logic                       start_tr 			= 'd0;
logic                       key_ready_r 		= 'd0;
logic   [1:0]               delay_start_r 		= 'd0;
logic   [2:0]               flag_in_en 			= 'd0;
logic   [4:0]               round_count 		= 'd0;
logic                       in_en_collision_irq = 'd0;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
assign start = (idle) ? 1'b0 : (in_en | start_r);

always_ff @(posedge clk) begin
	if (kill)
		round_count <= 5'b0;
	else if (start)
		round_count <= 5'b0;
	else if (round_count == 5'd29)
		round_count <= 5'b0;
	else if (start_r)
		round_count <= round_count + 5'b1;
end

/* Signal the disconnecting Mixcolums */
always_ff @(posedge clk) begin
	if (kill)
		en_mixcol <= 1'b0;
	else if (start)
		en_mixcol <= 1'b0;
	else if (round_count == 5'd25)
		en_mixcol <= 1'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		key_ready_r <= 1'b0;
	else if ((round_count == 5'd1 | 		round_count == 5'd4 | 		round_count == 5'd7 | 		round_count == 5'd10 |
	    	  round_count == 5'd13 | 		round_count == 5'd16 | 		round_count == 5'd19 | 		round_count == 5'd22 |
	    	  round_count == 5'd25 | 		round_count == 5'd28) & start_r)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;
end

assign key_ready = start_tr | key_ready_r;

always_ff @(posedge clk) begin
	if (kill)
		delay_start_r <= 2'b0;
	else if (start_tr)
		delay_start_r <= 2'b0;
	else if (start)
		delay_start_r <= delay_start_r + 2'b1;
end

always_ff @(posedge clk) begin
	if (kill)
		start_tr <= 1'b0;
	else if (delay_start_r == 2'b1)
		start_tr <= 1'b1;
	else 
		start_tr <= 1'b0;
end

always_ff @(posedge clk) begin
	if (kill)
		flag_in_en <= 3'b0;
	else if ((~start_r) & (~start_tr) & in_en & start)
		flag_in_en <= 3'b1;
	else if (start_r & (~start_tr) & in_en & start)
		flag_in_en <= flag_in_en + 3'b10;
	else if (start_r & start_tr & in_en & start)
		flag_in_en <= flag_in_en + 3'b100;
end

always_ff @(posedge clk) begin
	if (kill)
		out_en <= 1'b0;
	else if ((round_count == 5'd27) | ((round_count == 5'd28) & ((flag_in_en >> 1) & 1)) | ((round_count == 5'd29) & ((flag_in_en >> 2) & 1)))
		out_en <= 1'b1;
	else
		out_en <= 1'b0;
end

always_ff @(posedge clk) begin
	if (kill)
		start_r <= 1'b0;
	else if (start)
		start_r <= 1'b1;
	else if (out_en)
		start_r <= 1'b0;
end

always_ff @(posedge clk) begin
	if (kill)
		start_r1 <= 1'b0;
	else
		start_r1 <= start_r;
end

always_ff @(posedge clk) begin
	if (kill)
		idle <= 1'b0;
	else if (start_tr)
		idle <= 1'b1;
	else if (~start_r1)
		idle <= 1'b0;
end

/* flag double in_en */
always_ff @(posedge clk) begin
	if (kill)
		in_en_collision_irq <= 1'b0;
	else if (in_en & idle)
		in_en_collision_irq <= 1'b1;
	else if (in_en)
		in_en_collision_irq <= 1'b0;
end

/* debug signal */
always_ff @(posedge clk) begin
	if (kill)
		in_en_collision_irq_pulse <= 1'b0;
	else if (in_en_collision_irq)
		in_en_collision_irq_pulse <= ~in_en_collision_irq_pulse;
	else 
		in_en_collision_irq_pulse <= 1'b0;
end

endmodule : aes_128_control_3clk