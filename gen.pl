#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use autodie;

my $dir = getcwd();
# remove last 10k lines
# my @unabbrev = `head -n -10000 $dir/words/30k_editno5char.txt`;
# chomp(@unabbrev);

# remove all words shorter than _ chars
my @unabbrev = `sed -r '/^.{,1}\$/d' $dir/words-google/20k.txt`;
chomp (@unabbrev);

# open my $data, '<', 'words/30k_editno5char.txt';
# chomp (my @unabbrev = <$data>);
# close $data;

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
