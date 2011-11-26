#===============================================================================
#
#  DESCRIPTION:  Test Soy clases
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Plosurin::To::Perl5;
use strict;
use warnings;
use v5.10;
use vars qw($AUTOLOAD);
use Data::Dumper;
package main;
use strict;
use warnings;

use Test::More tests => 1;    # last test to print
use Plosurin::SoyTree;
use Data::Dumper;
use Plosurin::Context;
use Plosurin::To::Perl5;
use Plosurin::Writer::Perl5;

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
    'writer'  => new Plosurin::Writer::Perl5,
    'package' =>"Test",
);
my $st1 =
  new Plosurin::SoyTree(
#    src => '{call t.test.2 }{param t}ok{/param}{param t32 : 1/}{/call}' );
    src => '{$par}' );
my $t2 = $st1->reduced_tree;

$p5->write( @{$t2} );

#   say Dumper $f;
$p5->start_write();
$p5->write($f);
$p5->end_write();


#say $p5->wr->{code};
diag Dumper $p5->{tmpls};
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


