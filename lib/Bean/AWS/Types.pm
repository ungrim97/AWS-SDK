package Bean::AWS::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw/SNSMessage SNSSubjectStr SNSMessageStr SNSMessageFormat URL/;
use Type::Utils -all;
use Types::Standard -types;

use Bean::AWS::Exception;
use URI;

declare SNSSubjectStr,
    as Str,
    where {/^[\w\d,!\?\.]/ && length $_ <= 100},
    message {
        Bean::AWS::Exception::InvalidArgs->new({
            message => "SNS Message subject is invalid for sending via SNS"
        })->as_string;
    };

declare SNSMessageStr,
    as Str,
    where {length $_ <= 256000},
    message {
        Bean::AWS::Exception::InvalidArgs->new({
            message => "SNS Message content is too long for sending via SNS"
        })->as_string;
    };

declare SNSMessageFormat,
    as Enum[qw/json/],
    message {
        Bean::AWS::Exception::InvalidArgs->new({
            message => "SNS Message Format must be json if used"
        })->as_string;
    };

declare SNSMessage,
    as Dict[
        message => SNSMessageStr,
        subject => Optional[SNSSubjectStr],
        format  => Optional[SNSMessageFormat],
    ],
    message {
        if (ref $_ eq 'HASH' && !exists $_->{message}){
            return Bean::AWS::Exception::InvalidArgs->new({
                message => 'message is a required parameter'
            })->as_string;
         }
    };

declare URL,
    as InstanceOf['URI'];
coerce URL,
    from Str, via {URI->new($_)};

1;
