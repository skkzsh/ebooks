#!/bin/bash
: << POD
=head1 DESCRIPTION

Build ePub

=cut
POD

## Parameters
readonly level=$1
readonly src=../2_process

case ${level} in
    1) readonly nums=( 1 2 ) ;;
    2) readonly nums=( 1 2 ) ;;
    3) readonly nums=( 1 2 3 4 ) ;;
    *) ;;
esac

readonly template=template
readonly title=${template}/title.html
readonly h1=${template}/h1.html
readonly meta=${template}/metadata.xml
readonly dst=build

## Prepare with templates
for file in ${title} ${meta} ; do
    cat ${file} \
    | sed "s/%NOW%/$(LANG=C date +'%b %d, %Y')/" \
    | sed "s/%NUM%/${level}/" \
    > ${file}_tmp
done

body="${title}_tmp"
for n in ${nums[*]} ; do
    sed "s/%NUM%/${level}0${n}/" ${h1} > ${h1}_tmp_${n}
    body="$body ${h1}_tmp_${n} ${src}/${level}0${n}/*.shtml"
done

# echo "$body"; exit # Debug
# echo $body; exit # Debug
# cat $body > sum.html ; exit # Debug

mkdir -p ${dst}

## Build ePub
pandoc -f html \
${body} \
-o ${dst}/linuc-${level}.epub \
--epub-cover-image img/linuc-${level}.png \
--epub-metadata ${meta}_tmp
# --toc

# -o ${dst}/linuc-${level}_`date +'%y%m%d'`.epub \

## Clean temporary files
rm ${title}_tmp ${meta}_tmp ${h1}_tmp_?

# echo "Builded!"
