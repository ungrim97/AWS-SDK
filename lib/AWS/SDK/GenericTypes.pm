package AWS::SDK::GenericTypes;

use strict;
use warnings;

use Email::Valid;
use Type::Library
    -base,
    -declare => qw/URL PhoneNumber EmailAddress/;
use Type::Utils -all;
use Types::Standard -types;
use URI;


declare PhoneNumber,
    as Str,
    where {$_ =~ m#1[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}#};

declare EmailAddress,
    as Str,
    where {Email::Valid->address($_)};

declare URL,
    as HasMethods[qw/host query path/];
coerce URL,
    from Str, via {URI->new($_)};

1;
