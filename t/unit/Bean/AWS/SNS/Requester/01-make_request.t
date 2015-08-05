#!/usr/bin/env perl
use Test::Most;

use Bean::AWS::SNS;
use Test::LWP::UserAgent;
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

subtest 'Successful Response' => sub {
    my $publisher = Bean::AWS::SNS->new(
        topic   => 'test',
        ua      => generate_test_useragent(),
        config  => $config
    );

    my $response = $publisher->make_request($publisher->config->{sns}{url}.'/success', {Action => 'Publish'});

    ok($response, 'make_request returned a response');
    is($response->code => 200, '  -> was successfull');
    is($response->decoded_content => success_xml(), '  -> contains the right xml data');
};

done_testing;

sub generate_test_useragent {
    my $useragent = Test::LWP::UserAgent->new();
    $useragent->map_response(
        qr#/success# => HTTP::Response->new('200', 'OK', ['Content-Type' => 'text/xml'], success_xml()),
    );
    $useragent->map_response(
        qr#/fail# => HTTP::Response->new('500', 'InternalFailure', ['Content-Type' => 'text/plain'], ''),
    );
    return $useragent;
}

sub success_xml {
    return <<'XML';
<PublishResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
  <PublishResult>
    <MessageId>94f20ce6-13c5-43a0-9a9e-ca52d816e90b</MessageId>
  </PublishResult>
  <ResponseMetadata>
    <RequestId>f187a3c1-376f-11df-8963-01868b7c937a</RequestId>
  </ResponseMetadata>
</PublishResponse>
XML
}
