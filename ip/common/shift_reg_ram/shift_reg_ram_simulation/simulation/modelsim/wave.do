onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /shift_reg_ram_vhd_tst/clk
add wave -noupdate -radix unsigned /shift_reg_ram_vhd_tst/data_in
add wave -noupdate -radix unsigned /shift_reg_ram_vhd_tst/data_out
add wave -noupdate /shift_reg_ram_vhd_tst/data_valid
add wave -noupdate /shift_reg_ram_vhd_tst/data_valid_out
add wave -noupdate -radix unsigned /shift_reg_ram_vhd_tst/depth
add wave -noupdate /shift_reg_ram_vhd_tst/reset_n
add wave -noupdate /shift_reg_ram_vhd_tst/sim_clk
add wave -noupdate /shift_reg_ram_vhd_tst/sim_reset
add wave -noupdate /shift_reg_ram_vhd_tst/sim_trig
add wave -noupdate -radix unsigned /shift_reg_ram_vhd_tst/i1/depth
add wave -noupdate -radix unsigned /shift_reg_ram_vhd_tst/i1/AB_in
add wave -noupdate -radix unsigned /shift_reg_ram_vhd_tst/i1/AB_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9339 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 242
configure wave -valuecolwidth 38
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {31500 ps}
