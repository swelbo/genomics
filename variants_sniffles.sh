#!/bin/bash
#PBS -lselect=1:ncpus=48:mem=124gb
#PBS -lwalltime=24:00:00

# index array
i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
bams=(${args})

# sample name
sample=$( basename ${bams[$i]})

# vcf outfile
vcfout=${vcfout}

#  make output directory if it doesn't exist
if [ ! -d "${vcfout}/${sample}" ]; then mkdir -p "${vcfout}/${sample%%.*}"; fi

# command  # ./sniffles -m mapped.sort.bam -v output.vcf
~/Sniffles-master/bin/sniffles-core-1.0.11/sniffles -m "${bams[$i]}" -v "${vcfout}/${sample%%.*}/${sample%%.*}.vcf"