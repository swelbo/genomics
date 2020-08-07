#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# BBMAP to remove unwanted reads prior to assembly

# load modules
module load bbmap/36.92
module load java/jdk-8u66

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
fastq=(${args})

# sample name 
sample=$(echo ${fastq[$i]##*/} | cut -d_ -f4 )

# output location
assout=${assout}

# run bbduk
bbduk.sh -Xmx16g \
in="${fastq[$i]}" \
out="${assout}/${sample}.unmatched.fastq" \
outm="${assout}/${sample}.matched.fastq" \
ref="${ref}" \
k=31 \
hdist=1 \
stats="${assout}/stats.txt"
