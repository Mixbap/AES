function [ output_data ] = aes_array_to_matrix( input_data )

output_data(1:4, 1:32) = 0;
for i = 1:4
    input_data_1 = reshape(input_data( 32*(i-1)+1 : 32*i ), 8, 4);
    input_data_2 = transpose(input_data_1);
    output_data(1:4, 8*(i-1)+1 : 8*i) = input_data_2;
end


end

