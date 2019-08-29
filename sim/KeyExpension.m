function [ RoundKey ] = KeyExpension( Input_data )

w0 = [Input_data(1,1:8) Input_data(2,1:8) Input_data(3,1:8) Input_data(4,1:8)];
w1 = [Input_data(1,9:16) Input_data(2,9:16) Input_data(3,9:16) Input_data(4,9:16)];
w2 = [Input_data(1,17:24) Input_data(2,17:24) Input_data(3,17:24) Input_data(4,17:24)];
w3 = [Input_data(1,25:32) Input_data(2,25:32) Input_data(3,25:32) Input_data(4,25:32)];

RoundKey = [w0 w1 w2 w3];

for i = 1:10
%---Rcon---------------------------    
Rcon = zeros(1,32);
if i==9
    Rcon(1:8) = [0 0 0 1  1 0 1 1];
end
if i==10
    Rcon(1:8) = [0 0 1 1  0 1 1 0];
end
if i<9
    Rcon(9-i) = 1;
end
%-----------------------------------
x1 = [w3(9:16) w3(17:24) w3(25:32) w3(1:8)];

for X = 1:4
    y1((8*(X-1))+1 : 8*X) = SubBytes(x1((8*(X-1))+1 : 8*X));
end

z1 = [xor(y1(1:8), Rcon(1:8)) y1(9:32)];

w4 = xor(w0, z1);
w5 = xor(w4, w1);
w6 = xor(w5, w2);
w7 = xor(w6, w3);


RoundKey = [RoundKey w4 w5 w6 w7];

w0 = w4;
w1 = w5;
w2 = w6;
w3 = w7;

end



end

