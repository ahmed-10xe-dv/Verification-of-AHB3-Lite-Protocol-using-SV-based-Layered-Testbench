# Compile design and testbench files
vcs -sverilog design.sv testbench.sv -o simv -l comp.log
# Run the simulation with proper access permissions
./simv>sim.log
dve -vpd dump.vcd &
