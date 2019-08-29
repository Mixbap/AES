function [ output ] = aes_array128_to_hex_colums( input )

output = '';
for j = 1:4
    for i = 1:4
        output_val = aes_array2hex(input(i, (8*(j-1))+1 : 8*j));
        output = [output output_val];
    end
end


end

