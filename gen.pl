#!/usr/bin/perl
use strict;
use warnings;

open my $data, '<', 'words/10k.txt';
chomp (my @unabbrev = <$data>);
close $data;

my $dup = 'dup.txt';
open (my $duph, '>', $dup);

my $exception = 'exception.txt';
open (my $exceptionh, '>', $exception);

my $out = 'abbrevd.vim';
open (my $outh, '>', $out);

my %dict;

foreach my $unab (@unabbrev) {
	# remove vowels except for first
	my $novow = $unab;
	# use re 'debug';
	while (1) {
		my $cur = $novow;
		if (exists($dict{$cur})) {
			# repeat, can't remove all vowels
			print $exceptionh "$cur\t$unab\n";
			last;
		} elsif (!($cur =~ s/^[a-z]\w*?\K[aeiou]//g)) {
			# no more substitutions
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
	print $outh "iabbr ",ucfirst($ab),"\t",ucfirst($dict{$ab}),"\n";
}

close $duph;
close $outh;
close $exceptionh;


print "Done.";
