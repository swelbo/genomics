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
bamlist=(${args})

# sample name
sample=$( basename ${bamlist[$i]} )

# output location
vcfout=${vcfout}

java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R "${ref}" \
-I "${bamlist[$i]}" \
-ploidy 1 \
-o "${vcfout}/${sample%%.*}.all.raw.vcf" \
-stand_call_conf 30 \
-stand_emit_conf 30 \