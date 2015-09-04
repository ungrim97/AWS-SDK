#!/usr/bin/env perl
use Test::Most;

use AWS::SDK::SNS;
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

subtest 'Valid XML' => sub {
    my $publisher = AWS::SDK::SNS->new(topic => 'test', config => $config);

    my $message_id = $publisher->_get_message_id(success_xml());
    ok($message_id, 'Found Message ID');
    is($message_id => '94f20ce6-13c5-43a0-9a9e-ca52d816e90b', '  -> With correct string');
};

subtest 'Empty XML string' => sub {
    my $publisher = AWS::SDK::SNS->new(topic => 'test', config => $config);

    my $message_id = $publisher->_get_message_id('');
    ok(!$message_id, 'No message id found');
};

done_testing;

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
