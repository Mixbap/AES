`timescale 1 ps / 1 ps
module aes_128_top_tb;

`include "../cfg/aes_128_def.svh"
 
aes_128_top_tb_tasks aes_128_top_tb_tasks();

initial begin
    $display("START");
    aes_128_top_tb_tasks.reset;
    aes_128_top_tb_tasks.load_data_in_files;
    aes_128_top_tb_tasks.wait_n_clocks(10);

    aes_128_top_tb_tasks.test_1(20);

    aes_128_top_tb_tasks.wait_n_clocks(400);

    $display("END");
	$stop;
end

endmodule : aes_128_top_tb