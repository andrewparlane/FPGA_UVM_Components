# Some common macros and variables for use with compiling .sv files
# using vlog which is packaged as part of QuestaSim
#-----------------------------------------------------------------------------------

# colours for use in echo commands for highlighting
COLOUR_NONE		= \x1b[0m
COLOUR_RED		= \x1b[31;01m
COLOUR_BLUE		= \x1b[34;01m
COLOUR_GREEN 	= \x1b[32;01m

# macros to turn a .sv file into the compiled file in the relevant VLIB_DIR subdirectory
# src/abc/def.sv -> $(VLIB_DIR)/def/_primary.dat
src2obj 	= $(addsuffix /_primary.dat, $(addprefix $(VLIB_DIR)/, $(basename $(notdir $(1)))))

# macro to create a target for a given source file
# it takes two arguments:
# 1) the path and name of the source file
# 2) any dependencies
# It then creates a traget on the relevant _primary.dat (questaSim created object)
# with a dependency on the source file, and any other passed in dependencies
define create_target_for

$$(info create_target_for called on $(1))
$$(info creating target $(call src2obj, $(1)))
$$(info with dependencies $(VLIB_DIR) $(1) $(2))
$$(info )
$(call src2obj, $(1)): $(1) $(2)
	@echo -e "$(COLOUR_BLUE)compiling $(1) because of changes in: $$? $(COLOUR_NONE)\n"
	vlog $(VLOG_FLAGS) $(1)

endef
