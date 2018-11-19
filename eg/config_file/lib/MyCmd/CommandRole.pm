package MyCmd::CommandRole;

use Moo::Role;

requires 'parse_options';

has _config => (
    is      => 'ro',
    default => sub { {} },
);

around parse_options => sub {
    my $orig = shift;
    my $class = $_[0];
    my ( $params, $usage ) = &$orig;

    if ( exists $params->{config} ) {

        my $config = $params->{config};

        if ( !-f $config || !-R _ ) {
            use Carp ();
            Carp::croak(
                qq[config file "$config" does not exist or is not readable\n] );
        }

        require Config::Any;
        my $_config = $params->{_config} = Config::Any->load_files( {
                files           => [$config],
                use_ext         => 1,
                flatten_to_hash => 1,
            } )->{$config};

	# this assumes a hierarchical config file, with a level for
	# each subcommand.
	my %subcommands = $class->_osprey_subcommands;
        while ( my ( $key, $value ) = each %$_config ) {

	    # if key is subcommand name, it's parameters for that
	    # subcommand not for this command
            next if exists $subcommands{$key};
            $params->{$key} //= $value;
        }
    }

    return ( $params, $usage );
};

1;
