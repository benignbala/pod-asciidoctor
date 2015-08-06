package Pod::AsciiDoctor;

use warnings;
use strict;
use parent 'Pod::Parser';
use Data::Dumper;

sub initialize {
    my $self = shift;
    $self->SUPER::initialize(@_);
    $self->_prop;
    return $self;
}

sub adoc {
    my $self = shift;
    my $data = $self->_prop;
    return join "\n", @{$data->{text}};
}

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

sub _sanitise {
    my $self = shift;
    my $p = shift;
    chomp($p);
    return $p;
}

sub append {
    my ($self, $doc) = @_;
    my $data = $self->_prop;
    push @{$data->{text}}, $doc;
}
    
    
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

sub verbatim {
    my $self = shift;
    my $paragraph = shift;
    chomp($paragraph);
    $self->append($paragraph);
    return;
}

sub textblock {
    my $self = shift;
    my ($paragraph, $lineno) = @_;
    chomp($paragraph);
    $self->append($paragraph);
}

sub make_header {
    my ($self, $command, $level, $paragraph) = @_;
    if ($command =~ /head/) {
        my $h = sprintf("%s %s", "=" x ($level+1), $paragraph);
        return $h;
    } elsif ($command =~ /item/) {
        return "* $paragraph";
    }
}

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

sub set_formatting {
    my $self = shift;
    my $paragraph = shift;
    $paragraph =~ s/I<(.*)>/_$1_/;
    $paragraph =~ s/B<(.*)>/*$1*/;
    $paragraph =~ s/B<(.*)>/*$1*/;
    $paragraph =~ s/C<(.*)>/\`$1\`/xms;
    return $paragraph;
}

1;
