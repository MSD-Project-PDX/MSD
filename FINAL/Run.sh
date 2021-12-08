IFS=$'\n'
#list files in path
list=`ls ../TESTCASES/tracefile/`
for line in `ls ../TESTCASES/tracefile/`
do
	filename=`echo $line|cut -d'.' -f1`
	
	#create a makefile for each case
	cp Makefile_template Makefile
	sed -i "s/fp.txt/..\/TESTCASES\/tracefile\/$line/g" Makefile
	
	#run the makefile
	make
	
	#move the output file
	mv output_file.txt ../TESTCASES/outputfile/${filename}_op.out
done

#copy template to old file
cp Makefile_template Makefile

