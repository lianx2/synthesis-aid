# synthesis-aid
perl exercise for filtering rxns

findrxns.pl searches the provided reaction library for transformations that match the user’s input. For each transformation, the possible reactions are evaluated against the user’s input restraints (ex. acid), and are organized under the labels included and excluded. The potential reason for exclusion is also printed in output. Predictions are not implemented to evaluate or sort by viability the reactions as the intention of this program is not to determine a synthesis, but to aid the user in creatively considering potential reactions.

crudeness: findrxns.pl outputs a list of possible considerations for each transformation and the excluded reactions and reason for exclusion (ex. self-destruction) for the input command. Each node is treated independent of one another. Hence, lineage information is not stored, so the set of restrictions for subsequent transformations is not modified from the original input (ex. Formation of an acetal protecting group in transformation [0] will not exclude “H2O,acid” environments in transformation [1] unless both conditions were already specified by the user in the initial function call); the representation of compounds and input is critical to the capabilities and limitations of any program. Here, almost-definitely-not-standard abbreviations are acceptable inputs, which severely limit the versatility of this crude, crude program. There is no graphic user interface, and the algorithm is unable to thread/link multiple transformations or perform multi-step syntheses.

an initial testing library was manually created (rxn.lb); a supplementary function $findP.pl was written to identify reactions producing a user specified product from the input library.

some abbreviations 
1-OH	=> primary alcohol
2-OH  => secondary alcohol
3-OH  => tertiary alcohol
OH    => alcohol (for PGs and conversions, i.e. OTf, OMs, etc.)
1-2-diol  => 1,2-diol
1-3-diol  => 1,3-diol
1-4-diol  => 1,4-diol
a-w-diol  => alpha-omega-diol
cyc-ketone  => cyclic ketone
CHO	  => aldehyde
COOH  => carboxylic acid
X	    => halogen
COCl	=> acid chloride

