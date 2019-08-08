`timescale 1 ps / 1 ps
module aes_128_top_tb;
 
aes_128_top_tb_tasks aes_128_top_tb_tasks();

initial begin
    $display("START");
    aes_128_top_tb_tasks.reset;
    aes_128_top_tb_tasks.wait_n_clocks(10);
    aes_128_top_tb_tasks.write_key_set;
    aes_128_top_tb_tasks.wait_n_clocks(20);
    aes_128_top_tb_tasks.set_data;
    aes_128_top_tb_tasks.set_data;

    aes_128_top_tb_tasks.wait_n_clocks(200);

    $display("END");
	$stop;
end

endmodule : aes_128_top_tb