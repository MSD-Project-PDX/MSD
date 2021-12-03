sv_run: clean work_dir compile run

work_dir:
	vlib work
compile:
	vlog mem_ctrl.sv
run:
	vsim -c -do "run -all" mem_ctrl +ip_file="fp1.txt" +debug_en=1
clean:
	rm -rf transcript work
