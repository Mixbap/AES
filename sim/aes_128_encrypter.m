script
clear

%--------------------------TEST AES----------------------------------------
% Input_hex = ['00' '44' '88' 'cc'
%              '11' '55' '99' 'dd'
%              '22' '66' 'aa' 'ee'
%              '33' '77' 'bb' 'ff'];
% 
% Input_data = aes_debug_hex_to_bin_array(Input_hex);
% 
% Key_AES_hex = ['00' '04' '08' '0c'
%                '01' '05' '09' '0d'
%                '02' '06' '0a' '0e'
%                '03' '07' '0b' '0f'];
% 
% Key_AES = aes_debug_hex_to_bin_array(Key_AES_hex);

%----------Read key--------------------------------------------------------
% fdata_key = fopen('aes_key.dat', 'r');
% 
% Key_AES_length = fscanf(fdata_key, '%d', 1);
% 
% n = 1;
% A = fscanf(fdata_key, '%c', 1);
% for i = 1 : Key_AES_length
%     for j = 1:8
%         Key_AES_str = fscanf(fdata_key, '%c', 1);
%         Key_AES(n) = str2num(Key_AES_str);
%         n = n + 1;
%     end
%     A = fscanf(fdata_key, '%c', 1);
% end
% Key_AES = aes_array_to_matrix(Key_AES);
% fclose(fdata_key);
% clear A
% 
% %----------Read input data-------------------------------------------------
% fdata_in = fopen('aes_input_data.dat', 'r');
% 
% Input_data_length = fscanf(fdata_in, '%d', 1);
% 
% n = 1;
% A = fscanf(fdata_in, '%c', 1);
% for i = 1 : Input_data_length
%     for j = 1:8
%         Input_data_full_str = fscanf(fdata_in, '%c', 1);
%         Input_data_full(n) = str2num(Input_data_full_str);
%         n = n + 1;
%     end
%     A = fscanf(fdata_in, '%c', 1);
% end
% fclose(fdata_in);
% clear A


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%-----Generate random massive input data and keys--------------------------
Input_data_frame = 100; %value frame
[ Input_data_full, Key_AES_full ] = aes_128_gen_indata_key(Input_data_frame*128);
Input_data_length = Input_data_frame*16;

%----Generate random massive input enable----------------------------------
Input_enable = randi([1 3], 1, Input_data_length);

%----Write input enable in file--------------------------------------------
fen_in = fopen('../data/aes_128_enc_input_enable.dat', 'wb');
fprintf(fen_in, '%d\n', Input_data_frame);

for i = 0:Input_data_frame-1 
    fprintf(fen_in, '%d\n', Input_enable(i+1));
end

fclose(fen_in);


%----Write input data and keys in file-------------------------------------
Input_data_hex_full = '';
Key_AES_hex_full = '';


for i = 0 : Input_data_frame - 1
    
    Input_data_matrix = aes_array_to_matrix(Input_data_full(128*i + 1 : 128*(i + 1)));
    Input_data_hex = aes_array128_to_hex_colums(Input_data_matrix);
    Input_data_hex_obr = Input_data_hex(31:32);
    for c = 1:2:29
        Input_data_hex_obr = [Input_data_hex_obr Input_data_hex(30-c:30-c+1)];
    end
    Input_data_hex_full = [Input_data_hex_full  Input_data_hex_obr];
    Input_data_hex_obr = '';
    
    Key_AES_matrix = aes_array_to_matrix(Key_AES_full(128*i + 1 : 128*(i + 1)));
    Key_AES_hex = aes_array128_to_hex_colums(Key_AES_matrix);
    Key_AES_hex_full = [Key_AES_hex_full Key_AES_hex];
end
%-------------------Write input data---------------------------------------
fdata_in_hex = fopen('../data/aes_128_enc_input_data_hex.dat', 'wb');
fprintf(fdata_in_hex, '%d\n', Input_data_frame);

for i = 0:Input_data_frame-1 
for n = 1:31
    fprintf(fdata_in_hex, '%c', Input_data_hex_full(32*i + n));
end
    fprintf(fdata_in_hex, '%c\n', Input_data_hex_full(32*i + 32));
end

fclose(fdata_in_hex);
%-----------------Write Key_AES--------------------------------------------
% fkey_hex = fopen('../data/aes_128_enc_key_hex.dat', 'wb');
% fprintf(fkey_hex, '%d\n', Input_data_frame);
% 
% for i = 0:Input_data_frame-1 
% for n = 1:31
%     fprintf(fkey_hex, '%c', Key_AES_hex_full(32*i + (32-n)));
% end
%     fprintf(fkey_hex, '%c\n', Key_AES_hex_full(32*i + 32));
% end
% 
% fclose(fkey_hex);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------



%-----Encryption data------------------------------------------------------
for section = 0 : Input_data_length/16 - 1
    
Input_data = aes_array_to_matrix(Input_data_full(128*section + 1 : 128*(section + 1)));

%--------------------------------------------------------------------------
%If Key_AES generate random
Key_AES = aes_array_to_matrix(Key_AES_full(128*section + 1 : 128*(section + 1)));
%--------------------------------------------------------------------------


%--------------------------KeyExpension------------------------------------
RoundKey = KeyExpension( Key_AES );

if (section == 0)
    RoundKey_full = RoundKey;
else
    RoundKey_full = [RoundKey_full RoundKey];
end

%--------------------------AddRoundKey-------------------------------------
RoundData = AddRoundKey( Input_data, Key_AES );

%--------------------------------------------------------------------------
%-------------------1-10 ROUNDS---------------------------------------------
%--------------------------------------------------------------------------
for Round = 0:9
%---------------------------SubBytes---------------------------------------
for X = 1:4
    for Y = 1:4
        byte = RoundData(X, (8*(Y-1))+1 : 8*Y);
        RoundData(X, (8*(Y-1))+1 : 8*Y) = SubBytes(byte);
    end
end

%--------------------------ShiftRows---------------------------------------
RoundData = ShiftRows( RoundData );

%--------------------------MixColumns--------------------------------------
if (Round < 9)

for i = 1:4
    
    RoundData_colums = [RoundData(1,(8*(i-1))+1 : 8*i) RoundData(2,(8*(i-1))+1 : 8*i) RoundData(3,(8*(i-1))+1 : 8*i) RoundData(4,(8*(i-1))+1 : 8*i)];
   
    Data = MixColumns(RoundData_colums);
       
    for m = 1:4  
        RoundData_m(m, (8*(i-1))+1 : 8*i) = Data((8*(m-1))+1 : 8*m);
    end
        
end
RoundData = RoundData_m;

end

%--------------------------AddRoundKey-------------------------------------
Key_N_str = RoundKey((128*Round+128)+1 : 128*(Round+1)+128);

Key_N = aes_array_to_matrix(Key_N_str);

RoundData = AddRoundKey( RoundData, Key_N );

end

Encrypted_Data = RoundData;

% Encrypted_Data_hex = aes_array128_to_hex(Encrypted_Data);%debug
% Encrypted_Data_hex1 = aes_array128_to_hex_colums(Encrypted_Data);%debug

Enc0 = [Encrypted_Data(1,1:8) Encrypted_Data(2,1:8) Encrypted_Data(3,1:8) Encrypted_Data(4,1:8)];
Enc1 = [Encrypted_Data(1,9:16) Encrypted_Data(2,9:16) Encrypted_Data(3,9:16) Encrypted_Data(4,9:16)];
Enc2 = [Encrypted_Data(1,17:24) Encrypted_Data(2,17:24) Encrypted_Data(3,17:24) Encrypted_Data(4,17:24)];
Enc3 = [Encrypted_Data(1,25:32) Encrypted_Data(2,25:32) Encrypted_Data(3,25:32) Encrypted_Data(4,25:32)];

