package Bean::AWS::SNS::Publish;

use Moo::Role;

use Bean::AWS::Exception;
use Bean::AWS::Types qw/SNSMessage/;
use Try::Tiny;
use Types::Standard qw/Object/;
use Type::Params qw/compile/;
use XML::LibXML;
use XML::LibXML::XPathContext;

requires 'config';

=head1 INSTANCE METHODS

=head2 publish (\%message_details) -> 'MESSAGE_ID'

Takes a message hashref containing the keys. Returns he message_id returned
or throws an exception

=over

=item subject

The subject of the message. Must be a character string containing
only ASCII text of no more than 100 characters

=item message

The body of the message. Must be a character string that will
encode to a UTF8 byte string less than 256 bytes

=back

=cut

{
    my $check = compile(Object, SNSMessage);
    sub publish {
        my ($self, $input) = $check->(@_);

        my $base_url = $self->config->{sns}{publish_url};

        unless ($base_url){
            Bean::AWS::Exception::MissingConfig->throw({message => 'SNS Base URL undefined'});
        }

        my $format  = $input->{format};
        my %params = (
            Action   => 'Publish',
            Subject  => $input->{subject} || 'Bean::AWS::SNS Message',
            Message  => $input->{message},
            TopicARN => $self->topic_arn,
            $format ? (MessageStructure => $format) : (),
        );

        my $response = $self->make_request($base_url, \%params);
        my $message_id = $self->_get_message_id($response->decoded_content);
    }
}

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

1;
