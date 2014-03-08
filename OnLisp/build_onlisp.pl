#!/usr/bin/env perl

=head1 DESCRIPTION

Omit from 'on Lisp'

=cut

use strict;
use warnings;
# use 5.010;
# use utf8; # XXX
# $|++;

use encoding 'utf-8'; # XXX
# binmode STDOUT, ":utf8"; # XXX

use Encode qw( encode_utf8 );
use HTML::Entities qw( encode_entities decode_entities );
use Path::Class qw( file );
use HTML::TreeBuilder;
use Parallel::ForkManager;

# XXX: Encoding

my $max_ps = 4;

## Directories
my $src_dir = 'onlispjhtml';
my $dst_dir = 'ya_onlispjhtml';

&omit_para( $max_ps, $src_dir, $dst_dir );

sub omit_para {
    my ( $max_ps, $src_dir, $dst_dir ) = @_;

    mkdir $dst_dir unless -d $dst_dir;

    ## Sections
    my @secs = qw(
        preface
        extensibleLanguage
        functions
        functionalProgramming
        utilityFunctions
        returningFunctions
        functionsAsRepresentation
        macros
        whenToUseMacros
        variableCapture
        otherMacroPitfalls
        classicMacros
        generalizedVariables
        computationAtCompileTime
        anaphoricMacros
        macrosReturningFunctions
        macroDefiningMacros
        readMacros
        destructuring
        queryCompiler
        continuations
        multipleProcesses
        nondeterminism
        parsingWithATNs
        prolog
        objectOrientedLisp
        packages
    );

    my $pm = Parallel::ForkManager->new($max_ps);

    for (@secs) {
        my $pid = $pm->start and next; # Do the fork

        &omit($src_dir, $dst_dir, $_);

        $pm->finish; # Do the exit in the child process
    }

    $pm->wait_all_children;
}

sub omit {
    my ($src_dir, $dst_dir, $sec) = @_;

    ## Parse HTML
    my $tree = HTML::TreeBuilder->new;
    $tree->parse_file( $src_dir . '/' . $sec . '.html' );
    # $tree->parse_file( file( $src_dir, $sec . '.html' ) );

    ## Omit Content
    $_->delete for (
        $tree->find('head'),
        $tree->find('hr'),
        $tree->find('a'),
        $tree->find('address'),
    );

    ## Write to file
    open my $fh, '>', file( $dst_dir, $sec . '.html' )
        or die $!;
    print $fh encode_utf8 decode_entities $tree->as_HTML;
    # print $fh decode_entities $tree->as_HTML;
    # print $fh $tree->as_HTML;
    close $fh or die $!;

    ## Output progress
    print $sec, "\n";

    $tree = $tree->delete;
}
