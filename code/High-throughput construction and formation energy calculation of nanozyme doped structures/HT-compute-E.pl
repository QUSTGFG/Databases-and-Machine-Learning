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
	CalculateBondOrder => 'Mulliken', 
	CalculateCharge => 'Mulliken', # or 'Hirshfeld', 
	CalculateSpin => 'Mulliken', # or 'Hirshfeld', 
	Quality => 'Coarse', 
	# PropertiesKPointQuality => 'Coarse'
));
	my $ene2=$results->TotalEnergy*0.04336;
	print "$ene2\n";
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