#!/bin/bash
#PBS -lselect=1:ncpus=48:mem=124gb
#PBS -lwalltime=24:00:00

module load java/jdk-8u66
module load raxml/8.2.9

# input vcf file
invcf=${invcf}

# output directory
outdir=${outdir}

# sample name
prefix=${prefix}

#  Label individual runs of trees
treeid=${PBS_JOBID%%.ax4-login}.${HOSTNAME}

# generate a phylip file from the final VCF file
#~/tassel-5-standalone/run_pipeline.pl -Xmx32g -fork1 -vcf ${invcf} -export ${outdir}/${prefix} -exportType Phylip_Inter -sortPositions -runfork1

# run RAXML 
raxmlHPC-HYBRID-AVX -T 24 -w ${outdir} -x 12345 -m GTRCAT -n ${prefix}.raxml.${treeid} -f a -s ${outdir}/${prefix}.phy -p 12345 -N 1000


