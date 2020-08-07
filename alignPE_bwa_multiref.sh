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

# multiple references - include this in ngmlr command: ("${assemblies[$i]}")
assemblies=(${args3})

#  Output folder
bamout=${bamout}

# Various readgroup meta-data for the BAM files
#fcid=$(echo ${reads1[$i]##*/} | cut -d_ -f4 )
lane="one"
sample=$( basename $(dirname ${reads1[$i]}) )
lib="pilon_illumina"
RG="@RG\tID:1.1\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

# number of threads
threads=8

#  make output directory if it doesn't exist
if [ ! -d "${bamout}/${sample}" ]; then mkdir -p "${bamout}/${sample}"; fi

# read mapping 
bwa mem -t $threads -R "$RG" "${assemblies[$i]}" "${reads1[$i]}" "${reads2[$i]}" > "${bamout}/${sample}/${sample%%.*}.${lane}.sam"

# convert to .bam file 
samtools view -bhS "${bamout}/${sample}/${sample%%.*}.${lane}.sam" > "${bamout}/${sample}/${sample%%.*}.${lane}.bam"

# delete sam file 
#rm "${bamout}/${sample}/${sample%%.*}.${lane}.sam"

# sort bam 
samtools sort "${bamout}/${sample}/${sample%%.*}.${lane}.bam" "${bamout}/${sample}/${sample%%.*}.${lane}.sorted"

# index bam file 
samtools index "${bamout}/${sample}/${sample%%.*}.${lane}.sorted.bam"
