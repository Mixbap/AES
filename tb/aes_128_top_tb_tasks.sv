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

endmodule : aes_128_top_tb_tasks