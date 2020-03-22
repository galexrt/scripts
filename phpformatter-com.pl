#!/usr/bin/perl -w

use strict;
use warnings;

use Getopt::Long;
use LWP::UserAgent;
use JSON qw( decode_json );
use Time::HiRes qw(gettimeofday);

sub loadFile() {
    local $/=undef;
    open INPUT_FILE, $fileName or die "Couldn't open file: $!";
    chomp(my $code = <INPUT_FILE>);
    close INPUT_FILE;
    return $code;
}

my ($help, $debug, $newLine) = 0;

GetOptions(
    "h|help" => \$help,
    "debug" => \$debug,
    "n|newline" => \$newLine,
) or die("Error in command line arguments\n");

if ($help) {
    print($0 . "\n");
    print(" -h or --help - For help menu.\n");
    print(" -n or -newline - Add a new line to the output\n");
    print(" -debug - To enabled verbose debug output.\n");
    print("\n");
    exit(0);
}

my $fileName = $ARGV[0];

if (not defined $fileName) {
  die "Need filename as first argument.";
}
# TODO check if this really required
# my ($s, $ms) = gettimeofday();

my $browser = LWP::UserAgent->new;
$browser->timeout(10);
$browser->agent('Mozilla/5.0');

my $response = $browser->post(
    'http://beta.phpformatter.com/Output/',
    [
# TODO check if this is really required
#    'time' => $s . substr($ms, 0, -3),
    'spaces_around_map_operator' => 'on',
    'spaces_around_assignment_operators' => 'on',
    'spaces_around_bitwise_operators' => 'on',
    'spaces_around_relational_operators' => 'on',
    'spaces_around_equality_operators' => 'on',
    'spaces_around_logical_operators' => 'on',
    'spaces_around_math_operators' => 'on',
    'space_after_structures' => 'on',
    'align_assignments' => 'on',
    'indent_case_default' => 'on',
    'indent_number' => '4',
    'first_indent_number' => '0',
    'indent_char' =>  ' ',
    'indent_style' => 'PEAR',
    'code' => loadFile($fileName)
    ],
);
if ($response->is_success) {
    print("Server Response: " . $response->content . "\n===\n");
    my $decoded = decode_json($response->content);
    if (defined $ARGV[1]) {
        $fileName = $ARGV[1];
    }
    open(my $fh, '>:utf8', $fileName) or die "Could not open file '$fileName' $!";
    chomp($decoded->{'plainoutput'});
    $decoded->{'plainoutput'} =~ s/\n$//g;
    print $fh $decoded->{'plainoutput'};
    if ($newLine) {
        print $fh "\n";
    }
    close $fh;
    exit(0);
}
printf("[%d] %s\n", $response->code, $response->message);
exit(1);
