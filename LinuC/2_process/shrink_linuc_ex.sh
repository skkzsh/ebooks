#!/bin/bash

readonly level=$1
case $level in
    1) readonly dirs=( 101 102 ) ;;
    2) readonly dirs=( 201 202 ) ;;
    3) readonly dirs=( 301 302 303 304 ) ;;
    *) readonly dirs=( $level ) ;;
esac

readonly solve='今回は.*解いてみます。'
readonly example='※この例題.*異なります。'
readonly brtag='<br */><br */>'
readonly pre_wrap='<pre wrap="">'
readonly ums_tooltip='<div id="UMS_TOOLTIP".*;"></div>'

for dir in ${dirs[*]} ; do
    mkdir -p $dir

    for html_file in ../1_download/$dir/*.shtml ; do
        basename $html_file &&

        cat $html_file \
        | sed "s!${pre_wrap}!!" \
        | sed "s!${ums_tooltip}!!" \
        | sed "s!${solve}${brtag}!!" \
        | sed "s!${example}${brtag}!!" \
        | sed "s!${solve}!!" \
        | sed "s!${example}!!" \
        > $dir/$(basename $html_file)
    done

done

# for dir in 101 102 201 202 301 302 303 304 ; do
