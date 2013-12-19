package MPX::Test;

use strict;
use warnings;

use FindBin;
use Cwd qw(realpath);
#use File::Spec;
use Path::Class;

use base 'Exporter';

our @EXPORT_OK = qw(
	testEnviron
);

=func testEnviron ([$attach,] [$anotherAttach,] ...);

If $signal (optional) is 'config' absolute path of the configuration file is returned. 
Otherwise configuration directory (directory in which config resides) is returned.

If $attach is specified the string $attach is added to configuration directory. You
may add multiple $attach if you like.

If $signal is 'config' and $attach is added, $attach is ignored.

=cut

sub testEnviron {
	my $dir    = dir ( file($FindBin::Bin)->parent, 't', 'cases' );
	
	if (@_) {
		$dir = file( $dir, @_ );
	}
	return $dir;
}
1;