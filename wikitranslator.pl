#!/usr/bin/perl -w
use strict;
use URI;
use URI::Escape;
use Web::Scraper;
use Encode;

binmode STDOUT, ":utf8";

my ($lang, $word) = @ARGV;

my $s = scraper {
    process '#p-lang a[lang]', 'links[]' => '@href';
};

my $r = $s->scrape( URI->new("https://$lang.wikipedia.org/wiki/$word") );

my %tr = ($word => [ $lang ]);

for my $link (@{ $r->{links} }) {
    if ($link =~ m[https://([\w-]+)\.wikipedia.org/wiki/(.*)]) {
        my $lang = $1;
        my $word = decode_utf8 uri_unescape $2;
        push @{ $tr{$word} }, $lang;
    };
}

@$_ = sort @$_ for values %tr;

print join ", ",
    map {
        join("+", @{ $tr{$_} }) . ": $_"
    } sort { $tr{$a}[0] cmp $tr{$b}[0] } keys %tr;

print "\n";
