#!/bin/sh
: << POD
=head1 DESCRIPTION

Build ePub
(http://www.asahi-net.or.jp/~kc7k-nd/)

=cut
POD

src_dir=src
html_dir=ya_onlispjhtml

pandoc -f html \
$src_dir/title.html \
$html_dir/preface.html \
$html_dir/extensibleLanguage.html \
$html_dir/functions.html \
$html_dir/functionalProgramming.html \
$html_dir/utilityFunctions.html \
$html_dir/returningFunctions.html \
$html_dir/functionsAsRepresentation.html \
$html_dir/macros.html \
$html_dir/whenToUseMacros.html \
$html_dir/variableCapture.html \
$html_dir/otherMacroPitfalls.html \
$html_dir/classicMacros.html \
$html_dir/generalizedVariables.html \
$html_dir/computationAtCompileTime.html \
$html_dir/anaphoricMacros.html \
$html_dir/macrosReturningFunctions.html \
$html_dir/macroDefiningMacros.html \
$html_dir/readMacros.html \
$html_dir/destructuring.html \
$html_dir/queryCompiler.html \
$html_dir/continuations.html \
$html_dir/multipleProcesses.html \
$html_dir/nondeterminism.html \
$html_dir/parsingWithATNs.html \
$html_dir/prolog.html \
$html_dir/objectOrientedLisp.html \
$html_dir/packages.html \
-o onlisp_j.epub \
--epub-metadata $src_dir/metadata.xml \
--epub-cover-image img/cover.jpg
