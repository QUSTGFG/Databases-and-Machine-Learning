#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

sub Runfiles{
    my ($system) = @_;
    my $results = Modules->CASTEP->GeometryOptimization->Run($system, Settings(
	UseInsulatorDerivation => 'Yes',
	CellOptimization => 'Full',
	CalculateBondOrder => 'Mulliken',
	CalculateCharge => 'Mulliken',# or 'Hirshfeld',
	Quality => 'Medium',
	# PropertieskPointQuality => 'Coarse'
));

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