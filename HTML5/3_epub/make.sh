#!/bin/bash

: << POD
=head1 DESCRIPTION

Build ePub

=cut
POD

readonly lv=1

readonly template=template
# readonly title=${template}/title.html
readonly meta=${template}/metadata.xml

# readonly html_dir=../1_download/lv${lv}
readonly html_dir=../2_process/lv${lv}
readonly dst_dir=build

## Prepare with templates
for file in ${title} ${meta} ; do
    cat ${file} \
    | sed "s/%NOW%/$(LANG=C date +'%b %d, %Y')/" \
    > ${file}_tmp
done

mkdir -p ${dst_dir}

## Build ePub
pandoc -f html \
${html_dir}/*.html \
-o ${dst_dir}/html5-lv${lv}.epub \
--epub-metadata ${meta}_tmp \
--epub-cover-image img/img_lv0${lv}.png
# --toc

# Clean temporary files
rm ${meta}_tmp

