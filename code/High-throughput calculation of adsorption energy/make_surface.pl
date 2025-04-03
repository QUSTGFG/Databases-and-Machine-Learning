#!perl

use strict;
use Getopt::Long;
use MaterialsScript qw(:all);

sub Runfiles{
    my ($system) = @_;
    my $cleave = Tools->SurfaceBuilder->CleaveSurface;
$cleave->DefineCleave($system, MillerIndex(H => 3, K => 1, L => 1), Point(X => 1, Y => -2, Z => -1), Point(X => 0, Y => 1, Z => -1));
$cleave->MeshOrigin(Point(X => 0, Y => 0, Z => 0));
$cleave->SetThickness(2);
my $docSurface = $cleave->Cleave(Settings());

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