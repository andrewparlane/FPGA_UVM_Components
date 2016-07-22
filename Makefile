# Makefile for use in building all my UVM components
# ----------------------------------------------------------------------------------
# Requirements:
#   QuestaSim - We use the vlog compiler packaged with QuestaSim.
#     ModelSim also comes with vlog, but doesn't really support UVM.
#   UVM_INCLUDE_DIR environment var - This should point to the UVM src directory.
#     For me this is: C:\questasim_10.0b\verilog_src\uvm-1.0p1\src
# ----------------------------------------------------------------------------------
# Notes:
#   The vlog compiler creates an output folder in the VLIB_DIR directors
#   per package/module/interface with the same name as the entity
#   Any capitals are replace with @ followed by the lower case letter
#   IE. FooBar -> @foo@bar
#   This makefile requires that:
#     Each file can only contain a single interface, package or module
#     No capitals in package/module/interface naems
#     The package/module/interface has the same name as the file

# set the default target to be all. Otherwise it's the first target it finds
.DEFAULT_GOAL := all

# some variabls to use later
VLIB_DIR 	= ./uvm_components_work
VLIB_NAME	= uvm_components_work
VLOG_FLAGS 	= -work $(VLIB_NAME) +incdir+$(UVM_INCLUDE_DIR)

# pull in some macros
# this has: colour codes for outputting messages in colour
#			a macro to turn the source path into the object path
#			a macro to create a target based on a source file name
include uvm_components.mk

# src files - per directory for use with compile orders
#			  ie. transactions have to be compiled before drivers
INTERFACE_SRCS 		= $(wildcard src/interfaces/*.sv)
CONFIG_SRCS 		= $(wildcard src/configs/*.sv)
TRANSACTION_SRCS 	= $(wildcard src/transactions/*.sv)
SEQUENCE_SRCS 		= $(wildcard src/sequences/*.sv)
DRIVER_SRCS 		= $(wildcard src/drivers/*.sv)
MONITOR_SRCS 		= $(wildcard src/monitors/*.sv)
AGENT_SRCS 			= $(wildcard src/agents/*.sv)
SCOREBOARD_SRCS 	= $(wildcard src/scoreboards/*.sv)

# all source files - for use with creating makefile targets
SRCS				= $(INTERFACE_SRCS) \
                      $(CONFIG_SRCS) \
                      $(TRANSACTION_SRCS) \
                      $(SEQUENCE_SRCS) \
                      $(DRIVER_SRCS) \
                      $(MONITOR_SRCS) \
                      $(AGENT_SRCS) \
                      $(SCOREBOARD_SRCS)

# list of all the components
COMPONENTS	= interfaces \
              configs \
              transactions \
              sequences \
              drivers \
              monitors \
              agents \
              scoreboards


# default rule is to create the library, compile the UVM pkg and all the components
all: $(VLIB_DIR) UVM $(COMPONENTS)

# create the questaSim library if it's not already there
$(VLIB_DIR):
	vlib $(VLIB_DIR)
	vmap $(VLIB_NAME) $(VLIB_DIR)
	@echo -e "$(COLOUR_GREEN)Created the $(VLIB_DIR) library mapped to $(VLIB_NAME)$(COLOUR_NONE)\n"

# compile the UVM library
$(VLIB_DIR)/uvm_pkg/_primary.dat:
	vlog $(VLOG_FLAGS) $(UVM_INCLUDE_DIR)/uvm.sv
	@echo -e "$(COLOUR_GREEN)Compiled the UVM package$(COLOUR_NONE)\n"

# simple alias
UVM: $(VLIB_DIR) $(VLIB_DIR)/uvm_pkg/_primary.dat

# create targets for all our sources
# this loops through all of our source files in the $(SRCS) var
# and foreach one evaluates as makefile rules the results of calling
# the create_target_for macro on the source file.
# this macro is in the uvm_components.mk file
# note with this method we can't set dependencies within a single directory
$(foreach src,$(SRCS),$(eval $(call create_target_for, $(src))))

# define a phony target per directory so we can specify compile order
interfaces: $(VLIB_DIR) UVM \
            $(call src2obj, $(INTERFACE_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

configs: $(VLIB_DIR) UVM \
         $(call src2obj, $(CONFIG_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

transactions: $(VLIB_DIR) UVM \
              $(call src2obj, $(TRANSACTION_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

sequences: $(VLIB_DIR) UVM \
           transactions \
           $(call src2obj, $(SEQUENCE_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

drivers: $(VLIB_DIR) UVM \
         transactions interfaces \
         $(call src2obj, $(DRIVER_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

monitors: $(VLIB_DIR) UVM \
          transactions interfaces \
          $(call src2obj, $(MONITOR_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

agents: $(VLIB_DIR) UVM \
        drivers monitors transactions configs interfaces \
        $(call src2obj, $(AGENT_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

scoreboards: $(call src2obj, $(SCOREBOARD_SRCS))
	@echo -e "$(COLOUR_GREEN)Compiled all $@$(COLOUR_NONE)\n"

# delete the library and all compiled files
clean:
	if [ -d $(VLIB_DIR) ]; then vdel -lib $(VLIB_DIR) -all; fi;
	if [ -e modelsim.in ]; then rm modelsim.ini; fi;

.PHONY: clean UVM all $(COMPONENTS)
