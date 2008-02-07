package Apache2::DirBasedHandler::TT;

use Apache2::DirBasedHandler;
our @ISA = qw(Apache2::DirBasedHandler);

use Template;
our $tt;

sub init {
    my ($self,$r) = @_;
    my $args = $self->SUPER::init($r);
    my ($tt,$vars) = $self->_get_tt($r);
    $$args{'tt'} = $tt;
    $$args{'vars'} = $vars;
    return $args;
}

sub _get_tt {
    my $self = shift;
    my $r = shift;

    $tt ||= Template->new({
        'INCLUDE_PATH' => [$r->document_root],
    });

    my $vars = {};
    if ($r) {
        $$vars{'r'} = $r;
    };

    return ($tt,$vars);
}




