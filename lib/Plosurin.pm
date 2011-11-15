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

package TmplFile;
use strict;
use warnings;
use v5.10;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = bless( {@_}, $class );
    $self;
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

package Plosurin;
use strict;
use warnings;
use v5.10;
our $VERSION = 0.1_1;
use Regexp::Grammars;
our $file = "???";

sub TEMPLATE_GRAMMAR {
    our $file = shift;
    qr{
    <nocontext:>
    <matchline>
    <namespace>
    <[Templates]>+
    <rule: Templates>  <header>  <template>
    <rule: namespace> \{namespace <id>\} \n+
    <rule: id>  [\.\w]+
    <rule: header> \/\*{2}\n (?: <[h_params]>|<[h_comment]> )+ <javadoc_end> 
        | \/\*\n <matchline><fatal:(?{say "JavaDoc must start with /**! at $file line $MATCH{matchline} : $CONTEXT" })>

    <rule: javadoc_end>\*\/
        | <matchline><fatal:(?{say "JavaDoc must end with */! at $file line $MATCH{matchline} : $CONTEXT" })>

    <rule: h_comment> \* <raw_str>
    <rule: raw_str> [^@\n]+$
    <rule: h_params> \* \@param <id> <raw_str>

    <rule: template><start_from= matchline><start_template>
            <raw_template=(.*?)><stop_template><stop_at= matchline>
    
    <rule: raw_template>  .*?

    <rule: start_template> \{template <name=(\.\w+)>\} 
    | <matchline><fatal:(?{say "Bad template definition at $file line $MATCH{matchline} : $CONTEXT" })>
    <rule: stop_template>  \{\/template\}

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

