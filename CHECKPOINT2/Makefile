sv_run: clean work_dir compile run

python:
	python py_input.py
work_dir:
	vlib work
compile: python
	vlog mem_con.sv
run:
	vsim -c -do "run -all" mem_con +debug_en=1
clean:
	rm -rf transcript work ip_*
