package Apache2::DirBasedHandler::TT;

use strict;

use Apache2::DirBasedHandler;
our @ISA = qw(Apache2::DirBasedHandler);

use Template;
our $tt;
our $VERSION = 0.02;

=head1 NAME

Apache2::DirBasedHandler::TT - TT hooked into DirBasedHandler

=head1 SYNOPSIS

  package My::Thingy;

  use strict;

  use Apache2::DirBasedHandler::TT
  our @ISA = qw(Apache2::DirBasedHandler::TT);

  use Apache2::Const -compile => qw(:common);

  sub index {
      my $self = shift;
      my ($r,$uri_args,$args) = @_;

      if (@$uri_args) {
          return Apache2::Const::NOT_FOUND;
      }
      $$args{'vars'}{'blurb'} = qq[this is the index];

      return $self->process_template(
          $r,
          $$args{'tt'},
          $$args{'vars'},
          qq[blurb.tmpl],
          qq[text/plain; charset=utf-8],
      );
  }
  
  sub super_page {
      my $self = shift;
      my ($r,$uri_args,$args) = @_;
      $$args{'vars'}{'blurb'} = qq[this is \$location/super and all it's contents];

      return $self->process_template(
          $r,
          $$args{'tt'},
          $$args{'vars'},
          qq[blurb.tmpl],
          qq[text/plain; charset=utf-8],
      );
  }

  sub super_dooper_page {
      my $self = shift;
      my ($r,$uri_args,$args) = @_;
      $$args{'vars'}{'blurb'} = qq[this is \$location/super/dooper and all it's contents];

      return $self->process_template(
          $r,
          $$args{'tt'},
          $$args{'vars'},
          qq[blurb.tmpl],
          qq[text/plain; charset=utf-8],
      );
  }

  1;

=head1 DESCRIPTION

Apache2::DirBasedHandler::TT, is an subclass of Apache2::DirBasedHandler with modified
to allow easy use of Template Toolkit templates for content generation.

=head2 init

C<init> calls get_tt to get the template object, and stuffs it into the hash it gets back
from the super class.

=cut 

sub init {
    my ($self,$r) = @_;
    my $hash = $self->SUPER::init($r);
    my ($tt,$vars) = $self->get_tt($r);
    $$hash{'tt'} = $tt;
    $$hash{'vars'} = $vars;
    return $hash;
}

=head2 get_tt

C<get_tt> returns a Template Toolkit object, and a hash reference of variables which
will be passed into the TT process call.  You should really override this function with 
to create the Template object appropriate to your environment.

=cut

sub get_tt {
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

=head2 process_template

C<process_template> is a helper function to generate a page based using the
template object, variables, and template passed in.  It sets the content_type
of the response to the value of the fifth argument.

=cut

sub process_template {
    my $self = shift;
    my ($r,$tt,$vars,$template_name,$content_type) = @_;
    my $page_out;
    if (!$tt->process($template_name, $vars, \$page_out)) {
        $r->log_error($template_name . qq[ ] . $tt->error);
        return Apache2::Const::SERVER_ERROR;
    }

    return (Apache2::Const::OK,$page_out,$content_type);
}

1;

=head1 AUTHOR AND COPYRIGHT

Copyright 2008, Adam Prime (adam.prime@utoronto.ca) 

This software is free. It is licensed under the same terms as Perl itself.


