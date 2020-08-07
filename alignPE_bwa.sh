#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# modules
# load modules
module load bwa/0.7.8
module load samtools/1.3.1

# index array
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
reads1=(${args1})
reads2=(${args2})

#  Reference to map to
ref=${ref}

#  Output folder
bamout=${bamout}

# Various readgroup meta-data for the BAM files
#fcid=$(echo ${reads1[$i]##*/} | cut -d_ -f4 )
#lane=$(echo ${reads1[$i]##*/} | cut -d_ -f5 )
sample=$( basename $(dirname ${reads1[$i]}) )
lib="serial_afum${sample}"
RG="@RG\tID:1.1\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

# number of threads
threads=8

#  make output directory if it doesn't exist
if [ ! -d "${bamout}/${sample}" ]; then mkdir -p "${bamout}/${sample}"; fi

# read mapping 
bwa mem -t $threads -R "$RG" "$ref" "${reads1[$i]}" "${reads2[$i]}" >"${bamout}/${sample}/${sample%%.*}.${lane}.sam"

# convert to .bam file 
samtools view -b "${bamout}/${sample}/${sample%%.*}.${lane}.sam" > "${bamout}/${sample}/${sample%%.*}.${lane}.bam"

# delete sam file 
rm "${bamout}/${sample}/${sample%%.*}.${lane}.sam"

# sort bam 
samtools sort -O bam -T "${EPHEMERAL}" "${bamout}/${sample}/${sample%%.*}.${lane}.bam" > "${bamout}/${sample}/${sample%%.*}.${lane}.sorted.bam"

# index bam file 
samtools index "${bamout}/${sample}/${sample%%.*}.${lane}.sorted.bam"
