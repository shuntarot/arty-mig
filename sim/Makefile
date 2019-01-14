export IP_DIR   := $(realpath ../ip)
export RTL_DIR  := $(realpath ../rtl)

TOP       := tb
GUI       ?= off
DUMP      ?= off

XVLOG_OPT += -sv
# XVLOG_OPT += -i $(XILINX_VIVADO)/data/verilog/src/xeclib
XVLOG_OPT += -i ../rtl
XVLOG_OPT += -i ../ip/output/mmcm
XVLOG_OPT += -i ../ip/output/mig
XVLOG_OPT += -i ../ip/output/mig/mig/example_design/sim
XVLOG_OPT += -i ../ip/output/jtag_axi

XELAB_OPT += -L unisims_ver -L secureip

XELAB_OPT += -timescale 1ns/1ps
XELAB_OPT += -stat
SIM_OPT   += -t sim.tcl

# ddr3
XELAB_OPT += -d x2Gb -d sg15E -d x16

ifeq ($(strip $(GUI)), on)
  debug_opt = 1
  SIM_OPT  += -g
endif

ifneq ($(strip $(DUMP)), off)
  debug_opt = 1
endif

ifdef debug_opt
  XELAB_OPT += -debug all
endif

ifeq ($(strip $(DUMP)), wdb)
  SIM_OPT += -wdb out.wdb
endif

sim: compile
	xsim $(SIM_OPT) "work.$(TOP)" | tee -a sim.log

compile:
	xvlog $(XVLOG_OPT) -f compile.f | tee sim.log
	xelab $(XELAB_OPT) $(TOP)   | tee -a sim.log

clean:
	-rm -rf xvlog* xelab* webtalk* xsim* sim.log *.wdb *.vcd


