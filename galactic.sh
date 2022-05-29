#!/bin/bash

CAPSULES=($(cat galactic.dat | awk '{ print $1 }'))
EMPTY="."
declare -A tab
TRAVEL_R=(-1 -1 -1 0 0 1 1 1)
TRAVEL_C=(-1 0 1 -1 1 -1 0 1)
N_ROWS=25
N_COLS=80
let sr=$N_ROWS/2	# start row
let sc=$N_COLS/2	# start column

# Compute the position of given:
# $radius $distance $startig_row $starting_column $capsulename
# return:
#   1 capsule name displayed
#   0 capsule name not displayed
set_char() {

	r=$1
	d=$2
	sr=$3
	sc=$4
	capsulename=$5

	cr=$(awk "BEGIN {print int(sin(${r}*0.66)*(${d}*0.4+2.2)+${sr})}")	# current row = sin(radius) * distance + start row
	cc=$(awk "BEGIN {print int(cos(${r}*0.66)*(${d}*1.2+3.5)+${sc})}")	# current column = cos(radius) * distance + start column

	# truncate coordinates to given canvas	
	if [ $cr -le 1 ]; then 
		cr=1 
	fi
	if [ $cr -gt $N_ROWS ]; then 
		cr=$N_ROWS 
	fi
	if [ $cc -le 1 ]; then 
		cc=1 
	fi
	if [ $cc -gt $N_COLS ]; then 
		cc=$N_COLS 
	fi

	# detection of text collision
	draw=1
	for ((k=0;k<8;k++)) do
		let tcr=$cr+TRAVEL_R[$k]
		let tcc=$cc+TRAVEL_C[$k]
		if [ "${tab[$tcr,$tcc]}" != "$EMPTY" ]; then
			draw=0
			k=10
		fi
	done
	
	# if no collision then draw
	if [[ $draw -eq 1 ]]; then
		for ((k=0;k<8;k++)) do
			let tcr=$cr+TRAVEL_R[$k]
			let tcc=$cc+TRAVEL_C[$k]
			tab[$tcr,$tcc]=${capsulename:$k:1}
		done
		tab[$cr,$cc]="*"
		
		return 1	# capsule name displayed
	fi

	return 0	# capsule name not displayed
}

# Initialization galactic tab
for ((i=1;i<=N_ROWS;i++)) do
	for ((j=1;j<=N_COLS;j++)) do
		tab[$i,$j]=$EMPTY
	done
done

r=0			# radius
d=0			# distance
capsulenum=0		# capsule number

# Iterate through 24 capsule names, and compute galactic object positions
while [ $d -le 25 ]
do

	set_char $r $d $sr $sc ${CAPSULES[$capsulenum]}; exitcode=$?
	
	case $exitcode in
		1) ((capsulenum++))
          		;;
  		0)
          		;;
	esac

	((r+=3))
	((d++))
done

# Add noise
for ((i=1;i<=N_ROWS;i++)) do
	for ((j=1;j<=N_COLS;j++)) do
		if [ "${tab[$i,$j]}" == "$EMPTY" ]; then
			rnd=$(( $RANDOM % 100 + 1 ))
			if [[ $rnd -lt 3 ]]; then
				rndc=$(( $RANDOM % 3 + 1))
				case $rndc in
					1) tab[$i,$j]="+"
						;;
					2) tab[$i,$j]="'"
						;;
					3) tab[$i,$j]=":"
						;;
					4) tab[$i,$j]=","
				esac
			fi
		fi
	done
done

# Print galactic tab
for ((i=1;i<=N_ROWS;i++)) do
	#echo -en "$i\t"
	for ((j=1;j<=N_COLS;j++)) do
		echo -en "${tab[$i,$j]}"
	done
	echo -en "\n"
done
