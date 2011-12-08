#===============================================================================
#
#  DESCRIPTION:  Test Expr Grammasr
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

use strict;
use warnings;

use Test::More 'no_plan';                      # last test to print
use Regexp::Grammars;

my $q = qr{
    <expr>
#level 
    #ternary
    <rule: expr> <Main=add> \? <True=add> \: <False=add>
            |<MATCH=add>
#level 
    <objrule: add>
                <X=mult> <Op=([+-])> <Y=expr> 
                | <MATCH=mult> 

    <objrule: mult> 
                <X=term> <Op=(\^)> <Y=mult>
                | <MATCH=term>

     <objrule: term> 
              <MATCH=Literal> 
            | <Sign=([+-])> \( <expr>\) #unary
            | \( <MATCH=expr> \)

    <token: Literal>
                    <MATCH=Bool>   |
                    <MATCH=Var>    |
                    <MATCH=String> |
                    <MATCH=Digit> 

    <token: Ident>
            <MATCH=([a-z,A-Z_](?: [a-zA-Z_0-9])* )>

    <objtoken: Var>
            \$ <Ident>

    <objtoken: Bool>
            true | false

    <token: Digit>
            [+-]? \d++ (?: \. \d++ )?+

    <objtoken: String> 
        \'
      (
         [^'\\\n\r] 
        | \\ [nrtbf'"] 
        # TODO \ua3ce
      )*
      \'


}xms;

my $t = q!2 + 23 ? 2+2+$true9+'e' : 0!;
if ($t =~ $q) {
    use Data::Dumper 'Dumper';
    print Dumper %/;
#    warn "Ok"
} else {
 warn "BAD Reg"
}
ok "1";

