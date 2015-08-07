#!/usr/bin/env perl
use Test::Most;

use Bean::AWS::SNS;
use Test::MockObject::Extends;
use Test::Warnings;
use URI;

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

subtest 'hmac_sha256' => sub {
    my $sns = Bean::AWS::SNS->new(config => $config, topic => 'test_topic');
    my $mocked_sns = Test::MockObject::Extends->new($sns);
    $mocked_sns->mock(encode_params => sub {return join '&', map {"$_=".$_[1]{$_}} sort keys %{$_[1]}});
    $mocked_sns->mock(generate_signature => sub {return 'EncryptedSignature'});
    $mocked_sns->mock(auth_params => sub {return {}});
    my $url = URI->new($sns->config->{sns}{url});

    my $signed_url = $sns->sign_request($url, {foo => 'bar', baz => 1});
    is($signed_url->query => 'baz=1&foo=bar&Signature=EncryptedSignature', 'Got correct signature');
};

done_testing;
