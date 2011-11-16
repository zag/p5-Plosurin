#===============================================================================
#
#  DESCRIPTION:  Test clo syntax
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;    # last test to print
use Data::Dumper;
use v5.10;
use Regexp::Grammars;

my $q = qr{
#    <debug:step>
     <[content]>+ 
    <token: content>
        <raw_text>
        |<command_print>
        |<command_include>
        |<matchpos><raw_text1=(.?)><warning:(?{say "May be command ? $MATCH{raw_text1} at $MATCH{matchpos}"})>
    <rule: command_print> \{print <variable>\}
    <objrule: Plo::command_include> \{include <[attribute]>{2} % <_sep=(\s+)> \}
        |\{include <matchpos><fatal:(?{say "'Include' require 2 attrs at $MATCH{matchpos}"})>
    <token: attribute> <name=(\w+)>=['"]<value=(?: ([^'"]+) )>['"]
    <token: variable> \$?\w+ 
    <rule: raw_text><matchpos> [^\{]+
}xms;
my $t = <<'TXT';
<h1>test</h1>{print n} { sd text {print rt}
{include file="asd" rule=":sd"}
TXT
if ( $t =~ $q ) {
    say Dumper( {%/} );
    say( length $t );
}
else { say "BAD" }

