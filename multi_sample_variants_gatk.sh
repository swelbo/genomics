#!/bin/bash
#PBS -lselect=1:ncpus=48:mem=120gb
#PBS -lwalltime=24:00:00

# load modules
module load gatk/3.7
module load java/jdk-8u66

# path to reference genome
ref=${ref}

#  Expand a space-sperated parameter of file names into addressable array
bamlist=(${args})

#  Expand input bam string to array
bams=( "${bamlist[@]}" )
bams=( "${bams[@]/#/-I }" )

# output location
vcfout=${vcfout}

java -Xmx112G -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R ${ref} \
${bams[@]} \
-ploidy 1 \
-o ${vcfout} \
-stand_call_conf 30 \
-nct 48