#!/usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq);
use Data::Dumper;

while (my $line=<>){
    if ( $line =~ m/^#+/ )
    {
      print "$line";  #  print header and skip to next line
      next;
    }
    my @line_parts = split(/\t/, $line);
    my $idx = scalar(@line_parts) - 1;
    #  First 10 columns are the site information. Next columns are sample level info
    my @samples = @line_parts[ 9 .. $idx ];
    my %gts;
    GT_ADD: foreach my $sample (@samples)
    {
      my $gt = (split /:/, $sample)[0];
      #  Look for a missing call (any of '.', '.|.' or './.') and skip if found
      if ( grep {/\./} $gt ) { next GT_ADD; }
      #  Stops phased sites being treated as differnt to unphased when they contain the same nucleotides
      my @nucs = split(/\||\// , $gt );
      $gt = join( '' , sort( @nucs ) );
        if (exists $gts{$gt}) {
          next;
        } else {
            $gts{$gt} = 1;
            if ( scalar(keys(%gts)) >= 2 )
            {
              print "$line";
              last GT_ADD;
            }
        }
    }
    #my @uniqSNPs = List::uniq @snps[ 2 .. $#snps]
    #if ( scalar @uniqSNPs == 1 ){
    #    print "@snps[1..2]"
    #    }
}
