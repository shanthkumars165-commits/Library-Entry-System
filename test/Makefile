# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_lib_sys.v

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD      = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation:
SIM_BUILD      = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PWD)/tb.v
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include cocotb user-defined variables
TOPLEVEL = tt_um_lib_sys
MODULE   = test

include $(shell cocotb-config --makefiles)/Makefile.sim
