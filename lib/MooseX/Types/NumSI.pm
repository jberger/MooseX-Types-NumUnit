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
    my $given_unit = GetUnit( "$pv->[1]" );
    my $base_unit = GetTypeUnit( $given_unit->type );
    $val *= $given_unit->convert( $base_unit );

    my $base_str = $base_unit->name . " [" . $base_unit->expanded . "]";
    warn "Converted $pv => $val $base_str\n" if $Verbose;

    if (wantarray) {
      return ( $val, $base_unit );
    } else {
      return $val;
    }
}

sub num_of_unit {
  my $unit = GetTypeUnit( GetUnit( shift )->type );
  my $unit_str = $unit->name;
  
  my $subtype = subtype as 'NumSI';

  coerce $subtype,
    from 'Str',
    via { 
      my $input = $_;
      my ($val, $base_unit) = si_value($input);
      if ( $base_unit->equal( $unit ) ) {
        return $val;
      } else {
        warn "Value supplied ($input) is not of type $unit_str, using 0 instead.\n";
        return 0;
      }
    };

  return $subtype;
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

