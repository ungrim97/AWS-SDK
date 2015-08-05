#!/usr/bin/env perl
use Test::Most;

use Bean::AWS::SNS;
use Bean::AWS::Exception;
use Test::Fatal;
use Test::MockObject::Extends;
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

subtest 'Publish -> success' => sub {
    my $publisher = Bean::AWS::SNS->new(topic => 'test', config => $config);
    $publisher = Test::MockObject::Extends->new($publisher);
    $publisher->mock('make_request' => sub {return success_response()});

    my $message_id = $publisher->publish({
        subject => 'Test Message',
        message => 'This is a test message',
    });

    ok($message_id, 'Message ID returned');
    is($message_id => '94f20ce6-13c5-43a0-9a9e-ca52d816e90b', '  -> With correct id');
};

subtest 'Publish -> fail' => sub {
    my $publisher = Bean::AWS::SNS->new(topic => 'test', config => $config);
    $publisher = Test::MockObject::Extends->new($publisher);
    $publisher->mock('make_request' => sub {return fail_response()});

    cmp_deeply(
        exception {
            my $message_id = $publisher->publish({
                subject => 'Test Message',
                message => 'This is a test message',
            })
        }.'',
        re(qr/InternalFailure/),
        'Publish Failed correctly'
    );
};

subtest 'Publish -> invalid args' => sub {
    my $publisher = Bean::AWS::SNS->new(topic => 'test', config => $config);
    $publisher = Test::MockObject::Extends->new($publisher);
    $publisher->mock('make_request' => sub {return fail 'Should have died before now'});

    subtest 'Invalid subject' => sub {
        cmp_deeply(
            exception {
               my $message_id = $publisher->publish({
                    subject => scalar('1' x 101),
                    message => 'This is a test message',
                }),
            }.'',
            re(qr/SNS Message subject is invalid for sending via SNS/),
            'Publish Failed correctly'
        );
    };

    subtest 'Invalid Message' => sub {
        cmp_deeply(
            exception {
                my $message_id = $publisher->publish({
                    subject => 'Test Subject',
                    message => join('', (1) x 256001), # A very long message
                }),
            }.'',
            re(qr/SNS Message content is too long for sending via SNS/),
            'Publish Failed correctly'
        );
    };

    subtest 'Invalid args hash' => sub {
        cmp_deeply(
            exception {
                my $message_id = $publisher->publish({}),
            }.'',
            re(qr/requires key "message" to appear in hash/),
            'Publish Failed correctly'
        );
    };
};

done_testing;

sub fail_response {
    Bean::AWS::Exception::FailedRequest->throw({message => 'InternalFailure'});
}

sub success_response {
    my $content = <<'XML';
<PublishResponse xmlns="http://sns.amazonaws.com/doc/2010-03-31/">
  <PublishResult>
    <MessageId>94f20ce6-13c5-43a0-9a9e-ca52d816e90b</MessageId>
  </PublishResult>
  <ResponseMetadata>
    <RequestId>f187a3c1-376f-11df-8963-01868b7c937a</RequestId>
  </ResponseMetadata>
</PublishResponse>
XML

    HTTP::Response->new('200', 'Ok', ['Content-Type' => 'text/xml'], $content);
}
