#!/bin/bash

readonly color=silver

readonly h2='<h2>.*の例題解説「[^-]*-\s*(.*)」</h2>'
readonly h2_after='<h2>\1</h2>'
readonly example='※この例題.*異なります。'
readonly url='//oss-db.jp'

readonly subjects=( management knowledge development )
for sub in ${subjects[*]} ; do
    mkdir -p $color/$sub
    echo [$sub]

    for html_file in ../1_download/$color/$sub/*.html ; do
        basename $html_file &&

        cat $html_file \
        | sed -r "s!${h2}!${h2_after}!" \
        | sed "s!${example}!!" \
        | sed "s!$url!https:$url!" \
        > $color/$sub/$(basename $html_file)
    done

done

