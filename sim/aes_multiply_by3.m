function [ Output ] = aes_multiply_by3( Input )

if (Input(1) == 1)
    Input_shift = [Input(2:8) 0]; %сдвиг влево на 1
    Output = xor(Input_shift, [0 0 0 1  1 0 1 1]); %xor c 1b
else
    Output = [Input(2:8) 0]; %сдвиг влево на 1
end

Output = xor(Output, Input); %xor c входными данными


end

