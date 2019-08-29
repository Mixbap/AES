function [ Output_data ] = MixColumns( Input_data )

state0 = Input_data(1:8);
state1 = Input_data(9:16);
state2 = Input_data(17:24);
state3 = Input_data(25:32);

out_state0 = xor(xor(aes_multiply_by2(state0), aes_multiply_by3(state1)), xor(state2, state3)); 
out_state1 = xor(xor(state0, aes_multiply_by2(state1)), xor(aes_multiply_by3(state2), state3)); 
out_state2 = xor(xor(state0, state1), xor(aes_multiply_by2(state2), aes_multiply_by3(state3))); 
out_state3 = xor(xor(aes_multiply_by3(state0), state1), xor(state2, aes_multiply_by2(state3)));

Output_data = [out_state0 out_state1 out_state2 out_state3];

end

