#!/bin/bash

: << POD
=head1 DESCRIPTION

Build ePub

=cut
POD

readonly color=silver
readonly subjects=( management knowledge development )

readonly template=template
readonly title=${template}/title.html
readonly meta=${template}/metadata.xml

readonly dst_dir=build
readonly html_dir=../2_process/${color}

# nkf --overwrite -w -Lu $html_dir/**/*.html &&

## Prepare with templates
for file in ${title} ${meta} ; do
    cat ${file} \
    | sed "s/%NOW%/$(LANG=C date +'%b %d, %Y')/" \
    > ${file}_tmp
done

body="${title}_tmp"
for sub in ${subjects[*]} ; do
    body="$body ${template}/${color}/h1_${sub}.html ${html_dir}/${sub}/*.html"
done

mkdir -p ${dst_dir}

## Build ePub
pandoc -f html \
${body} \
-o ${dst_dir}/ossdb-${color}.epub \
--epub-metadata ${meta}_tmp \
--epub-cover-image img/ossdb-${color}.jpg
# --toc

# Clean temporary files
rm ${title}_tmp ${meta}_tmp

