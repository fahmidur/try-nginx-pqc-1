#!/usr/bin/env perl

use Data::Dumper;

my %providers;
my $in_provider = "";

while(<>) {
  if($_ =~ /^\s*$/) {
    next;
  }
  if($_ =~ /^Providers:/i) {
    next;
  }
  # print;
  if($_ =~ /^\s*(\w+)\s*$/) {
    my $provider_key = $1;
    $providers{$provider_key} = ();
    $in_provider = $provider_key;
    next;
  }
  if($in_provider) {
    # print "$in_provider || $_";
    if($_ =~ /^\s*(\w+):\s+(.+)\s*$/) {
      my $k = $1;
      my $v = $2;
      $providers{$in_provider}{$k} = $v;
    }
  }
}

# print "---\n";
# print Dumper(%providers);

$required_provider = 'oqsprovider';
my $status = $providers{$required_provider}{status};
print "PROVIDER($required_provider) STATUS = $status\n";
if($status eq "active") {
  print "AOK. Provider is active\n";
  exit 0;
} else {
  print "NOK. Privider is NOT active\n";
  exit 1;
}


