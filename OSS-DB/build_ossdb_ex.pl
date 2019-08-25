#!/usr/bin/env perl

# NOTE
# wget -np -r http://oss-db.jp/sample/

=head1 DESCRIPTION

Get HTML files extracted from OSS-DB exercise pages
(Update every other Friday)

=cut

use strict;
use warnings;
# use 5.010;
# use utf8; # XXX
# binmode STDOUT, ":utf8"; # XXX

use Encode qw( encode_utf8 );
use HTML::Entities qw( decode_entities );
use File::Basename qw( basename dirname );
use Path::Class qw( file dir );
use File::Path qw( mkpath );
use HTML::TreeBuilder;
use IO::HTML qw( html_file );
# use Web::Scraper;
use Parallel::ForkManager;

my $max_ps = 8;

## Directories
my $dst_prefix_dir = dir '1_download';

&extract_para( $max_ps, $dst_prefix_dir );

sub extract_para {
    my ( $max_ps, $dst_prefix_dir ) = @_;

    my $pm = Parallel::ForkManager->new($max_ps);

    my $color = 'silver';
    my $src_dir = dir 'oss-db.jp', 'sample';
    my @local_dirs = glob "$src_dir/$color*";  # FIXME
    # print @local_dirs; exit;    # Debug
    for (@local_dirs) {
        my $pid = $pm->start and next; # Do the fork

        &extract_dir($_, $dst_prefix_dir);

        $pm->finish; # Do the exit in the child process
    }

    $pm->wait_all_children;
}

sub extract_dir {
    my ($src_dir, $dst_prefix_dir) = @_;

    my @list = split /_/, basename $src_dir;
    my $dst_dir = dir $dst_prefix_dir, $list[0], $list[1];
    mkpath $dst_dir;

    my @local_files = glob "$src_dir/*";
    # print @local_files; exit;    # Debug

    for (@local_files) {
        &extract_file($_, $dst_dir);
    }
}

sub extract_file {
    my ($src_file, $dst_dir) = @_;
    my $file = basename $src_file;

    ## Parse HTML
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_file( html_file $src_file );

    # FIXME
    ## Omit JS
    $_->delete for (
        $tree->find('script'),
    );

    ## Extract Content
    my $title = $tree->find('title');
    my $h2_title = $tree->find('h2'); # FIXME
    my @tags = (
        # $title,
        $h2_title,
        $tree->look_down( 'class', qr/sample_example/ ),
    );

    ## Convert to HTML
    my $enc_extracted_html = '';
    $enc_extracted_html .= $_->as_HTML . "\n" for @tags;

    # my @enc_extracted_htmls = map { $_->as_HTML . "\n" } @tags;
    # my $enc_extracted_html = "@enc_extracted_htmls";

    # print @enc_extracted_htmls; exit;    # Debug
    # print $enc_extracted_html; exit;    # Debug

    ## Write to file
    open my $fh, '>', file( $dst_dir, $file . '.html')
        or die $!;
    print $fh encode_utf8 decode_entities $enc_extracted_html;
    close $fh or die $!;

    ## Output progress
    print encode_utf8 $title->as_text, "\n";

    $tree = $tree->delete;
}
