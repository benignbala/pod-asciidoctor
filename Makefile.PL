use 5.006;
use strict;
use warnings FATAL => 'all';
use inc::Module::Install;

name     'Pod-AsciiDoctor';
all_from 'lib/Pod/AsciiDoctor.pm';
author   q{Balachandran Sivakumar <balachandran@balachandran.org>};
license  'artistic2';

perl_version 5.006;

tests_recursive('t');

resources (
   #homepage   => 'http://yourwebsitehere.com',
   #IRC        => 'irc://irc.perl.org/#Pod-AsciiDoctor',
   license    => 'http://www.perlfoundation.org/artistic_license_2_0',
   #repository => 'git://github.com/Balachandran Sivakumar/Pod-AsciiDoctor.git',
   bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pod-AsciiDoctor',
);

configure_requires (
   'Module::Install' => 0,
);

build_requires (
   'Test::More' => 0,
);

requires (
   #'ABC'              => 1.6,
   #'Foo::Bar::Module' => 5.0401,
);

install_as_cpan;
auto_install;
WriteAll;
