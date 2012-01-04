#===============================================================================
#
#  DESCRIPTION: Plosurin - Perl 5 implementation of Closure Templates
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

=head1 NAME

Plosurin - Perl 5 implementation of Closure Templates

=head1 SYNOPSIS

         plosurin.p5 -t perl5 -package Test test.soy > Test.pm
         perldoc Test.pm


=head1 DESCRIPTION

Plosurin - Perl 5 implementation of Closure Templates

=cut

package Plo::File;
use Plosurin::SoyTree;
use base 'Soy::base';

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

sub childs {
    my $self = shift;
    return [ $self->templates ];
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
use Plosurin::SoyTree;
use base 'Soy::base';

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub body { $_[0]->{template_block}->{raw_template} }
sub name { $_[0]->{template_block}->{start_template}->{name} }

sub comment {
    return join "\n", map { $_->{raw_str} } @{ $_[0]->{header}->{h_comment} };
}
sub params { @{ $_[0]->{header}->{h_params} } }
sub full_name { my $self = shift; $self->{namespace} . $self->name }

sub namespace {
    $_[0]->{namespace}->{id};
}

#parse body and return Soy tree
sub childs {
    my $self = shift;
    my $plo = new Plosurin::SoyTree( src => $self->body );
    die $plo unless ref $plo;
    my $reduced = $plo->reduced_tree;
    return $reduced;
}

1;

package Plosurin;
use strict;
use warnings;
use v5.10;
our $VERSION = '0.0_2';
use Regexp::Grammars;
use Plosurin::Grammar;
use Plosurin::Context;
use Plosurin::SoyTree;
use Plosurin::To::Perl5;
use Plosurin::Writer::Perl5;
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
    my $self = shift;
    my $opt  = shift;
    return " need at least one $file" unless scalar(@_);
    my @files = map { ( ref($_) eq 'ARRAY' ) ? @{$_} : ($_) } @_;
    my @alltemplates = ();

    my $package = $opt->{package} || die "
      use as_perl5( { package => ... } ) !";

    my $ctx = new Plosurin::Context(@files);
#    print Dumper (\@files);
    my $p5  = new Plosurin::To::Perl5(
        'context' => $ctx,
        'writer'  => new Plosurin::Writer::Perl5,
        'package' => $package,
    );
    $p5->start_write();
    $p5->write(@files);
    $p5->end_write();
    my $res = $p5->wr->{code};
    wantarray() ? ( $res, @{ $p5->{tmpls} } ) : $res;
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
it under the same terms as Perl itself.

=cut

