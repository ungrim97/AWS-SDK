package Bean::AWS::SNS;

use Moo;
use Types::Standard qw/Str/;

# Helper roles
with 'Bean::AWS::Configurator';
with 'Bean::AWS::SNS::Auth';
with 'Bean::AWS::SNS::Requester';

has topic => (is => 'ro', isa => Str, required => 1);

# Supported Actions
with 'Bean::AWS::SNS::Publish';

sub topic_arn {
    my ($self) = @_;

    return $self->config->{sns}{topics}{$self->topic};
}

1;
