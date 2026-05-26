set ::env(DESIGN_NAME) tt_um_lib_sys

set ::env(VERILOG_FILES) "\
    $::env(DESIGN_DIR)/tt_um_lib_sys.v \
"

set ::env(CLOCK_PORT) "clk"

set ::env(FP_PDN_AUTO_ADJUST) 1

set ::env(PL_TARGET_DENSITY) 0.50
