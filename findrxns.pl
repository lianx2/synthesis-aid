#!usr/bin/perl -w
#
# Written: jlian@cecil
# Updated: February 26, 2022
# 
# Take a user input in the command line in the format "[transformations] [restriction1] [restriction2] ..."
# and identify the desired transformations to be made. Compare the transformations against the supplied
# library of reactions and organize "included" and "excluded" reactions by the specified restrictions.
# The intention of this short (crude) program is to supplement the beginner student's working and
# conceptual knowledge of organic reactions and viable synthetic steps.
#
use diagnostics;
#########################################
# \begin{main}
retrieve_library();
my @transformfgs = ();
my @cnode_crest = ();
#
my @usr_inputs = @ARGV;
my $USRIN = $ARGV[1];
my $tmpref = id_transforms();
@transformfgs = @$tmpref;
print "[Success] Transformations identified.\n";
for (my $i=0; $i <= $#transformfgs; $i++) {
  printf "[\#%d]\t=> %s\n", $i, $transformfgs[$i];
}
for (my $si=2; $si <= $#ARGV; $si++) {
  my $add_rest = $ARGV[$si];
  push (@cnode_crest, $add_rest);
  print "[Success] Added \"$add_rest\" to list of restrictions.\n";
}
for (my $i=0; $i <= $#transformfgs; $i++) {
  my $trf = $transformfgs[$i];
  print "-" x 110 ."\n";
  printf "[\#%d] %s:\n", $i, $trf;
  if ($#{"$trf"."_values"} == -1) {
    print "Error! No existing reactions for this transformation in the supplied library.\n";
  } else {
    my ($refin, $refex) = construct_cnode($trf);
    print_rxns($refin, $refex);
  }
}
# \end{main}
#########################################
# Subroutines
#########################################
#
# retrieve_library 
# Generates a transformation of array of arrays (nested). Stores reaction arrays (nested) within broader transformation 
# with names uniquely generated from the input library.  
#
sub retrieve_library {
  #my $inpath = './rxn_lib1.txt';
  my $inpath = $ARGV[0];
  open (LIBIN, "<", "$inpath") || die "Cannot open input file $inpath: $!\n";
  while (<LIBIN>) {
    chomp;
    my @indivline = split /\t/;
    my $transformkey = "$indivline[3]_$indivline[4]";	# Store the name of the transformation in the library
    my $rxn_name = "$indivline[0]_$indivline[2]";	# Store the reaction name for the subsequent rxn array
                                                        # i.e. 1_Jones to distinguish arrays
    push ( @{"$rxn_name"}, ("$indivline[5]", "$indivline[7]", "$indivline[8]", "$indivline[1]", "$indivline[6]", "$indivline[2]") );
            # @1_Jones = ( REAGENT, rxn_environment, product_restriction, category, rxn type, reaction name)
    push ( @{"$transformkey"."_values"}, \@{"$rxn_name"} ); 
  }
  close (LIBIN) || die "Cannot close input file $inpath: $!\n"; 
}
#
# construct_cnode 
# Search for the hash key that matches the specified transformation, and evaluate the designation of each reaction by searching for
# conditions in @cnode_crest (pulled from nested, nested arrays) that match 
#
sub construct_cnode {
  my $trf = $_[0];
  %{"$trf"."rxnenviron"} = ();
  my (@included, @excluded) = ();
  my $ref_rxnarray = ();
  # Here, for every reaction array (i.e. 1_Jones) in the USR-specified transformation array,
  # extract the cnode_environ of that reaction and store it as the value for every reaction name (hash key).
  for (my $si=0; $si <= $#{"$trf"."_values"}; $si++) {
    $ref_rxnarray = ${"$trf"."_values"}[$si];
    if ($#cnode_crest == -1) {
      push (@included, $ref_rxnarray);	# If no restrictions are specified, copy all reactions to @included
    } else {
      my @deref_rxnarray = @$ref_rxnarray;
      my $rxn_environ = $deref_rxnarray[1];
      ${"$trf"."rxnenviron"}{$ref_rxnarray} = $rxn_environ; # If there are restrictions, create a key in the hash
    }
  }
  #
  # Now, evaluate the conditions stored in cnode_crest to the reaction environments of the reactions stored
  # in the rxnenviron hash. Sort the reactions (still arrayrefs) into @included and @excluded reactions for
  # the transformation.
  #
  foreach my $crest (@cnode_crest) {
    for (my $sj=0; $sj <= $#{"$trf"."_values"}; $sj++) {
      $ref_rxnarray = ${"$trf"."_values"}[$sj];
      my @deref_rxnarray = @{ $ref_rxnarray };
      $deref_rxnarray[1] =~ s/\"//g; # Removes all instances of \"
#      print "Here is \$deref = $deref_rxnarray[1]\n";
      my @conditions = split /,/, $deref_rxnarray[1];
      if ($#conditions == 0) {      
        if ($crest eq $conditions[0]) {
          delete ${"$trf"."rxnenviron"}{$ref_rxnarray};
          push (@excluded, $ref_rxnarray);
        }
      } else { # If there are multiple reaction conditions, evaluate each one
        foreach (@conditions) {
          if ($crest eq $_) {
          delete ${"$trf"."rxnenviron"}{$ref_rxnarray};
          push (@excluded, $ref_rxnarray) unless grep{$_ eq $ref_rxnarray} @excluded;  # If the reaction is already excluded, do not repeat
          }
        }
      }
    }
    # Push the remaining keys in the hash into @included array
    for (my $sj=0; $sj <= $#{"$trf"."_values"}; $sj++) {
      $ref_rxnarray = ${"$trf"."_values"}[$sj];
      foreach $key (keys %{"$trf"."rxnenviron"}) {
        if ($key eq $ref_rxnarray) {
          delete ${"$trf"."rxnenviron"}{$ref_rxnarray};
          push (@included, $ref_rxnarray) unless grep{$_ eq $ref_rxnarray} @included;	# If the reaction is already excluded, do not repeat
        }
      }
    }
  }
  return(\@included, \@excluded);
}
#
# print_rxns
#
sub print_rxns {
  my ($i, $e) = @_;
  my @in = @{ $i };	# Here, rxn arrays are nested as arrayrefs
  my @ex = @{ $e };
  if ($#in == -1) { print "No inclusions found.\n" } else {
    print "Printing inclusions...\n";
    for (my $si=0; $si <= $#in; $si++) {
      @deref_rxn = @{ $in[$si] };
      $deref_rxn[0] =~ s/\"//g;		# Removes all instances of \" from reagent list
      printf "%0.3d\t%-20s\tSELTIVTY: %-10s => %-30s\tNREST: %s\n", $si, "$deref_rxn[$#deref_rxn]_$deref_rxn[3]", $deref_rxn[4], $deref_rxn[0], $deref_rxn[2];
    }
  }
  if ($#ex == -1) { print "No exclusions found.\n" } else {
    print "Printing exclusions...\n";
    for (my $si=0; $si <= $#ex; $si++) {
      @deref_rxn = @{ $ex[$si] };
      $deref_rxn[0] =~ s/\"//g;
      $deref_rxn[1] =~ s/\"//g;
      printf "%0.3d\t%-20s\tSELTIVTY: %-10s => %-30s\tNREST: %s\n", $si, "$deref_rxn[$#deref_rxn]_$deref_rxn[3]", $deref_rxn[4], $deref_rxn[0], $deref_rxn[2];
      printf "\tPotential reason for exclusion: %s\n", $deref_rxn[1];
    }
  }
}
#
# id_transforms
# Identifies and returns an array of functional group transformations specified by the user in the command line.
#
sub id_transforms {
  my @tfgs = ();
  my @fgs = split /_/, $USRIN;
  for (my $si=0; $si <= $#fgs-1; $si++) {
    my $fg_fg = "$fgs[$si]_$fgs[$si+1]";
    push (@tfgs, $fg_fg);
  }
  return \@tfgs;
}
