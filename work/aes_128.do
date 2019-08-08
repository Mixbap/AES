transcript on
vlib work

vlog ../src/*.sv
vlog ../tb/*.sv

vsim -t 1ns aes_128_top_tb

do ../work/wave.do

run -all
wave zoom full