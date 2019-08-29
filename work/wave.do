######################################################################################################
#                                                                                                    #
#                                      WAVE GEN SECTION                                              #
#                                                                                                    #
######################################################################################################

add wave -radix hexadecimal -group TESTBENCH sim:/aes_128_top_tb/aes_128_top_tb_tasks/*
add wave -radix hexadecimal -group AES_128 sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/*
add wave -radix hexadecimal -group SUBBYTES_SHIFTROWS sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/subbytes_shiftrows/*
add wave -radix hexadecimal -group MIXCOLUMS sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/mixcol/*
#add wave -radix hexadecimal -group CORE_CONTROL sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/aes_128_control_3val/*
#add wave -radix hexadecimal -group CORE_CONTROL sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/aes_128_control_4val/*
#add wave -radix hexadecimal -group SWITCH_KEY_RAM sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/switch_key_ram/*
#add wave -radix hexadecimal -group SWITCH_KEY_RAM sim:/aes_128_top_tb/aes_128_top_tb_tasks/aes_128_top/single_key_ram/*

configure wave -signalnamewidth 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 200
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps

