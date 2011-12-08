package MooseX::Types::NumSI;

use strict;
use warnings;

use Moose::Util::TypeConstraints;

use Math::Units::PhysicalValue qw/PV/;
use Physics::Unit qw/GetUnit GetTypeUnit/;

use Carp;

our $Verbose;

subtype 'NumSI',
  as 'Num';

coerce 'NumSI',
  from 'Str',
  via { scalar si_value($_) };

sub si_value {
    my $in = shift;
    my $pv = PV($in) || croak "Could not understand $_";

    my $val = 0+$pv->deunit->bsstr;
    my $unit = GetUnit( "$pv->[1]" );
    my $base_unit = GetTypeUnit( $unit->type );
    $val *= $unit->convert( $base_unit );

    my $base_str = $base_unit->name . " [" . $base_unit->expanded . "]";
    print STDERR "Converted $pv => $val $base_str\n" if $Verbose;

    if (wantarray) {
      return ( $val, $base_unit );
    } else {
      return $val;
    }
}

#__END__

sub unit {
  my $unit = GetUnit( shift );
  
  my $subtype = 
    subtype as 'NumSI',
      where { 
        my ($val, $base_unit) = si_value($_);
        $_ = $val;
        eval { $unit->convert( $base_unit ) };
        !! $@;
      };
}

__END__
__POD__

=head1 NAME

MooseX::Types::NumSI - Type(s) for using units in Moose

=head1 SYNOPSIS

Coming soon.

=head1 DESCRIPTION

Type(s) for using units in Moose.


=head1 SOURCE REPOSITORY

L<http://github.com/jberger/MooseX-Types-NumSI>

=head1 AUTHOR

Joel Berger, E<lt>joel.a.berger@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Joel Berger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

