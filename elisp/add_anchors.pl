#!/usr/bin/env perl -i

# Some of the definitions (Special Forms, especially) do not already
# have anchors before them.  Ensure that every definition has a
# preceeding anchor.

my @type = (
  'Function',
  'Command',
  'Special Form',
  'Macro',
  'Variable',
  'User Option',
  'Prefix Command',
  'Constant',
);

my $types_rx = '(?:' . join('|', @type) . ')';
my $types_rx = qr{$types_rx};

my $anchor_rx = qr{
  (?<!</a>)(&mdash;\s*$types_rx:\s*<b>[^<]+</b>)
}xs;

my $i = 0;
{
  local($/) = undef;
  while (<>) {
    my $matches = s{$anchor_rx}{$i++; "<a name=\"DASH-$i\"></a>$1"}ge;
    # print STDERR "$matches matches\n";
    print;
  }
}
