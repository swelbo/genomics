#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

## Merge bams ##

# load modules
module load picard/2.6.0
module load java/jdk-8u66
module load samtools/1.3.1

i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
bams=(${args})

# sample name 
sample=$( basename ${bams[$i]}) 

# list of files to be merged
merge=(${bams[$i]}/*sorted.bam)

#  Expand input bam string to array including INPUT=
merge=( "${merge[@]}" )
input=( "${merge[@]/#/INPUT=}" )

# merge bams
if [[ "${#input[@]}" -gt 1 ]]
then
java -jar $PICARD_HOME/picard.jar MergeSamFiles "${input[@]}" OUTPUT="${bams[$i]}/${sample}.merged.bam" CREATE_INDEX=TRUE
else
mv "${merge}" "${bams[$i]}/${sample}.merged.bam"
samtools index "${bams[$i]}/${sample}.merged.bam"
fi