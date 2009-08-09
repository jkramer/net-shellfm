package Net::ShellFM;

use warnings;
use strict;

use IO::File;
use IO::Socket::INET;
use IO::Socket::UNIX;
use Carp;


=head1 NAME

Net::ShellFM - Interface to the Shell.FM radio player.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This module a simple interface to Shell.FMs TCP/UNIX socket interface, allowing
you to control it remotely.


    use Net::ShellFM;

    my $shc = new Net::ShellFM;

	# Play my personal station.
	$shc->play('lastfm://user/shell-monkey/personal');

	# Skip track.
	$shc->next;

	# Ban track.
	$shc->ban;

    ...

=head1 METHODS

=head2 new

=cut

sub new {
	my $class = shift;

	my $self = bless [ @_ ], $class;
}


=head2 play("lastfm://...")

Tune into the given station.

=cut

sub play {
	my ($self, $station) = @_;

	return $self->_send_command("play $station");
}


=head2 love

Love the currently played track.

=cut

sub love {
	my ($self) = @_;

	return $self->_send_command("love");
}


=head2 ban

Ban the currently played track.

=cut

sub ban {
	my ($self) = @_;

	return $self->_send_command("ban");
}


=head2 skip

Skip the currently played track.

=cut

sub skip {
	my ($self) = @_;

	return $self->_send_command("skip");
}


=head2 next

Alias for B<skip>.

=cut

sub next {
	my ($self) = @_;

	return $self->skip;
}


=head2 quit

Quit Shell.FM.

=cut

sub quit {
	my ($self) = @_;

	return $self->_send_command("quit");
}


=head2 format("format string")

Request information about the currently played track/station. Check the
Shell.FM manual ("man shell-fm") for a list of format flags.

=cut

sub format {
	my ($self, $format) = @_;

	return $self->_send_command_with_reply("info $format");
}


=head2 pause

Toggle pause/continue.

=cut

sub pause {
	my ($self) = @_;

	return $self->_send_command("pause");
}


=head2 discovery

Toggle discovery mode on/off.

=cut

sub discovery {
	my ($self) = @_;

	return $self->_send_command("discovery");
}


=head2 tag_artist("tag,another-tag,yet-another-tag")

Tag the artist with the given, comma-separated tags.

=cut

sub tag_artist {
	my ($self, $list) = @_;

	return $self->_send_command("tag-artist $list");
}


=head2 tag_album("tag,another-tag,yet-another-tag")

Tag the album with the given, comma-separated tags.

=cut

sub tag_album {
	my ($self, $list) = @_;

	return $self->_send_command("tag-album $list");
}



=head2 tag_track("tag,another-tag,yet-another-tag")

Tag the track with the given, comma-separated tags.

=cut

sub tag_track {
	my ($self, $list) = @_;

	return $self->_send_command("tag-track $list");
}


=head2 artist_tags

Get artist tags.

=cut

sub artist_tags {
	my ($self) = @_;

	return $self->_send_command_with_reply("artist-tags");
}


=head2 album_tags

Get album tags.

=cut

sub album_tags {
	my ($self) = @_;

	return $self->_send_command_with_reply("album-tags");
}


=head2 track_tags

Get track tags.

=cut

sub track_tags {
	my ($self) = @_;

	return $self->_send_command_with_reply("track-tags");
}


=head2 stop

Stop station.

=cut

sub stop {
	my ($self) = @_;

	return $self->_send_command("stop");
}


sub _send_command {
	my ($self, $command) = @_;

	my $socket = $self->_connect or return;

	return $socket->print($command, "\n");
}


sub _send_command_with_reply {
	my ($self, $command) = @_;

	my $socket = $self->_connect or return;

	return unless $socket->print($command, "\n");

	return $socket->getline;
}


sub _connect {
	my ($self) = @_;

	@$self = $self->_parse_config unless @$self;

	if(@$self == 1) {
		return $self->_unix_connect;
	}

	elsif(@$self == 2) {
		return $self->_inet_connect;
	}

	else {
		return;
	}
}


sub _unix_connect {
	my ($self) = @_;

	return new IO::Socket::UNIX(Peer => $self->[0]);
}


sub _inet_connect {
	my ($self) = @_;

	return new IO::Socket::INET(
		PeerHost => $self->[0],
		PeerPort => $self->[1],
	);
}


sub _parse_config {
	my $rc_path = $ENV{HOME} . '/.shell-fm/shell-fm.rc';

	if(-r $rc_path) {
		my $rc = new IO::File($rc_path);
		my %rc;

		while(defined(my $line = $rc->getline)) {
			chomp $line;

			if($line =~ /^\s*([^=\s]+)\s*=\s*(.*?)\s*$/) {
				$rc{$1} = $2;
			}
		}

		$rc->close;

		if($rc{bind}) {
			return ($rc{bind}, ($rc{port} || 54311));
		}
		elsif($rc{unix}) {
			return $rc{unix};
		}
	}

	return;
}


=head1 AUTHOR

Jonas Kramer, C<< <jkramer at nex.scrapping.cc> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-shellfm at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-ShellFM>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::ShellFM


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-ShellFM>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-ShellFM>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-ShellFM>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-ShellFM/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Jonas Kramer, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
