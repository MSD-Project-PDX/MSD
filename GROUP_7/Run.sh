IFS=$'\n'

cp Makefile_template Makefile

#list files in path
for line in `ls TRACEFILES/`
do
        filename=`echo $line|cut -d'.' -f1`

        #create a makefile for each case
        echo -e "\tvsim -c -do \"run -all\" mem_ctrl +ip_file=\"TRACEFILES/${line}\" +op_file=\"OUTPUTFILES/${filename}_op.out\" +refresh_en=1" >> Makefile
done

#run the makefile
make

#remove work directory and transcript file
rm -rf work transcript 
