package WWW::API::Binance::WSS;
use strict;
use warnings;
use Protocol::WebSocket::Client;
use JSON::PP;
use Carp;

our $BASEURL = 'wss://stream.binance.com:9443';

sub new {
    my ($self) = @_;
    return bless +{
        streams => +{},
        triggers => +{},
    };
}

sub on {
    my ($self, $trigger, $code) = @_;
    $self->{triggers}{$trigger} = $code;
}

sub on_connect {
    my ($self, $code) = @_;
    $self->on(connect => $code);
}

sub on_read {
    my ($self, $code) = @_;
    $self->on(read => $code);
}

sub on_write {
    my ($self, $code) = @_;
    $self->on(write => $code);
}

sub add_stream {
    my ($self, $symbol1, $symbol2, $stream_name) = @_;
    my $stream_id = sprintf('%s%s@%s', lc($symbol1), lc($symbol2), $stream_name);
    $self->{streams}{$stream_id} = 1;
}

sub aggregate_trade {
    my ($self, $symbol1, $symbol2) = @_;
    $self->add_stream($symbol1, $symbol2, 'aggTrade');
}

sub trade {
    my ($self, $symbol1, $symbol2) = @_;
    $self->add_stream($symbol1, $symbol2, 'trade');
}

sub kline {
    my ($self, $symbol1, $symbol2, $interval) = @_;
    $interval ||= '1m';
    $self->add_stream($symbol1, $symbol2, 'kline_'.$interval);
}

sub ticker {
    my ($self, $symbol1, $symbol2) = @_;
    $self->add_stream($symbol1, $symbol2, 'ticker');
}

sub all_market_ticker {
    my ($self) = @_;
    $self->add_stream('!', 'ticker', 'arr');
}

sub partial_book_depth {
    my ($self, $symbol1, $symbol2, $levels) = @_;
    $levels ||= 10;
    $self->add_stream($symbol1, $symbol2, 'depth'.$levels);
}

sub diff_depth {
    my ($self, $symbol1, $symbol2) = @_;
    $self->add_stream($symbol1, $symbol2, 'depth');
}

sub connect {
    my ($self) = @_;
    my $url = $BASEURL. '/stream?streams='. join('/', keys %{$self->{streams}});
    my $stream = Protocol::WebSocket::Client->new(url => $url);
    my $code;
    for my $trigger (qw/connect error read write eof frame/) {
        $code = $self->{triggers}{$trigger} || sub {};
        $stream->on($trigger => $code);
    }
    $self->{stream} = $stream->connect;
}

sub read {
    my ($self) = @_;
    $self->{stream}->read;
}

sub disconnect {
    my ($self) = @_;
    $self->{stream}->disconnect;
}

1;