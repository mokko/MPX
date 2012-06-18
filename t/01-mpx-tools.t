use strict;
use warnings;
use Test::More tests => 6;
use MPX::Test qw (testEnviron);
use MPX::CLI qw (say);
use Params::Util qw(_INSTANCE);

BEGIN {
	use_ok('MPX::Tools') || print "Bail out!
";
}

my $tb = new MPX::Tools;
ok( _INSTANCE( $tb, 'MPX::Tools' ), 'right kind of object' );

#meaning that it finds it helper files (xsd, xsl)

##
## validate
##


{
	my $sampleFN = testEnviron('sampleData-small.mpx');

	my $input = XML::LibXML->load_xml( location => $sampleFN )
	  or die "Cant open mpx file!";

	ok( $tb->validateMPX($input), 'validate returns true' );
}

{

	my $input = XML::LibXML->load_xml( string => <<'EOT');
  <some-xml/>
EOT

	ok( !$tb->validateMPX($input), 'rubbish doesn\'t validate: '.$tb->error );

}


##
## fix
##

{
	my $sampleFN = testEnviron('sampleData-small.mpx');

	my $input = XML::LibXML->load_xml( location => $sampleFN )
	  or die "Cant open mpx file!";

	ok( $tb->fix($input), 'fix returns true' );

}

##
## transform
##
{
	my $sampleFN = testEnviron('sampleData-small.mpx');

	my $input = XML::LibXML->load_xml( location => $sampleFN )
	  or die "Cant open mpx file!";
	my $result=$tb->transform ('stat.xsl', $input);  
	ok (_INSTANCE($result,'XML::LibXML::Document'), 'transform produces LibXML::Document');
}