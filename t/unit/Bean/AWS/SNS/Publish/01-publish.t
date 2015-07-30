#!/usr/bin/env perl
use Bean::AWS::SNS;

use FindBin;
use Test::Fatal;
use Test::MockObject::Extends;
use Test::Most;
use Test::Warnings;

use Bean::AWS::Exception;

subtest 'Publish -> success' => sub {
    my $publisher = Bean::AWS::SNS->new(topic => 'test', config_dir => $FindBin::Bin);
    $publisher = Test::MockObject::Extends->new($publisher);
    $publisher->mock('make_request' => sub {return success_xml()});

    my $message_id = $publisher->publish({
        subject => 'Test Message',
        message => 'This is a test message',
    });

    ok($message_id, 'Message ID returned');
    is($message_id => '94f20ce6-13c5-43a0-9a9e-ca52d816e90b', '  -> With correct id');
};

subtest 'Publish -> fail' => sub {
    my $publisher = Bean::AWS::SNS->new(topic => 'test', config_dir => $FindBin::Bin);
    $publisher = Test::MockObject::Extends->new($publisher);
    $publisher->mock('make_request' => sub {return fail_xml()});

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
    my $publisher = Bean::AWS::SNS->new(topic => 'test', config_dir => $FindBin::Bin);
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
            re(qr/SNS Message content is invalid for sending via SNS/),
            'Publish Failed correctly'
        );
    };

    subtest 'Invalid args hash' => sub {
        cmp_deeply(
            exception {
                my $message_id = $publisher->publish({}),
            }.'',
            re(qr/message is a required parameter/),
            'Publish Failed correctly'
        );
    };
};

done_testing;

sub fail_xml {
    Bean::AWS::Exception::FailedRequest->throw({message => 'InternalFailure'});
}

sub success_xml {
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

    return {
        content => $content,
        success => 1,
        status  => 200,
        reason  => 'Success',
    };
}
