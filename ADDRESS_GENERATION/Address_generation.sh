ip_file=$1
> /u/pmanthu/address1/output_file.txt
count=1
IFS=$'\n'

#generating binary code from bankgroup,bank,row and columns
for line in `cat /u/pmanthu/address1/main/${ip_file}.txt`
do
	echo "Reading $count line"
	bank_group=`echo $line |cut -d$'\t' -f1`
	bank=`echo $line |cut -d$'\t' -f2`
	row=`echo $line |cut -d$'\t' -f3`
	col=`echo $line |cut -d$'\t' -f4`
	#low_col=`echo $line |cut -d$'\t' -f5`
	#byte_sel=`echo $line |cut -d$'\t' -f6`
	low_col=0
	byte_Sel=0
	oper=`echo $line |cut -d$'\t' -f5`
	time=`echo $line |cut -d$'\t' -f6`
	if [ $oper == "Read" ];then
	oper_in=0
	elif [ $oper == "Write" ];then
	oper_in=1;
	else
	oper_in=2
	fi
	echo -n "$time $oper_in 0x|000" >> /u/pmanthu/address1/output_file.txt
	row_to_bin=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
	echo -n ${row_to_bin[$row]} >> /u/pmanthu/address1/output_file.txt
	col_to_bin=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
	echo -n ${col_to_bin[$col]} >> /u/pmanthu/address1/output_file.txt
	bank_to_bin=({0..1}{0..1})
	echo -n ${bank_to_bin[$bank]} >> /u/pmanthu/address1/output_file.txt
	bankgrp_to_bin=({0..1}{0..1})
	echo -n ${bankgrp_to_bin[$bank_group]} >> /u/pmanthu/address1/output_file.txt
	lowcol_to_bin=({0..1}{0..1}{0..1})
	echo -n ${lowcol_to_bin[$low_col]} >> /u/pmanthu/address1/output_file.txt
	bytesel_to_bin=({0..1}{0..1}{0..1})
	echo -n ${bytesel_to_bin[$byte_sel]} >> /u/pmanthu/address1/output_file.txt
	echo "" >> /u/pmanthu/address1/output_file.txt
	((count++))
done

#generating hex values from binary code
> /u/pmanthu/address/output_preval.txt
> /u/pmanthu/address/output.txt
> /u/pmanthu/address/output_final.txt
IFS=$'\n'

for line1 in `cat /u/pmanthu/address1/output_file.txt`
do
pre_val=`echo $line1|cut -d'|' -f1`
echo "$pre_val" >> /u/pmanthu/address/output_preval.txt
line=$`echo $line1|cut -d'|' -f2`
count=0
        for bit in `echo $line |sed -e 's/\(.\)/\1\n/g'`
        do
                echo -n $bit >> /u/pmanthu/address/bin_file.txt
                        if [ $count -eq 3 ];then
                        bin_num=`cat /u/pmanthu/address/bin_file.txt`
                        bin_code=`cat /u/pmanthu/address/hex_to_bin_def.txt |grep "${bin_num}$"|cut -d'|' -f1`
                        echo -n "$bin_code" >> /u/pmanthu/address/output.txt
                        > /u/pmanthu/address/bin_file.txt
                        count=0
                        else
                        ((count++))
                        fi
        done
        echo "" >> /u/pmanthu/address/output.txt
done
paste -d'|' /u/pmanthu/address/output_preval.txt /u/pmanthu/address/output.txt > /u/pmanthu/address/output_final.txt
cat /u/pmanthu/address/output_final.txt|sed 's/|//g' > /u/pmanthu/address1/main/${ip_file}_output.txt

