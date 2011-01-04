#!/bin/bash
#
# Copyright (c) 2011, Olivier Bilodeau <olivier@bottomlesspit.org>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
# 
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY OLIVIER BILODEAU ``AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL OLIVIER BILODEAU OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

# These settings are tweaked for good results with my camera (Canon 7 mega-pixel)
BITRATE=50
AUDIO_CODEC=mp3lame
# older Canon A70 required AUDIO_CODEC=copy because the weird raw PCM properties prevented 
# transcoding into mp3lame

# change IFS to newline to handle special file names in for loop
OLDIFS=$IFS
IFS='
'

I=0

(
	for FILE in $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
	do
		# I couldn't find how to extract this out of the loop..
		NUM_FILES=${#@}

		let "I = $I + 1"

		# first pass
		echo "# File $I: First pass encoding"
		let "PROGRESS=(($I-1)*3+1)*100/(3*$NUM_FILES)"
		echo "$PROGRESS"
		cd /tmp
		mencoder "$FILE" -ovc x264 -x264encopts pass=1:bitrate=$BITRATE -nosound -o /dev/null 
		if [ $? -ne  0 ]; then
			zenity --error --text="Something went wrong, bailing out"
			exit
		fi
		
		# second pass
		echo "# File $I: Second pass encoding"
		let "PROGRESS=(($I-1)*3+2)*100/(3*$NUM_FILES)"
		echo "$PROGRESS"
		cd /tmp
		mencoder "$FILE" -ovc x264 -x264encopts pass=2:bitrate=$BITRATE -oac $AUDIO_CODEC -o "$FILE.tmp"
		if [ $? -ne 0 ]; then
			zenity --error --text="Something went wrong, bailing out"
			exit
		fi

		# renaming files and removing temp files
		echo "# File $I: Renaming and cleaning-up"
		let "PROGRESS=(($I-1)*3+3)*100/(3*$NUM_FILES)"
		echo "$PROGRESS"
		rm /tmp/divx2pass.log
		rm /tmp/divx2pass.log.mbtree

		mv "$FILE" "$FILE.orig"
		mv "$FILE.tmp" "$FILE"
	done
) | zenity --auto-close --progress --title="x264 encoding"

IFS=$OLDIFS
