#!/bin/bash

# Only the central page can be A4
# Odd page number without poster result in a failure because wtf are you printing ?

function quit(){
	rm out*.pdf
	exit $1
}

# TODO correct to A4 if needed
#pdfjam --outfile out.pdf --paper a4paper in.pdf

# Needs an input file
if [ $# != 2 ]; then
	echo "Usage $0 <file.pdf> <out.pdf>"
	quit -1
fi

# Page count
declare -i nbPages=`pdfinfo "$1" | grep 'Pages:' | cut -d ':' -f 2`
pdfseparate "$1" out%d.pdf
declare -i midPage=$nbPages-\($nbPages/2\) # this is integer division

# Is the central double page a poster ?
if [[ $(pdfinfo out${midPage}.pdf | grep 'A4') ]] ; then
	posterMode=1
else
	posterMode=0
fi
posterMode=0

# Defining page order
pageOrder=''
declare -i page=1
declare -i oppositePage=$nbPages
declare -i pagesLeft=$nbPages

while [ $pagesLeft -ne 0 ]; do
	if [ $pagesLeft -ge 4 ]; then
		declare -i next=$page+1
		declare -i nextOppositePage=$oppositePage-1
		pageOrder="$pageOrder out${oppositePage}.pdf out${page}.pdf out${next}.pdf out${nextOppositePage}.pdf"
		page=$page+2
		oppositePage=$oppositePage-2
	elif [ $pagesLeft -eq 3 ]; then
		pageOrder="$pageOrder out${page}.pdf out${oppositePage}.pdf"
		page=$page+1
		oppositePage=$oppositePage-1
	elif [ $pagesLeft -eq 2 ]; then
		pageOrder="$pageOrder out${page}.pdf out${page}.pdf"
		pageOrder="$pageOrder out${oppositePage}.pdf out${oppositePage}.pdf"
		page=$page+1
		oppositePage=$oppositePage-1
	elif [ $pagesLeft -eq 1 ]; then
		if [ $posterMode -eq 0 ] ; then
			quit -1
		fi
		page=$page+1
	fi
	pagesLeft=$oppositePage-$page+1
done


pdfunite $pageOrder result.pdf
pdfnup result.pdf --nup '2x1' -o "$2"

if [ $posterMode -eq 1 ] ; then
	pdfunite "$2" out${midPage}.pdf result.pdf
fi

quit 0
