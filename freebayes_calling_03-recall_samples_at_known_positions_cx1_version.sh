#!/bin/bash
#PBS -l select=1:ncpus=1:mem=8gb
#PBS -l walltime=24:00:00

module load freebayes/2016-09-22
module load bcftools/1.3.1
module load htslib
module load vt
module load vcflib

#  Expand string of input BAMs to array
bams=( ${bamlist} )
#  Seelct BAM to process using qsub index variable
bam=${bams[ ${PBS_ARRAY_INDEX} ]}
#  If an output file has not been specified
#  output goes to input BAM file directory
regex="(raw)?.mkdup.bam"

outfile=${outdir}/$(basename ${bam} .raw.mkdup.bam).recalled.raw.freebayes.vcf.gz

filtered=${outdir}/$(basename ${bam} .raw.mkdup.bam).recalled.filtered.freebayes.vcf.gz

rm $outfile
rm $filtered

  #  Call BAM using index of all variant positions
  freebayes -f "${ref}" \
  --variant-input "${varIndex}" \
  -b "${bam}" \
  --no-partial-observations \
  --min-repeat-entropy 1 \
  --genotype-qualities \
  --min-mapping-quality 20 \
  | bgzip -c > "${outfile}"

  #  Index new VCF
  tabix -f "${outfile}"



#  Filter VCF got low quality variants
zcat ${outfile} | \
  bcftools annotate -x FMT/DPR | \
  vcfallelicprimitives -t DECOMPOSED --keep-geno | \
  vcffixup - | \
  vcfstreamsort | \
  vt normalize -n -r ${ref} -q - | vcfuniqalleles | \
  bcftools filter -S 0 -e 'AC > 0 && NUMALT == 0 | %QUAL < 5 | AF[*] <= 0.5 && DP < 4 | AF[*] <= 0.5 && DP < 13 && %QUAL < 10 | AF[*] > 0.5 && DP < 4 && %QUAL < 50' - | \
  vcffixup - | \
  bcftools filter -s MISSING -S . -e 'AC == 0 && DP < 4' - | \
  awk -F$'\t' -v OFS='\t' '{if ($0 !~ /^#/ && $6 < 1) $6 = 1 } {print}' | \
  bgzip -c > ${filtered}

#  Index filtered VCF
tabix -f ${filtered}


#  Move output if an output directory has been specified
#if [[ ! -z ${outdir} ]]; then
#  mv ${outfile}* ${outdir}
#  mv ${filtered}* ${outdir}
#fi
