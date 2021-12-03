> /u/pmanthu/address1/output_file.txt
count=0
IFS=$'\n'

#generating binary code from bankgroup,bank,row and columns
for line in `cat /u/pmanthu/address1/input_file.txt`
do
	bank_group=`echo $line |cut -d$'\t' -f1`
	bank=`echo $line |cut -d$'\t' -f2`
	row=`echo $line |cut -d$'\t' -f3`
	col=`echo $line |cut -d$'\t' -f4`
	low_col=`echo $line |cut -d$'\t' -f5`
	byte_sel=`echo $line |cut -d$'\t' -f6`
	echo -n "000" >> /u/pmanthu/address1/output_file.txt
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
for line in `cat /u/pmanthu/address1/output_file.txt`
do
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

cat /u/pmanthu/address/output.txt|sed 's/^/0x/g'

