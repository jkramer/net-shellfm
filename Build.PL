use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::ShellFM',
    license             => 'perl',
    dist_author         => 'Jonas Kramer <jkramer@nex.scrapping.cc>',
    dist_version_from   => 'lib/Net/ShellFM.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Net-ShellFM-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
