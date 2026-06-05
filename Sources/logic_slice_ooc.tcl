# Read all required sources
read_verilog -sv {atoms.sv nodes.sv latch_mem.sv logic_module.sv}

# Synthesize logic slice standalone (no top-level ports assumed driven)
synth_design \
    -mode out_of_context \
    -top logic_slice \
    -part xc7a100tcsg324-1

# Write the checkpoint
catch {exec attrib -r checkpoints}
write_checkpoint -force checkpoints/logic_slice.dcp
close_design