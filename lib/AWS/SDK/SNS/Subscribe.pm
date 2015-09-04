package AWS::SDK::SNS::Subscribe;

use Moo::Role;

use AWS::SDK::Types qw/SNSEndpoint SNSScheme/;
use Type::Params;

requires 'make_request';

=head1 INSTANCE METHODS

=head2 subscribe (ENDPOINT, SCHEME)

Subscribe endpoints for given schemes to the topic.

Returns a SubscriptionArn if created or throws and exception

=cut

{
    my $check = compile(SNSEndpoint, SNSScheme);
    sub subscribe {
        my ($self, $endpoint, $scheme) = $check->(@_);

        my $response = $self->make_request($self->config->{sns}{url}, {
            Action   => 'Subscribe',
            Protocol => $scheme,
            Endpoint => $endpoint,
            TopicArn => $self->topic_arn,
        });

        return $response->is_success ? 1 : 0;
    }
}

1;
