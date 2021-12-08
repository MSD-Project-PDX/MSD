sv_run: clean work_dir compile run

work_dir:
	vlib work
compile:
	vlog mem_ctrl.sv
clean:
	rm -rf transcript work
	clear
run:
	#vsim -c -do "run -all" mem_ctrl +ip_file="tracefile.txt" +op_file="output_file.out" +debug_en=1
	#vsim -c -do "run -all" mem_ctrl +ip_file="tracefile.txt" +op_file="output_file.out" +refresh_en=1 +adaptive_en=1
	#vsim -c -do "run -all" mem_ctrl +ip_file="tracefile.txt" +op_file="output_file.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t0.trace" +op_file="OUTPUTFILES/t0_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t1.trace" +op_file="OUTPUTFILES/t1_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t10.trace" +op_file="OUTPUTFILES/t10_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t11.trace" +op_file="OUTPUTFILES/t11_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t2.trace" +op_file="OUTPUTFILES/t2_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t3.trace" +op_file="OUTPUTFILES/t3_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t4.trace" +op_file="OUTPUTFILES/t4_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t5.trace" +op_file="OUTPUTFILES/t5_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t6.trace" +op_file="OUTPUTFILES/t6_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t7.trace" +op_file="OUTPUTFILES/t7_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t8.trace" +op_file="OUTPUTFILES/t8_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/t9.trace" +op_file="OUTPUTFILES/t9_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_1.txt" +op_file="OUTPUTFILES/tracefile_1_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_10.txt" +op_file="OUTPUTFILES/tracefile_10_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_11.txt" +op_file="OUTPUTFILES/tracefile_11_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_12.txt" +op_file="OUTPUTFILES/tracefile_12_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_13.txt" +op_file="OUTPUTFILES/tracefile_13_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_14.txt" +op_file="OUTPUTFILES/tracefile_14_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_15.txt" +op_file="OUTPUTFILES/tracefile_15_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_16.txt" +op_file="OUTPUTFILES/tracefile_16_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_17.txt" +op_file="OUTPUTFILES/tracefile_17_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_18.txt" +op_file="OUTPUTFILES/tracefile_18_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_19.txt" +op_file="OUTPUTFILES/tracefile_19_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_2.txt" +op_file="OUTPUTFILES/tracefile_2_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_20.txt" +op_file="OUTPUTFILES/tracefile_20_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_21.txt" +op_file="OUTPUTFILES/tracefile_21_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_22.txt" +op_file="OUTPUTFILES/tracefile_22_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_23.txt" +op_file="OUTPUTFILES/tracefile_23_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_24.txt" +op_file="OUTPUTFILES/tracefile_24_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_3.txt" +op_file="OUTPUTFILES/tracefile_3_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_4.txt" +op_file="OUTPUTFILES/tracefile_4_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_5.txt" +op_file="OUTPUTFILES/tracefile_5_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_6.txt" +op_file="OUTPUTFILES/tracefile_6_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_7.txt" +op_file="OUTPUTFILES/tracefile_7_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_8.txt" +op_file="OUTPUTFILES/tracefile_8_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_9.txt" +op_file="OUTPUTFILES/tracefile_9_op.out" +refresh_en=1
	vsim -c -do "run -all" mem_ctrl +ip_file="TRACEFILES/tracefile_final.txt" +op_file="OUTPUTFILES/tracefile_final_op.out" +refresh_en=1
