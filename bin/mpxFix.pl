#!/usr/bin/perl
# PODNAME: mpxFix.pl
# ABSTRACT: apply mpxFix.xsl and test result

use strict;
use warnings;
use Getopt::Std;
use Pod::Usage;
use Params::Util qw (_INSTANCE);

use File::Spec;
use FindBin;
use lib File::Spec->catfile( $FindBin::Bin, '..', 'lib' );

use MPX::Tools;
our %opts;

sub verbose;
sub error;

getopts( 'hvV', \%opts );

if ( $opts{h} ) {
	pod2usage( verbose => 2 );
	exit 1;
}

=head1 SYNOPSIS

 mpxFix.pl [-vV] path/to/input.mpx  #writes to path/to/input.fix.mpx
 mpxFix.pl -h help

=head2 PARAMS

=over 1

=item -v verbose

=item -V don't validate

=back

=head1 DESCRIPTION

=over 1

=item 1) validate input

=item 2) apply mpxFix.xsl

=item 3) validate output

=item 4) test output (todo)

=item 5) on success, save output to file with name $input.fix.mpx

=back

=cut

if ( !$ARGV[0] ) {
	error "No input file specified!";
}

if ( !-f $ARGV[0] ) {
	error "Input file not found!";
}

#verbose "verbose mode on";

my $tb = new MPX::Tools or die "Cant create toolbox!";
verbose "toolbox created";

my $input = XML::LibXML->load_xml( location => $ARGV[0] )
  or die "Cant open xml file!";
verbose "input XML loaded";

if ( !$opts{V} ) {
	$tb->validateMPX($input) or die $tb->error;
	verbose "input is valid mpx";
}

my $output = $tb->fix($input) or die $tb->error;
verbose "fix applied";

if ( !$opts{V} ) {
	$tb->validateMPX($output) or die $tb->error;
	verbose "output is valid mpx";
}

#$tb->laxTests or die $tb->error;
#verbose "result passes laxTests";
#$tb->strictTests or die $tb->error;
#verbose "result passes strictTests"

write2File($output);

####
#### SUBS
####

sub write2File {
	my $outputFN = $ARGV[0] or die "Should never get here!";
	my $result = _INSTANCE( shift, 'XML::LibXML::Document' )
	  or die "Wrong object!";
	$outputFN =~ s/\.\w+/.fix.mpx/;
	verbose "planned output file name: $outputFN";

	if ( -e $outputFN ) {
		verbose "WARNING: output file exists already and will be overwritten";
	}

	$result->toFile( $outputFN, 1 ) or die "Cant write results!";
	verbose "Results written";
}

sub verbose {
	my $msg = shift or return;
	print ": $msg\n" if $opts{v};
}

sub error {
	my $msg = shift;
	print "Error: $msg\n";
	exit 1;
}
