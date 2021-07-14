#==============================================================================#
# AIC2021 Project1 - TPU Design                                                #
# file: Makefile                                                               #
# description: Makefile for TPU testbench                                      #
# authors: kaikai (deekai9139@gmail.com)                                       #
#          suhan  (jjs93126@gmail.com)                                         #
#==============================================================================#

#------------------------------------------------------------------------------#
# Change your own verilog compiler.                                            #
#------------------------------------------------------------------------------#
VERILOG=irun
#VERILOG=ncverilog
#VERILOG=iverilog

#------------------------------------------------------------------------------#
# Directories Declarations                                                     #
#------------------------------------------------------------------------------#
CUR_DIR=$(PWD)
TB_DIR=tb
BUILD_DIR=build
SRC_DIR=src
INC_DIR=inc

test1:
	cd $(TB_DIR) && python3 matmul.py inputs1
	$(VERILOG) tb/top_tb.v \
    +incdir+$(PWD)/$(SRC_DIR)+$(PWD)/$(TB_DIR)+$(PWD)/$(BUILD_DIR) +access+r

test2:
	cd $(TB_DIR) && python3 matmul.py inputs2
	$(VERILOG) tb/top_tb.v \
    +incdir+$(PWD)/$(SRC_DIR)+$(PWD)/$(TB_DIR)+$(PWD)/$(BUILD_DIR) +access+r

test3:
	cd $(TB_DIR) && python3 matmul.py inputs3
	$(VERILOG) tb/top_tb.v \
    +incdir+$(PWD)/$(SRC_DIR)+$(PWD)/$(TB_DIR)+$(PWD)/$(BUILD_DIR) +access+r

monster:
	cd $(TB_DIR) && python3 matmul.py monster
	$(VERILOG) tb/top_tb.v \
    +incdir+$(PWD)/$(SRC_DIR)+$(PWD)/$(TB_DIR)+$(PWD)/$(BUILD_DIR) +access+r

clean:
	rm -rf build
