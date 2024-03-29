# $Id: Table_template.pm,v 1.1 2010/11/20 20:38:52 Paulo Exp $
# file generated by <% $program %>, do not edit

package <% $package %>;

#------------------------------------------------------------------------------

=head1 NAME

<% $package %> - Z80 assembly / disassembly tables

=cut

#------------------------------------------------------------------------------

use strict;
use warnings;

our $VERSION = '1.00';

#------------------------------------------------------------------------------

=head1 SYNOPSIS

  use <% $package %>;
  Asm::Z80::Table->asm_table->{'adc'}{'a'}{','}{'('}{'hl'}{')'}{''} is [0x8E]
  Asm::Z80::Table->disasm_table->{0x8E}{''} is ['adc', 'a', ',', '(', 'hl', ')']
  my $iter = Asm::Z80::Table->iterator;
  my($tokens, $bytes) = $iter->();

=cut

#------------------------------------------------------------------------------

my $asm_table    = <% dump_table( \%asm_table ) %>;
my $disasm_table = <% dump_table( \%disasm_table ) %>;

sub asm_table    { $asm_table }
sub disasm_table { $disasm_table }

#------------------------------------------------------------------------------
# return iterator to return all items in the asm_table
sub iterator {
	my($class) = @_;
	
	my $table = $class->asm_table;
	my @children = sort keys %$table;
	my @tokens;
	my @stack = [$table, \@children, \@tokens];	
	
	# unroll recursive algorithm
	return sub {
		while (@stack) {
			my($table, $children, $tokens) = @{$stack[-1]};
			my $child = shift @$children;
			if (! defined $child) {
				pop @stack;						# end of leaf
			}
			elsif ($child eq '') {				# leaf
				my @bytes = @{$table->{''}};
				return ([@$tokens], \@bytes);	# make a copy
			}
			else {								# node
				my @grand_children = sort keys %{$table->{$child}};
				push @stack, [ $table->{$child}, 
							   \@grand_children,
							   [@$tokens, $child] ];
			}
		}
		return ();								# end
	};
}

1;

__END__

#------------------------------------------------------------------------------

=head1 DESCRIPTION

This module provides hash tables to assemble / disassemble all Z80 CPU 
assembly instructions, including undocumented ones (e.g. 'ld ixh,N')
and instructions composed by sequences (e.g. 'ld bc,hl'). 

This module is used in a Z80 assembler / disassembler. 

It was spun off the L<CPU::Z80::Assembler|CPU::Z80::Assembler> module.

=head1 EXPORTS

Nothing.

=head1 FUNCTIONS

=head2 asm_table

This function returns the assembly hash table.

Starting at the root and 
following one sub-hash table for each token, with an empty token at the 
end of the list, produces an array of opcode bytes of the corresponding Z80 
assembly.

=head2 disasm_table

Starting at the root key and following one sub-hash table for each 
opcode byte, with an empty byte at the end of the list, produces an array
of tokens of the corresponding disassembled Z80 instruction.

=head2 iterator

Returns an iterator function that returns the next pair of 
token list and bytes list, while traversing all the C<asm_table>. The iterator 
funtion returns an empty list C<()> at the end.

=head1 SPECIAL TOKENS

The following special tokens are used in both the tokens and bytes lists:

=over 4

=item N

One byte;

=item NN

One word;

=item NNl

The low byte of the word;

=item NNh

The high byte of the word;

=item NNo

The offset byte of a JR/DJNZ instruction that is converted to NN by adding
address + 1;

=item DIS

The offset of a (ix+DIS) expression;

=item DIS+1

The offset of a (ix+DIS) expression for 16-bit load, e.g. C<ld (ix+DIS),bc>;

=item NDIS

The offset of a (ix-NDIS) expression.

=item NDIS+1

The offset of a (ix-NDIS) expression for 16-bit load, e.g. C<ld (ix-NDIS),bc>;

=back

=head1 EXTENSIONS TO STANDARD Z80 ASSEMBLY

The following extensions were implemented in this assembly/disassembly table:

=over 4

=item *

C<ixh> and C<ixl> can be used as the high- and low-byte of C<ix>; 
the same with C<iyh> and C<iyl>.

=item *

C<ldi> increments the memory pointer in indirect register addressing after
the load, e.g. C<'ldi a,(hl)'> is C<'ld a,(hl):inc hl'>.

=item *

C<ldd> decrements the memory pointer in indirect register addressing after
the load; e.g. C<'lda a,(hl)'> is C<'ld a,(hl):dec hl'>.

=item *

16-bit load between two registers is composed by two 8-bit load instructions or 
a sequence of push/pop, e.g. C<'ld bc,de'> is C<'ld b,d:ld c,e'>, and 
C<'ld hl,ix'> is C<'push ix:pop hl'>.

=item *

16-bit load in indirect register addressing is composed by a sequence of 
8-bit load instructions and register increment/decrement, 
e.g. C<'ld bc,(hl)'> is C<'ld c,(hl):inc hl:ld b,(hl):dec hl'>.

=item *

16-bit subtract is composed by clearing the carry flag and subtract with carry,
e.g. C<'sub hl,bc'> is C<'or a:sbc hl,bc'>.

=item *

C<sll> (and the synonym C<sli>) is Shift Logical Left, works as C<sla> but sets
bit 0.

=item *

C<'in f,(c)'> reads the port pointed by C<c> and sets the flags, but does not
store the result.

=item *

C<'out (c),0'> outputs zero to the port pointed by C<c>.

=item *

Two argument rotate instrution in index register indirect mode stores the result
in the second argument, e.g. C<'rlc (ix+d),c'> rotates the value pointed by
C<(ix+d)> and stores the result in C<c>.

=item *

Three argument bit set/clear instrution in index register indirect mode 
stores the result in the third argument, e.g. C<'set 3,(ix+d),c'> 
sets bit-3 of the the value pointed by
C<(ix+d)> and stores the result in C<c>.

=item *

Rotate instructions (C<rl>, C<rr>, C<sla>, C<sll>, C<sli>, C<sra>, C<srl>)
with the 16-bit registers are implemented by rotating one register
into carry and the other from carry.

=item *

Conditional relative jump with flags not available in C<jr> are coded as 
absolute jumps, e.g. <'jr po,NN'> is <'jp po,NN'>.

=item *

The RST instruction takes as its parameter either the address to jump to 
or the reset vector number - this is just the address / 8.

=item *

C<'stop'> is a special instruction for L<CPU::Emulator::Z80|CPU::Emulator::Z80>
coded as C<0xDD, 0xDD, 0x00>.

=back

=head2 Full Z80 Assembly Table

The official Z80 assembly instructions have a maximum of 4 bytes; the composed 
instructions have a maximum of 10 bytes.

<% assembly_table() %>

=head1 ACKNOWLEDGEMENTS

Based on sjasmplus L<http://sjasmplus.sourceforge.net/> undocumented opcodes.
See also L<http://www.z80.info/zip/z80-documented.pdf> for a description 
of the undocumented Z80 instructions.

=head1 AUTHOR

Paulo Custodio, C<< <pscust at cpan.org> >>

=head1 BUGS and FEEDBACK

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Asm-Z80-Table>.  

=head1 LICENSE and COPYRIGHT

Copyright (c) 2010 Paulo Custodio.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

#------------------------------------------------------------------------------

