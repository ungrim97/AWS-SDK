#!/usr/bin/env perl
use Test::Most;

use Bean::AWS::SNS;
use Encode qw/encode_utf8/;
use Test::Warnings;

my $config = {
    sns => {
        url => "http://sns.eu-west-1.amazonaws.com/",
        topics      => {
            test_topic => "arn:aws:sns:eu-west-1:868002146347:testtopic"
        }
    },
    aws_access_key => "bar",
    aws_secret_key => "foo",
};

subtest 'encode - ASCII' => sub {
    my $sns = Bean::AWS::SNS->new(topic => 'test_topic', config => $config);

    my $encoded_query = $sns->encode_params({
        foo => 'bar',
        baz => 'boo',
    });

    is($encoded_query => 'baz=boo&foo=bar', 'Encoded correctly');
};

subtest 'encode - UTF8 bytes' => sub {
    my $sns = Bean::AWS::SNS->new(topic => 'test topic', config => $config);

    my $encoded_query = $sns->encode_params({
        foo => encode_utf8("\x{2f96}"),
        bar => 'baz',
    });

    is($encoded_query => 'bar=baz&foo=%E2%BE%96', 'Encoded bytes correctly');
};

done_testing;
