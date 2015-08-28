#!/usr/bin/perl

use strict;
use warnings;

my $bin = 0;
my $output;

while(defined (my $line = <>)){
	if ($bin==2){
		print "$output";
		exit;
	} else {	
		if ($line=~/^>(.*)$/){
			if ($bin == 0) {$output=$output=$line}
			$bin++;	
		} else {	 
			$output=$output.$line;
			#$output=~ s/-//g;
			}	
	}
}
