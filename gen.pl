#!/usr/bin/perl
use strict;
use warnings;

open my $data, '<', 'words/20k_no5char.txt';
chomp (my @unabbrev = <$data>);
close $data;

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
		if (exists($dict{$cur})) {
			# repeat, can't remove all vowels
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
