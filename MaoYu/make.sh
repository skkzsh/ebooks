#!/bin/sh
: << POD
=head1 DESCRIPTION

Build ePub

=cut
POD

src_dir=src
html_dir=../0_download

pandoc -f html \
$src_dir/title.html \
$html_dir/*.html \
-o maoyu.epub \
--epub-metadata $src_dir/metadata.xml \
--epub-cover-image img/cover.jpg
