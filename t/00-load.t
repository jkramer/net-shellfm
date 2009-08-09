#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::ShellFM' );
}

diag( "Testing Net::ShellFM $Net::ShellFM::VERSION, Perl $], $^X" );
