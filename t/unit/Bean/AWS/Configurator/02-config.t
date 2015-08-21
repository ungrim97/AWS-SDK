#!/usr/bin/env perl
use Test::Most;

use Bean::AWS::SNS;
use FindBin;
use Test::Fatal;
use Test::Warnings;

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

subtest 'valid config hash' => sub {
    my $sns;
    cmp_deeply(
        exception {
            $sns = Bean::AWS::SNS->new(topic => 'test', config => $config);
        },
        undef,
        'No exception thrown',
    );

    check_config($sns, $config);
};

subtest 'config from file' => sub {
    my $sns;
    cmp_deeply(
        exception {
            $sns = Bean::AWS::SNS->new(topic => 'test', config_dir => $FindBin::Bin);
        },
        undef,
        'No exception thrown',
    );

    check_config($sns, $config);
};

subtest 'invalid params' => sub {
    subtest 'Missing AWS Access Key' => sub {
        my $config = {%$config};
        delete $config->{aws_access_key};
        cmp_deeply(
            exception {
                my $sns = Bean::AWS::SNS->new(topic => 'test', config => $config);
            }.'',
            re(qr/requires key "aws_access_key"/),
            'Got correct error',
        );
    };

    subtest 'Missing AWS Access Key' => sub {
        my $config = {%$config};
        delete $config->{aws_secret_key};
        cmp_deeply(
            exception {
                my $sns = Bean::AWS::SNS->new(topic => 'test', config => $config);
            }.'',
            re(qr/requires key "aws_secret_key"/),
            'Got correct error',
        );
    };

    subtest 'Missing AWS Access Key' => sub {
        my $config = {%$config};
        delete $config->{sns}{url};
        cmp_deeply(
            exception {
                my $sns = Bean::AWS::SNS->new(topic => 'test', config => $config);
            }.'',
            re(qr/requires key "url"/),
            'Got correct error',
        );
    };

    subtest 'Missing AWS Access Key' => sub {
        my $config = {%$config};
        delete $config->{sns}{topics};
        cmp_deeply(
            exception {
                my $sns = Bean::AWS::SNS->new(topic => 'test', config => $config);
            }.'',
            re(qr/requires key "topics"/),
            'Got correct error',
        );
    };
};

done_testing;

sub check_config {
    my ($sns) = @_;

    ok($sns->config, 'Config set');
    is(ref $sns->config => 'HASH', '  -> is a HashRef');
    is($sns->config->{aws_access_key} => $config->{aws_access_key}, '  -> AWS Access Key set');
    is($sns->config->{aws_secret_key} => $config->{aws_secret_key}, '  -> AWS Secret Key set');
    is(ref $sns->config->{sns}{url}   => 'URI::http', '  -> String URL coerced into a URI Object');
    is($sns->config->{sns}{url}       => $config->{sns}{url}, '  -> URL set');
    is($sns->config->{sns}{topics}{test}   => $config->{sns}{topics}{test}, '  -> Topic ARN set');
}
