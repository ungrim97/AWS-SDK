package Bean::AWS::SNS::Auth;

use Moo::Role;

use Digest::SHA qw/hmac_sha256_base64/;
use DateTime;
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

Default: HmacSH256

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
        return DateTime->now(time_zone => 'UTC', locale => 'en_UK')."Z";
    }
);

=head2 api_version

Version of API for which the calls are made

Default: 2010-03-31

=cut

has api_version => (is => 'ro', lazy => 1, default => '2010-03-31');

=head1 INSTANCE METHODS

=head2 auth_params

Returns a HashRef of key value pairs of the specific query params
expected by Amazon to Authenticate the request.

SignatureVersion, SignatureMethod, Timestamp, Versin, AWSAcessKeyID

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

Generates a string that represents the encryption string of
the encoded request against the AWS Secret Key

=cut

sub generate_signature {
    my ($self, $url) = @_;

    my $signature;
    if ($self->signature_method eq 'HmacSHA256'){
        $signature = hmac_sha256_base64(
            join("\n", (
                "POST",
                $url->host,
                $url->path,
                $url->query,
            )),
            $self->config->{aws_secret_key}
        );
        while (length($signature) % 4){
            $signature .= '=';
        }
    }

    return $signature;
}

1;
