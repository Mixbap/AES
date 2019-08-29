function [ Out ] = aes_debug_hex_to_bin_array( Input_hex )

for i = 1:4
    for j = 1:4
        Input_dec(i,j) = hex2dec(Input_hex(i, (2*(j-1))+1 : (2*(j-1))+2));
        Input_bin = dec2bin(Input_dec(i,j), 8);
        for n = 1:8
            Out_array(n) = str2num(Input_bin(n));
        end
        Out(i, (8*(j-1))+1 : (8*(j-1))+8) = Out_array;
    end
end

end

