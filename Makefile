TOP := libre_top
GUI ?= 1

PROJECT_DIR := project
EDA_TCL     := project.tcl
SDK_TCL     := sdk.tcl

.PHONY: project sdk clean

project:
	vivado -mode batch -source $(EDA_TCL) -tclargs $(PROJECT_DIR) $(GUI)

sdk:
	xsct $(SDK_TCL)
ifeq ($(GUI), 1)
	vitis -workspace $(PROJECT_DIR)/$(TOP).sdk &
endif

clean:
	rm -rf $(PROJECT_DIR)/$(TOP)
	rm -rf $(PROJECT_DIR)/$(TOP).cache
	rm -rf $(PROJECT_DIR)/$(TOP).hw
	rm -rf $(PROJECT_DIR)/$(TOP).runs
	rm -rf $(PROJECT_DIR)/$(TOP).sim
	rm -rf $(PROJECT_DIR)/$(TOP).gen
	rm -rf $(PROJECT_DIR)/$(TOP).srcs
	rm -rf $(PROJECT_DIR)/$(TOP).src
	rm -rf $(PROJECT_DIR)/$(TOP).ip_user_files
	rm -rf $(PROJECT_DIR)/$(TOP).sdk
	rm -rf $(PROJECT_DIR)/.Xil
	rm $(PROJECT_DIR)/$(TOP).xpr
	rm $(PROJECT_DIR)/*.log
	rm $(PROJECT_DIR)/*.jou
	rm *.log
	rm *.jou
