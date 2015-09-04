#!/usr/bin/env perl
use Test::Most;

use AWS::SDK::SNS;
use FindBin;
use Test::Fatal;
use Test::Warnings;

subtest 'valid dir' => sub {
    my $sns;
    cmp_deeply(
        exception {
            $sns = AWS::SDK::SNS->new({config_dir => $FindBin::Bin, topic => 'test'}),
        },
        undef,
        'No exception thrown'
    );

    is($sns->config_dir => $FindBin::Bin, 'SNS has correct path set');
};

subtest 'invalid dir' => sub {
    my $sns;
    cmp_deeply(
        exception {
            $sns = AWS::SDK::SNS->new({config_dir => 'non/existent/dir', topic => 'test'}),
        },
        re(qr#non/existent/dir directory doesn't exist#),
        'Correct exception thrown'
    );

    ok(!$sns, 'SNS object not created');
};

done_testing;
