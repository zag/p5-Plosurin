#===============================================================================
#
#  DESCRIPTION: util for tree
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

=head1 NAME

Plosurin::SoyTree - syntax tree

=head1 SYNOPSIS

    my $plo = new Plosurin::SoyTree( src => $self->body );

=head1 DESCRIPTION

Plosurin::SoyTree - syntax tree

=cut

package Soy::Actions;
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
    warn "Content";
    #   say Dumper( $a );
    #    say Dumper(\@_);
    #    @_
    $a;
}

sub command_foreach {
    my $self = shift;
    warn "Action !!!";
#    warn Dumper( \@_ );
    die;

    #    Soy::command_foreach
    #    return
}
1;

package Soy::base;
use Data::Dumper;

sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

sub attrs {
    my $self = shift;
    my $attr = $self->{attribute} || [];
    my %attr = ();
    foreach my $rec (@$attr) {
        $attr{ $rec->{name} } = $rec->{value};
    }
    return \%attr;
}

sub childs {
    my $self = shift;
    if (@_) {
        $self->{content} = shift;
    }
    return [] unless exists $self->{content};
    [ @{ $self->{content} } ];
}

sub as_perl5 { die "$_[0]\-\>as_perl5 unimplemented " }

sub dump {
    my $self   = shift;
    my $childs = $self->childs;
    my $res    = {};
    if ( scalar(@$childs) ) {
        $res->{childs} = [
            map {
                { ref( $_->{obj} ) => $_->{obj}->dump }
              } @$childs
        ];
    }
    if ( scalar( keys %{ $self->attrs } ) ) {
        $res->{attrs} = $self->attrs;
    }

    $res;

}
1;

package Soy::command_print;
use base 'Soy::base';
1;

package Soy::expression;
use base 'Soy::base';
1;

package Soy::raw_text;
use base 'Soy::base';

sub as_perl5 {
    my $self = shift;
    my $str  = $self->{''};
    $str =~ s/\!/\\\!/g;
    "\$res .=q!$str!;\n";
}
1;

package Soy::command_elseif;
use base 'Soy::base';
use Data::Dumper;
use strict;
use warnings;

sub dump {
    my $self = shift;
    return { %{ $self->SUPER::dump() },
        expression => $self->{expression}->dump };
}
1;

package Soy::command_call_self;
use base 'Soy::base';
use strict;
use warnings;
use Data::Dumper;

sub as_perl5 {
    my ( $self, $ctx ) = @_;
    my $template = $self->{tmpl_name};
    my $attr     = $self->attrs;
    my $tmpl     = $ctx->get_template_by_name($template);
    my $sub = $ctx->get_perl5_name($tmpl) || die "Not found template $template";
    if ( scalar( @{ $self->childs } ) ) {
        my $code = '';
        my @ch   = @{ $self->childs };
        foreach my $p ( @{ $self->childs } ) {

            #check if childs id param
            die "{call ... }{/call} can contain only {param}"
              unless $p->isa('Soy::command_param') || $p->isa('Soy::Node');

            #now export
            $code .= $p->as_perl5($ctx);
        }
        return
            '$res .= &' 
          . $sub . '(' 
          . $code
          . '); # calling '
          . $template . "\n";
    }
    return '$res .= &' . $sub . '(@_); # calling ' . $template . "\n";
}

sub dump {
    my $self = shift;
    my $res  = $self->SUPER::dump;
    $res->{template} = $self->{tmpl_name};
    $res;
}
1;

package Soy::command_call;
use Plosurin::SoyTree;
use base 'Soy::command_call_self';
use strict;
use warnings;

package Soy::command_else;
use base 'Soy::base';
use strict;
use warnings;
1;

package Soy::command_if;
use base 'Soy::base';
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

package Soy::command_param;
use base 'Soy::base';
use warnings;
use strict;
use Data::Dumper;

