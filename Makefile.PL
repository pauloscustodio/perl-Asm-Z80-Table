use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Asm::Z80::Table',
    AUTHOR              => q{Paulo Custodio <pscust@cpan.org>},
    VERSION_FROM        => 'lib/Asm/Z80/Table.pm',
    ABSTRACT_FROM       => 'lib/Asm/Z80/Table.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Data::Dumper' 				=> 2.128,
        'File::Basename'			=> 0,
        'File::Slurp' 				=> 9999.13,
		'Iterator::Array::Jagged'	=> 0.05,
		'List::MoreUtils'			=> 0.22,
        'Test::More' 				=> 0.96,	# needs done_testing()
		'Text::Template'			=> 1.45,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Asm-Z80-Table-*' },
);

sub MY::postamble {
	return q{

# generate the lib/Asm/Z80/Table.pm file
lib/Asm/Z80/Table.pm : tools/build_Table.pl tools/Table_template.pm tools/Z80_instructions.dat
	$(PERLRUN) tools/build_Table.pl Asm::Z80::Table lib/Asm/Z80/Table.pm

};
}
