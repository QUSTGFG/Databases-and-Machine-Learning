#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

sub Runfiles{
    my ($system) = @_;
    my $adsorptionSimulatedAnnealing = Modules->AdsorptionLocator->SimulatedAnnealing;
my $component1 = $Documents{"H2O2.xsd"}; # Replace with the desired adsorption substrate file name
eval {
        $adsorptionSimulatedAnnealing->AddComponent($component1);
        $adsorptionSimulatedAnnealing->Loading($component1) = 1;
    };

    if ($@) {
        print "Component already added. Skipping...\n";
    }
    my $results = $adsorptionSimulatedAnnealing->Run($system, Settings(
        ChargeAssignment => 'Use current'
    ));
    my $outLowestEnergyStructure = $results->LowestEnergyStructure;
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