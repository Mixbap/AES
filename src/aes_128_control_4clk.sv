/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_control_4clk.sv                                                        *
 *                                                                                                *
 **************************************************************************************************
 *  History:                                                                                      *
 *      July 2019: D. Kalinin - initial version                                                   *
 **************************************************************************************************                                                                                                *
 *  Description:                                                                                  *
 *      Control aes core (4 clock per round)                                                      *
 *                                                                                                *
 **************************************************************************************************
 *  SystemVerilog Code                                                                            *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

module aes_128_control_4clk (
	/* inputs */
	input			    clk,
	input			    kill,
	input			    in_en,

	/* outputs */
	output			    start,
	output	logic		en_mixcol                   = 'b0,
	output			    key_ready,
	output	logic		idle                        = 'b0,
	output	logic		out_en                      = 'b0,
	output	logic		in_en_collision_irq_pulse   = 'b0
	);

/**************************************************************************************************
 *      LOCAL PARAMETERS & VARIABLES                                                              *
 **************************************************************************************************/
logic		    start_r             = 'b0;
logic		    start_tr            = 'b0;
logic		    key_ready_start     = 'b0;
logic		    key_ready_r         = 'b0;
logic	[1:0]	delay_start_r       = 'b0;
logic	[2:0]	flag_in_en          = 'b0;
logic	[5:0]	round_count;
logic		    in_en_collision_irq = 'b0;

/**************************************************************************************************
 *      LOGIC                                                                                     *
 **************************************************************************************************/
assign start = (idle) ? 1'b0 : (in_en | start_r);

always @(posedge clk)
	if (kill)
		round_count <= 6'b0;
	else if (start)
		round_count <= 6'b0;
	else if (round_count == 6'd40)
		round_count <= 6'b0;
	else if (start_r)
		round_count <= round_count + 6'b1;

/* en_mixcol - signal the disconnecting Mixcolums */
always @(posedge clk)
	if (kill)
		en_mixcol <= 1'b0;
	else if (start)
		en_mixcol <= 1'b0;
	else if (round_count == 6'd35)
		en_mixcol <= 1'b1;

always @(posedge clk)
	if (kill)
		key_ready_r <= 1'b0;
	else if ((round_count == 6'd1 | 		round_count == 6'd5 | 		round_count == 6'd9 | 		round_count == 6'd13 |
	    	  round_count == 6'd17 | 		round_count == 6'd21 | 		round_count == 6'd25 | 		round_count == 6'd29 |
	    	  round_count == 6'd33 | 		round_count == 6'd37) & start_r)
		key_ready_r <= 1'b1;
	else
		key_ready_r <= 1'b0;

assign key_ready = key_ready_start | key_ready_r;

always @(posedge clk)
	if (kill)
		delay_start_r <= 2'b0;
	else if (start_tr)
		delay_start_r <= 2'b0;
	else if (start)
		delay_start_r <= delay_start_r + 2'b1;

always @(posedge clk)
	if (kill)
		start_tr <= 1'b0;
	else if (delay_start_r == 2'b1)
		start_tr <= 1'b1;
	else 
		start_tr <= 1'b0;

always @(posedge clk)
	if (kill)
		key_ready_start <= 1'b0;
	else if (start & key_ready_start)
		key_ready_start <= 1'b0;
	else if (start & ~(start_r))
		key_ready_start <= 1'b1;
	else
		key_ready_start <= 1'b0;

always @(posedge clk)
	if (kill)
		flag_in_en <= 3'b0;
	else if ((~start_r) & (~start_tr) & in_en & start)
		flag_in_en <= 3'b1;
	else if (start_r & (~start_tr) & in_en & start)
		flag_in_en <= flag_in_en + 3'b10;
	else if (start_r & start_tr & in_en & start)
		flag_in_en <= flag_in_en + 3'b100;

always @(posedge clk)
	if (kill)
		out_en <= 1'b0;
	else if ((round_count == 6'd38) | ((round_count == 6'd39) & ((flag_in_en >> 1) & 1)) | ((round_count == 6'd40) & ((flag_in_en >> 2) & 1)))
		out_en <= 1'b1;
	else
		out_en <= 1'b0;

always @(posedge clk)
	if (kill)
		start_r <= 1'b0;
	else if (start)
		start_r <= 1'b1;
	else if (out_en)
		start_r <= 1'b0;

/* idle - high level  - status AES_CALC, low level  - status AES_IDLE */
always @(posedge clk)
	if (kill)
		idle <= 1'b0;
	else if (start_tr)
		idle <= 1'b1;
	else if (~(start_r | out_en))
		idle <= 1'b0;
	
/* in_en_collision_irq - flag double in_en */
always @(posedge clk)
	if (kill)
		in_en_collision_irq <= 1'b0;
	else if (in_en & idle)
		in_en_collision_irq <= 1'b1;
	else if (in_en)
		in_en_collision_irq <= 1'b0;

/* in_en_collision_irq_pulse - debug signal */
always @(posedge clk)
	if (kill)
		in_en_collision_irq_pulse <= 1'b0;
	else if (in_en_collision_irq)
		in_en_collision_irq_pulse <= ~in_en_collision_irq_pulse;
	else 
		in_en_collision_irq_pulse <= 1'b0;

endmodule : aes_128_control_4clk