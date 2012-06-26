#!/usr/bin/env perl -i

my $anchor_rx = qr{
  (&mdash;\s*[\w-]+:\s*<b>[\w-]+</b>)
  (.*?)
  (<a\s+name=.*?></a>)
}x;

while (<>) {
    s/$anchor_rx/\3\2\1/;
    print;
}
