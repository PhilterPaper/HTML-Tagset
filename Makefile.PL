# This -*-perl-*- program writes the Makefile for installing this distribution.
#
# See "perldoc perlmodinstall" or "perldoc ExtUtils::MakeMaker" for
# info on how to control how the installation goes.

require 5.004;
use strict;
use ExtUtils::MakeMaker;

my $parms = {
    NAME            => 'HTML::Tagset',
    AUTHOR          => 'Andy Lester <andy@petdance.com>',
    VERSION_FROM    => 'lib/HTML/Tagset.pm',
    ABSTRACT_FROM   => 'lib/HTML/Tagset.pm',
    PMLIBDIRS       => [qw(lib/)],
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean           => { FILES => 'HTML-Tagset-*' },
};

if ( $ExtUtils::MakeMaker::VERSION =~ /^\d\.\d\d$/ and $ExtUtils::MakeMaker::VERSION > 6.30 ) {
    $parms->{LICENSE} = 'artistic_2';
}

if ( $ExtUtils::MakeMaker::VERSION ge '6.46' ) {
    $parms->{META_MERGE} = {
        resources => {
            license     => 'https://opensource.org/licenses/artistic-license-2.0',
            homepage    => 'https://github.com/petdance/html-tagset',
            bugtracker  => 'https://github.com/petdance/html-tagset/issues',
            repository  => 'https://github.com/petdance/html-tagset',
        }
    };
}

WriteMakefile( %$parms );
