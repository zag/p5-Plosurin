#!/usr/bin/perl 
package TmplFile;
use strict;
use warnings;
use v5.10;
use Data::Dumper;
sub new {
   my $class = shift;
   $class = ref $class if ref $class;
   my $self = bless( {@_}, $class );
   $self;
}

sub Templates {
    my ($self , $a) = @_;
    say Dumper( $a);
    return $a;
}


sub h_comment {
    my ($self, $a ) = @_;
#    say Dumper( $a);
    return $a
    
}
sub header {
    my ($self, $a ) = @_;
    return $a
}

sub h_params {
    my ($self, $a ) = @_;
#    say Dumper( $a);
    return $a
}
sub AUTOLOADa {
    my $self = shift;
    ( my $sub = $TmplFile::AUTOLOAD ) =~ /DESTROY/ && do {
        warn "DESTORU";
        return};

    warn $TmplFile::AUTOLOAD;
    return {};
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
 * Test11
 * Test12
 * @param test Test file11
 * @param test1 Test file12
 **/
{template .test}
       
asdasd asd
{/template}


TEXT
our $file = 'TST';
my $r = qr{
    <nocontext:>
    <matchline>
    <namespace>
    <[Templates]>+
    <rule: Templates>  <header>  <template>
    <rule: namespace> \{namespace <id>\} \n+
    <rule: id>  \w+
    <rule: header> \/\*+\n (?: <[h_params]>|<[h_comment]> )+ \*+\/ 
    <rule: h_comment> \s+\* <raw_str>
    <rule: raw_str> [^@\n]+$
    <rule: h_params> \s+\* \@param <id> <raw_str>
    <rule: template><start_from= matchline><start_template>
            <raw_template=(.*?)><stop_template><stop_at= matchline>
            (?{  Dumper(\%MATCH); say "end"; })
    <rule: raw_template>  .*?
    <rule: start_template> \{template <name=(\.\w+)>\} 
    | <matchline><fatal:(?{say "Bad template definition at $file line $MATCH{matchline} : $CONTEXT" })>
    <rule: stop_template>  \{\/template\}
}xms;


say "ok";
if ( $t =~ $r->with_actions(TmplFile->new(file=>"Test")) ) {
#    say "OK: " .  pos($t);
#    say Dumper  {%/} ;
#     say Dumper strip({%/});
#    say {*STDERR} $_ for @!;
}
else {
    say "Bad string";
}
say "ok2";exit;
my %commas=(':','',',');
my $r = qr{
    <nocontext:>
    <[dlist]>+
    <rule: dlist>
    <[dig=(\d+)]>+ % <%commas>
    <rule: item>
    \d
    <rule: comma>
    , | : 
    
    }x;
("1, 2, 03,7, 56: 3" =~ $r ) ?  do { say Dumper {%/}} : die "bad"; 
1;

