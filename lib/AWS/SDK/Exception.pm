package AWS::SDK::Exception;

{
    package AWS::SDK::Exception::Base;

    use Moo;
    use overload qw/""/ => 'as_string', fallback => 1;

    has message => (is => 'ro');

    with 'Throwable';
}
{
    package AWS::SDK::Exception::MissingConfig;

    use Moo;

    extends 'AWS::SDK::Exception::Base';

    sub as_string {
        return "Missing entry in config file: ".shift->message."\n";
    }
}
{
    package AWS::SDK::Exception::InvalidArgs;

    use Moo;

    extends 'AWS::SDK::Exception::Base';

    sub as_string {
        return 'Invalid arguments provided: '.shift->message."\n";
    }
}
{
    package AWS::SDK::Exception::FailedRequest;

    use Moo;

    extends 'AWS::SDK::Exception::Base';

    sub as_string {
        return 'AWS::SDK request failed: '.shift->message."\n";
    };
}

1;
