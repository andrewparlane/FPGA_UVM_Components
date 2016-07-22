# FPGA_UVM_Components
A collection of UVM components for use when building a verification interface

To build simply run make in the root directory

Requirements:
    QuestaSim - We use the vlog compiler packaged with QuestaSim.
        ModelSim also comes with vlog, but doesn't really support UVM.
    UVM_INCLUDE_DIR environment var - This should point to the UVM src directory.
        For me this is: C:\questasim_10.0b\verilog_src\uvm-1.0p1\src
