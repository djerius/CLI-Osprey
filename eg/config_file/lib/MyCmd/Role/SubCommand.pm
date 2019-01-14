package MyCmd::Role::SubCommand;

use Moo::Role;

with 'MyCmd::Role::Config';

# this percolates up to the top level to retrieve the global message
# option
has '+parent_command' => (
    is      => 'ro',
    handles => ['message'],
);

around new_with_options => sub {
    my ( $orig, $class, %params ) = @_;

    my $_config = $params{_config} = $params{parent_command}->_config->{$params{subcommand}} // {};
    $class->_extract_config_params( $_config, \%params );
    return $class->$orig( %params );
};

1;
