#!/usr/bin/env perl

=head1 DESCRIPTION

Get HTML files extracted from LPIC exercise pages
(Update every other Friday)

=cut

use strict;
use warnings;
use 5.010;
# use utf8; # XXX
# $|++;

# use encoding 'utf-8'; # XXX
# binmode STDOUT, ":utf8"; # XXX

use Encode qw( encode );
use HTML::Entities qw( decode_entities );
use File::Basename qw( basename );
use Path::Class qw( file dir );
use WWW::Mechanize;
use HTML::TreeBuilder;
# use Web::Scraper;
use Parallel::ForkManager;
use POSIX qw( strftime );

# XXX: Encoding

# my @exams = ( 101, 102, 201, 202, 301 .. 304 );
# my @exams = ( 101, 102, 201, 202 );
my @exams = ( 101, 102 );
my $max_ps = 4;

&get_from_exams( $max_ps, @exams );


## Get HTML files extracted from exercise pages
sub get_from_exams {
    my ( $max_ps, @exams ) = @_;

    my $pm = Parallel::ForkManager->new($max_ps);

    for (@exams) {
        my $pid = $pm->start and next; # Do the fork

        &get_from_exam($_);

        $pm->finish; # Do the exit in the child process
    }

    $pm->wait_all_children;
}

## Get HTML files extracted from exam
sub get_from_exam {
    my $exam = shift;

    mkdir $exam unless -d $exam;

    my $mech = WWW::Mechanize->new( autocheck => 1 );
    ## Go to exam list
    my $url= 'http://www.lpi.or.jp/ex';
    $mech->get($url);
    ## Go to exercise list for exam
    $mech->follow_link( url_regex => qr!ex/$exam! );
    # say $mech->uri(); exit;    # Debug

    ## Get all links of exercises
    my @links = $mech->find_all_links( url_regex => qr!ex_\d*! );

    ## Get HTML files extracted from exercises
    for ( 1 .. @links ) {

        my $link = $links[$_ - 1];
        # say $link->url; exit;    # Debug

        my $max = 500;
        my $prefix = sprintf( "%03d", $max - @links + $_ );
        my $file = file( $exam, $prefix . '_' . basename $link->url );

        ## Get only when outdated
        my $check = &check_update( $_, $exam, $file, @links );
        if    ( $check eq 'all-updated' ) { return; }
        elsif ( $check eq 'this-updated' ) { next; }

        ## Go to exercise
        $mech->get( $link->url );
        # say $mech->content; exit;    # Debug

        ## Extract HTML
        my ( $extracted_html, $title ) = &extract_html($mech->content);

        ## Output progress
        # print '[', $num, '/', scalar @links, '] ',
        #     encode( 'utf-8', $title ), " " x 50, "\r";
        my $num = sprintf( "%03d", $_ );
        my $sum = sprintf( "%03d", scalar @links );
        print '[', $exam, '] ', '(', $num, '/', $sum, ') ',
            encode( 'utf-8', $title ), "\n";

        ## Write to file
        open my $fh, '>', $file or die $!;
        print $fh encode( 'utf-8', $extracted_html );
        # print $fh $extracted_html;
        close $fh or die $!;
    }

    # say 'Complete!', ' ' x 100;
    print $exam, ": Complete!\n";
}

## Check update
sub check_update {
    my ( $num, $exam, $file, @links ) = @_;

    if ( -s $file ) {
        my @local_files = <$exam/*'.shtml'>;
        # say @local_files; exit;    # Debug

        if ( $num == 1 and @links == @local_files ) {
            print $exam, ": Already up-to-date\n";
            return 'all-updated';
        }
        else {
            # print $file, ": Already builded\n";
            return 'this-updated';
        }

    }
    else {
        return 'this-outdated';
    }

    # else {
    #     my $backup = 'backup';
    #     mkdir $backup unless -d $backup;
    #     my $today = strftime '%y%m%d', localtime;
    #     rename $exam, dir( $backup, $today . '_' . $exam );
    #     mkdir $exam unless -d $exam;
    # }
}

## Extract HTML
sub extract_html {
    my $html = shift;

    ## Parse HTML
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($html);

    ## Extract Content
    my @tags = (
        $tree->look_down( _tag => 'h2', class => 'title04h2' ),
        $tree->look_down( 'class', 'exercise' ),
        $tree->look_down( _tag => 'h3', class => 'style01' ),
        $tree->look_down( 'class', 'answer' ),
        # $tree->find('h2')->look_down( 'class', 'title04h2' ),
        # $tree->find('h3')->look_down( 'class', 'style01' ),
    );

    ## Convert to HTML
    my $enc_extracted_html = '';
    $enc_extracted_html .= $_->as_HTML . "\n" for @tags;

    # my @enc_extracted_htmls = map { $_->as_HTML . "\n" } @tags;
    # my $enc_extracted_html = "@enc_extracted_htmls";

    # print @enc_extracted_htmls; exit;    # Debug
    # print $enc_extracted_html; exit;    # Debug

    my $title = $tags[0]->as_text;

    $tree = $tree->delete;

    my $extracted_html = decode_entities($enc_extracted_html);
    # say $extracted_html; exit;    # Debug

    ( $extracted_html, $title );
}
