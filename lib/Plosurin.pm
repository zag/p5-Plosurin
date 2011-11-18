#===============================================================================
#
#  DESCRIPTION: Plosurin - Perl 5 implementation of Closure Templates
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

=head1 NAME

Plosurin - Perl 5 implementation of Closure Templates

=head1 SYNOPSIS

         plosurin.p5 -t perl5 -package Test test.soy > Test.pm
         perldoc Test.pm


=head1 DESCRIPTION

Plosurin - Perl 5 implementation of Closure Templates

=cut

package Plo::File;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );

    #set namespace
    my $namespace = $self->{namespace}->{id};
    foreach my $tmpl ( @{ $self->{templates} } ) {
        $tmpl->{namespace} = $namespace;
    }
    $self;
}

sub namespace {
    $_[0]->{namespace}->{id};
}

=head2 templates
Return array of tempaltes
=cut

sub templates {
    my $self = shift;
    @{ $self->{templates} };
}

package Plo::template;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub body { $_[0]->{template_block}->{raw_template} }
sub name { $_[0]->{template_block}->{start_template}->{name} }
sub comment { return join "\n", map { $_->{raw_str} } @{ $_[0]->{header}->{h_comment}} }
sub params { @{ $_[0]->{header}->{h_params}}}
sub full_name { my $self = shift; $self->{namespace} . $self->name}
1;

package Plosurin;
use strict;
use warnings;
use v5.10;
our $VERSION = 0.1_1;
use Regexp::Grammars;
use Plosurin::Grammar;
use Plosurin::Context;
use Plosurin::SoyTree;
our $file = "???";

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub parse {
    my $self = shift;
    my $ref  = shift;
    our $file = shift;
    my $r = qr{
       <extends: Plosurin::Template::Grammar>
        <matchline>
        \A <File> \Z
    }xms;
    if ( $ref =~ $r ) {
        return {%/}->{File};
    }
    undef;
}

=head2 as_perl5 { package=>"MyApp::Tmpl" }, $node1[, $noden]

Export nodes as perl5 package 

=cut

use Data::Dumper;

sub as_perl5 {
    my $self  = shift;
    my $opt   = shift;
    eturn "need at least one $file" unless scalar(@_);
    my @files = map { ( ref($_) eq 'ARRAY' ) ? @{$_} : ($_) } @_;
    my $res   = '';
    #1. collect template_full_name (namespace+name)
    my $ctx = new Plosurin::Context::(@files);
    $ctx->{package} = $opt->{package} || die " use as_perl5( {package=> ...} )!";
    foreach my $file (@files) {
        my $tmpl_code;
        for (sort $file->templates ) {
            my $tmpl_name = $_->name;
            my $namespace = $file->namespace;
            ( my $converted_name = $namespace . $tmpl_name ) =~ tr/\./_/;

            my $plo = new Plosurin::SoyTree( src => $_->body );
            die $plo unless ref $plo;
            my $reduced = $plo->reduced_tree;
            my $code = '';    # =  Dumper $plo->dump_tree(  $reduced );
                              #diag Dumper Dumper($reduced); exit;
            
            foreach my $node (@$reduced) {
                $ctx->{namespace} = $namespace;
                $code .= $node->as_perl5( $ctx );
            }
            $tmpl_code .= <<"SUB"
=head1 $converted_name

@{[ $_->comment ]}

( I<src>: C<@{[ $file->{file} ]}>, I<template name>: C<$tmpl_name> )
=cut
sub $converted_name \{
       my \$res = '';
       $code
      return \$res;
\}
SUB
        }
        $res .= <<"TMPL";
package $opt->{package};
use strict;
use utf8;
=head1 NAME

$opt->{package} - set of generated teplates 

=head1 SYNOPSIS

 use Test;
 print &Test::some_template(key1=>val1);

=head1 DESCRIPTION

$opt->{package} - set of generated teplates by plosurin

=cut

$tmpl_code
1;
__END__

=head1 SEE ALSO

Closure Templates Documentation L<http://code.google.com/closure/templates/docs/overview.html>

Perl 6 implementation L<https://github.com/zag/plosurin>

=cut
TMPL
    }
    $res;
}
1;
__END__

=head1 SEE ALSO

Closure Templates Documentation L<http://code.google.com/closure/templates/docs/overview.html>

Perl 6 implementation L<https://github.com/zag/plosurin>


=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

