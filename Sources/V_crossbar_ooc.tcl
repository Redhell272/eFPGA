# Read all required sources
read_verilog -sv {atoms.sv nodes.sv latch_mem.sv crossbar.sv}

# Synthesize crossbar standalone (no top-level ports assumed driven)
synth_design \
    -mode out_of_context \
    -top V_crossbar \
    -part xc7a100tcsg324-1

# Write the checkpoint
write_checkpoint -force checkpoints/V_crossbar.dcp
close_design