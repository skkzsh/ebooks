#!/usr/bin/env perl

=head1 DESCRIPTION

Get HTML files extracted from Maoyu

=cut

use strict;
use warnings;
# use 5.010;
# use utf8; # XXX
# $|++;

# use encoding 'utf-8'; # XXX
# binmode STDOUT, ":utf8"; # XXX

use Encode qw( encode_utf8 );
use HTML::Entities qw( decode_entities );
use LWP::Simple qw( get );
use HTML::TreeBuilder;
use Parallel::ForkManager;

# XXX: Encoding

my $max_ps = 4;

&omit_para($max_ps);

sub omit_para {
    my $max_ps = shift;

    my $pm = Parallel::ForkManager->new($max_ps);

    ## Thread number
    my @nums = map { sprintf( "%02d", $_ ) } 1 .. 13;

    for (@nums) {
        my $pid = $pm->start and next; # Do the fork

        &omit($_);

        $pm->finish; # Do the exit in the child process
    }

    $pm->wait_all_children;
}

sub omit {
    my $num = shift;

    my $url = 'http://maouyusya2828.web.fc2.com';
    my $file = 'matome'. $num . '.html';

    ## Parse HTML
    my $tree = HTML::TreeBuilder->new;
    $tree->parse( get( $url . '/' . $file ) );

    ## Omit Content
    $_->delete for (
        $tree->find('head'),
        $tree->find('h3'),
        $tree->look_down('id', 'footer'),
        $tree->find('script'),
        $tree->find('img'),
    );

    ## Write to file
    open my $fh, '>', $file or die $!;
    print $fh encode_utf8 decode_entities $tree->as_HTML;
    # print $fh encode_utf8 $extracted_html;
    close $fh or die $!;

    ## Output progress
    print $num, "\n";

    $tree = $tree->delete;
}
