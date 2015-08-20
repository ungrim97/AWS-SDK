package Bean::AWS::SNS::Auth;

use Moo::Role;

use Bean::AWS::GenericTypes qw/URL/;
use DateTime;
use Digest::SHA qw/hmac_sha256_base64/;
use Type::Params qw/compile/;
use Types::Standard qw/Object/;
use URI::Escape qw/uri_escape/;

=head1 REQUIRED METHODS

=head2 config

A method that returns a HashRef of configuration details. This is
used to retrieve the aws_secret_key and aws_access_key.

=cut

requires 'config';

=head1 ATTRIBUTES

=head2 signature_version

Stores the current AWS Signature Version in use.

Default: 2

=cut

has signature_version => (is => 'ro', lazy => 1, default => 2);

=head2 signature_method

Stores the name of the Encryption method by which the digital Signature
is generated

Default: HmacSHA256

=cut

has signature_method  => (is => 'ro', lazy => 1, default => 'HmacSHA256');

=head2 timestamp

Stores the ISO8601 string value of the request

Default: Current Time.

=cut

has timestamp         => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return DateTime->now(time_zone => 'UTC', locale => 'en_UK');
    }
);

=head2 api_version

Version of API for which the calls are made

Default: 2010-03-31

=cut

has api_version => (is => 'ro', lazy => 1, default => '2010-03-31');

=head1 INSTANCE METHODS

=head2 auth_params

Returns a HashRef of key value pairs of the specific query parameters
expected by Amazon to Authenticate the request.

SignatureVersion, SignatureMethod, Timestamp, Version, AWSAccessKeyID

=cut

sub auth_params {
    my ($self) = @_;
    return {
        SignatureVersion    => $self->signature_version,
        SignatureMethod     => $self->signature_method,
        Timestamp           => $self->timestamp,
        Version             => $self->api_version,
        AWSAccessKeyId      => $self->config->{aws_access_key},
    };
}

=head2 generate_signature (URI)

Takes a URI object or valid url for creating one then
generates a string that represents the encryption string of
the encoded request against the AWS Secret Key

The encryption method used to generate the signature is based on
the Signature Version set. To provide alternative encryption methods
provide a Method called 'encrypt_*' where * is the value set for
signature_method. This method will receive a single argument in the
form of a URI object appropriate to the URL passed to generate_signature

=cut

{
    my $check = compile(Object, URL);
    sub generate_signature {
        my ($self, $url) = $check->(@_);

        if (my $encrypt_method = $self->can("encrypt_".$self->signature_method)){
            return $self->$encrypt_method($url);
        } else {
            Bean::AWS::Exception::InvalidArgs->throw({
                message => 'No Encryption method found for '.$self->signature_method
            });
        }
    }

    sub encrypt_HmacSHA256 {
        my ($self, $url) = $check->(@_);
        my $signature = hmac_sha256_base64(
            join("\n", (
                "POST",
                $url->host,
                $url->path,
                $url->query,
            )),
            $self->config->{aws_secret_key}
        );

        $signature .= '=' while length($signature) % 4;
        return $signature;
    }
}

1;
