#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use autodie;

my $dir = getcwd();
my $wordfile = 'words/30k_edit.txt';
# remove last 10k lines
# my @unabbrev = `head -n -10000 $wordfile`;
# chomp(@unabbrev);

# spellcheck, lists only valid words
my $spellchkcmd = "comm -23 <(sort -d $wordfile) <(sort -d <(aspell -d en_US  --size=10 --ignore-case list < $wordfile))";

# remove all words up to _ chars long
my $rmcmd = 'sed -r "/^.{,3}$/d"';
my @unabbrev = `bash -c '$rmcmd <($spellchkcmd)'`;
chomp (@unabbrev);

my $twoltr = 'words-custom/2letter.txt';
open (my $twoltrh, '<', $twoltr);
my %twoltrhash;
while (<$twoltrh>) {
	chomp($_);
	$twoltrhash{$_} = 1;
}
close $twoltrh;

my $threeltr = 'words-custom/3letter.txt';
open (my $threeltrh, '<', $threeltr);
my %threeltrhash;
while (<$threeltrh>) {
	chomp($_);
	$threeltrhash{$_} = 1;
}
close $threeltrh;


my $dup = 'dup.txt';
open (my $duph, '>', $dup);

my $exception = 'exception.txt';
open (my $exceptionh, '>', $exception);

my $out = 'abbrevd.vim';
open (my $outh, '>', $out);

my %dict;

# sort abbrev by word length
@unabbrev = sort {length $a <=> length $b} @unabbrev;

foreach my $unab (@unabbrev) {
	# remove vowels except for first
	my $novow = $unab;
	my $cur = $novow;
	# use re 'debug';
	while (1) {
		my $subbed = ($cur =~  s/^[a-z]\w*\K[aeiou]//g);

		if (exists($twoltrhash{$cur}) || exists($threeltrhash{$cur}) || exists($dict{$cur})) {
			# can't collide with two or three letter words or is a repeat
			# unable to remove all vowels
			print $exceptionh "$cur\t$unab\n";
			last;
		} elsif (!$subbed){
			# no more substitutions possible
			$novow = $cur;
			last;
		} else {
			$novow = $cur;
		}
	}
	if (!exists($dict{$novow})) {
		$dict{$novow} = $unab;
	} else {
		print $duph "$novow\t$unab\n";
	}
}

foreach my $ab (keys %dict) {
	print $outh "iabbr $ab\t$dict{$ab}\n";
	# print $outh "iabbr ",ucfirst($ab),"\t",ucfirst($dict{$ab}),"\n";
}

close $duph;
close $outh;
close $exceptionh;


print "Done.";
