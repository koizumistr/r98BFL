#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Usage: $(basename "$0") betafile"
    exit
fi

is_not_zero() {
    local file="$1"
    local size="$2"

    if ! cmp -s -n "$size" "$file" /dev/zero; then
	return 0
    fi
    return 1
}

fname=$(basename $1)
stem=${fname%.*}
fullpath=$(dirname $1)/$stem

pdif=0
bdif=0
# .r1, .g1, .b1, .e1 files
for file in ${fullpath}.[RrGgBbEe]1; do
    if is_not_zero "$file" 32000; then
	bdif=1
	break
    fi
done

# .rgb file
for file in ${fullpath}.[rR][gG][bB]; do
    if is_not_zero "$file" 48; then
	pdif=1
	break
    fi
done

case "${bdif}${pdif}" in
    "00")
	msg="まっくろ"             #  black
	ret=0
	;;
    "01")
	msg="palのみ設定されている"  #  only palette set
	ret=1
	;;
    "10")
	msg="palが設定されてない"   #  palette not set
	ret=2
	;;
    "11")
	msg="何か描かれている"      # something painted
	ret=3
	;;
esac

echo "${fullpath}: ${msg}"
exit $ret
