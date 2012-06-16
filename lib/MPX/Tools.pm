#!/usr/bin/perl
#ABSTRACT: some helpers for MPX
use strict;
use warnings;

package MPX::Tools;

use Moose;
use namespace::autoclean;
use Carp qw(croak carp confess);
use Params::Util qw (_INSTANCE);
use XML::LiBXML;
use XML::LibXSLT;
use File::Spec;
use Cwd qw(realpath);
has 'error' => ( is => 'ro', isa => 'Str', writer => '_setError', );
has 'mpxXsd' => ( is => 'ro', isa => 'Str' );
has 'fixXsl' => ( is => 'ro', isa => 'Str' );

#error has error message (if any, gets set internally)
#mpxXsd has location of mpx schema file, gets set during BUILD
#fixXsl has location of mpxFix.xsl file, gets set during BUILD

=head2 SYNOPSIS

my $tb=new MPX::Tools; #toolbox

my $bool=$tb->validateMPX($dom); #true if validates or false if not

	if (!$tb->validateMPX($dom)) {
		print $tb->error
	}

my $outputDom=$tb->fix ($inputDom); 

my $bool=$tb->laxTests ($dom) #true if all tests pass or false if not

	if (!$tb->simpleTests ($dom)) {
		print $tb->error
	}

my $bool=$tb->strictTests ($dom) #true if all tests pass or false if not

	if (!$tb->strictTests ($dom)) {
		print $tb->error
	}

=method print $tb->error

Don't use the method error to test for error since error message is not set on
every error. Instead use the actual boolean return value:
	$tb->strictTests ($dom) or return

=cut

=method my $outputDom=$tb->fix ($inputDom); 


=cut

sub fix {
	my $self = shift or croak "Need myself!";
	my $dom = _INSTANCE( shift, 'XML::LibXML::Document' );

	if ( !$dom ) {
		$self->_setError('Param not of kind \'XML::LibXML::Document\'');
		return;
	}

	print "GET HERE".$self->{fixXsl}."\n";
	my $styleDoc = XML::LibXML->load_xml( location => $self->{fixXsl} );

	if ( !$styleDoc ) {
		$self->_setError($self->{fixXsl}.' not loaded');
		return;
	}

	my $xslt       = XML::LibXSLT->new();
	my $stylesheet = $xslt->parse_stylesheet($styleDoc);

	if ( !$stylesheet ) {
		$self->_setError('stylesheet doesn\'t exist');
		return;
	}



	my $result = $stylesheet->transform($dom);

	if ( !$result ) {
		$self->_setError('result  doesn\'t exist');
		return;
	}

	return $result;
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

	my $xmlschema = XML::LibXML::Schema->new( location => $self->{mpxXsd} );
	
	eval { $xmlschema->validate($dom); };

	if ($@) {
		$self->_setError("validation failed: $@");
		return;
	}
	return 1;    #validates
}

###
### private
###

sub BUILD {
	my $self = shift or croak "Need myself!";
	my $modDir = $self->_modDir;

	my %load = (
		mpxXsd => File::Spec->catfile( $modDir, 'xsd', 'mpx.xsd' ),
		fixXsl => File::Spec->catfile( $modDir, 'xsl', 'mpxFix.xsl' ),
	);

	foreach my $key ( keys %load ) {
		$self->{$key} = $load{$key};
		if ( !-e $self->{$key} ) {
			croak "$key not found at: $load{$key}";
		}
		#print "$key:$load{$key}\n";
	}
}

sub _modDir {
	my $self = shift or croak "Need myself!";
	my $modDir = __FILE__;
	$modDir =~ s,\.pm$,,;
	$modDir = realpath( File::Spec->catfile( $modDir, '..','..','..' ) );

	if ( !-d $modDir ) {
		$self->_setError ("modDir does not exist! ($modDir)");
		return;
	}
	#print "modDir:$modDir\n";
	return $modDir;
}

__PACKAGE__->meta->make_immutable;
1;

