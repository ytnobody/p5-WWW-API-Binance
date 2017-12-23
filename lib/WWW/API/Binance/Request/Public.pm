package WWW::API::Binance::Request::Public;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/
    ping server_time order_book agregate_trades klines 
    ticker_24h ticker_price ticker_book
/;

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

sub ticker_price {
    my ($self, $symbol1, $symbol2) = @_;

    return $self->request(
        GET => '/api/v1/ticker/price',
        symbol => $symbol1.$symbol2
    )->do;
}

sub ticker_book {
    my ($self, $symbol1, $symbol2) = @_;

    return $self->request(
        GET => '/api/v1/ticker/bookTicker',
        symbol => $symbol1.$symbol2
    )->do;
}

1;