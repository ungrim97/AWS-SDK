package AWS::SDK::SNS::Publish;

use Moo::Role;

use AWS::SDK::Exception;
use AWS::SDK::Types qw/SNSMessage/;
use Data::Dumper;
use Try::Tiny;
use Types::Standard qw/Dict Object Optional/;
use Type::Params qw/compile/;
use XML::LibXML;
use XML::LibXML::XPathContext;

requires 'config';
requires 'make_request';

=head1 INSTANCE METHODS

=head2 publish (\%message_details) -> 'MESSAGE_ID'

Takes a message hashref containing the keys. Returns he message_id returned
or throws an exception

L<http://docs.aws.amazon.com/sns/latest/api/API_Publish.html>

=over

=item subject (Optional)

The subject of the message. Must be a character string containing
only ASCII text of no more than 100 characters

=item message

The body of the message. Must be a byte string encoded as UTF8
less than 256 bytes or a HashRef that can be encoded to JSON.
If its a HashRef it must contain at least a default key containing the
message to send.

NOTE: That the size of the message is always 256 bytes regardless of if
your sending as JSON to multiple endpoints or as a string

=item format (Optional)

If set, then it must have a value of json. This determines if different
messages should be sent to different endpoint protocols. If set then the
message will be encoded as JSON. If the message is a string then it will
be used as the message for all end points. If the message is a HashRef
then it will be encoded as is with the structure preserved

=back

=cut

{
    my $check = compile(Object, SNSMessage);
    sub publish {
        my ($self, $input) = $check->(@_);

        my $base_url = $self->config->{sns}{url};
        my $format   = $input->{format};

        my $response = $self->make_request($base_url, {
            Action   => 'Publish',
            Subject  => $input->{subject} || 'AWS::SDK::SNS Message',
            Message  => $input->{message},
            TopicArn => $self->topic_arn,
            $format ? (MessageStructure => $format) : (),
        });

        if ($response->is_success){
            my $message_id = $self->_get_message_id($response->decoded_content);
        } else {
            AWS::SDK::Exception::FailedRequest->throw({message => Dumper $response});
        }
    }
}

# Extracts the MessageId string from a successful response
sub _get_message_id {
    my ($self, $content) = @_;

    return try {
        my $xpath = XML::LibXML::XPathContext->new(
            XML::LibXML->load_xml(string => $content)
        );
        $xpath->registerNs(sns => "http://sns.amazonaws.com/doc/2010-03-31/");

        return $xpath->findvalue('/sns:PublishResponse/sns:PublishResult/sns:MessageId/text()');
    } catch {
        return undef
    }
}

=head1 SEE ALSO

L<http://docs.aws.amazon.com/sns/latest/api/API_Publish.html>
L<http://docs.aws.amazon.com/sns/latest/api/CommonParameters.html>
L<http://docs.aws.amazon.com/sns/latest/api/CommonErrors.html>

1;