sub as_perl5 {
    my $self = shift;

    #    my $ctx = shift;
    #die Dumper($self);
    #die $self->childs
    my $str = join ' . ', map { $_->as_perl5(@_) } @{ $self->childs };
    return qq!'$self->{name}' => $str!;
}

sub dump {
    my $self = shift;
    my %res = ( %{ $self->SUPER::dump() }, name => $self->{name}, );
    $res{value} = $self->{value} if exists $self->{value};
    \%res;
}

package Soy::command_param_self;
use base 'Soy::command_param';

package Soy::Node;
use base 'Soy::base';

sub childs {
    [ $_[0]->{obj} ];
}

sub as_perl5 {
    my $self = shift;
    return $self->{obj}->as_perl5(@_);
}

package Soy::command_import;
use strict;
use warnings;
use base 'Soy::base';
1;

package Soy::command_foreach;
use strict;
use warnings;
use base 'Soy::base';

sub dump {
    my $self = shift;
    my %res  = (
        %{ $self->SUPER::dump() },

        #    expression => $self->{expression}
    );
    if ( exists $self->{command_foreach_ifempty} ) {
        my $ife = $self->{command_foreach_ifempty};
        $res{ifempty} = $ife->dump;

    }
    \%res;
}

package Soy::command_foreach_ifempty;
use strict;
use warnings;
use base 'Soy::base';

package Plosurin::SoyTree;
use strict;
use warnings;
use v5.10;
use Data::Dumper;
use Plosurin::Grammar;
use Regexp::Grammars;

=head2 new

    my $st = new Plosurin::SoyTree( 
            src => "txt",
            srcfile=>"filesrc",
            start_line=>1
            );

=cut

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    if ( my $src = $self->{src} ) {
        unless ( $self->{_tree} = $self->parse($src) ) { return $self->{_tree} }
    }
    $self;
}

=head2  parse

return [node1, node2]

=cut

sub parse {
    my $self = shift;
    my $str  = shift || return [];
    my $q    = shift || qr{
     <extends: Plosurin::Grammar>
#    <debug:step>
    \A  <[content]>* \Z
    }xms;
    if ( $str =~ $q->with_actions( new Soy::Actions:: ) ) {
        return {%/};
    }
    else {
        "bad template";
    }
}

=head2 raw 

return syntax tree

=cut

sub raw_tree {
    $_[0]->{_tree} || {};
}

=head2 reduce_tree

Union raw_text nodes

=cut

sub reduced_tree {
    my $self = shift;
    my $tree = shift || $self->raw_tree->{content} || return [];
    my @res  = ();
    my @tmp = @$tree;    #copy for protect from modify orig tree
    while ( my $node = shift @tmp ) {

        #skip first node
        #skip all non text nodes
        if ( ref( $node->{obj} ) ne 'Soy::raw_text' || scalar(@res) == 0 ) {
##            if ( my $sub_tree = $node->{obj}->childs ) {
##                $node->{obj}->childs( $self->reduced_tree($sub_tree) );
######                 $self->reduced_tree($sub_tree);
            #           }
            push @res, $node;
            next;
        }
        my $prev = pop @res;
        unless ( ref( $prev->{obj} ) eq 'Soy::raw_text' ) {
            push @res, $prev;
        }
        else {

            #now union !
            $node->{obj} = Soy::raw_text->new(
                { '' => $prev->{obj}->{''} . $node->{obj}->{''} } );
            $node->{matchline} = $prev->{matchline};
            $node->{matchpos}  = $node->{matchpos};
        }
        push @res, $node;
    }
    \@res;
}

=head2 dump_tree($obj1 [, $objn])

Minimalistic tree
return [ "clasname", {key1=>key2} ] 

=cut

sub dump_tree {
    my $self = shift;
    my @res  = ();
    foreach my $rec ( @{ shift || [] } ) {
        my $obj = $rec->{obj};
        push @res, { ref($obj) => $obj->dump() };
    }
    \@res;
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

