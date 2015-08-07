package Bean::AWS::GenericTypes;

use strict;
use warnings;

use Email::Valid;
use Type::Library
    -base,
    -declare => qw/URL PhoneNumber EmailAddress/;
use Type::Utils -all;
use Types::Standard -types;
use Number::Phone::US qw/validate_number/;
use URI;

declare PhoneNumber,
    as Str,
    where {validate_number($_)};

declare EmailAddress,
    as Str,
    where {Email::Valid->address($_)};

declare URL,
    as InstanceOf['URI'];
coerce URL,
    from Str, via {URI->new($_)};

1;
