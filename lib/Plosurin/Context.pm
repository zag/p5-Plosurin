#===============================================================================
#
#  DESCRIPTION:  mantain collection of files and templates 
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
# while export is going
package Plosurin::Context;
use strict;
use warnings;
=head2 new
    
    init colection
    new Plosurin::Context( <Plo::File1>,<Plo::File2> );

=cut

sub new  {
    my $class = shift;
    bless ( {src=>[@_]}, ref($class) || $class);
}

=head2 name2tmpl
return hash all templates
 {
    
 }
=cut

sub name2tmpl {
    my $self = shift;
    my %res = ();
    foreach my $file ( @{ $self->{src} } ) {
       for ($file->templates) {
           my $full_name = $file->namespace . $_->name;
           $res{$full_name} = $_;
       }
    }
    \%res
}

=head2 get_template_by_name
get by .name -> absolute -> rerurn ref to template
=cut
sub get_template_by_name {
    my $self = shift;
    my $name = shift || return undef;
    #get current namespace
    if ($name =~/^\./) {
    $name = $self->{namespace} . $name;
    } 
    return $self->name2tmpl->{$name};
}

=head2 get_perl5_name $template_object

get perl5 full path

=cut
sub  get_perl5_name {
    my $self = shift;
    my $tmpl = shift || return ;
    (my $p5name = $tmpl->full_name) =~ tr/\./_/;
    $p5name;
}
    
1;


