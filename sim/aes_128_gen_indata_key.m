function [ Input_data_full, Key_AES ] = aes_128_gen_indata_key( Input_data_length )
%Create random massive input data and keys 

Input_data_full = randi([0 1], 1, Input_data_length);

Key_AES = randi([0 1], 1, Input_data_length);

end