Encrypted_Data_m = [Enc0 Enc1 Enc2 Enc3];

if (section == 0)
    Encrypted_Data_full = Encrypted_Data_m;
else
    Encrypted_Data_full = [Encrypted_Data_full Encrypted_Data_m];
end

end

%----Write keys in file----------------------------------------------------
RoundKey_hex_full = '';

for i = 0 : Input_data_frame*11 - 1
    
    RoundKey_matrix = aes_array_to_matrix(RoundKey_full(128*i + 1 : 128*(i + 1)));
    RoundKey_hex = aes_array128_to_hex_colums(RoundKey_matrix);
    RoundKey_hex_obr = RoundKey_hex(31:32);
    for c = 1:2:29
        RoundKey_hex_obr = [RoundKey_hex_obr RoundKey_hex(30-c:30-c+1)];
    end
    RoundKey_hex_full = [RoundKey_hex_full RoundKey_hex_obr];
    RoundKey_hex_obr = '';
    
end

fkey_hex = fopen('../data/aes_128_enc_key_hex.dat', 'wb');
fprintf(fkey_hex, '%d\n', Input_data_frame*2*11);

for i = 1:2:Input_data_frame*2*11 
    for n = 1:15
        fprintf(fkey_hex, '%c', RoundKey_hex_full(16*i + n));
    end
        fprintf(fkey_hex, '%c\n', RoundKey_hex_full(16*i + 16));
        
    for n = 1:15
        fprintf(fkey_hex, '%c', RoundKey_hex_full(16*(i-1) + n));
    end
        fprintf(fkey_hex, '%c\n', RoundKey_hex_full(16*(i-1) + 16));
        
end

fclose(fkey_hex);
%--------------------------------------------------------------------------

%-----------Write data-----------------------------------------------------
fdata_out = fopen('../data/aes_128_enc_output_data.dat', 'wb');
fprintf(fdata_out, '%d\n', Input_data_length);
for i = 1 : 8*Input_data_length
   switch (mod(i, 8))
    case 0
        fprintf(fdata_out, '%d\n', Encrypted_Data_full(i - 7));
    case 1
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 8 )); 
    case 2
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 7 ));
    case 3
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 6 ));
    case 4
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 5 )); 
    case 5
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 4 ));
    case 6
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 3 ));
    case 7
       fprintf(fdata_out, '%d', Encrypted_Data_full( (i - mod(i,8)) + 2 ));
    end 
end

fclose(fdata_out);
%--------------------------------------------------------------------------
%-------------------Write output data hex----------------------------------
Encrypted_Data_hex_full = '';
for i = 0 : Input_data_frame - 1
    
    Encrypted_Data_full_matrix = aes_array_to_matrix(Encrypted_Data_full(128*i + 1 : 128*(i + 1)));
    Encrypted_Data_hex_f = aes_array128_to_hex_colums(Encrypted_Data_full_matrix);
    
    Encrypted_Data_hex_f_obr = Encrypted_Data_hex_f(31:32);
    for c = 1:2:29
        Encrypted_Data_hex_f_obr = [Encrypted_Data_hex_f_obr Encrypted_Data_hex_f(30-c:30-c+1)];
    end
    Encrypted_Data_hex_full = [Encrypted_Data_hex_full Encrypted_Data_hex_f_obr];
    Encrypted_Data_hex_f_obr = '';
    
end

fdata_out_hex = fopen('../data/aes_128_enc_output_data_hex.dat', 'wb');
fprintf(fdata_out_hex, '%d\n', Input_data_frame);

for i = 0:Input_data_frame-1 
for n = 1:31
    fprintf(fdata_out_hex, '%c', Encrypted_Data_hex_full(32*i + n));
end
    fprintf(fdata_out_hex, '%c\n', Encrypted_Data_hex_full(32*i + 32));
end

fclose(fdata_out_hex);
%--------------------------------------------------------------------------


