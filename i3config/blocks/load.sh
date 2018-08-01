#!/bin/sh

script_dir=/usr/lib/i3blocks
tmp_dir=/tmp/i3blocks/load
sw_file=$tmp_dir/full
label_file=$tmp_dir/label
pipe_cpu=$tmp_dir/cpu
pipe_mem=$tmp_dir/mem
pipe_disk=$tmp_dir/disk
pipe_net=$tmp_dir/net

mkdir -p $tmp_dir

function write_values {
	# write in background (for the next execution)
	top -bn1 | grep Cpu | tr -s " " | cut -d ' ' -f8 | sed -E 's/\,./%/' > $pipe_cpu &
	echo $($script_dir/memory | head -1) > $pipe_mem &
	echo $($script_dir/disk | head -1) > $pipe_disk &
	echo $($script_dir/bandwidth | head -1) > $pipe_net &
}

function cpu {
	cat $pipe_cpu | sed 's/\...//'
}

function mem {
        cat $pipe_mem
}

function disk {
        cat $pipe_disk
}

function net {
	NET=$(cat $pipe_net)
        NET="${NET/IN/}"
        NET="${NET/OUT/}"	
        NET="${NET/down/}"
	printf "$NET"
}

function print_values {
	if [[ -f $sw_file ]]; then
	        # output
	        if [[ -f $label_file ]]; then
	                echo "CPU $(cpu) – MEM $(mem) – DSK $(disk) – NET $(net)"
	        else
	                echo "$(cpu) $(mem) $(disk) $(net)"
	        fi
	else
	        #exit
	        /usr/lib/i3blocks/load_average
	fi
}

case "$BLOCK_BUTTON" in
	1)
		if [[ -f $sw_file ]]; then
			rm $sw_file
		else
			touch $sw_file
		fi
		print_values
		;;
	2|3)
		if [[ -f $label_file ]]; then
			rm $label_file
		else
			touch $label_file
		fi
		print_values
		;;
	*)
		print_values
		write_values
		;;
esac
