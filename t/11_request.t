use strict;
use Test::More;
use WWW::API::Binance;

# Example request : https://www.binance.com/restapipub.html#user-content-signed-endpoint-security

my $binance = WWW::API::Binance->new(
    api_key => 'vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A',
    secret_key => 'NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j'
);

isa_ok $binance, 'WWW::API::Binance';

can_ok $binance, qw/request/;

my $req = $binance->request(
    POST        => '/api/v3/order', 
    symbol      => 'LTCBTC',
    side        => 'BUY',
    type        => 'LIMIT',
    timeInForce => 'GTC',
    quantity    => 1,
    price       => 0.1,
    recvWindow  => 5000,
    timestamp   => 1499827319559,
);

is $req->uri->query, 'symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1&price=0.1&recvWindow=5000&timestamp=1499827319559&signature=c8db56825ae71d6d79447849e617115f4a920fa2acdcab2b053c4b2838bd6b71';
is_deeply $req->param, +{headers => {
    "X-MBX-APIKEY" => "vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A",
}};

done_testing;