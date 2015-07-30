package Bean::AWS::SNS::Requester;

use Moo::Role;

use Bean::AWS::Exception;
use Bean::AWS::Types qw/URL/;
use LWP::UserAgent;
use URI;
use URI::Escape qw/uri_escape_utf8/;
use Type::Params qw/compile/;
use Types::Standard qw/InstanceOf Optional Object HashRef/;

requires 'auth_params';

has ua => (
    is      => 'ro',
    isa     => InstanceOf['LWP::UserAgent'],
    lazy    => 1,
    default => sub {LWP::UserAgent->new()}
);

=head1 INSTANCE METHODS

=head2 make_request ('BASE_URL', \%query_params)

Merges the provided optional query parameters with the
required Auth Parameters from config then encodes the result
as UTF8, escapes them and then makes a request to the AWS
SNS API at BASE_URL with the resulting query string.

Returns a HTTP::Response object or throws and exception

=cut
{
    my $check = compile(Object, URL, Optional[HashRef]);
    sub make_request {
        my ($self, $url, $params) = $check->(@_);

        $url->query( $self->encode_params({%{$params||{}}, %{$self->auth_params}}) );

        return try {
            return $self->ua->post($url->as_string);

            # TODO: Do we need to handle failed (non 2xx) responses? Retry?
        } catch {
            # TODO: Handle aborted requests
            Bean::AWS::Exception::FailedRequest->new(content => $_)->throw
        }
    }
}

=head2 encode_params (\%params)

Takes a hashref of query parameter key value pairs. Encodes them as a
UTF8 Byte string then escapes any metacharacters. Expects unencoded
characters.

=cut

sub encode_params {
    my ($self, $params) = @_;

    return uri_escape_utf8(%{$params});
}

1;
