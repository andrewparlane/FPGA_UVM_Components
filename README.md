# FPGA_UVM_Components
A collection of UVM components for use when building a verification interface

To build simply run make in the root directory

Requirements:
    QuestaSim - We use the vlog compiler packaged with QuestaSim.
        ModelSim also comes with vlog, but doesn't really support UVM.
    UVM_HOME environment var - This should point to the UVM src directory.
        For me this is: C:/questasim_10.0b/uvm-1.0p1

Colourization:
    The uvm_components.mk makefile includes some macros to colourize the outputs
    of vlog and vsim and whatever else you wish to use.
    These can be extended using the MORE_COLOURS variable.
    Or overwritten using the COLOURIZE_SED_ALL variable (must be before the include directive).
    For example to colourize an entire line that contains the word Importing to green:
        MORE_COLOURS = $(call GENERATE_COLOURIZE_SED,^(.*Importing.*)$$,$(COLOUR_GREEN))
    Or to disable colourization altogether:
        COLOURIZE_SED_ALL = sed ''