package main;

use 5.010;

use strict;

use ExtUtils::MakeMaker 7.00;

my %parms = (
    NAME             => 'HTML::Tagset',
    AUTHOR           => 'Andy Lester <andy@petdance.com>',
    ABSTRACT         => 'Data tables useful in parsing HTML',
    VERSION_FROM     => 'lib/HTML/Tagset.pm',
    LICENSE          => 'artistic_2',
    MIN_PERL_VERSION => 5.010001,
    TEST_REQUIRES    => {
        'Test::More' => '0.95',
    },
    META_MERGE       => {
        resources => {
            license     => 'https://opensource.org/licenses/artistic-license-2.0',
            homepage    => 'https://github.com/petdance/html-tagset',
            bugtracker  => 'https://github.com/petdance/html-tagset/issues',
            repository  => 'https://github.com/petdance/html-tagset',
        }
    },
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean           => { FILES => 'HTML-Tagset-*' },
);

WriteMakefile( %parms );
