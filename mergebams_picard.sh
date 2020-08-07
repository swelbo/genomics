#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

## Merge bams ##

# load modules
module load picard/2.6.0
module load java/jdk-8u66
module load samtools/1.3.1

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
bam1=(${args1})
bam2=(${args2})

# sample name 
sample=$(echo ${bam1[$i]##*/} | cut -d_ -f4 )

# output location
mergeout=${mergeout}

# name 
mergename=${mergename}

# merge bams

java -jar $PICARD_HOME/picard.jar MergeSamFiles \
INPUT="${bam1[$i]}" \
INPUT="${bam2[$i]}" \
OUTPUT="${mergeout}/${sample}_${mergename}_merged.bam" \
CREATE_INDEX=TRUE