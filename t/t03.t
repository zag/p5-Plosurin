#===============================================================================
#
#  DESCRIPTION:  Test Soy clases
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Plosurin::Writer::Perl5;
use strict;
use warnings;
use v5.10;

sub new {
    my $class = shift;
    my $ini = $#_ == 0 ? shift : {@_};
    $ini->{varstack} = [ { name => 'res', inited => 0 } ];
    $ini->{ident} = 4;
    bless( $ini, ref($class) || $class );

}

#ident for generated code
sub inc_ident {
    $_[0]->{ident} += 4;
}

sub ident { $_[0]->{ident} }

sub dec_ident {
    my $self = shift;
    $self->{ident} -= 4 if $self->{ident} > 4;
}

sub say {
    my $self = shift;
    return $self->print( @_, "\n" );
}

sub print {
    my $self = shift;
    $self->{code} .= " "x $self->ident . "@_";
}

sub pushOtputVar {
    my ( $self, $var ) = @_;
    push @{ $self->{varstack} }, { name => $var, value => '' };

}

sub popOtputVar {
    my ( $self, $var ) = @_;
    pop @{ $self->{varstack} };    #, {name=> $var, value=>''};
}

sub currentVar {
    my $self = shift;
    $self->{varstack}[-1];
}

sub appendOutputVar {
    my $self = shift;
    my $data = join '', @_;
    my $v    = $self->currentVar;
    my $name = $v->{name};
    unless ( $v->{inited} ) {
        $self->print( 'my $' . $name . ' = ' . $data . ';' . "\n" );
    }
    else { die "!" }
}
1;

package Plosurin::To::Perl5;
use strict;
use warnings;
use v5.10;
use vars qw($AUTOLOAD);
use Data::Dumper;

=head2 new context=>$ctx, writer=>$writer


=cut

sub new {
    my $class = shift;
    my $self = bless( $#_ == 0 ? shift : {@_}, ref($class) || $class );
    $self->{nodeid} = 1;
    $self;
}

=head2 writer or wr
Return current writer object. 
    $self->wr
    $self->writer
=cut

sub writer { $_[0]->{writer} }
sub wr     { $_[0]->{writer} }

=head2 context or ctx
 retrun current context
=cut

sub context { $_[0]->{context} }
sub ctx     { $_[0]->{context} }

sub visit {
    my $self = shift;
    my $n    = shift;

    #get type of file
    my $ref = ref($n);
    unless ( ref($n) && UNIVERSAL::isa( $n, 'Soy::base' ) ) {
        die "Unknown node type $n (not isa Soy::base)";
    }

    my $method = ref($n);
    $method =~ s/.*:://;

    #make method name
    $self->$method($n);
}

sub visit_childs {
    my $self = shift;
    foreach my $n (@_) {
        die "Unknow type $n (not isa Soy::base)"
          unless UNIVERSAL::isa( $n, 'Soy::base' );
        foreach my $ch ( @{ $n->childs } ) {
            $self->visit($ch);
        }
    }
}

sub start_write {
    my $self = shift;

}

sub end_write {
    my $self = shift;
}

sub write {
    my $self   = shift;
    my $writer = $self->{writer};
    $self->start_write($writer);
    foreach my $n (@_) {
        $self->visit($n);
    }
    $self->end_write($writer);
}

#Node container of command. <content>
sub Node {
    my $self = shift;
    my $node = shift;
    $self->visit_childs($node);
}

sub command_call {
    my ( $self, $n ) = @_;
    my $w   = $self->wr;
    my $ctx = $self->ctx;
    my $template = $n->{tmpl_name};
    my $tmpl     = $ctx->get_template_by_name($template);
    my $sub = $ctx->get_perl5_name($tmpl) || die "Not found template $template";

    #if data='all' or empty params
    # &sub(@_)
    my $attr = $n->attrs;
    if ( scalar( @{ $n->childs } ) == 0
        || exists $attr->{data} && $attr->{data} eq 'all' )
    {
        $w->print( '&' . $sub . '(@_); # calling ' . $template . "\n" );
    }
    else {

        #if need external var ?
        #$self-> !!!!!  #TODO
        #if not
        my @params = ();
        foreach my $ch (
            map { UNIVERSAL::isa( $_, 'Soy::Node' ) ? @{ $_->childs } : $_ }
            @{ $n->childs } )
        {

            # skip not param nodes
            next unless UNIVERSAL::isa( $ch, 'Soy::command_param' );
            my $vname = 'param' . ++${ $w->{nodeid} };
            $w->pushOtputVar($vname);
            $self->visit($ch);
            push @params, { name => $ch->{name}, vname => $vname };
            $w->popOtputVar;
        }
        $w->say(q!# calling '. $template;!);
        $w->appendOutputVar(
                '&' 
              . $sub . '('
              . join( ',',
                map { "'" . $$_{name} . q!' => $! . $$_{vname} } @params )
              . ')'
        );
    }
}

sub command_param {
    my ( $self, $node ) = @_;
    $self->visit_childs($node);
}

sub command_param_self {
    my ( $self, $node ) = @_;
    my $w = $self->wr;
    $w->appendOutputVar("'$node->{value}'");
}

sub raw_text {
    my ( $self, $node ) = @_;
    my $w = $self->wr;
    $w->appendOutputVar("'$node->{''}'");

    #    warn Dumper($node);
}

sub AUTOLOAD {
    my $self   = shift;
    my $method = $AUTOLOAD;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';

    #check if can
    if ( $self->can($method) ) {
        my $superior = "SUPER::$method";
        $self->$superior(@_);
    }
    else {
        die "NON IMPLEMENTED $method";
    }

}

1;

package main;
use strict;
use warnings;

use Test::More tests => 1;    # last test to print
use Plosurin::SoyTree;
use Data::Dumper;
use Plosurin::Context;
use Plosurin;
my $t1 = <<'T1';
{namespace t.test}
/** ok */
{template .1}
 
{/template}

/*
  * ok
  * @param d raw txt
*/
{template .2}
<h1>template2</h1>
{/template}
T1

#parse base template
my $p1  = new Plosurin::();
my $f   = $p1->parse( $t1, "test" );
my $ctx = new Plosurin::Context($f);
my $p5  = new Plosurin::To::Perl5(
    'context' => $ctx,
    writer    => new Plosurin::Writer::Perl5
);
my $st1 =
  new Plosurin::SoyTree( src => '{call t.test.2 }{param t}ok{/param}{param t32 : 1/}{/call}' );
my $t2 = $st1->reduced_tree;

#   say Dumper $t2;

$p5->write( @{$t2} );

say $p5->wr->{code};

#warn Dumper $p5->wr;
exit;
my $namespace = $f->namespace;
my $code      = '';
foreach my $node (@$t2) {
    $ctx->{namespace} = $namespace;
    $code .= $node->as_perl5($ctx);
}
diag $code;

#diag $f;
#diag $p1->as_perl5({package=>"T"},$f);
1;

