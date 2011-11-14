#===============================================================================
#
#  DESCRIPTION:  Test clo syntax
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print
use Data::Dumper;
use v5.10;
use Regexp::Grammars;

my $q = qr{
    <[content]>+
    <rule: content> <raw_ext>
    <rule: raw_text> (?![\{\}])+
}xms;
my $t =<<TXT;
<h1>test</h1>{print $n}
TXT
if ($t =~ $q) {
    say Dumper({%/})
} else { say "BAD"}



