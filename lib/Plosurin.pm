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


=head1 DESCRIPTION

Plosurin - Perl 5 implementation of Closure Templates

=cut


package Plosurin;
use strict;
use warnings;
use v5.10;
our $VERSION = 0.1_1;
use Regexp::Grammars;
use Plosurin::SoyTree;
our $file = "???";

sub TEMPLATE_GRAMMAR {
    our $file = shift;
    qr{
    <grammar: Plosurin::Template::Grammar>
#    <nocontext:>

  }xms;

}

sub new {
        my $class = shift;
        bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    }

sub parse {
    my $self = shift;
    my $ref  = shift;
    our $file = shift;
    my $r = &TEMPLATE_GRAMMAR;
    if ( $ref =~ $r->with_actions( TmplFile->new( file => "Test" ) ) ) {
        say "ok";
    }
    else {
        say "Bad string $ref";
    }
}
1;
__END__

=head1 SEE ALSO


=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

