#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load vcftools/0.1.13
module load tabix/0.2.6

# index array 
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
vcflist=(${args})

# sample name
sample=$( basename ${vcflist[$i]} )

# output vcf file
output=${output}

# zip and tabix index
bgzip -c "${vcflist[$i]}" > "${output}/${sample%%.*}.vcf.gz"
tabix -p vcf "${output}/${sample%%.*}.vcf.gz"




