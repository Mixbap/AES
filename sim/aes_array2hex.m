function [ out_data ] = aes_array2hex( input_data )

str_data1 = num2str(input_data(1:4));
dec_data1 = bin2dec(str_data1);
out_data1 = dec2hex(dec_data1);

str_data2 = num2str(input_data(5:8));
dec_data2 = bin2dec(str_data2);
out_data2 = dec2hex(dec_data2);

out_data = [out_data1 out_data2];

end

