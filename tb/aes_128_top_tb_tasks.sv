`timescale 1 ps / 1 ps
module aes_128_top_tb_tasks;

`include "../cfg/aes_128_def.svh"

parameter LENGTH_DATA   = 120;
parameter LENGTH_KEY    = LENGTH_DATA * 11 * 2;
parameter LENGTH_ENABLE = 100;

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

logic   [15:0]          in_en_len;
logic   [15:0]          in_data_len;
logic   [15:0]          keyset_len;
logic   [15:0]          out_data_len;

/* Matlab data vector */
logic   [1:0]           in_en_m [LENGTH_ENABLE-1:0];
logic   [127:0]         in_data_m [LENGTH_DATA-1:0];
logic   [63:0]          keyset_m [LENGTH_KEY-1:0];
logic   [127:0]         out_data_m [LENGTH_DATA-1:0];

/* Matlab files descriptors */
integer                 in_en_fd;
integer                 in_data_fd;
integer                 keyset_fd;
integer                 out_data_fd;

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


    $display("Input signals were initialized\n"); 
end

initial forever begin
    #4000 clk = ~clk; // 125 MHz
end

/*************************************************************************************
 *            LOGIC                                                                  *
 *************************************************************************************/
logic   [31:0]      in_en_count = 'd0;

always_ff @(posedge clk) begin
    if (kill)
        in_en_count <= 32'd0;
    else if (in_en)
        in_en_count <= in_en_count + 32'b1;
end

/*************************************************************************************
 *            TASKS                                                                  *
 *************************************************************************************/
task reset;
    repeat (30) @(posedge clk)
        kill <= 1'b1;

    kill <= 1'b0;
endtask : reset

task wait_n_clocks;
input integer N;
integer n; 
    @(posedge clk);
    for (n = 0; n < N; n++)
        begin
           @(posedge clk);
        end   
endtask : wait_n_clocks

task set_data;
begin
	@(posedge clk);
	in_en <= 1'b1;
	in_data <= 128'hffeeddccbbaa99887766554433221100;
	@(posedge clk);
	in_en <= 1'b0;
	in_data <= 128'b0;

    $display("Input data set\n"); 
end
endtask : set_data

task load_data_in_files;
integer i;
begin
    /* Input enable */
    in_en_fd = $fopen("../data/aes_128_enc_input_enable.dat", "r");
        $fscanf(in_en_fd, "%d", in_en_len);

    for (i = 0; i < in_en_len; i++)
        $fscanf(in_en_fd, "%d", in_en_m[i]);

    $fclose(in_en_fd);
    $display("Vector input enable were written to memory\n");

    /* Input data */
    in_data_fd = $fopen("../data/aes_128_enc_input_data_hex.dat", "r");
        $fscanf(in_data_fd, "%h", in_data_len);

    for (i = 0; i < in_data_len; i++)
        $fscanf(in_data_fd, "%h", in_data_m[i]);

    $fclose(in_data_fd);
    $display("Vector input data were written to memory\n");

    /* Keyset */
    keyset_fd = $fopen("../data/aes_128_enc_key_hex.dat", "r");
        $fscanf(keyset_fd, "%h", keyset_len);

    for (i = 0; i < keyset_len; i++)
        $fscanf(keyset_fd, "%h", keyset_m[i]);

    $fclose(keyset_fd);
    $display("Vector keyset were written to memory\n");

    /* Output data */
    out_data_fd = $fopen("../data/aes_128_enc_output_data_hex.dat", "r");
        $fscanf(out_data_fd, "%h", out_data_len);

    for (i = 0; i < out_data_len; i++)
        $fscanf(out_data_fd, "%h", out_data_m[i]);

    $fclose(out_data_fd);
    $display("Vector output data were written to memory\n");    
end
endtask : load_data_in_files

task set_input_data;
input integer frame_count;
input integer data_count;
begin
    unique case (in_en_m[frame_count])
        2'd1:   begin
                    in_en <= 1'b1;
                    in_data <= in_data_m[data_count];
                    @(posedge clk);
                    in_en <= 1'b0;
                    in_data <= 128'b0;
                end

        2'd2:   begin
                    in_en <= 1'b1;
                    in_data <= in_data_m[data_count];
                    @(posedge clk);
                    in_en <= 1'b0;
                    in_data <= 128'b0;
                    @(posedge clk);
                    in_en <= 1'b1;
                    in_data <= in_data_m[data_count + 1];
                    @(posedge clk);
                    in_en <= 1'b0;
                    in_data <= 128'b0;
                end

        2'd3:   begin
                    in_en <= 1'b1;
                    in_data <= in_data_m[data_count];
                    @(posedge clk);
                    in_data <= in_data_m[data_count + 1];
                    @(posedge clk);
                    in_data <= in_data_m[data_count + 2];
                    @(posedge clk);
                    in_en <= 1'b0;
                    in_data <= 128'b0;
                end
            endcase
end
endtask : set_input_data

task check_out_data;
input integer idx;
output integer out_val;
integer i;
integer j;
begin
    j = 0;
    out_val = 0;
    while (out_en == 0)
        @(posedge clk);

    for (i = 0; i < 3; i++)
        begin
            if (out_en && (out_data == out_data_m[idx + j]))
                begin
                    out_val++;
                    j++;
                    @(posedge clk);
                end
            else
                @(posedge clk);
        end
end
endtask : check_out_data

task test_1;
input integer frame_count;
integer i;
integer k;
integer result;
begin
    k = 0;
    result = 0;
    for (i = 0; i < frame_count; i++)
        begin
            set_keyset(in_en_count);
            wait_n_clocks(30);
            fork
                set_input_data(i, in_en_count);
                check_out_data(in_en_count, k);
            join
            result = result + k;
            wait_n_clocks(50);
        end

    if (result == in_en_count)
        $display("\nTesbench successfully completed\n"); 
    else
        $display("\nTesbench failed, successful completions %d out for %d\n", result, in_en_count);
end
endtask : test_1

/*************************************************************************************
 *            ONE KEY TASKS                                                          *
 *************************************************************************************/
`ifdef ONE_KEY
task write_keyset;
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

    $display("Write new key set\n");
end
endtask : write_keyset

task set_keyset;
input integer num_key;
integer i;
begin
    @(posedge clk);
    for (i = num_key*11*2; i < ((num_key + 1)*11*2); i = i + 2)
        begin
            @(posedge clk);
            en_wr <= 1'b1;
            key_round_wr <= {keyset_m[i + 1], keyset_m[i]};
        end
    @(posedge clk);
    en_wr <= 1'b0;
    key_round_wr <= 128'b0;
end
endtask : set_keyset
`endif

/*************************************************************************************
 *            TWO KEY TASKS                                                          *
 *************************************************************************************/
`ifdef TWO_KEY
task write_keyset;
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

    $display("Write new key set, buffer = %d\n", num_buf);
end
endtask : write_keyset

task set_keyset;
input integer num_key;
integer i;
begin
    @(posedge clk);
    for (i = num_key*11*2; i < ((num_key + 1)*11*2); i++)
        begin
            @(posedge clk);
            en_wr <= 1'b1;
            key_round_wr <= keyset_m[i];
        end
    @(posedge clk);
    en_wr <= 1'b0;
    key_round_wr <= 64'b0;
    switch_key <= 1'b1;
    @(posedge clk);
    switch_key <= 1'b0;
end
endtask : set_keyset
`endif


endmodule : aes_128_top_tb_tasks