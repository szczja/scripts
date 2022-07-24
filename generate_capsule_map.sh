#!/bin/bash
# gemlog/2022-07-10-Ancient-Domains-Of-Mystery.gmi:tags: #game, #adom, #howto

OUTPUT="tags.gmi"
echo "" > $OUTPUT

# reading files with "tags: <tag1>, <tag2>, ... <tagN>" format to an array
files=()
while read f; do
	files+=("$f")
done < <(grep "tags:" gemlog/*.gmi)	

# process the array
for f in "${files[@]}"
do
	# convert line to "<filename>, <tag1>, <tag2>, ... <tagN>" format
	f=${f//":tags:"/","}

	tags=($f)
	nt=0
	for t in "${tags[@]}"
	do
		let "nt+=1"
		# <filename>
		if [ $nt == 1 ]; then
			link=$t
			# remove coma/last char
			if [[ $link =~ ^.*,$ ]]; then
				link=${link::-1}
			fi
		# <tag1>, <tag2>, ... <tagN>
		else
			# remove coma/last char
			if [[ $t =~ ^.*,$ ]]; then
				t=${t::-1}
			fi
			echo "=> $link $t" >> $OUTPUT
		fi
	done
done

# sort file by tag name
sort -k3 $OUTPUT -o $OUTPUT
