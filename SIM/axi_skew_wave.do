onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_top/minf_32/aclk
add wave -noupdate /axi_top/minf_32/mdrv_cb/awaddr
add wave -noupdate /axi_top/minf_32/mdrv_cb/awvalid
add wave -noupdate /axi_top/minf_32/mdrv_cb/awready
add wave -noupdate /axi_top/sinf_32/sdrv_cb/awvalid
add wave -noupdate /axi_top/sinf_32/sdrv_cb/awready
add wave -noupdate /axi_top/sinf_32/smon_cb/awaddr
add wave -noupdate /axi_top/sinf_32/smon_cb/awvalid
add wave -noupdate /axi_top/sinf_32/smon_cb/awready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {173 ns}
