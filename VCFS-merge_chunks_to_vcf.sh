#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=1:mem=32gb

module load bcftools/1.3.1
module load htslib
module load vt
module load vcflib

#outfile
#input_dir
echo "Outfile: $outfile"
echo "Input directory: $input_dir"

#  Run this after you've made all the chunks
bcftools concat --no-version -Oz ${input_dir}/*.gz > ${outfile}

#  Make a SNPs only file
zcat ${outfile} | vcfcreatemulti | bcftools view -V indels,other - | bcftools annotate -Oz -x INFO/set - > ${outfile%%.vcf.gz}.snps.only.vcf.gz
tabix -f ${outfile%%.vcf.gz}.snps.only.vcf.gz
