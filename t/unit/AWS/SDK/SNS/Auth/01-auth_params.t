#!/usr/bin/env perl
use Test::Most;

use AWS::SDK::SNS;

my $config = {
    sns => {
        url => "http://sns.eu-west-1.amazonaws.com/",
        topics      => {
            test => "arn:aws:sns:eu-west-1:868002146347:testtopic"
        }
    },
    aws_access_key => "bar",
    aws_secret_key => "foo",
};

subtest 'Params' => sub {
    my $sns = AWS::SDK::SNS->new(timestamp => '2015-08-06T15:00:00Z', config => $config, topic => 'test');

    my $auth_params = $sns->auth_params;

    is(ref $auth_params => 'HASH', 'Correct data type returned');

    for my $key (qw/Version AWSAccessKeyId SignatureVersion SignatureMethod Timestamp/){
        ok($auth_params->{$key}, "Auth Parameters contains $key");
    }

    is($auth_params->{Version} => '2010-03-31', 'Correct API Version');
    is($auth_params->{SignatureVersion} => 2, 'Correct Signature Version');
    is($auth_params->{SignatureMethod} => 'HmacSHA256', 'Correct Signature Encryption Method');
    is($auth_params->{Timestamp} => '2015-08-06T15:00:00Z', 'Correct Timestamp string');
    is($auth_params->{AWSAccessKeyId} => $config->{aws_access_key}, 'Correct AWS Access Key ID');
};

done_testing;
