package MooseX::Types::NumUnit;

use strict;
use warnings;

use Moose::Util::TypeConstraints;

use Math::Units::PhysicalValue qw/PV/;
use Physics::Unit qw/GetUnit GetTypeUnit/;

use Carp;

use parent 'Exporter';

our @EXPORT_OK = qw/num_of_unit num_of_si_unit/;

our $Verbose;

subtype 'NumUnit',
  as 'Num';

subtype 'NumSI',
  as 'NumUnit';

coerce 'NumSI',
  from 'Str',
  via { convert($_) };

sub num_of_si_unit {
  my $unit = GetTypeUnit( GetUnit( shift )->type );
  return _num_of_unit($unit);
}

sub num_of_unit {
  my $unit = GetUnit( shift );
  return _num_of_unit($unit);
}

sub _num_of_unit {
  my $unit = shift;

  my $subtype = subtype as 'NumUnit';

  coerce $subtype,
    from 'Str',
    via { convert($_, $unit) };

  return $subtype;
}

sub convert {
    my ($input, $requested_unit) = @_;
    my $pv = PV($input) || croak "Could not understand $_";

    my $val = 0+$pv->deunit->bsstr;

    my $given_unit = GetUnit( "$pv->[1]" );

    unless ($requested_unit) {
      my $base_unit = GetTypeUnit( $given_unit->type );
      $requested_unit = $base_unit;
    }

    my $req_str = $requested_unit->name . " [" . $requested_unit->expanded . "]";

    my $conv_error = 0;
    { 
      local $SIG{__WARN__} = sub { $conv_error = 1 };
      $val *= $given_unit->convert( $requested_unit );
    }

    if ($conv_error) {
      warn "Value supplied ($input) is not of type $req_str, using 0 instead.\n";
      $val = 0;
    } else {
      warn "Converted $pv => $val $req_str\n" if $Verbose;
    }

    return $val;
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

