requires 'perl', '5.014';

requires 'Digest::SHA';
requires 'URI';
requires 'Net::SSLeay';
requires 'Time::HiRes';
requires 'Try::Tiny';
requires 'Protocol::WebSocket';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

