# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use Authen::TacacsPlus;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# You will have to change these to suit yourself:
my $host = 'zulu.open.com.au';
my $key = 'mysecret';
my $timeout = 15;
my $port = 49;
my $username = 'mikem';
my $password = 'fred';
# This is the CHAP encrypted password, including the challenge
# and identifier
my $chap_password = 'djfhafghlkdlkfjasgljksgljkdsjsdfshdfgsdfkjglgh';

my $tac = new Authen::TacacsPlus(Host=>$host,
				 Key=>$key,
				 Timeout=>$timeout,
				 Port=>$port);
if ($tac)
{
    print "ok 2\n";
}
else
{
    print "Could not connect to TACACSPLUS Host $self->{Host}: " . Authen::TacacsPlus::errmsg() . "\n";
    print "not ok 2\n" ;
}


# test default type (ASCII), backwards compatible
if ($tac->authen($username, $password))
{
    print "ok 3\n";
}
else
{
    my $reason = Authen::TacacsPlus::errmsg();
    print "authen failed: $reason\n";
    print "not ok 3\n" 
}
$tac->close();

my $tac = new Authen::TacacsPlus(Host=>$host,
				 Key=>$key,
				 Timeout=>$timeout,
				 Port=>$port);
if ($tac)
{
    print "ok 4\n";
}
else
{
    print "Could not connect to TACACSPLUS Host $self->{Host}: " . Authen::TacacsPlus::errmsg() . "\n";
    print "not ok 4\n" ;
}


# test default PAP type
if ($tac->authen($username, $password, &Authen::TacacsPlus::TAC_PLUS_AUTHEN_TYPE_PAP))
{
    print "ok 5\n";
}
else
{
    my $reason = Authen::TacacsPlus::errmsg();
    print "authen failed: $reason\n";
    print "not ok 5\n" 
}
$tac->close();

$tac = new Authen::TacacsPlus(Host=>$host,
				 Key=>$key,
				 Timeout=>$timeout,
				 Port=>$port);
if ($tac)
{
    print "ok 6\n";
}
else
{
    print "Could not connect to TACACSPLUS Host $self->{Host}: " . Authen::TacacsPlus::errmsg() . "\n";
    print "not ok 6\n" ;
}

# test CHAP auth type
require Digest::MD5;
$chap_id = '5';
$chap_challenge = '1234567890123456';
# This is the CHAP response from the NAS. We will fake it here
# by calculating it in the same way th eNAS does:
$chap_response = Digest::MD5::md5($chap_id . $password . $chap_challenge);
$chap_string = $chap_id . $chap_challenge . $chap_response;

if ($tac->authen($username, $chap_string, &Authen::TacacsPlus::TAC_PLUS_AUTHEN_TYPE_CHAP))
{
    print "ok 7\n";
}
else
{
    my $reason = Authen::TacacsPlus::errmsg();
    print "authen failed: $reason\n";
    print "not ok 7\n" 
}
$tac->close();

