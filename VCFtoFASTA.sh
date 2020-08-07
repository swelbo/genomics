#!/bin/sh

# Script to create new FASTA file including SNPs called - an alternate reference

module load java
module load gatk

input=$1
output=$2
reference_dir=~/WORK/jlrhodes/Fisher-Aspergillus/Fisher-Aspergillus-Reference/
reference=$reference_dir/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa

/apps/gatk/3.7/GenomeAnalysisTK.jar -T FastaAlternateReferenceMaker -R $reference_dir/$reference -V $input -o $output.fasta
