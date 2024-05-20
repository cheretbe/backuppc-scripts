#!/usr/bin/perl

use lib "/usr/local/BackupPC/lib";
use BackupPC::Lib;
use Data::Dumper;
use List::Util qw(any);
use FindBin qw($Bin);
use File::Basename;
use File::Spec;
use Term::Choose qw(choose);
use YAML::Tiny;
use strict;
use warnings;

# https://stackoverflow.com/questions/5553898/what-are-the-differences-between-in-perl-variable-declaration/5554495#5554495
my $bpc      = BackupPC::Lib->new();
my $hosts    = $bpc->HostInfoRead();
my $mainConf = $bpc->ConfigDataRead();

my $host_name = choose([sort { lc($a) cmp lc($b) } keys %{$hosts}], { prompt => 'Select host:' });
if (!defined($host_name)) { exit 1; }
print ("Updating exclusions for host '$host_name'\n");
my $hostConf = $bpc->ConfigDataRead($host_name);

my @exclude_shares = keys % {$hostConf->{BackupFilesExclude}};
my $share_name;
if (scalar @exclude_shares == 1) {
  $share_name = $exclude_shares[0];
  print("Auto-selecting the only share '$share_name'\n");
} else {
  $share_name = choose([@exclude_shares], { prompt => 'Select share:' });
  if (!defined($share_name)) { exit 1; }
}
print ("Using share '$share_name'\n");

# Hashes in Perl don't store the array itself, but a reference to it
my $host_excludes = $hostConf->{BackupFilesExclude}->{$share_name};
# print Dumper $host_excludes;

# Perl programming is painful. Leaving this here as a reference
# my $default_exclusions_file = File::Spec->catfile($Bin, 'typical_windows_exclusions.txt');
# my @default_exclusions;
# open(my $fh, "<", $default_exclusions_file)
#     or die "Failed to open file $default_exclusions_file: $!\n";
# while(<$fh>) {
#     chomp;
#     unless ($_ =~ /^\s*$/) {
#       # Filter empty strings and strings containing whitespaces only
#       push @default_exclusions, Encode::decode_utf8($_);
#     }
# }
# close $fh;
# # print Dumper @default_exclusions;

my $yaml = YAML::Tiny->read(dirname(__FILE__) . "/typical_windows_exclusions.yml");
my @default_exclusions;
print "Select share type:\n";
my $answer = choose([("users", "root")], { default => 0 });
if ($answer eq "root") {
  push(@default_exclusions, @{$yaml->[0]{root_share}});
  foreach (@{$yaml->[0]{users_share}}) {
    push(@default_exclusions, "/Users$_");
  }
} else {
  push(@default_exclusions, @{$yaml->[0]{users_share}});
}
# print Dumper @{$host_excludes};
# foreach (@default_exclusions) {
#   print Encode::encode_utf8($_), "\n";
# }


my @exclusions_to_add;
foreach my $def_exclude (@default_exclusions) {
  if (any { $_ eq $def_exclude } @{$host_excludes}) {
    print "  '", Encode::encode_utf8($def_exclude), "' is already present, skipping\n";
  } else {
    push(@exclusions_to_add, $def_exclude);
  }
}

if (scalar @exclusions_to_add > 0) {
  print "The following items will be added to '$share_name' share of BackupFilesExclude ",
    "option of host '$host_name':\n";
  print "  ", Encode::encode_utf8(join(",\n  ", @exclusions_to_add)), "\n";
  print "Do you want to continue?\n";
  my $answer = choose([("yes", "no")], { default => 0 });
  if ($answer eq "yes") {
    push(@{$host_excludes}, @exclusions_to_add);
    # print Dumper @{$host_excludes};
    print("Updating config for host '$host_name'\n");
    $bpc->ConfigDataWrite($host_name, $hostConf);
  }
}
