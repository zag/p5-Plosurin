#!/usr/bin/perl 
package TmplFile;
use strict;
use warnings;
use Data::Dumper;
sub new {
   my $class = shift;
   $class = ref $class if ref $class;
   my $self = bless( {@_}, $class );
   $self;
}

sub template {
    my ($self , $a) = @_;
#    return {%a}
#    diag Dumper
    die Dumper($a,$self);
}

1;
package main;
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
{template .test1}

asdasd asd
{/template}

/**
 * Test1
 * Test2
 * @param test Test file
 * @param test1 Test file
 **/
{template .test}
       
asdasd asd
{/template}


TEXT
our $file = 'TST';
my $r = qr{
    <namespace>
    <[Templates]>+
    <rule: Templates>  <header>  <template>
    <rule: namespace> \{namespace <id>\} \n+
    <rule: id>  \w+
    <rule: header> \/\*+\n (?: <h_params> | <h_comment> )+ \*+\/ 
    <rule: h_comment> \s+\* <raw_str>
    <rule: raw_str> [^@\n]+$
    <rule: h_params> \s+\* \@param <id> <raw_str>
    <rule: template><start_from= matchline><start_template>
            <raw_template=(.*?)><stop_template><stop_at= matchline>
            (?{  Dumper(\%MATCH); $MATCH{1} =1; })
    <rule: raw_template>  .*?
    <rule: start_template> \{template <name=(\.\w+)>\} 
    | <matchline><fatal:(?{say "Bad template definition at $file line $MATCH{matchline} : $CONTEXT" })>
    <rule: stop_template>  \{\/template\}
}xms;


say "ok";
if ( $t =~ $r->with_actions(TmplFile->new(file=>"Test")) ) {

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
#    say Dumper  {%/} ;
    say Dumper strip({%/});
    say {*STDERR} $_ for @!;
}
else {
    say "Bad string";
}
say "ok2";
1;

