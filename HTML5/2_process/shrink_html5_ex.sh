#!/bin/bash

readonly lv=1

# FIXME: entityに対応させる
readonly range='出題範囲.*からの出題です。'
readonly example='※この例題は実際の.*とは異なります。'
readonly detail='出題範囲の詳細'
readonly href='href="/'
readonly href_after='href="https://html5exam.jp/'


mkdir -p lv${lv}

for html_file in ../1_download/lv${lv}/*.html ; do
    basename $html_file &&

    cat $html_file \
    | sed "s!$href!$href_after!g" \
    > lv${lv}/$(basename $html_file)
    # | sed "s!${range}!!" \
    # | sed "s!${example}!!" \
    # | sed "s!${detail}!!" \
done

