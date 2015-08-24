package Bean::AWS::Configurator;

=head1 NAME

Bean::AWS::Configuration - Config handler for Bean::AWS

=head1 SYNOPSIS

    with 'Bean::Configurator';

    my $aws_obj = Bean::AWS->new(config_dir => 'my/app/config/dir');
    my $config = $aws_obj->config;
    $config->{config_key};

=head1 DESCRIPTION

A simple Moo Role to handle loading of the config file for Bean::AWS

=cut

use Moo::Role;

use Bean::AWS::Exception;
use Path::Tiny qw/path/;
use JSON qw/decode_json/;
use Types::Standard qw/HashRef/;

=head1 ATTRIBUTES

=head2 config_dir

config_dir is a required attribute for any instance of a class consuming this role

it must be a full qualified directory that exists.

Must be provided if no L<Bean::AWS::Configurator#config|config> hashref is provided

=cut

has config_dir => (
    is       => 'ro',
    isa      => sub {
        die "$_[0] directory doesn't exist or doesn't contain a valid config file"
          unless -d $_[0] && -e $_[0].'/bean_aws.json';
    },
);

=head2 config

Returns a hashref containing the config details. If not provided as part of the
instantiation of the consuming object then these will be loaded from a file
called 'bean_aws.json' from the L<Bean::AWS::Configurator#config_dir|config_dir>

NOTE: The file is read with a binmode of ':unix:encoding(UTF-8)'

SEE ALSO

L<Path::Tiny#slurp>

=cut

has config => (
    is      => 'ro',
    lazy    => 1,
    isa     => HashRef,
    builder => 1,
);

sub _build_config {
    my ($self) = @_;

    my $config_file = path($self->config_dir.'/bean_aws.json');
    return decode_json($config_file->slurp_utf8);
}

sub BUILDARGS {
    my ($self, @args) = @_;

    my $args = @args % 2 == 1 ? $args[0] : {@args};

    if (!exists $args->{config} && !exists $args->{config_dir}){
        Bean::AWS::Exception::InvalidArgs->throw({message => 'Missing config_dir param'});
    }

    return $args;
}

=head1 SEE ALSO

L<Config::JFDI>

=cut

1;
