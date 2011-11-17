#===============================================================================
#
#  DESCRIPTION:  grammar
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Plosurin::Grammar;
use strict;
use warnings;
use v5.10;
use Regexp::Grammars;

qr{
     <grammar: Plosurin::Grammar>
#    \A  <[content]>* \Z
    <token: Plo::content><matchpos><matchline>
        (?:

         <obj=raw_text>
        |<obj=command_print>
        |<obj=command_include>
        |<obj=command_if>
        |<obj=command_call_self>
        |<obj=command_call>
        |<obj=raw_text_add>

        )
    <objrule: Plo::raw_text=raw_text_add><matchpos>(.+?) 
#    <require: (?{ length($CAPTURE) > 0 })>
#        <fatal:(?{say "May be command ? $MATCH{raw_text_add} at $MATCH{matchpos}"})>
    <objrule: Plo::command_print>
                   \{print <variable>\}
    <objrule: Plo::command_include>
              \{include <[attribute]>{2} % <_sep=(\s+)> \}
             |\{include <matchpos><fatal:(?{say "'Include' require 2 attrs at $MATCH{matchpos}"})>

    <token: attribute> <name=(\w+)>=['"]<value=(?: ([^'"]+) )>['"]

    <token: variable> \$?\w+ 
    <objtoken: Plo::expression> .*?

    <objrule:  Plo::raw_text> [^\{]+
    <objrule: Plo::command_if> \{if <expression>\} <[content]>+?
                        (?:
                        <[commands_elseif=command_elseif]>*
                        <command_else>
                        )?
                    \{\/if\}
    <objrule: Plo::command_elseif><matchpos><matchline> \{elseif <expression>\} <[content]>+?
    <objrule: Plo::command_else><matchpos><matchline> \{else\} <[content]>+?

    #self-ending call block
    <objrule: Plo::command_call_self> \{call <tmpl_name=([\.\w]+)> <[attribute]>* % <_sep=(\s+)> \/\}
    <objrule: Plo::command_call> \{call <tmpl_name=([\.\w]+)> \}
                               <[content=param]>*
                                \{\/call\}

    <token: param> <matchpos><matchline> (?: <obj=command_param_self> | <obj=command_param> )
    <objrule: Plo::command_param_self> \{param <name=(.*?)> : <value=(.*?)> \/\}
    <objrule: Plo::command_param> \{param <name=(.*?)> \}
                    <[content]>+?
                  \{\/param\}
}xms;

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
use Data::Dumper;

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub childs {
    my $self = shift;
    if (@_) {
        $self->{content} = shift;
    }
    return [] unless exists $self->{content};
    [ @{ $self->{content} } ];
}

sub dump {
    my $self   = shift;
    my $childs = $self->childs;
    if ( scalar(@$childs) ) {
        return {
            childs => [
                map {
                    { ref( $_->{obj} ) => $_->{obj}->dump }
                  } @$childs
            ]
        };
    }
    {};
}
1;

package Plo::command_print;
use base 'Plo::base';
1;

package Plo::expression;
use base 'Plo::base';
1;

package Plo::raw_text;
use base 'Plo::base';
1;

package Plo::command_elseif;
use base 'Plo::base';
use Data::Dumper;
use strict;
use warnings;

sub dump {
    my $self = shift;
    return { %{ $self->SUPER::dump() },
        expression => $self->{expression}->dump };
}
1;

package Plo::command_call_self;
use base 'Plo::base';
use strict;
use warnings;

sub attrs {
    my $self = shift;
    my $attr = $self->{attribute} || [];
    my %attr = ();
    foreach my $rec (@$attr) {
        $attr{ $rec->{name} } = $rec->{value};
    }
    return \%attr;
}

sub dump {
    my $self = shift;
    my $res  = $self->SUPER::dump;
    $res->{attrs}    = $self->attrs;
    $res->{template} = $self->{tmpl_name};
    $res;
}
1;

package Plo::command_call;
use base 'Plo::command_call_self';
use strict;
use warnings;

package Plo::command_else;
use base 'Plo::base';
use strict;
use warnings;
1;

package Plo::command_if;
use base 'Plo::base';
use strict;
use warnings;
use v5.10;
use Data::Dumper;

sub dump {
    my $self = shift;
    my %ifs  = ();
    $ifs{'if'} =
      { %{ $self->SUPER::dump }, expression => $self->{expression}->dump, };
    if ( exists $self->{commands_elseif} ) {
        my $elseifs = $self->{commands_elseif};
        $ifs{elseif} = [
            map {
                { ref($_) => $_->dump }
              } @$elseifs
        ];

    }
    if ( my $elseif = $self->{command_else} ) {

        $ifs{else} = { ref($elseif) => $elseif->dump() };
    }

    \%ifs;
}
1;

package Plo::command_param;
use base 'Plo::base';

package Plo::command_param_self;
use base 'Plo::base';
use strict;
use warnings;
use v5.10;
use Data::Dumper;

sub dump {
    my $self = shift;
    return {
        %{ $self->SUPER::dump() },
        name  => $self->{name},
        value => $self->{value}
    };
}
1;


