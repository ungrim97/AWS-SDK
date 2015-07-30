package Bean::AWS::SNS::Auth;

use Moo::Role;

use DateTime;

requires 'config';

has signature_version => (is => 'ro', lazy => 1, default => 2);
has signature_method  => (is => 'ro', lazy => 1, default => 'HmacSHA256');
has timestamp         => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return DateTime->now(time_zone => 'UTC', locale => 'en_UK')."Z";
    }
);
has api_version => (is => 'ro', lazy => 1, default => '2010-03-31');

sub auth_params {
    my ($self) = @_;
    return {
        SignatureVersion    => $self->signature_version,
        SignatureMethod     => $self->signature_method,
        Timestamp           => $self->timestamp,
        Version             => $self->api_version,
        AWSAccessKey        => $self->config->{aws_access_key},
        Signature           => $self->config->{aws_signature},
    };
}

1;
