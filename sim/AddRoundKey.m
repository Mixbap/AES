function [ RoundData ] = AddRoundKey( Input_data, Key_AES )

RoundData = xor(Input_data, Key_AES);

end

