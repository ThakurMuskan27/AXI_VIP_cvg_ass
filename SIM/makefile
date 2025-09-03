
#Makefile

PKG= ../ENV/AXI_M_AGENT/axi_mpkg.svh ../ENV/AXI_S_AGENT/axi_spkg.svh ../ENV/axi_env_pkg.svh ../TEST/axi_test_pkg.svh ../TOP/axi_assertion.sv 
TOP_DIR= ../TOP/axi_assertion.sv ../TOP/axi_tb_top.sv
TOP= axi_top

COV_EN=0
TEST = axi_wrap_narrow_test

lb:
	vlib work

cmp: 
	vlog +acc $(RTL) $(PKG) $(TOP_DIR) +incdir+../ENV +incdir+../TEST +incdir+../ENV/AXI_M_AGENT +incdir+../ENV/AXI_S_AGENT +incdir+../TOP 

cmp_coverage:
	vlog -coveropt 3 +cover +acc $(RTL) $(PKG) $(TOP_DIR) +incdir+../ENV +incdir+../TEST

sim_cmd:
	vsim -vopt $(TOP) -c -do "run -all; exit" +UVM_TESTNAME=$(TEST) 

sim:
	vsim -vopt $(TOP) -assertdebug -do "run -all; exit" +UVM_TESTNAME=$(TEST)  

sim_coverage:
	vsim -coverage -vopt $(TOP) -c -do "coverage save -onexit -directive -cvg -codeall AXI_CVG.ucdb; run -all; exit" $(TEST) -l TEST.log
	vcover report -details -html AXI_CVG.ucdb -htmldir AXI_CVG_REPORT	

ifeq ($(COV_EN),1)
run: cmp_coverage sim_coverage
else
run: cmp sim
endif

run_cmd: cmp sim_cmd 
