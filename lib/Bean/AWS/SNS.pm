package Bean::AWS::SNS;

=head1 NAME

Bean::AWS::SNS - Interface with the Amazon SNS service

=head1 SUMMARY

    use Bean::AWS::SNS;

    my $publisher = Bean::AWS::SNS->new(config_path => '~/', topic => 'MyTopic');
    $publisher->publish({message => $message, subject => $subject});

=head1 DESCRIPTION

The Amazon SNS (Simple Notification System) L<http://aws.amazon.com/documentation/sns/>
provides a cloud based Publish/Subscribe system that allows for the distribution
of messages to all subscribers on a per topic basis.

There are (at time of writing) two other CPAN modules that provide an interface with SNS:

L<Amazon::SNS> - This provides a fairly complete implementation of the API to SNS. It
doesn't not however provide support for resending a request if it failed. It also has no
tests.

L<Paws::SNS> - This distribution is supposed to provide a full SDK implementation. It is
however very much in Beta and its support for SNS seems incomplete. It is also lacking in
tests

The aim here is that this module would be replaced by a more complete CPAN library (likely Paws)
or would become an open source library of its own. It currently implements the various API
calls provided by the SNS system.

See L<Bean::AWS::SNS#Supported Actions> for more information

=cut

use Moo;
use Types::Standard qw/Str/;

# Helper roles
with 'Bean::AWS::Configurator';
with 'Bean::AWS::SNS::Auth';
with 'Bean::AWS::SNS::Requester';

=head1 ATTRIBUTES

=head2 topic - required

A string representing the name of a topic as it appears in
the config. Provides a more human readable reference to the
topic for use in Loggings. Must be present in the config.

=cut

has topic => (is => 'ro', isa => Str, required => 1);

=head1 Supported Actions

A list of the currently implemented API Calls.

See L<http://docs.aws.amazon.com/sns/latest/api/Welcome.html> for information on what
API Methods are available in Amazon

=over

=item Publish

Send messages to SNS

=cut

# Supported Actions
with 'Bean::AWS::SNS::Publish';

=back

=cut

=head1 INSTANCE METHODS

=head2 topic_arn

Get the full ARN for the instances topic name from the config.

Will look for the keys sns -> topics -> $self->topic

=cut

sub topic_arn {
    my ($self) = @_;

    return $self->config->{sns}{topics}{$self->topic};
}

1;
