package MPX::CLI;

#ABSTRACT: Common stuff used for the command line interfaces

use strict;
use warnings;
use base 'Exporter';
use Pod::Usage;
use Carp qw(croak);

sub verbose;

our @EXPORT = qw(
  error
  loadMPX
  newToolbox
  say
  usage
  verbose
  getParam
  getParamFile
  val
);

=func error "bla";
=cut

sub error {
    my $msg = shift;
    print "Error: $msg\n";
    exit 1;
}

=func my $tb=newToolbox();

Dies on error.

=cut

sub newToolbox {
    my $tb = new MPX::Tools or die 'Can\'t create toolbox!';
    verbose 'toolbox created';
    return $tb;
}

=func my $dom=loadMPX($file);

Dies on error.

=cut

sub loadMPX {
    my $file = shift or error "No input file specified!";

    #should already be tested
    #if ( !-f $file ) {
    #	error "Input file not found!";
    #}

    my $input = XML::LibXML->load_xml( location => $file )
      or die 'Can\'t open xml file!';
    verbose 'input XML loaded';
    return $input;
}

=func say "blah";
=cut

sub say {
    my $msg = shift or return;
    print "$msg\n";
}

=func usage();
=cut

sub usage {
    if ( $MPX::Commands::opts{h} ) {
        pod2usage( verbose => 2 );
        exit 1;
    }
}

=func verbose "bla";
=cut

sub verbose {
    my $msg = shift or return;
    print ": $msg\n" if $MPX::Commands::opts{v};
}

sub getParam {
    my $name = shift || 'parameter';
    if ( !$ARGV[0] ) {
        error "No $name specified!";
    }
    return shift @ARGV;
}

sub getParamFile {
    my $name = shift || 'file';
    my $file = getParam($name);
    if ( !-f $file ) {
        error "$name not found!";
    }
    verbose "file $file exists";
    return $file;
}

sub val {
    my $type  = shift or croak "Need type";
    my $tb    = shift or croak "Need toolbox";
    my $input = shift or croak "Need input";
    if ( !$MPX::Commands::opts{V} ) {
        $tb->validateMPX($input) or die $tb->error;
        verbose "$type is valid mpx";
    }
}

1;
