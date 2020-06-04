package WWW::API::Binance;
use 5.014;
use strict;
use warnings;
use WWW::API::Binance::Request;
use WWW::API::Binance::Request::Public;
use WWW::API::Binance::Request::Account;
use Carp;
use URI;
use URI::Escape;
use JSON::PP;
use Digest::SHA qw/hmac_sha256_hex/;
use Time::HiRes; qw//;
use Try::Tiny;

our $VERSION = "0.01";
our $BASEURL = 'https://api.binance.com';

sub new {
    my ($class, %param) = @_;

    for my $key (qw/api_key secret_key/) {
        croak "option '$key' is required" if !$param{$key};
    }

    return bless +{%param}, $class;
}

sub request {
    my ($self, $method, $path, @param) = @_;

    my $uri = URI->new($BASEURL);
    $uri->path($path);
    my @query_item = ();
    my ($key, $val);
    while (@param) {
        $key = shift(@param);
        $val = shift(@param);
        push @query_item, sprintf('%s=%s', $key, uri_escape($val));
    }
    my $query = join '&', @query_item;

    if (_is_public($path)) {
        $uri->query($query);
    } 
    else {
        if ($query !~ /timestamp=/) {
            my $time = int(Time::HiRes::time() * 1000);
            $query .= "&timestamp=$time";
        }
        my $sign = hmac_sha256_hex($query, $self->{secret_key});
        $uri->query("$query&signature=$sign");
    }
    
    return WWW::API::Binance::Request->new(
        $method, $uri->as_string,
        headers => +{'X-MBX-APIKEY' => $self->{api_key}},
    );
}

sub _is_public {
    my ($path) = @_;
    $path =~ m'^/api/v[0-9]+/' ? 1 : undef;
}

1;
__END__

=encoding utf-8

=head1 NAME

WWW::API::Binance - It's new $module

=head1 SYNOPSIS

    use WWW::API::Binance;

=head1 DESCRIPTION

WWW::API::Binance is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

