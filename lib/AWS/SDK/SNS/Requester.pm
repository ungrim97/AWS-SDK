package AWS::SDK::SNS::Requester;

=head1 NAME

AWS::SDK::SNS::Requester - Role to handle making requests to SNS

=head1 SUMMARY

    with 'AWS::SDK::SNS::Requester';

    ...

    my $response = $obj->make_request('http://my.base.url.com', {my => 'params'});
    my $signed_url = $obj->sign_request($url->new('http://my.base.url.com'), {my => 'params'});
    my $encode_query_string = $obj->encode_params({my => 'Params'});

=head1 DESCRIPTION

A Role designed to encapsulate the logic responsible for making requests to the
Amazon Simple Notification Service

=cut

use Moo::Role;

use AWS::SDK::Exception;
use AWS::SDK::Types qw/URL/;
use HTTP::Response;
use HTTP::Tiny;
use URI::Escape qw/uri_escape_utf8 uri_escape/;
use Type::Params qw/compile/;
use Types::Standard qw/InstanceOf Optional Object HashRef/;

=head1 REQUIRED METHODS

Consuming classes must provide the following methods

=head2 auth_params

A method that provides the common parameters used by Amazon
to verify and Authenticate the request.

=head2 generate_signature

A method that accepts an URI object and generates a digital
signature returned as a string

=cut

requires 'auth_params';
requires 'generate_signature';

=head1 ATTRIBUTES

=head2 ua

A UserAgent for making the request. Must be an
instance of the HTTP::Tiny class (or subclasses)

=cut

has ua => (
    is      => 'ro',
    isa     => InstanceOf['HTTP::Tiny'],
    lazy    => 1,
    default => sub {HTTP::Tiny->new()}
);

=head1 INSTANCE METHODS

=head2 make_request ('BASE_URL', \%query_params)

Merges the provided optional query parameters with the
required Auth Parameters from config, escapes them and
then makes a request to the AWS::SDK SNS API at BASE_URL with
the resulting query string.

Returns a HTTP::Response object or throws and exception

=cut
{
    my $check = compile(Object, URL, Optional[HashRef]);
    sub make_request {
        my ($self, $url, $params) = $check->(@_);

        my $signed_url = $self->sign_request($url, $params);

        return try {
            my $response = $self->ua->post($signed_url);
            return HTTP::Response->new(
                $response->{status},
                $response->{reason},
                [%{$response->{headers}}],
                $response->{content},
            );

            # TODO: Do we need to handle failed (non 2xx) responses? Retry?
        } catch {
            # TODO: Handle aborted requests
            AWS::SDK::Exception::FailedRequest->throw({message => $_});
        }
    }
}

=head2 encode_params (\%params)

Takes a hashref of query parameter key value pairs encoded as a
UTF8 Byte string then escapes any metacharacters. Expect non encoded
characters. Returns a string suitable as the query part of a URL.

=cut

sub encode_params {
    my ($self, $params) = @_;

    return join('&', (map {
        "$_=".uri_escape($params->{$_}, '^A-Za-z0-9\-_.~')
    } sort keys %$params));
}

=head2 sign_request (URI, \%params)

AWS::SDK SNS expects all calls to its API to be signed. The signature
is the result of HMAC_SHA256 encrypting the encoded URL query string.

This method takes a URI Object representing the root Url and a hashref of
parameters. URI escapes the parameters along with the required
L<AWS::SDK::SNS::Auth::auth_params|auth_params> and generates a digital
signature before both the signature and the encoded parameters are used to set
the L<URI::query|query> string on the URI object

=cut

sub sign_request {
    my ($self, $url, $params) = @_;

    my $encoded_query = $self->encode_params({%{$params||{}}, %{$self->auth_params}});

    $url->query($encoded_query);

    my $signature = $self->generate_signature($url);
    $url->query($encoded_query.'&'.$self->encode_params({
        Signature => $signature,
    }));
    return $url;
}

1;
