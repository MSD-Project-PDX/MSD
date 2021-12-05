paste -d'|' /u/pmanthu/address1/main/request1_output.txt /u/pmanthu/address1/main/request2_output.txt /u/pmanthu/address1/main/request3_output.txt > /u/pmanthu/address1/main/file_output_final.txt
IFS=$'\n'
count=1
for line in `cat /u/pmanthu/address1/main/file_output_final.txt`
do
	va1=`echo $line |cut -d'|' -f1`
	va2=`echo $line |cut -d'|' -f2`
	va3=`echo $line |cut -d'|' -f3`
	echo "$va1" > /u/pmanthu/address1/main/tracefile/tracefile_${count}.txt
	echo "$va2" >> /u/pmanthu/address1/main/tracefile/tracefile_${count}.txt
	echo "$va3" >> /u/pmanthu/address1/main/tracefile/tracefile_${count}.txt
	((count++))
done

