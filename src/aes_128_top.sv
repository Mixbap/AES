/**************************************************************************************************
 *                                                                                                *
 *  File Name:     aes_128_top.sv                                                                 *
 *                                                                                                *
 **************************************************************************************************
 *  History:                                                                                      *
 *      July 2019: D. Kalinin - initial version                                                   *
 **************************************************************************************************                                                                                                *
 *  Description:                                                                                  *
 *      Top module                                                                                *
 *                                                                                                *
 **************************************************************************************************
 *  SystemVerilog Code                                                                            *
 **************************************************************************************************/

(* keep_hierarchy = "yes" *)

`include "../cfg/aes_128_def.svh"

module aes_128_top
    (
	    input			    clk,
	    input			    kill,
	    input   [127:0]	    in_data,
	    input			    in_en,
	    input			    en_wr,
	    input	[127:0]	    key_round_wr,
	
	    output	[127:0]	    out_data,
	    output			    out_en,
        output              idle,
	    output			    in_en_collision_irq_pulse
	);

/**************************************************************************************************
 *      LOCAL PARAMETERS & VARIABLES                                                              *
 **************************************************************************************************/
`ifdef ROUND_4CLK
logic   [127:0]             round_data_buf  = 'd0;
`endif

logic   [127:0]             round_data      = 'd0;
logic   [127:0]             subbytes_out;
logic   [127:0]             mixcol_out;
logic                       en_mixcol;
logic                       start;
logic   [127:0]             key_round;
logic                       key_ready;

/**************************************************************************************************
 *      AES CORE                                                                                  *
 **************************************************************************************************/
/* Subbytes and ShiftRows */
aes_128_subbytes_shiftrows

    subbytes_shiftrows
    (
        .clk,
        .kill,

    `ifdef ROUND_4CLK
        .in_data (round_data_buf),
    `endif

    `ifdef ROUND_3CLK
        .in_data (round_data),
    `endif

        .out_data (subbytes_out)
    );

/* MixColums */
aes_128_mixcol

    mixcol
    (
        .clk,
        .kill,
        .en (en_mixcol),
        .in_data (subbytes_out),
        .out_data (mixcol_out)
    );

/* AddRoundKey */
always_ff @(posedge clk) begin
	if (kill)
		round_data <= 128'b0;
	else if (start)
		round_data <= in_data ^ key_round;
	else
		round_data <= mixcol_out ^ key_round;
end

`ifdef ROUND_3CLK
assign out_data = round_data;
`endif

`ifdef ROUND_4CLK
/* Delay buffer round data */
always_ff @(posedge clk) begin
	if (kill)
		round_data_buf <= 128'b0;
	else 
		round_data_buf <= round_data;
end

assign out_data = round_data_buf;
`endif

/**************************************************************************************************
 *      AES CONTROL                                                                                *
 **************************************************************************************************/
`ifdef ROUND_3CLK
aes_128_control_3clk

    aes_128_control_3val
    (	
        .clk,
		.kill,
		.in_en,
		.start (start),
		.en_mixcol (en_mixcol),
		.key_ready,
		.idle,
		.out_en,
		.in_en_collision_irq_pulse
    );
`endif

`ifdef ROUND_4CLK
`endif

/**************************************************************************************************
 *      KEY EXPENSION                                                                             *
 **************************************************************************************************/
`ifdef ONE_KEY
aes_128_single_key

    single_key
    (
        .clk,
        .kill,
        .en_wr,
        .key_round_wr,
        .key_ready,
        .key_round_rd (key_round)
    );
`endif

`ifdef TWO_KEY_SWITCH
`endif

`ifdef TWO_KEY_AUTO
`endif


endmodule : aes_128_top
