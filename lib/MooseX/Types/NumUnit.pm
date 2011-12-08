package MooseX::Types::NumUnit;

use strict;
use warnings;

use Moose::Util::TypeConstraints;

use Math::Units::PhysicalValue qw/PV/;
use Physics::Unit qw/GetUnit GetTypeUnit/;

use Carp;

use Moose::Exporter;
Moose::Exporter->setup_import_methods (
  as_is => [qw/num_of_unit num_of_si_unit/],
);

## For AlwaysCoerce only ##
use namespace::autoclean;
use Moose ();
use MooseX::ClassAttribute ();
use Moose::Util::MetaRole;
###########################

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

## The following is stolen almost directly from MooseX::AlwaysCoerce version 0.16

{
    package MooseX::Types::NumUnit::Role::Meta::Attribute;
    use namespace::autoclean;
    use Moose::Role;

    around should_coerce => sub {
        my $orig = shift;
        my $self = shift;

        my $current_val = $self->$orig(@_);

        return $current_val if defined $current_val;

        return 1 if $self->type_constraint && $self->type_constraint->has_coercion && $self->type_constraint->is_a_type_of('NumUnit');
        return 0;
    };

    package MooseX::Types::NumUnit::Role::Meta::Class;
    use namespace::autoclean;
    use Moose::Role;
    use Moose::Util::TypeConstraints;

    around add_class_attribute => sub {
        my $next = shift;
        my $self = shift;
        my ($what, %opts) = @_;

        if (exists $opts{isa}) {
            my $type = Moose::Util::TypeConstraints::find_or_parse_type_constraint($opts{isa});
            $opts{coerce} = 1 if not exists $opts{coerce} and $type->has_coercion and $type->is_a_type_of('NumUnit');
        }

        $self->$next($what, %opts);
    };
}

my (undef, undef, $init_meta) = Moose::Exporter->build_import_methods(

    install => [ qw(import unimport) ],

    class_metaroles => {
        attribute   => ['MooseX::Types::NumUnit::Role::Meta::Attribute'],
        class       => ['MooseX::Types::NumUnit::Role::Meta::Class'],
    },

    role_metaroles => {
        (Moose->VERSION >= 1.9900
            ? (applied_attribute => ['MooseX::Types::NumUnit::Role::Meta::Attribute'])
            : ()),
        role                => ['MooseX::Types::NumUnit::Role::Meta::Class'],
    }
);

sub init_meta {
    my ($class, %options) = @_;
    my $for_class = $options{for_class};

    MooseX::ClassAttribute->import({ into => $for_class });

    # call generated method to do the rest of the work.
    goto $init_meta;
}

__END__
__POD__

=head1 NAME

MooseX::Types::NumUnit - Type(s) for using units in Moose

=head1 SYNOPSIS

Coming soon.

=head1 DESCRIPTION

Type(s) for using units in Moose.


=head1 SOURCE REPOSITORY

L<http://github.com/jberger/MooseX-Types-NumUnit>

=head1 AUTHOR

Joel Berger, E<lt>joel.a.berger@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Joel Berger

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

