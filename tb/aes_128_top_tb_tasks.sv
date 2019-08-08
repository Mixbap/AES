`timescale 1 ps / 1 ps
module aes_128_top_tb_tasks;

`include "../cfg/aes_128_def.svh"

parameter LENGTH_DATA   = 120;
parameter LENGTH_KEY    = LENGTH_DATA * 11 * 2;

logic                   clk;
logic                   kill;
logic                   in_en;
logic   [127:0]         in_data;
logic                   en_wr;
logic   [127:0]         key_round_wr;
logic   [127:0]         single_key_set [10:0];

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
		.out_data(out_data),
		.out_en(out_en),
        .idle(),
		.in_en_collision_irq_pulse()
    );

/*************************************************************************************
 *            INITIALIZE                                                             *
 *************************************************************************************/
initial begin
    clk = 'd0;
    kill = 'd0;
    in_data = 'd0;
    in_en = 'd0;
    en_wr = 'd0;
    key_round_wr = 'd0;

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

task write_key_set;
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

endmodule : aes_128_top_tb_tasks