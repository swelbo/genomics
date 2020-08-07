#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# load modules
module load gatk/3.6
module load java/jdk-8u66

# index array 
i=$PBS_ARRAY_INDEX

# path to reference genome
ref=${ref}

#  Expand a space-sperated parameter of file names into addressable array
vcflist=(${args})

# sample name
sample=$( basename ${vcflist[$i]} )

# output location
vcfout=${vcfout}

# Select SNPS only 
java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-T SelectVariants \
-R "${ref}" \
-V "${vcflist[$i]}" \
-o "${vcfout}/${sample%%.*}.raw.snps.vcf" \
-selectType SNP

# Annotate SNPs to ID allele balance
java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-R "${ref}" \
-T VariantAnnotator \
-V "${vcfout}/${sample%%.*}.raw.snps.vcf" \
-o "${vcfout}/${sample%%.*}.annotated.snps.vcf" \
--annotation AlleleBalance

# Filter high confidence SNPs
# Filter on mapping quality (MQ), depth of coverage (DP), Fisher strand bias (FS) and the balance of alleles (ABHom)
java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-T VariantFiltration \
-R "${ref}" \
-V "${vcfout}/${sample%%.*}.annotated.snps.vcf" \
-o "${vcfout}/${sample%%.*}.filtered.snps.vcf" \
--filterExpression "DP < 4 || MQ < 40.0 || QD < 2.0 || QUAL < 50" \
--filterName LowConf
