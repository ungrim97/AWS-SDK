package Bean::AWS;

use Moo;

with 'Bean::AWS::Configurator';
with 'Bean::AWS::Auth';
with 'Bean::AWS::Requester';

1;
