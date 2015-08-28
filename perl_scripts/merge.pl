#!usr/bin/perl

use strict;
use warnings;


use Getopt::Long; 

#Declaring variables
my($ids_file,$mfa_file,$out_file,@ids); 

#Options
usage() if (@ARGV < 1 or !GetOptions(
		'ids=s'=>\$ids_file,
		'fa=s'=>\$mfa_file,
		'out:s'=>\$out_file		
		)); 

sub usage{ 
  print "Unknown option: @_\n" if(@_);
  print "\nUsage: merge.pl --ids IDs_filename --fa mFASTA_filename [--out filename]\n\n";
  exit;
}



# Run 

@ids = load_ids($ids_file);
select_seqs(\@ids,$mfa_file);
exit;


#Subroutines

sub load_ids{ # load ids as an array

  open(INFILE,$_[0]) or die "\nCannot open $_[0]\n\n"; 
  my @in_file = <INFILE>;
  foreach my $id (@in_file){
  chomp $id;
  }
  close INFILE;
  return @in_file;
}


sub select_seqs { # if header in ids, store id+seq

  my($ids,$mfasta) = @_; 
  open(INFILE,$mfasta) or die "\nCannot open $mfasta\n\n";
  
  my ($output,$bin,$id);  
 
  while(defined (my $line = <INFILE>)){
    if ($line=~/^>..\|(.*)\|.*$/){
      if ( grep { $_ eq $1 } @ids ) {
         $output=$output.$line;
 	 $bin=1;
      }else {
         $bin=0;
	 next;
      }  
    }else{
      	if ($bin==1){
	  $output=$output.$line;	
	}else{
	  next;
	}	  
    }
  }
  print $output;
}
