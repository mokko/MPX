#!/usr/bin/perl
#ABSTRACT: some helpers for MPX
use strict;
use warnings;

package MPX::Tools;

#use File::ShareDir ':ALL'; #todo
use Moose;
use namespace::autoclean;
use Carp qw(croak carp confess);
use Params::Util qw (_INSTANCE _STRING);
use XML::LiBXML;
use XML::LibXSLT;
use XML::LibXML::XPathContext;

#use File::Spec;
use Path::Class;

#use Cwd qw(realpath);
has 'error' => ( is => 'ro', isa => 'Str', writer => '_setError', );
has 'mpxXsd' => ( is => 'ro', isa => 'Str' );
has 'fixXsl' => ( is => 'ro', isa => 'Str' );

#error has error message (if any, gets set internally)
#mpxXsd has location of mpx schema file, gets set during BUILD
#fixXsl has location of mpxFix.xsl file, gets set during BUILD

=head2 SYNOPSIS

	my $tb=new MPX::Tools; #toolbox
	my $bool=$tb->validateMPX($dom) or die $tb->error; #true if validates or false if not
	my $outputDom=$tb->fix ($inputDom) or die $tb->error; 

	#todo
	my $bool=$tb->laxTests ($dom) #true if all tests pass or false if not
	my $bool=$tb->strictTests ($dom) #true if all tests pass or false if not

=method print $tb->error

=method my $outputDOM=$tb->fix ($inputDOM); 

=cut

sub fix {
	my $self = shift or croak "Need myself!";
	my $dom = _INSTANCE( shift, 'XML::LibXML::Document' ) or return undef;

	return $self->transform( 'mpxFix.xsl', $dom );

}

=method my $outputDOM=$tb->transform ($xslFN,$inputDOM);

Excepts $xslFN is a filename in the module's xsl directory (not a valid path 
from cwd). It does check if file exists, so caller doesn't need to do that.

=cut

sub transform {
	my $self  = shift or croak "Need myself!";
	my $xslFN = _STRING(shift);
	my $dom   = _INSTANCE( shift, 'XML::LibXML::Document' );
	my $type  = shift || '';

	if ( !$dom ) {
		$self->_setError('Param not of kind \'XML::LibXML::Document\'');
		return;
	}

	my $stylesheet = $self->_loadXSL($xslFN);
	if ( !$stylesheet ) {
		$self->_setError("stylesheet '$xslFN' not loaded");
		return;
	}

	my $result = $stylesheet->transform($dom);

	if ( !$result ) {
		$self->_setError('result  doesn\'t exist');
		return;
	}

	if ( $type eq 'as_chars' ) {
		$result = $stylesheet->output_as_chars($result);
	}
	return $result;
}

=method my $xpc=$tb->registerMpx($dom);

registers namespace 'http://www.mpx.org/mpx' as the prefix 'mpx' and returns a
XML::LibXML::XPathContext object. Expects a XML::LibXML::Document.

Untested.

=cut

sub registerMPX {
	my $self = shift or croak "Need myself!";
	my $dom = _INSTANCE( shift, 'XML::LibXML::Document' );

	my $xpc = XML::LibXML::XPathContext->new($dom);
	$xpc->registerNs( 'mpx', 'http://www.mpx.org/mpx' );
	return $xpc;
}

=method my $bool=$tb->validateMPX($dom); #true if validates or false if not

	if (!$tb->validateMPX($dom)) {
		print $tb->error
	}

=cut

sub validateMPX {
	my $self = shift or croak "Need myself!";
	my $dom = _INSTANCE( shift, 'XML::LibXML::Document' );

	if ( !$dom ) {
		$self->_setError('Param not an instance of \'XML::LibXML::Document\'');
		return;
	}

	my $mpxXsd = $self->share( 'share', 'mpx.xsd' );
	if ( $self->error ) {
		die $self->error;
	}

	my $xmlschema = XML::LibXML::Schema->new( location => $mpxXsd );

	eval { $xmlschema->validate($dom); };

	if ($@) {
		$self->_setError("validation failed: $@");
		return;
	}
	return 1;    #validates
}

=method my @l=$tb->xslList();

List the contents of this module's xsl directory. Returns filenames in that dir
as array.

For use in 'transf.pl -l'.

=cut

sub xslList {
	my $self = shift or croak "Need myself!";
	my $xslDir = $self->share('xsl');

	if ( !-d $xslDir ) {
		$self->_setError("MPX's xsl directory not found at $xslDir");
		return;
	}

	#don't list subdirectories, links and dotfiles
	opendir my ($dh), $xslDir or croak "Couldn't open dir '$xslDir': $!";
	my @files =
	  grep { !/^\./ && -f File::Spec->catfile( $xslDir, $_ ) } readdir($dh);
	closedir $dh;

	return @files;
}

###
### private
###

=method my $xslDom=$tb->_loadXSL ('bla');

'bla' is the name of the xsl in the module's xsl dir.

Since this is an internal method I am not sure if I need to set errors 
(with _setError). It should get overwritten anyways. Let's 
leave it in for the moment.

=cut

sub _loadXSL {
	my $self = shift or croak "Need myself!";
	my $xslFN = _STRING(shift);

	if ( !$xslFN ) {
		$self->_setError('xsl not specified');
		return;
	}

	$xslFN = $self->share( $xslFN ) || die "No xsl file";

	if ( !-f $xslFN ) {
		$self->_setError("xsl not found at $xslFN");
		return;
	}

	my $styleDoc = XML::LibXML->load_xml( location => $xslFN );

	if ( !$styleDoc ) {
		$self->_setError( $self->{fixXsl} . ' not loaded' );
		return;
	}

	my $xslt       = XML::LibXSLT->new();
	my $stylesheet = $xslt->parse_stylesheet($styleDoc);

	if ( !$stylesheet ) {
		$self->_setError('stylesheet doesn\'t exist');
		return;
	}

	return $stylesheet;
}

=method my $modDir=$self->_modDir || die self->error;  

returns absolute path of module's directory or error. 
	
If you specify a relative path inside the module dir, _modDir returns that 
path: 

	$self->_modDir('A','B.xml')

You can specify as many subdirectories as you want.
	
_modDir should work in your local build directory or when perl module is 
installed. If that is also possible with File::ShareDir I don't know how.

On failure, _modDir sets error and returns nothing.

=cut

sub _modDir {
	print "_modDir\n";
	my $self = shift or croak "Need myself!";

	my $modDir = file(__FILE__)->parent->parent->parent;

	if ( !$modDir ) {

		#very unlikely, but conceivable
		$self->_setError('NO modDir!');
		return;
	}

	if ( !-d $modDir ) {
		$self->_setError("modDir does not exist! ($modDir)");
		return;
	}

	if (@_) {
		$modDir = file( $modDir, @_ );

		if ( !-e $modDir ) {
			$self->_setError("file does '$modDir' not exist!");
			return;
		}
	}
	return $modDir;
}

=method my $path=$self->share(file);

my $absolute_path=$self->share();
my $absolute_path_to_file=$self->share('local','path','relative','to','modDir');

should work before installed and after make install.

=cut

sub share {
	my $self = shift or croak "Need myself!";
	use File::ShareDir qw(dist_dir dist_file);

	my $path;
	if ( !@_ ) {
		$path = $self->_modDir() || dist_dir();
	}
	else {
		$path = $self->_modDir( 'share', @_ ) || dist_file( 'MPX', @_ );
	}
	return $path;
}

__PACKAGE__->meta->make_immutable;
1;

