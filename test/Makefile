# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/tt_um_morse_to_hex.v
VERILOG_SOURCES += $(PWD)/../src/morseToHex.v
VERILOG_SOURCES += $(PWD)/../src/hexto7seg.v

ifneq ($(GATES),yes)
  TOPLEVEL = tt_um_morse_to_hex
else
  SIM_ARGS += -DGL_TEST -DFUNCTIONAL -DUSE_POWER_PINS -DSIM -DUNIT_DELAY=#1
  VERILOG_SOURCES := \
    $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v \
    $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v \
    $(PWD)/gate_level_netlist.v
  TOPLEVEL = tt_um_morse_to_hex
endif

MODULE = test

include $(shell cocotb-config --makefiles)/Makefile.sim