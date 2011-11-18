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

sub namespace {
    my ($self, $attr) = @_;
    #$self->{namespace};
    die Dumper(\@_);
}
sub Templates {
    my ( $self, $a ) = @_;
    return $a;
}

sub h_comment {
    my ( $self, $a ) = @_;
    return $a

}

sub header {
    my ( $self, $a ) = @_;
    return $a;
}

sub h_params {
    my ( $self, $a ) = @_;
    return $a;
}
1;
package Plo::File;
sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    #set namespace
    my $namespace = $self->{namespace}->{id};
    foreach my $tmpl ( @{ $self->{templates} }) {
       $tmpl->{namespace} = $namespace; 
    }
    $self;
}
sub namespace {
    $_[0]->{namespace}->{id}
}
=head2 templates
Return array of tempaltes
=cut

sub templates {
    my $self = shift;
    @{ $self->{templates} }
}

package Plo::template;
use strict;
use warnings;
sub new {
    my $class = shift;
    bless ( ($#_ == 0) ? shift : {@_}, ref($class) || $class);
}

sub body {$_[0]->{template_block}->{raw_template}}
sub name { $_[0]->{template_block}->{start_template}->{name}}
1;
package main;
use strict;
use warnings;
use Test::More tests => 1;    # last test to print
use Data::Dumper;
use v5.10;
use Regexp::Grammars;

use Plosurin;

my $p   = new Plosurin::;
my $str = <<'TXT';
{namespace Test.more}

/**
 * Commets text
 * @param test Test param
 * @param mode Mode for tempalate
 */
{template .Hello}
<p>Ok</p>
{/template}
TXT
our $file = "Test file";
my $q = qr{
     <extends: Plosurin::Template::Grammar>
    <matchline>
#    <debug:step>
    \A <File> \Z
    <objtoken: Plo::File>
    <namespace>
    <[templates=template]>+
    <objtoken: Plo::template> <header> <template_block>
    <rule: namespace> \{namespace <id>\} \n+
    <rule: id>  [\.\w]+
    <rule: header> \/\*{2}\n (?: <[h_params]>|<[h_comment]> )+ <javadoc_end> 
        | \/\*\n <matchline><fatal:(?{say "JavaDoc must start with /**! at $file line $MATCH{matchline} : $CONTEXT" })>

    <rule: javadoc_end>\*\/
        | <matchline><fatal:(?{say "JavaDoc must end with */! at $file line $MATCH{matchline} : $CONTEXT" })>

    <rule: h_comment> \* <raw_str>
    <rule: raw_str> [^@\n]+$
    <rule: h_params> \* \@param <id> <raw_str>

    <rule: template_block>
            <start_template>
            <raw_template=(.*?)>
            <stop_template>
    <rule: raw_template>  .*?

    <rule: start_template> \{template <name=(\.\w+)>\} 
    | <matchline><fatal:(?{say "Bad template definition at $file line $MATCH{matchline} : $CONTEXT" })>
    <rule: stop_template>  \{\/template\}
}xms;

my $res;
#if ( $str =~ &Plosurin::TEMPLATE_GRAMMAR($file) )
if ( $str =~ $q )
#->with_actions( TmplFile->new() ) )
{
    my $file = {%/}->{File};
    for ($file->templates) {
    my $tmpl_name = $_->name;
    my $namespace = $file->namespace;
    ( my $converted_name = $namespace . $tmpl_name ) =~ tr/\./_/;
#    say Dumper $_;
    my $sub_name = "Package::$converted_name";
    my $plo = new Plosurin::SoyTree(src=>$_->body);
    die $plo unless ref $plo;
    my $code =  Dumper $plo->dump_tree( $plo->reduced_tree  );

     $res .=  <<"TMPL";
package Package;
use strict;
use utf8;
sub $sub_name \{
$code
\}
TMPL
    }
    
#    say Dumper ;
}

say $res;
#$p->parse($str, 'test1');
#diag $p;

#Test::Class->runtests()

