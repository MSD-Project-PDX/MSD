ECE 585 FALL 2021 - MSD PROJECT GROUP 7 README FILE

-- To run all the tracefiles from the TRACEFILES/ directory, execute the below command

>sh Run.sh


NOTES for Run.sh:
1) Any number of input files can be placed in the TRACEFILES/ directory.
2) When this Run.sh script is called, separate output files will be created in the OUTPUTFILES/ directory with the same <input_file_name>.out
3) The Makefile will be updated with the vsim command for all the tracefiles.
4) The Makefile will then be called once and all the input tracefiles will be executed sequentially.
