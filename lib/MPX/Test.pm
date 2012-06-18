package MPX::Test;

use strict;
use warnings;

use FindBin;
use Cwd qw(realpath);
use File::Spec;

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
	my $dir    = File::Spec->catfile( $FindBin::Bin, '..', 't', 'cases' );
	my $return=$dir;
	
	if (@_) {
		foreach my $item (@_) {
			$return=File::Spec->catfile($return, $item);
		}
	}
	return $return;
}
1;