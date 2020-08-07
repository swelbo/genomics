#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# modules
# load modules
module load bwa/0.7.8
module load samtools/1.3.1
module load picard/2.6.0
module load java/jdk-8u66

# index array
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
reads=(${args})

#  Reference to map to
ref=${ref}

#  Output folder
bamout=${bamout}

# Various readgroup meta-data for the BAM files
fcid=$(echo ${reads[$i]##*/} | cut -d_ -f4 )
lane=$(echo ${reads[$i]##*/} | cut -d_ -f5 )
sample=$( basename ${reads[$i]} )
lib="kihansi_shotgun${sample}"
RG="@RG\tID:${fcid}.${lane}\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

# number of threads
threads=8

# read mapping 
bwa mem -t $threads -R "$RG" "$ref" "${reads[$i]}" >"${bamout}/${sample%%.*}.sam"

# convert to .bam file 
samtools view -b "${bamout}/${sample%%.*}.sam" > "${bamout}/${sample%%.*}.bam"

# delete sam file 
rm "${bamout}/${sample%%.*}.sam"

# sort bam 
samtools sort -O bam -T "${EPHEMERAL}" "${bamout}/${sample%%.*}.bam" > "${bamout}/${sample%%.*}.sorted.bam"

# index bam file 
samtools index "${bamout}/${sample%%.*}.sorted.bam"



