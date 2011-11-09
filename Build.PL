use Module::Build;
use 5.8.0;
Module::Build->new
    ( module_name => 'Plosurin',
    license => 'perl',
   prereq => {
	'Test::Class'=>0,
	     },
    script_files=>[qw!
	scripts/p5losurin
    !],
   dist_version_from=>'lib/Plosurin.pm',
    meta_merge=>{
     resources=> {
        repository => 'git://github.com/zag/p5-Plosurin.git',
        bugtracker=>'http://rt.cpan.org/Public/Dist/Display.html?Name=Plosurin'
    }
    },
   dist_author=>'Zahatski Aliaksandr zag@cpan.org',
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
