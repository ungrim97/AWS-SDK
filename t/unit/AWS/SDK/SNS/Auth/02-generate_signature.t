#!/usr/bin/env perl
use Test::Fatal;
use Test::Most;
use Test::Warnings;

{
    package TestsFor::AWS::SDK::SNS::Auth;

    use Moo;

    use AWS::SDK::GenericTypes qw/URL/;
    use Test::Most;
    use Safe::Isa;

    sub config {}

    with 'AWS::SDK::SNS::Auth';

    sub encrypt_test {
        my ($self, $url) = @_;
        ok(1, 'Encrypt method for signature_method correctly called');
        ok($url, 'url value passed to encrypt method');
        ok(URL->check($url, '  -> With correct type'));
        ok($url->$_isa('URI'), '  -> coerced correctly from string');
        return $url;
    };
}

subtest 'generate signature' => sub {
    plan tests => 5;
    my $signer = TestsFor::AWS::SDK::SNS::Auth->new(signature_method => 'test');

    my $url = 'http://this.is.a.test.url.com?some=query&params=here';
    my $signed_url = $signer->generate_signature($url);
    is($signed_url => $url, 'Return from generate_signature correct');
};

subtest 'generate signature - no encrypt method' => sub {
    plan tests => 1;
    my $signer = TestsFor::AWS::SDK::SNS::Auth->new(signature_method => 'invalid');

    cmp_deeply(
        exception {$signer->generate_signature('http://this.is.a.test.url.com?some=query&params=here')},
        re(qr/No Encryption method found for invalid/),
        'Correct exception thrown for no existant encryption method'
    );
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
