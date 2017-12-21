package WWW::API::Binance;
use 5.014;
use strict;
use warnings;
use WWW::API::Binance::Request;
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
    $path =~ m'^/api/v1/' ? 1 : undef;
}

sub ping {
    my ($self) = @_;

    my $is_success = 1;
    my $res;

    try {
        $res = $self->request(GET => '/api/v1/ping')->do;
    } catch {
        $is_success = 0;
    };

    if (ref($res) ne 'HASH') {
        $is_success = 0;
    }

    return $is_success;
}

sub server_time {
    my ($self) = @_;

    my $res = $self->request(GET => '/api/v1/time')->do;

    return $res->{serverTime};
}

sub order_book {
    my ($self, $symbol1, $symbol2, %param) = @_;

    my $res = $self->request(
        GET => '/api/v1/depth', 
        symbol => $symbol1.$symbol2, 
        %param
    )->do;
    for my $key (qw/asks bids/) {
        $res->{$key} = [map {+{
            price    => $_->[0],
            quantity => $_->[1],
            opts     => $_->[2],
        }} @{$res->{$key}}];
    }

    return $res;
}

sub aggregate_trades {
    my ($self, $symbol1, $symbol2, %param) = @_;
    
    my $res = $self->request(
        GET => '/api/v1/aggTrades',
        symbol => $symbol1.$symbol2,
        %param
    )->do;

    return [map {+{
        "aggregateTradeId" => $_->{a},
        "price"            => $_->{p},
        "quantity"         => $_->{q},
        "firstTradeId"     => $_->{f},
        "lastTradeId"      => $_->{l},
        "timestamp"        => $_->{T},
        "buyerWasMaker"    => $_->{m},
        "tradeWasBestPriceMatch" => $_->{M},
    }} @$res];
}

sub klines {
    my ($self, $symbol1, $symbol2, %param) = @_;

    my $res = $self->request(
        GET => '/api/v1/klines',
        symbol => $symbol1.$symbol2,
        %param
    )->do;

    return [map {+{
        openTime    => $_->[0],
        open        => $_->[1],
        high        => $_->[2],
        low         => $_->[3],
        close       => $_->[4],
        volume      => $_->[5],
        closeTime   => $_->[6],
        quoteAssetVolume => $_->[7],
        numOfTrades => $_->[8],
        takerBuyBaseAssetVolume => $_->[9],
        takerBuyQuoteAssetVolume => $_->[10],
        canBeIgnored => $_->[11],
    }} @$res];
}

sub ticker_24h {
    my ($self, $symbol1, $symbol2) = @_;
    
    return $self->request(
        GET => '/api/v1/ticker/24hr',
        symbol => $symbol1.$symbol2,
    )->do;
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

