#===============================================================================
#
#  DESCRIPTION:  Test plo syntax
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Plo::Actions;
use strict;
use warnings;
use v5.10;
use Data::Dumper;

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub content_ {
    my $self = shift;
    my ($a) = @_;

    #   say Dumper( $a );
    #    say Dumper(\@_);
    #    @_
    $a;
}
1;

package Plo::base;
sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}
sub childs {[]}
1;
package Plo::command_print;
use base 'Plo::base';
1;
package Plo::raw_text;
use base 'Plo::base';
1;
package Plo::command_if;
use base 'Plo::base';
use strict;
use warnings;
use v5.10;
use Data::Dumper;
sub childs {
    my $self =shift;
    if (@_) {
        $self->{content} = shift;
    }
    $self->{content}
}
1;

package Plosutin::Plo;
use strict;
use warnings;
use v5.10;
use Data::Dumper;

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub syntax_tree {
    my $sellf = shift;
}

=head2 reduce_tree
Union raw_text nodes
=cut

sub reduce_tree {
    my $self = shift;
    my $tree = shift || return [];
    my @res  = ();
    while ( my $node = shift @$tree ) {

        #skip first node
        #skip all non text nodes
        if ( ref( $node->{obj} ) ne 'Plo::raw_text' || scalar(@res) == 0 ) {
            if ( my $sub_tree = $node->{obj}->childs ) {
                $node->{obj}->childs($self->reduce_tree($sub_tree));
            }
            push @res, $node;
            next;
        }
        my $prev = pop @res;
        unless ( ref( $prev->{obj} ) eq 'Plo::raw_text' ) {
            push @res, $prev;
        }
        else {

            #now union !
            $node->{obj} = Plo::raw_text->new(
                { '' => $prev->{obj}->{''} . $node->{obj}->{''} } );
            $node->{matchline} = $prev->{matchline};
            $node->{matchpos}  = $node->{matchpos};
        }
        push @res, $node;
    }
    \@res;
}

package main;
use strict;
use warnings;

use Test::More tests => 1;    # last test to print
use Data::Dumper;
use v5.10;
use Regexp::Grammars;

my $q = qr{
#    <debug:step>
     <[content]>+ 
    <token: Plo::content><matchpos><matchline>
        (?:

         <obj=raw_text>
        |<obj=command_print>
        |<obj=command_include>
        |<obj=command_if>
        |<obj=raw_text_add>

        )
    <objrule: Plo::raw_text=raw_text_add><matchpos>(.?)
#        <warning:(?{say "May be command ? $MATCH{raw_text_add} at $MATCH{matchpos}"})>
    <objrule: Plo::command_print>
                   \{print <variable>\}
    <objrule: Plo::command_include>
              \{include <[attribute]>{2} % <_sep=(\s+)> \}
             |\{include <matchpos><fatal:(?{say "'Include' require 2 attrs at $MATCH{matchpos}"})>

    <token: attribute> <name=(\w+)>=['"]<value=(?: ([^'"]+) )>['"]

    <token: variable> \$?\w+ 
    <token: expression> .*?

    <objrule:  Plo::raw_text> [^\{]+
    <objrule: Plo::command_if> \{if <expression>\} <[content]>+
                    \{\/if\}
}xms;
my $t = <<'TXT';
{if 3.14}
  {$pi} is a good approximation of pi.
{/if}
TXT

if ( $t =~ $q->with_actions( new Plo::Actions:: ) ) {

    say  Dumper( Plosutin::Plo->new()->reduce_tree( {%/}->{content} ) );

    #    say( length $t );
}
else { say "BAD" }

