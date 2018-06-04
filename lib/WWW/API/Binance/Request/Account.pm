package WWW::API::Binance::Request::Account;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/
    order buy sell query_order cancel_order
    active_orders all_orders
    account my_trades
/;

sub order {
    my ($self, $symbol1, $symbol2, %param) = @_;

    return $self->request(
        POST => '/api/v3/order',
        symbol => $symbol1.$symbol2,
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

sub buy {
    my ($self, $symbol1, $symbol2, %param) = @_;
    
    return $self->order($symbol1, $symbol2, 
        side => 'BUY', 
        %param
    );
}

sub sell {
    my ($self, $symbol1, $symbol2, %param) = @_;
    
    return $self->order($symbol1, $symbol2, 
        side => 'SELL', 
        %param
    );
}

sub query_order {
    my ($self, $symbol1, $symbol2, %param) = @_;

    return $self->request(
        GET => '/api/v3/order',
        symbol => $symbol1.$symbol2,
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

sub cancel_order {
    my ($self, $symbol1, $symbol2, %param) = @_;

    return $self->request(
        DELETE => '/api/v3/order',
        symbol => $symbol1.$symbol2,
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

sub active_orders {
    my ($self, $symbol1, $symbol2, %param) = @_;

    return $self->request(
        GET => '/api/v3/openOrders',
        symbol => $symbol1.$symbol2,
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

sub all_orders {
    my ($self, $symbol1, $symbol2, %param) = @_;

    return $self->request(
        GET => '/api/v3/allOrders',
        symbol => $symbol1.$symbol2,
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

sub account {
    my ($self, %param) = @_;

    return $self->request(
        GET => '/api/v3/account',
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

sub my_trades {
    my ($self, $symbol1, $symbol2, %param) = @_;

    return $self->request(
        GET => '/api/v3/myTrades',
        symbol => $symbol1.$symbol2,
        timestamp => $self->server_time + 1000,
        %param
    )->do;
}

1;