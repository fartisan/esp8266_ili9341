#!/bin/bash
#
# Print data, rodata, bss sizes in bytes
#
# Usage: 
# OBJDUMP=../xtensa-lx106-elf/bin/xtensa-lx106-elf-objdump ./mem_usage.sh app.out [total_mem_size]
#
# If you specify total_mem_size, free heap size will also be printed
# For esp8266, total_mem_size is 81920
#

. setpath
OBJDUMP=$SDK_BIN/xtensa-lx106-elf-objdump

if [ -z "$OBJDUMP" ]; then
	echo "Please set OBJDUMP"
	exit 1
fi

if [ -z "$1" ]
then
	echo "Usage $0 ELF_file"
	echo "Example: $0 build/demo/elf"
	exit 1
fi
 
objdump=$OBJDUMP
app_out=$1

#ESP8266 internal RAM size is fixed to 81920
total_size=81920
#total_size=$2
export used=0
 
function print_usage()
{
	name=$1
	start_sym="_${name}_start"
	end_sym="_${name}_end"
 
	objdump_cmd="$objdump -t $app_out"	
	addr_start=`$objdump_cmd | grep " $start_sym" | cut -d " " -f1 | tr 'a-f' 'A-F'`
	addr_end=`$objdump_cmd | grep " $end_sym" | cut -d " " -f1 | tr 'a-f' 'A-F'`
	export size=`printf "ibase=16\n$addr_end - $addr_start\n" | bc`
	export used=$((used + size))
	echo $name: $size
}
 
print_usage data
print_usage rodata
print_usage bss
echo total: $used
if [[ ! -z "$total_size" ]]; then
	echo free: $(($total_size-$used))
fi
