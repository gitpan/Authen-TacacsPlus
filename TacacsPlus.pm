#
# (C) 1998 Mike Shoyher <msh@corbina.net>, <msh@apache.lexa.ru>

package Authen::TacacsPlus;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
	TACPLUS_CLIENT
);
$VERSION = '0.17';

sub new
{
my $class = shift;
my %h = @_;
my $self = {};
bless $self, $class;
my $res=-1;
$self->{'timeout'} = $h{'Timeout'} ? $h{'Timeout'} : 15;
$self->{'port'} = $h{'Port'} ? $h{'Port'} : 'tacacs';
$self->{'host'} = $h{'Host'};
$self->{'key'} = $h{'Key'};
$res=init_tac_session($self->{'host'},$self->{'port'},
	$self->{'key'},$self->{'timeout'});
undef $self if ($res < 0);
$self;
}

# Third arg authen_type is optional, defaults to 
# TAC_PLUS_AUTHEN_TYPE_ASCII
sub authen
{
    my $class = shift;
    my $username = shift;
    my $password = shift;
    my $authen_type = shift || &Authen::TacacsPlus::TAC_PLUS_AUTHEN_TYPE_ASCII;
    my $res=make_auth($username,$password,$authen_type);
    $res;
}

sub close
{
    deinit_tac_session();
}



sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined Authen::TacacsPlus macro $constname";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

bootstrap Authen::TacacsPlus $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Authen::TacacsPlus - Perl extension for authentication using tacacs+ server

=head1 SYNOPSIS

  use Authen::TacacsPlus;

  $tac = new Authen::TacacsPlus(Host=>$server,
			Key=>$key,
			[Port=>'tacacs'],
			[Timeout=>15]);

  $tac->authen($username,$passwords);

  Authen::TacacsPlus::errmsg(); 

  $tac->close();


=head1 DESCRIPTION

Authen::TacacsPlus allows you to authenticate using tacacs+ server.

  $tac = new Authen::TacacsPlus(Host=>$server,      
 	                Key=>$key,          
                        [Port=>'tacacs'],   
                        [Timeout=>15]);     

Opens new session with tacacs+ server on host $server, encrypted
with key $key. Undefined object is returned if something wrong
(check errmsg()).


  Authen::TacacsPlus::errmsg();

Returns last error message.  

  $tac->authen($username,$password,$authen_type);

Tries an authentication with $username and $password. 1 is returned if
authenticaton succeded and 0 if failed (check errmsg() for reason).

$authen_type is an optional argument that specifies what type
of authentication to perform. Allowable options are:
Authen::TacacsPlus::TAC_PLUS_AUTHEN_TYPE_ASCII (default)
Authen::TacacsPlus::TAC_PLUS_AUTHEN_TYPE_PAP
Authen::TacacsPlus::TAC_PLUS_AUTHEN_TYPE_CHAP

ASCII uses Tacacs+ version 0, and will authenticate against 
the "login" or "global" password on the Tacacs+ server. If no
authen_type is specified, it defaults to this type of authentication.

PAP uses Tacacs+ version 1, and will authenticate against 
the "pap" or "global" password on the Tacacs+ server.

CHAP uses Tacacs+ version 1, and will authenticate against 
the "chap" or "global" password on the Tacacs+ server. With CHAP,
the password if formed by the concatenation of
  chap id + chap challenge + chap response

Ther is example code in test.pl


  $tac->close();

Closes session with tacacs+ server.

=head1 EXAMPLE

  use Authen::TacacsPlus;                                             
                                                              
                                                              
  $tac = new Authen::TacacsPlus(Host=>'foo.bar.ru',Key=>'9999');  
  unless ($tac){                                              
          print "Error: ",Authen::TacacsPlus::errmsg(),"\n";          
          exit(1);                                            
  }                                                           
  if ($tac->authen('john','johnpass')){                   
          print "Granted\n";                                  
  } else {                                                    
          print "Denied: ",Authen::TacacsPlus::errmsg(),"\n";         
  }                                                           
  $tac->close();                                              
  


=head1 AUTHOR

Mike Shoyher, msh@corbina.net, msh@apache.lexa.ru

Mike McCauley, mikem@open.com.au

=head1 BUGS

only authentication is supported

only one session may be active (you have to close one session before
opening another one)

=head1 SEE ALSO

perl(1).

=cut
