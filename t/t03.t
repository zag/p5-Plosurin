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

use Test::More tests => 2;    # last test to print
use Plosurin::SoyTree;
use Data::Dumper;
use Plosurin::Context;
use Plosurin::To::Perl5;
use Plosurin::Writer::Perl5;

use Plosurin;
our $t1 = <<'T1';
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
=pod
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
    src => '{$par}' );
my $t2 = $st1->reduced_tree;
=cut
=head2 code2perl5 $writer, $code_string

  code2perl5 $p5, '{$test}';

=cut
sub code2perl5 {
    my $code = shift;
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
    src => $code );
    my $t2 = $st1->reduced_tree;
    $p5->write( @{$t2} );
    return wantarray()  ? ( $p5->wr->{code}, $t2) : $p5->wr->{code};
}


#$p5->write( @{$t2} );
#say $p5->wr->{code};
ok code2perl5('{$par}') =~ /\$args{'par'}/, '{$par}';
ok code2perl5('{import file="t/samples/test.pod6"/}')=~/Some text/, 'import';
exit;

#   say Dumper $f;
#$p5->start_write();
#$p5->write($f);
#$p5->end_write();

#ok $p5->wr->{code}, 'code gen';
#say $p5->wr->{code};
#diag Dumper $p5->{tmpls};
#warn Dumper $p5->wr;
1;


