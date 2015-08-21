package Bean::AWS::Types;

use strict;
use warnings;

use Type::Library
    -base,
    -declare => qw/
        SNSMessage
        SNSMessageStr
        SNSMessageSubject
        SNSMessageJSON
        SNSMessageFormat
        SNSEndpoint
        SNSScheme
        AWSARN
    /;
use Type::Utils -all;
use Types::Standard -types, qw/slurpy/;

extends 'Bean::AWS::GenericTypes';

use Bean::AWS::Exception;
use JSON qw/encode_json/;

# Type Declarations
declare SNSMessageSubject,
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
        subject => Optional[SNSMessageSubject],
        format  => Optional[SNSMessageFormat],
    ];

declare SNSScheme,
    as Enum[qw/
        http
        https
        email
        email_json
        sms
        sqs
        application
        lambda
    /];

declare SNSMessageJSON,
    as Dict[
        default    => Str,
        slurpy Map[SNSScheme, Str],
    ];

declare SNSEndpoint,
    as Enum[qw/
        EmailAddress
        URL
        PhoneNumber
        AWSARN
    /];

declare AWSARN,
    as Str,
    where {
        my ($type, $partition, $service, $region, $account, @resource) = split(':', $_);

        return $type eq 'arn'
            && $partition eq 'aws'
            && $service
            && $region
            && $account
            && $resource[0]
    };

# Type Coercions
coerce SNSMessageStr,
    from SNSMessageJSON,
    via {encode_json($_)};

1;
