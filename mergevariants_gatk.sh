#!/bin/bash
#PBS -lselect=1:ncpus=1:mem=32gb
#PBS -lwalltime=24:00:00

module load freebayes/2016-09-22
module load bcftools/1.3.1
module load htslib
module load vt
module load vcflib
module load java/jdk-8u66

#  Expand input VCF string to array
vcfs=( ${vcflist[@]} )
vcfs=( "${vcfs[@]/#/--variant }" )

# combine variants
eval "java -jar /apps/gatk/3.6/GenomeAnalysisTK.jar -T CombineVariants \
    --genotypemergeoption UNSORTED \
    -R ${ref} \
    -U LENIENT_VCF_PROCESSING \
    --logging_level ERROR \
    ${vcfs[@]} \
    --filteredrecordsmergetype KEEP_UNCONDITIONAL \
    --suppressCommandLineHeader \
    --minimalVCF \
    --out ${outfile}"

# streamsort
zcat ${outfile} | vcfstreamsort | vcfcreatemulti | bcftools annotate -Oz -x INFO/set - > ${outfile}.tmp
mv ${outfile}.tmp ${outfile}
tabix -f ${outfile}