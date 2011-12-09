package MyTest;

use lib 'lib';
use Moose;
use MooseX::Types::NumUnit qw/num_of_unit/;

#$MooseX::Types::NumUnit::Verbose = 1;

has 'speed' => ( isa => num_of_unit('ft / hour'), is => 'rw', required => 1 );

no Moose;
__PACKAGE__->meta->make_immutable;

my $test = MyTest->new( speed => '2 m / s' );

print $test->speed, "\n";

