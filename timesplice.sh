#!/bin/bash -x 
lastsec=0
fno=0
output=/tmp/timesplice.$$
defaultspeed=60.0
CRF=20
intfmt=MP4
opts="-strict -2 -y"
file=""
isuffix=""
titlet=0
titletime=2
titlesize=4
titlecolor=black

VF="copy"
TSPEC="copy"

#while true; do 
while read startsec endsec speed; do  
        echo STARTSEC $startsec ENDSEC $endsec SPEED $speed
    if (echo $startsec | grep '^#'); then continue; fi
	if [[ "$startsec" == "" ]]; then continue; fi
	if [[ "$startsec" == "END" ]]; then break; fi
    if [[ "$startsec" == "DEFAULT" ]]; then defaultspeed=$endsec; continue; fi
	if [[ "$startsec" == "TITLE_COLOR" ]]; then titlecolor=$endsec; continue; fi
	if [[ "$startsec" == "TITLE_SIZE" ]]; then titlesize=$endsec; continue; fi
	if [[ "$startsec" == "TITLE_TIME" ]]; then titletime=$endsec; continue; fi
	if [[ "$startsec" == "TITLE_START" ]]; then titlet=$endsec; continue; fi
	if [[ "$startsec" == "VF" ]]; then VF=$endsec; continue; fi
	
	if [[ "$startsec" == "TITLE" ]]; then 
		titlestart=$titlet
		titleend=$(($titlet + $titletime))
		titlet=$titleend
		T="$endsec $speed"
		TSPEC="${TSPEC},drawtext=fontsize=(h/${titlesize}):fontcolor=${titlecolor}:fontfile=FreeSerif.ttf:text=\'$T\':y=h/2:x=w/2-text_w/2:alpha=.5:enable=between\(t\\,${titlestart}\\,${titleend}\)"
		continue;
	fi

	if [[ "$startsec" == "OPTS" ]]; then opts="$endsec $speed"; continue; fi
	if [[ "$startsec" == "INPUT_SUFFIX_OVERRIDE" ]]; then isuffix="$endsec"; continue; fi
	if [[ "$startsec" == "OUTPUT" ]]; then out="$endsec"; continue; fi 
	if [[ "$startsec" == "INPUT_FOLDER" ]]; then INPUT_FOLDER="$endsec"/; continue; fi
	if [[ "$startsec" == "INPUT" ]]; then
		if [[ "$file" != "" ]] && (($defaultspeed > 0)); then 
			fno=$(($fno + 1))
			snipspeed  $lastsec 999999 $defaultspeed "$file" "$output.${fno}.$intfmt"	< /dev/null
		fi
		file="${INPUT_FOLDER}$endsec"; 
		if [[ "$isuffix" != "" ]]; then
			file=`echo $file | sed "s/\.[^.]*/.$isuffix/"`
			file=`echo $file | sed "s/GH/GL/"`
		fi
		lastsec=0; 
		continue; 
	fi
	if [[ "$speed" == "" ]]; then speed=1; fi
	if (($startsec > $lastsec && $defaultspeed > 0)); then 
		fno=$(($fno + 1))
		snipspeed $lastsec $startsec $defaultspeed "$file" "$output.$fno.$intfmt" < /dev/null
	fi 
	if (($startsec >= $lastsec)); then 
		lastsec=$endsec
		if [[ "$speed" != "SKIP" ]]; then 
			fno=$(($fno + 1))
			snipspeed $startsec $endsec $speed "$file" "$output.$fno.$intfmt"	< /dev/null
		fi 
	fi
done

if (($defaultspeed > 0)); then 
	fno=$(($fno + 1))
	snipspeed  $lastsec 999999 $defaultspeed "$file" "$output.${fno}.$intfmt"	 < /dev/null
fi 

cat /dev/null > $output.$intfmt
for (( f=1; f <= $fno ; f++ )); do
   echo file $output.${f}.$intfmt >> $output.txt
done

ffmpeg -safe 0 -f concat -i $output.txt -vf "${VF},${TSPEC}" -crf $CRF -ab 128k -y $opts $out

#rm "$output".*


exit
# Everything below is a sample input file 
# Name of output file
OUTPUT /tmp/out.mp4

# Default speed for portions of video files that aren't explicitly specified
# Use 0 to not show unspecified portions at all
DEFAULT 200

# Override input file suffixes, to use LRV instead of MP4 
INPUT_SUFFIX_OVERRIDE LRV


# Title text specifications 
TITLE_START 1  			# Start time of titles 
TITLE_TIME 2   			# Seconds per title line 
TITLE Lazy     
TITLE_COLOR red 		# Change title colors
TITLE Low-Angle 	
TITLE_SIZE 2    		# Change title size (smaller is bigger) 
TITLE Pow       		 


# List next input file 
INPUT GH010119.MP4

DEFAULT 0   # skip unspecified portions 
# Explicit sections of video to show:
# <start seconds> <end seconds> [<speed>]
211 216
DEFAULT 200 
46 50
182 185
262 266
350 354
390 392
920 922

INPUT GH010120.MP4
314 317

INPUT GH010119.MP4
61 67
DEFAULT 0 


# You can use END to stop processing early 
END



