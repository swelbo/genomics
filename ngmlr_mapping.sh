#!/bin/bash
#PBS -lselect=1:ncpus=48:mem=124gb
#PBS -lwalltime=24:00:00

# load modules
module load samtools/1.3.1

# index array 
i=$PBS_ARRAY_INDEX

## reference assembly (# out as necessary)
# single reference
ref=${ref}

# multiple references - include this in ngmlr command: ("${assemblies[$i]}")
#assemblies=(${args1})

#  Expand a space-sperated parameter of file names into addressable array
reads=(${args})

# output path fir mkdup bams 
bamout=${bamout}

# sample name
sample=$( basename $(dirname ${reads[$i]}) )

# ngmlr command
~/ngmlr-0.2.7/ngmlr -t 48 -r "${ref}" -q "${reads[$i]}" -o "${bamout}/${sample%%.*}/${sample%%.*}.sam" -x pacbio

# convert to bam
samtools view -bS "${bamout}/${sample%%.*}/${sample%%.*}.sam" > "${bamout}/${sample%%.*}/${sample%%.*}.bam"

# sort
samtools sort -o "${bamout}/${sample%%.*}/${sample%%.*}.sorted.bam" -T "$TMPDIR" -O bam "${bamout}/${sample%%.*}/${sample%%.*}.bam"