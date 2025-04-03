#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

sub Runfiles{
    my ($system) = @_;
    my $results = Modules->CASTEP->Energy->Run($system, Settings(
	SCFConvergence => 1e-005, 
	UseInsulatorDerivation => 'Yes', 
	SpinTreatment => 'Collinear', 
	CalculateDOS => 'Partial', 
	Quality => 'Coarse', 
	# PropertiesKPointQuality => 'Coarse'
));
}
#xcd
#Filter out only the .xsd fils in the Document collection, countributed by BIOVIA
foreach my $key (keys %Documents) {
	my $system = $Documents{$key};
	if ($system->Type eq "3DAtomistic" ) {
	#print "$key $doc";
	   Runfiles($system);
	}
	$system->Close;
}													        