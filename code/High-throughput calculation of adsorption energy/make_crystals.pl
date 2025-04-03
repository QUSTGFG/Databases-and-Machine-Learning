#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

sub Runfiles{
    my ($system) = @_;
    Tools->CrystalBuilder->VacuumSlab->Build($system, Settings());

}

#Filter out only the .xsd fils in the Document collection, countributed by BIOVIA
foreach my $key (keys %Documents) {
	my $system = $Documents{$key};
	if ($system->Type eq "3DAtomistic" ) {
	#print "$key $doc";
	   Runfiles($system);
	}
	$system->Close;
}													        