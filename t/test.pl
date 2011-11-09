#!/usr/bin/perl 
use strict;
use warnings;
use feature qw/say/;
use Test::More;
use Data::Dumper;
use v5.10;
use Regexp::Grammars;
my $t = <<'TEXT';
{namespace Test}
/**
 * Test1
 * Test2
 * @param test Test file
 * @param test1 Test file
 **/
{template}
{/template}
TEXT
my $r = qr{
    <namespace>
    <header>

    <rule: namespace> \{namespace <id>\} \n+
    <rule: id>  \w+
    <rule: header> \/\*+\n <[h_line]>+ \*+\/ 
    <rule: h_line> <h_params> | <h_comment> 
    <rule: h_comment> \s+\* <raw_str>
    <rule: raw_str> [^@\n]+$
    <rule: h_params> \s+\* \@param <id> <raw_str>
}xms;

say "ok";
if ( $t =~ $r ) {

    sub strip {
        my $ref = shift;
        if ( ref($ref) eq 'ARRAY' ) {
            for (@$ref) {
                $_ = strip($_);
            }
        }
        elsif ( ref($ref) eq 'HASH' ) {
            while ( my ( $k, $v ) = each %$ref ) {
                if ( $k eq '' ) { delete $ref->{$k}; next }
                $ref->{$k} = strip($v);
            }
        }
        $ref;
    }
#    say "OK: " .  pos($t);
#    say Dumper strip( {%/} );
     say Dumper strip({%/});
}
else {
    say "Bad string";
}
say "ok2";
1;

