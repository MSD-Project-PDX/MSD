#!/usr/bin/python

import copy

sort_enable = 0

f_name = raw_input("Enter the name of the input file : ");
f_name = f_name.strip()
print("Name of the file received : " + f_name);
#f = open("input_file.txt", "r")
f = open(f_name, "r")
f1 = f.readlines()	#Reads all the lines from the input file and stores them in the list "f1"

# Initializing lists to store time, operation and address separately
time = []
operation = []
address = []

time_final = []
operation_final = []
address_final = []

# Loop to store the individual values into the list
for x in range(0,len(f1)):

	local_time = f1[x].split()[0].strip()
	time.append( 		 int(f1[x].split()[0].strip()) )
	operation.append( 	 f1[x].split()[1].strip()) 
	address.append( 	 f1[x].split()[2].strip()) 
	
	#if local_time in time:
	#	print("Trace File Error: Time overlapping for " + f1[x].split()[0].strip())
	#else:

if sort_enable == 1:
	original_time = []
	original_time = copy.copy(time)
	time.sort()
	
	print("original_time: \n " + str(original_time))
	print("time: \n " + str(time))
	
	position = []
	
	for i in range(0, len(original_time)):
		for j in range(0,len(time)):
			if original_time[i] == time[j]:
				position.append(j)
	
	for i in position:
		print(i)
	
	for x in range(0, len(time)):
		for y in range(0, len(position)):
			if x == position[y]:
				time_final.append(original_time[y])
				operation_final.append(operation[y])
				address_final.append(address[y])
		#time_final.append(original_time[position[x]])
		#operation_final.append(operation[position[x]])
		#address_final.append(address[position[x]])
	
else:
	time_final = time
	operation_final = operation
	address_final = address

ip1 = open("ip_time.txt", "w")
ip2 = open("ip_oper.txt", "w")
ip3 = open("ip_addr.txt", "w")

for x in range(0, len(time_final)):
	ip1.write(str(time_final[x]) + "\n")
	ip2.write(operation_final[x] + "\n")
	ip3.write(address_final[x] + "\n")
ip1.close()
ip2.close()
ip3.close()

