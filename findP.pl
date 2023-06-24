#!usr/bin/perl

use diagnostics;

my @rfoundrxns = ();
my $product = $ARGV[1];
search_lib();


if ($#rfoundrxns == -1) {
  printf "Error! There are no such reactions to produce \"$product\" in the given library.\n";
} else {
  printf "[Success] Found the following reactions for %s.\n", $product;
}
my $count = 0;
foreach (@rfoundrxns) {
  my @foundrxn = @{$_};
  $foundrxn[0] =~ s/\"//g;
  printf "%0.3d\t%-30s\t%-20s SELTIVTY: %-10s => %-30s\tNREST: %s\n", $count, "$foundrxn[$#foundrxn-1]_$foundrxn[3]", $foundrxn[$#foundrxn], $foundrxn[4], $foundrxn[0], $foundrxn[2];
  $count++;
}


sub search_lib {
  my $inpath = $ARGV[0];
  open (LIBIN, "<", $inpath) || die "Cannot open inpute file: $!\n";
  while (<LIBIN>) {
    chomp;
    my @indivline = split /\t/;
    my $transformkey = "$indivline[3]"."_"."$indivline[4]";
    my $fproduct = $indivline[4];
    my $rxn_name = "$indivline[0]_$indivline[2]";
    push ( @{"$rxn_name"}, ("$indivline[5]", "$indivline[7]", "$indivline[8]", "$indivline[1]", "$indivline[6]", "$indivline[2]", $transformkey)); 
    if ($product eq $fproduct) { push (@rfoundrxns, \@{$rxn_name}); }
  }
  close (LIBIN) || die "Cannot close input file $inpath: $!\n";
  
}
