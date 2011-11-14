#!/usr/bin/perl
use lib 't/lib';
use Test::Class;

package Plosurin::Parser;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub parse {
    my $self = shift;
    my $str  = shift;

}
1;

package main;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use v5.10;
use Plosurin;
my $p   = new Plosurin::;
my $str = <<'TXT';
{namespace Test.more}

/**
 * Commets text
 * @param test Test param
 * @param mode Mode for tempalate
 **/
{template .Hello}
<p>Ok</p>
{/template}
TXT
our $file = "Test file";

if ( $str =~ &Plosurin::TEMPLATE_GRAMMAR($file) )
#    ->with_actions( TmplFile->new() ) )
{
    say Dumper {%/};
}

#$p->parse($str, 'test1');
#diag $p;

#Test::Class->runtests()

