`timescale 1 ps / 1 ps
module aes_128_top_tb_tasks;

`include "../cfg/aes_128_def.svh"

parameter LENGTH_DATA   = 120;
parameter LENGTH_KEY    = LENGTH_DATA * 11 * 2;

/* input signal */
logic                   clk;
logic                   kill;
logic                   in_en;
logic   [127:0]         in_data;
logic                   en_wr;

`ifdef ONE_KEY
logic   [127:0]         key_round_wr;
`else
logic   [63:0]          key_round_wr;
`endif

logic   [127:0]         single_key_set [10:0];
logic   [63:0]          double_key_set [43:0];

logic                   switch_key;
logic                   key_idx;

/* output signal */
logic                   out_en;
logic   [127:0]         out_data;
logic                   idle;
logic                   in_en_collision_irq_pulse;

 /*************************************************************************************
 *            BLOCK INSTANCE                                                          *
 *************************************************************************************/
aes_128_top

    aes_128_top
    (		
        .clk,
		.kill,
		.in_data(in_data),
		.in_en(in_en),
		.en_wr(en_wr),
		.key_round_wr(key_round_wr),

    `ifdef TWO_KEY
        .switch_key,
        .key_idx,
    `endif

		.out_data,
		.out_en,
        .idle,
		.in_en_collision_irq_pulse
    );

/*************************************************************************************
 *            INITIALIZE                                                             *
 *************************************************************************************/
initial begin
    clk             = 'd0;
    kill            = 'd0;
    in_data         = 'd0;
    in_en           = 'd0;
    en_wr           = 'd0;
    key_round_wr    = 'd0;
    switch_key      = 'd0;

    /* Single key set */
    single_key_set[0] <= 128'h0f0e0d0c0b0a09080706050403020100;
	single_key_set[1] <= 128'hfe76abd6f178a6dafa72afd2fd74aad6;
	single_key_set[2] <= 128'hfeb3306800c59bbef1bd3d640bcf92b6;
	single_key_set[3] <= 128'h41bf6904bf0c596cbfc9c2d24e74ffb6;
	single_key_set[4] <= 128'hfd8d05fdbc326cf9033e3595bcf7f747;
	single_key_set[5] <= 128'haa22f6ad57aff350eb9d9fa9e8a3aa3c;
	single_key_set[6] <= 128'h6b1fa30ac13d55a79692a6f77d0f395e;
	single_key_set[7] <= 128'h26c0a94e4ddf0a448ce25fe31a70f914;
	single_key_set[8] <= 128'hd27abfaef4ba16e0b9651ca435874347;
	single_key_set[9] <= 128'h4e972cbe9ced9310685785f0d1329954;
	single_key_set[10] <= 128'hc5302b4d8ba707f3174a94e37f1d1113;

    /* Double key set */
	double_key_set[0] <= 64'h0706050403020100;		double_key_set[1] <= 64'h0f0e0d0c0b0a0908;		double_key_set[2] <= 64'hfa72afd2fd74aad6;		double_key_set[3] <= 64'hfe76abd6f178a6da;
	double_key_set[4] <= 64'hf1bd3d640bcf92b6;		double_key_set[5] <= 64'hfeb3306800c59bbe;		double_key_set[6] <= 64'hbfc9c2d24e74ffb6;		double_key_set[7] <= 64'h41bf6904bf0c596c;
	double_key_set[8] <= 64'h033e3595bcf7f747;		double_key_set[9] <= 64'hfd8d05fdbc326cf9;		double_key_set[10] <= 64'heb9d9fa9e8a3aa3c;	    double_key_set[11] <= 64'haa22f6ad57aff350;
	double_key_set[12] <= 64'h9692a6f77d0f395e;	    double_key_set[13] <= 64'h6b1fa30ac13d55a7;	    double_key_set[14] <= 64'h8ce25fe31a70f914;	    double_key_set[15] <= 64'h26c0a94e4ddf0a44;
	double_key_set[16] <= 64'hb9651ca435874347;	    double_key_set[17] <= 64'hd27abfaef4ba16e0;	    double_key_set[18] <= 64'h685785f0d1329954;	    double_key_set[19] <= 64'h4e972cbe9ced9310;
	double_key_set[20] <= 64'h174a94e37f1d1113;	    double_key_set[21] <= 64'hc5302b4d8ba707f3;		

	double_key_set[22] <= 64'h0706050403020100;	    double_key_set[23] <= 64'h0f0e0d0c0b0a0908;	    double_key_set[24] <= 64'hfa72afd2fd74aad6;	    double_key_set[25] <= 64'hfe76abd6f178a6da;
	double_key_set[26] <= 64'hf1bd3d640bcf92b6;	    double_key_set[27] <= 64'hfeb3306800c59bbe;	    double_key_set[28] <= 64'hbfc9c2d24e74ffb6;	    double_key_set[29] <= 64'h41bf6904bf0c596c;
	double_key_set[30] <= 64'h033e3595bcf7f747;	    double_key_set[31] <= 64'hfd8d05fdbc326cf9;	    double_key_set[32] <= 64'heb9d9fa9e8a3aa3c;	    double_key_set[33] <= 64'haa22f6ad57aff350;
	double_key_set[34] <= 64'h9692a6f77d0f395e;	    double_key_set[35] <= 64'h6b1fa30ac13d55a7;	    double_key_set[36] <= 64'h8ce25fe31a70f914;	    double_key_set[37] <= 64'h26c0a94e4ddf0a44;
	double_key_set[38] <= 64'hb9651ca435874347;	    double_key_set[39] <= 64'hd27abfaef4ba16e0;	    double_key_set[40] <= 64'h685785f0d1329954;	    double_key_set[41] <= 64'h4e972cbe9ced9310;
	double_key_set[42] <= 64'h174a94e37f1d1113;	    double_key_set[43] <= 64'hc5302b4d8ba707f3;


    $display("input signals were initialized\n"); 
end

initial forever begin
    #4000 clk = ~clk; // 125 MHz
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
task reset;
    repeat (30) @(posedge clk)
        kill <= 1'b1;

    kill <= 1'b0;
endtask

task wait_n_clocks;
input integer N;
integer n; 
    @(posedge clk);
    for (n = 0; n < N; n++)
        begin
           @(posedge clk);
        end   
endtask

task set_data;
begin
	@(posedge clk);
	in_en <= 1'b1;
	in_data <= 128'hffeeddccbbaa99887766554433221100;
	@(posedge clk);
	in_en <= 1'b0;
	in_data <= 128'b0;

    $display("input data set\n"); 
end
endtask

task write_single_key_set;
integer i;
begin
    for (i = 0; i < 11; i = i + 1)
    begin
        @(posedge clk);
        en_wr <= 1'b1;
        key_round_wr <= single_key_set[i];
    end
    @(posedge clk);
    en_wr <= 1'b0;
    key_round_wr <= 128'b0;

    $display("write new key set\n");
end
endtask

task write_double_key_set;
input num_buf;
integer i;
begin
    for (i = 0; i < 22; i = i + 1)
    begin
        @(posedge clk);
        en_wr <= 1'b1;
        key_round_wr <= double_key_set[i + num_buf*22];
    end
    @(posedge clk);
    en_wr <= 1'b0;
    key_round_wr <= 64'b0;

    @(posedge clk);
    switch_key <= 1'b1;
    @(posedge clk);
    switch_key <= 1'b0;

    $display("write new key set, buffer = %d\n", num_buf);
end
endtask

endmodule : aes_128_top_tb_tasks