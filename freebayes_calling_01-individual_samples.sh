#!/bin/bash
#PBS -lselect=1:ncpus=1:mem=32gb
#PBS -lwalltime=24:00:00

module load freebayes/2016-09-22
module load bcftools/1.3.1
module load htslib
module load vt
module load vcflib
module load java/jdk-8u66

shopt -s extglob

#  The $bamlist parameter is passed to the script when it is submitted to the job scheduler
bams=( ${bamlist} )
bam=${bams[$PBS_ARRAY_INDEX]}
ref=${ref}
callout=${callout}
normout=${normout}

#  If the normout directory has not been passed to the script
#  output goes to input BAM file directory
if [[ -z $callout ]]; then
  callout=$(dirname ${bam})
fi

if [[ -z $normout ]]; then
  normout=$(dirname ${bam})
fi

sample=$( basename ${bam%%.mkdup.*} )
outfile="${callout}/${sample}.freebayes"
normfile="${normout}/${sample}.normalised.freebayes"

#  Call variants in input file
freebayes -f "${ref}" -b "${bam}" --no-partial-observations --min-repeat-entropy 1 --genotype-qualities --min-mapping-quality 20 | bgzip -c > "${outfile}.vcf.gz"
tabix -f "${outfile}.vcf.gz"

#  Split complex variants into allelic primitives
zcat "${outfile}.vcf.gz" | bcftools filter -i 'ALT="<*>" || QUAL > 5' | \
  bcftools annotate -x FMT/DPR | bcftools view -a - | \
  vcfallelicprimitives -t DECOMPOSED --keep-geno | \
  vcffixup - | vcfstreamsort | \
  vt normalize -n -r "${ref}" -q - | vcfuniqalleles | \
  bgzip -c > "${normfile}.vcf.gz"
tabix -f "${normfile}.vcf.gz"

bcftools view -f 'PASS,.' "${normfile}.vcf.gz" | vcfallelicprimitives | bgzip -c > "${normfile}.passing.vcf.gz"
tabix -f "${normfile}.passing.vcf.gz"
