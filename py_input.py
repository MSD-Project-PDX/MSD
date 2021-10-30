#!/usr/bin/pythn

CLOCK_PERIOD = 312     # micro seconds  --> The CPU is running at 3.2 GHz
debug_en = 1                     # Should be enabled to see the parsed input values at specific cycle time

print("Calling the input parsing code")

f = open("input_file.txt", "r")
f1 = f.readlines()              #Reads all the lines from the input file and stores them in the list "f1"

# Initializing lists to store time, operation and address separately
time = []
operation = []
address = []

# Loop to store the individual values into the list
for x in range(0,len(f1)):
                time.append(                     f1[x].split()[0].strip()) 
                operation.append(           f1[x].split()[1].strip()) 
                address.append(               f1[x].split()[2].strip()) 
                #print("output " + time[x] + " " + operation[x] + " " + address[x])

#The MAX_TIME_SIM is calclulated from the max value of the time used in input_file.txt with an extra 10 clock cycles (Assuming sequential order of inputs)
MAX_TIME         = int(time[len(time) - 1]) +1
MAX_TIME_SIM               = MAX_TIME + 10 

if(debug_en == 1):
                j = 0
                for i in range(0, MAX_TIME_SIM-1):
                                if(i == int(time[j])):
                                                print("Processor_time = " + str(int(time[j])*int(CLOCK_PERIOD)) + "us; \tCPU clock cycle = " + time[j] + "; \tOperation = " + operation[j] + "; \tHEX Addr = " + address[j] + ";")
                                                if(j < len(time)-1): j = j+1
                                else:
                                                print("Processor_time = " + str(i*CLOCK_PERIOD) + "us; \tCPU clock cycle = " + str(i) + "; \tOperation = No Operation")

# END OF CODE 
