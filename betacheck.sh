#!/bin/sh

if [ $# -lt 1 ]; then
    echo "usage:" $0 "betafile"
    exit
fi

temp_beta=$(mktemp /tmp/beta_XXXXXX) || exit 1
temp_pal=$(mktemp /tmp/pal_XXXXXX) || exit 1
head -c 32000 /dev/zero > $temp_beta
head -c 48 /dev/zero > $temp_pal

fname=$(basename $1)
stem=${fname%.*}
fullpath=$(dirname $1)/$stem

pdif=0
bdif=0
# .r1, .g1, .b1, .e1 files
for file in ${fullpath}.[RrGgBbEe]1; do
    diff -s $file $temp_beta > /dev/null
    case $? in
	0)
	    echo "same" > /dev/null ;;
	1)
	    echo "differ" > /dev/null ; bdif=1 ;;
	*)
	    echo "error" ;;
    esac
done

# .rgb file
for file in ${fullpath}.[rR][gG][bB]; do
    diff -s $file $temp_pal > /dev/null
    case $? in
	0)
	    echo "same" > /dev/null ;;
	1)
	    echo "differ" > /dev/null ; pdif=1 ;;
	*)
	    echo "error" ;;
    esac
done

if [ $bdif -eq 0 ] && [ $pdif -eq 0 ]; then
    msg="まっくろ"            #  black
elif [ $bdif -eq 0 ]; then
    msg="palのみ設定されている" #  only palette set
elif [ $pdif -eq 0 ]; then
    msg="palが設定されてない" #  palette not set
else
    msg="何か描かれている"    # something painted
fi

echo $fullpath: $msg

rm $temp_beta $temp_pal
