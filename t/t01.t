#!/usr/bin/perl
use lib 't/lib';
use Test::Class;
package Plosurin::Parser;
use strict;
use warnings;
sub new {
  my $class = shift;
  bless( ($#_ ==0 ) ? shift : {@_}, ref($class)|| $class);
}

sub parse {
    my $self = shift;
    my $str = shift;
    
}
1;

package main;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

my $p = new Plosurin::Parser::;

my $str = <<TXT;
{namespace Test.more}

/*
 *
 *
 */
{template .Hello}
<p>Ok</p>
{/template}
TXT

$p->parse($str);
diag $p;


#Test::Class->runtests()
