#!/usr/bin/env perl
use Test::Most;

use Digest::SHA qw/hmac_sha256_base64/;
use Test::Fatal;

{
    package TestsFor::AWS::SDK::SNS::Auth;

    use Moo;

    sub config {return {aws_secret_key => 'testkey'}}

    with 'AWS::SDK::SNS::Auth';
}

subtest 'HmacSHA256 signature' => sub {
    my $signer = TestsFor::AWS::SDK::SNS::Auth->new();

    my $url = 'http://this.is.a.test.url.com/?with=a&query=string';
    my $signature = $signer->encrypt_HmacSHA256($url);
    my $expected_signature = hmac_sha256_base64(
        "POST\nthis.is.a.test.url.com\n/\nwith=a&query=string",
        'testkey',
    );
    $expected_signature .= '=' while length($expected_signature) % 4;
    is($signature => $expected_signature, 'Signature generated correctly');
};

subtest 'generate signature - invalid url' => sub {
    plan tests => 1;
    my $signer = TestsFor::AWS::SDK::SNS::Auth->new();

    cmp_deeply(
        exception {$signer->generate_signature('This is not a valid url string')}.'',
        re(qr/did not pass type constraint "URL"/),
        'Correct exception thrown for no existant encryption method'
    );
};

done_testing;
