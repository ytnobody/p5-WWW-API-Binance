package WWW::API::Binance::Request;
use strict;
use warnings;
use HTTP::Tiny;
use Try::Tiny;
use Carp;
use URI;
use JSON::PP qw/decode_json/;

our $AGENT = HTTP::Tiny->new(agent => 'WWW::API::Binance/0.01');

sub new {
    my ($class, $method, $path, %param) = @_;

    return bless [$method, $path, +{%param}], $class;
}

sub method {
    shift->[0];
}

sub uri {
    URI->new(shift->[1]);
}

sub param {
    shift->[2];
}

sub do {
    my ($self) = @_;

    my $res = $AGENT->request(@$self);
    if (!$res->{success}) {
        my $err;
        try { 
            $err = decode_json($res->{content});
        } catch {
            croak $res->{content};
        };
        croak sprintf(
            "%s %s: %s (code=%s)", 
            $res->{status}, 
            $res->{reason}, 
            $err->{msg},
            $err->{code}
        );
    }

    return decode_json($res->{content});
}

1;