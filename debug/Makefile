RTL_DIR:=../aes128enc
LIB_DIR:=../aes128enc
TB_DIR:=.
INCLUDE_PATH:=../aes128enc
VLOGOPT:=-novopt

# protection level: 8 or 13
PLEVEL?=8
# enabling new linear algebra for plevel 8
NEW_LA?=0

# base rtl
CORE_SRC:=openAES_128e.v AES128_control.v AES128enc_Coding.v \
openAES_128e_Core.v AES_128e_reg_output.v AES_input.v AES_reg.v \
AES_reg_sharedext.v blocks_red.v grand_blocks_red.v

# plevel dependend rtl
## plevel 8
LIB_8_SOURCES:=arithmetics_red_8.v

## plevel 8 with new linear algebra
LIB_8_NEWLA_SOURCES:=arithmetics_red_8.v arithmetics_red_8_modified.v

## plevel 13
LIB_13_SOURCES:=arithmetics_red_13.v


TB_SRC:=aes_simple_tb.sv

VSIM_DEFINES:= +define+CONFIG_FROM_TOOL 
XRUN_DEFINES:= -define CONFIG_FROM_TOOL 

ifeq "$(PLEVEL)" "13"
	LIB_SRC=$(LIB_13_SOURCES)
	VSIM_DEFINES+= +define+REDUNDANCY_13
	XRUN_DEFINES+= -define REDUNDANCY_13
else ifeq "$(PLEVEL)" "8"
	VSIM_DEFINES+= +define+REDUNDANCY_8
	XRUN_DEFINES+= -define REDUNDANCY_8
	ifeq "$(NEW_LA)" "1"
		LIB_SRC=$(LIB_8_NEWLA_SOURCES)
		VSIM_DEFINES+= +define+NEW_LA_EN
		XRUN_DEFINES+= -define NEW_LA_EN
	else
		LIB_SRC=$(LIB_8_SOURCES)
	endif
endif

CORE_PATH=$(addprefix $(RTL_DIR)/,$(CORE_SRC))
TB_PATH=$(addprefix $(TB_DIR)/,$(TB_SRC))
LIB_PATH=$(addprefix $(LIB_DIR)/,$(LIB_SRC))

.PHONY: all xcelium_run xcelium_rung clean

all: run

SRC_PATH:=$(LIB_PATH) $(CORE_PATH) $(TB_PATH)

ifdef opt
OPT:=-O3
endif

VLOGOPT:=+acc

VSIMINIT=set NumericStdNoWarnings 1; set IterationLimit 10000
VSIMFLAGS=-t 10ps $(VLOGOPT)

xcelium_run: $(SRC_PATH)
	xrun -sv $(OPT) -incdir $(INCLUDE_PATH) -top tb $(XRUN_DEFINES) $(SRC_PATH)

xcelium_rung: $(SRC_PATH)
	xrun -sv $(OPT) -incdir $(INCLUDE_PATH) -top tb $(XRUN_DEFINES) $(SRC_PATH) -access +rwc -gui

vsim_run: compile
	vsim $(VSIMFLAGS) -do "$(VSIMINIT); run -all; quit -f" -c work.tb

vsim_rung: compile
	vsim $(VSIMFLAGS) -do "$(VSIMINIT)" work.tb

compile: work
	vlog -work work -sv $(VLOGOPT) +incdir+$(INCLUDE_PATH) $(VSIM_DEFINES) $(SRC_PATH) -source 
	vlog -work work -sv $(VLOGOPT) +incdir+$(INCLUDE_PATH) $(VSIM_DEFINES) $(TB_PATH) -source 

work:
	vlib work
	vmap work work

clean:
	rm -r -f work
	rm -rf INCA_libs
	rm -f *.o
	rm -f transcript
	rm -f irun.key
	rm -f vsim.wlf
	rm -rf *.shm
	rm -f coverage.txt
	rm -f modelsim.ini
	rm -f testbench.bin *.o *.so
	rm -f tb.bin *.o *.so
	rm -f *.log
	rm -f vsim_stacktrace.vstf
	rm -rf xcelium.d
	rm -f xrun.history
	rm -f xrun.key
