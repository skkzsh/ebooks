#!/bin/sh
: << POD
=head1 DESCRIPTION

Build ePub

=cut
POD

## Parameters
level=$1

case ${level} in
    1) nums='1 2' ;;
    2) nums='1 2' ;;
    3) nums='1 2 3 4' ;;
    *) ;;
esac

src=template
title=${src}/title.html
h1=${src}/h1.html
meta=${src}/metadata.xml
dst=build

## Prepare with templates
cat ${title} \
| sed "s/%NOW%/`LANG=C date +'%b %d, %Y'`/" \
| sed "s/%NUM%/${level}/" \
> ${title}_tmp

sed "s/%NUM%/${level}/" $meta > ${meta}_tmp

body=''
for n in ${nums} ; do
    sed "s/%NUM%/${level}0${n}/" ${h1} > ${h1}_tmp_$n
    body="$body ${h1}_tmp_${n} ../1_download/${level}0${n}/*.shtml"
done

# echo "$body"; exit # Debug
# echo $body; exit # Debug

[ -d ${dst} ] || mkdir ${dst}

## Build ePub
pandoc -f html \
${title}_tmp \
${body} \
-o ${dst}/lpic-${level}.epub \
--epub-cover-image img/lpic-${level}.jpeg \
--epub-metadata ${meta}_tmp

## Clean temporary files
rm ${title}_tmp ${meta}_tmp ${h1}_tmp_?

# echo "Builded!"
