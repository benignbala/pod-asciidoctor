package Pod::AsciiDoctor;

use 5.006;
use strict;
use warnings FATAL => 'all';

=head1 NAME

Pod::AsciiDoctor - Convert from POD to AsciiDoc

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Converts the POD of a Perl module to AsciiDoc format.

    use Pod::AsciiDoctor;

    my $adoc = Pod::AsciiDoctor->new();
    $adoc->parse_from_filehandle($fh);
    print $adoc->adoc();

=head1 SUBROUTINES/METHODS

=head2 initialize

=cut

sub initalize {
    my $self = shift;
    $self->SUPER::initialize(@_);
    $self->_prop;
    return $self;
}

=head2 adoc

=cut

sub adoc {
    my $self = shift;
    my $data = $self->_prop;
    return join "\n", @{$data->{text}};
}

=head2 _prop

=cut

sub _prop {
    my $self = shift;
    $self->{prop} //=  {
        'text' => [],
        'headers' => "",
        'topheaders' => {},
        'command' => '',
        'indent' => 0
    };
}

=head2 sanitise

=cut

sub _sanitise {
    my $self = shift;
    my $p = shift;
    chomp($p);
    return $p;
}

=head2 append

=cut

sub append {
    my ($self, $doc) = @_;
    my $data = $self->_prop;
    push @{$data->{text}}, $doc;
}
    
    
=head2 command

    Overrides Pod::Parser::command

=cut
    
sub command {
    my ($self, $command, $paragraph, $lineno) = @_;
    my $data = $self->_prop;
    $data->{command} = $command;
    # _sanitise: Escape AsciiDoctor syntax chars that appear in the paragraph.
    $paragraph = $self->_sanitise($paragraph);

    if ($command =~ /head(\d)/) {
        my $level = $1;
        $level //= 2;
        $data->{command} = 'head';
        $data->{topheaders}{$1} = defined($data->{topheaders}{$1}) ? $data->{topheaders}{$1}++ : 1;
        $paragraph = $self->set_formatting($paragraph);
        # print "PARA:: $paragraph\n";
        $self->append($self->make_header($command, $level, $paragraph));
    }

    if ($command =~ /over/) {
        $data->{indent}++;
    }
    if ($command =~ /back/) {
        $data->{indent}--;
    }
    if ($command =~ /item/) {
        $self->append($self->make_text($paragraph, 1));
    }
    return;
}

=head2 verbatim

    Overrides Pod::Parser::verbatim

=cut
    
sub verbatim {
    my $self = shift;
    my $paragraph = shift;
    chomp($paragraph);
    $self->append($paragraph);
    return;
}

=head2 textblock

    Overrides Pod::Parser::textblock

=cut
    
sub textblock {
    my $self = shift;
    my ($paragraph, $lineno) = @_;
    chomp($paragraph);
    $self->append($paragraph);
}

=head2 make_header

=cut
    
sub make_header {
    my ($self, $command, $level, $paragraph) = @_;
    if ($command =~ /head/) {
        my $h = sprintf("%s %s", "=" x ($level+1), $paragraph);
        return $h;
    } elsif ($command =~ /item/) {
        return "* $paragraph";
    }
}

=head2 make_text

=cut
    
sub make_text {
    my ($self, $paragraph, $list) = @_;
    my @lines = split "\n", $paragraph;
    my $data = $self->_prop;
    my @i_paragraph;
    my $pnt = $list ? "*" : "";
    for my $line (@lines) {
        # print "MKTXT::$line\n";
        push @i_paragraph, $pnt x $data->{indent} . " " . $line . "\n";
    }
    return join "\n", @i_paragraph;
}

=head2 set_formatting

=cut
    
sub set_formatting {
    my $self = shift;
    my $paragraph = shift;
    $paragraph =~ s/I<(.*)>/_$1_/;
    $paragraph =~ s/B<(.*)>/*$1*/;
    $paragraph =~ s/B<(.*)>/*$1*/;
    $paragraph =~ s/C<(.*)>/\`$1\`/xms;
    return $paragraph;
}
    
=head1 AUTHOR

Balachandran Sivakumar, C<< <balachandran at balachandran.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pod-asciidoctor at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pod-AsciiDoctor>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Pod::AsciiDoctor


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pod-AsciiDoctor>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Pod-AsciiDoctor>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Pod-AsciiDoctor>

=item * Search CPAN

L<http://search.cpan.org/dist/Pod-AsciiDoctor/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Balachandran Sivakumar.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Apache License (2.0). You can get a copy of 
the license at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.

=cut

1;
