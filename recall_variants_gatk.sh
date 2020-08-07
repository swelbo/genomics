#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load gatk/3.6
module load java/jdk-8u66

# index array 
i=$PBS_ARRAY_INDEX

# path to reference genome
ref=${ref}

#  Expand a space-sperated parameter of file names into addressable array
bamlist=(${bamlist})

# sample name
#sample=$( basename ${bamlist[$i]} )

# input allele calls
varIndex=${varIndex}

#  Expand input VCF string to array
bams=( "${bamlist[@]}" )
bams=( "${bams[@]/#/-I }" )

java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-alleles ${varIndex} \
-R ${ref} \
${bams[@]} \
-gt_mode GENOTYPE_GIVEN_ALLELES \
-o test.vcf