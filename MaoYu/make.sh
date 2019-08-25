#!/bin/sh
: << POD
=head1 DESCRIPTION

Build ePub

=cut
POD

readonly src_dir=src
readonly html_dir=download

# Patch
sed -i -e 's/^.*<div id="Box">//' -e 's/id="header2"//' $html_dir/*.html &&

pandoc -f html \
$src_dir/title.html \
$html_dir/*.html \
-o maoyu.epub \
--epub-metadata $src_dir/metadata.xml \
--epub-cover-image img/cover.jpg \
--toc
