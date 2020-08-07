#!/bin/bash
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=1:mem=12gb
module load freebayes/2016-09-22
module load bcftools/1.3.1
module load htslib
module load vt
module load vcflib
module load R
module load java/jdk-8u66

shopt -s extglob
#  Turn off warning about R_HOME
unset R_HOME

#  There are 292 chunks to make the complete genome
chunk=${PBS_ARRAY_INDEX}

#  Process chromosome by chromosome
#  Reference file that reads were mapped to
ref="${ref}"

#  The extra outer paraentheses are to assign the output of the Rscript into an array
#  First array element gives the bed-style interval for this chunk
#  Second element is just the pbs array index, formatted with leading zeroes
block=( $(Rscript /rds/general/user/tsewell/projects/fisher-bd-analysis/live/split_bd_genome_to_chunks.R ${chunk}) )

#  Where are all the VCFs to combine stored?
vcf_dir="${vcf_dir}"

#  Where to put the merged multisample VCF chunks
out="${out}"
if [[ ! -d "${out}/chunks" ]]; then
  mkdir ${out}/chunks
fi

#  What should this chunk be called?
outfile="${out}/chunks/${name_out}.chunk.${block[1]}.vcf.gz"

#  Combine raw variant files for positions
#  Don't forget to combine multiple sites into one and then use stream sort
IFS=$'\r\n'
vcfs=( ${vcf_dir}/*.filtered.freebayes.vcf.gz )

vars=()
for vcf in "${vcfs[@]}"; do
    vars+=($(echo "--variant ${vcf}"))
done

#vars=( $( for f in `seq 0 $(( ${#vcfs[@]} - 1 ))`; do echo "--variant ${vcfs[$f]}"; done) )


eval "java -jar /apps/gatk/3.6/GenomeAnalysisTK.jar -T CombineVariants \
    --genotypemergeoption UNSORTED \
    -L ${block[0]} \
    -R ${ref} \
    -U LENIENT_VCF_PROCESSING \
    --logging_level ERROR \
    ${vars[@]} \
    --filteredrecordsmergetype KEEP_UNCONDITIONAL \
    --suppressCommandLineHeader \
    --out ${outfile}"

tabix -f ${outfile}
