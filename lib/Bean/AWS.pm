package Bean::AWS;

use Moo;

with 'Bean::AWS::Configurator';
with 'Bean::AWS::Auth';
with 'Bean::AWS::Requester';

=head1 NAME

Bean::AWS

=head1 SUMMARY

    use Bean::AWS::...

=head1 DESCRIPTION

Provids an SDK (Software development kit) for the various Amazon APIs

=cut

1;
