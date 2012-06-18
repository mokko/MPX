package MPX::Commands;

use strict;
use warnings;
use Carp qw(carp croak);
use Getopt::Std;
our @imports=qw(error usage verbose loadMPX newToolbox say getParam getParamFile val);
our %opts;
use MPX::CLI @imports;
#use Data::Dumper qw(Dumper);

=func fix ($mpxFile);

expects location of input mpx, applies mpxFix.xsl to this file and writes 
result to a new file. If input has format
	to/path/input.mpx
new file name will be 
	to/path/input.fix.mpx

=cut

sub fix {
	getopts( 'hvV', \%opts );
	usage();

	my $tb    = newToolbox();
	my $inputFN = getParamFile('mpx file');
	my $input   = loadMPX($inputFN);
	val( 'input', $tb, $input );

	my $result = $tb->fix( $input ) or die $tb->error;
	verbose 'fix applied';

	#or do i have to call _transform?

	#$tb->laxTests or die $tb->error;
	#verbose "result passes laxTests";
	#$tb->strictTests or die $tb->error;
	#verbose "result passes strictTests"

	my $outputFN = $inputFN;
	$outputFN =~ s/\.\w+$/.fix.mpx/;
	verbose "planned output file name: $outputFN";

	if ( -e $outputFN ) {
		warn 'WARNING: output file exists already and will be overwritten';
	}

	$result->toFile( $outputFN, 1 ) or die 'Can\'t write results!';
	verbose "Result written";
}

=func my $result=transform ($xslFile,$mpxFile);

Expects an xsl file name in the module's xsl directory (not absolute or 
relative path), and a path to mpx file. Returns the result of the 
transformation as XML::LibXML::Document.

Validation: on default validates input and ouput. Disable with -V.

=cut

sub transform {
	getopts( 'hlvV', \%opts );
	usage();

	my $tb    = newToolbox();
	
	if ($opts{l}) {
		verbose "files in MPX's xsl directory";
		foreach ($tb->xslList()) {
			print "$_\n";
		}
	return 1; #success;
	}

	my $xslFN = getParam('xsl file');
	#$xslFN = $tb->_modDir( 'xsl', $xslFN );
	#if ( !-f $xslFN ) {
	#	error "xsl file not found at $xslFN";
	#}

	my $inputFN = getParamFile('mpx file');
	my $input   = loadMPX($inputFN);
	val( 'input', $tb, $input );

	my $output = $tb->transform( $xslFN, $input ) or die $tb->error;
	verbose 'transformation applied';

	val( 'output', $tb, $output );
	print $output->toString(1); #i didn't load libXML, kinda wrong
	#not sure about toString format
}

=func stat $mpxFile;

Prints a little statistic on the numbers of records in input.mpx.

(Internally $modDir/xsl/stat.xsl is called.)

On default input document is validated. Disable with -V.

=cut

sub stat {
	getopts( 'hvV', \%opts );
	usage();
	my $inputFN = getParamFile('mpx file');
	my $input = loadMPX($inputFN);
	my $tb    = newToolbox();
	val( 'input', $tb, $input );

	my $output = $tb->transform( 'stat.xsl', $input, 'as_chars' ) or die $tb->error;
	verbose 'stat.xsl to chars';
	print $output;
}

=func validate $mpxFile;

validate mpxFile against mpx.xsd.

Note: You can't disable validation with -V

=cut

sub validate {
	getopts( 'hv', \%opts );
	usage();

	my $tb    = newToolbox();
	my $inputFN = getParamFile('mpx file');
	my $input   = loadMPX($inputFN);
	val( 'file', $tb, $input ); #dies if doesn't validate
	#return 0; #success (shell exit code for success is 0)
}


####
#### INTERNAL: these should go MPX::CLI
####


1;
