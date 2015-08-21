package Bean::AWS::Exception;

package Bean::AWS::Exception::Base {

    use Moo;
    use overload qw/""/ => 'as_string', fallback => 1;

    has message => (is => 'ro');

    with 'Throwable';
};

package Bean::AWS::Exception::MissingConfig {

    use Moo;

    extends 'Bean::AWS::Exception::Base';

    sub as_string {
        return "Missing entry in config file: ".shift->message."\n";
    }
};

package Bean::AWS::Exception::InvalidArgs {

    use Moo;

    extends 'Bean::AWS::Exception::Base';

    sub as_string {
        return 'Invalid arguments provided: '.shift->message."\n";
    }
};

package Bean::AWS::Exception::FailedRequest {

    use Moo;

    extends 'Bean::AWS::Exception::Base';

    sub as_string {
        return 'AWS request failed: '.shift->message."\n";
    };
};

1;
