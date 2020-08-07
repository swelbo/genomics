#!/bin/bash

#  SELECT ISOLATES  ---------------

# isolate list
BdNZ=(Ab09NSW CR09Tas JEL253 Me00LB MM05LB Pa10CMCC RTP5 To05LB Tu06LB Tu98LB)

# reference isolates
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"

#  READ TRIMMING  ---------------

# array of isolate files
reads1=()
for i in "${BdNZ[@]}"; do
    reads1+=(/rds/general/user/tsewell/projects/fisher-bd-rawdata/live/NEW_ZEALAND_SEQ/${i}/*_1.fastq.gz)
done

# serialise array for passing to qsub script
args1=$(printf "%s " ${reads1[@]})

reads2=()
for i in "${BdNZ[@]}"; do
    reads2+=(/rds/general/user/tsewell/projects/fisher-bd-rawdata/live/NEW_ZEALAND_SEQ/${i}/*_2.fastq.gz)
done
# serialise for passing to qsub script
args2=$(printf "%s " ${reads2[@]})
jmax=$(( ${#reads1[@]}-1 ))

# trim reads
qsub -J 0-${jmax} -v "args1=${args1},args2=${args2},trimout=/rds/general/user/tsewell/projects/fisher-bd-results/live/trimmed" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/trim.sh
#  ----------------------------------

#   READ MAPPING  ---------------

# reference isolates
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"

# array of quality trimmed FORWARD read files
reads1=(/rds/general/user/tsewell/projects/fisher-bd-results/live/trimmed/*/*.trimmed.R1.fq.gz)
# serialise array for passing to qsub script
args1=$(printf "%s " ${reads1[@]})

# array of quality trimmed REVERSE read files
reads2=(/rds/general/user/tsewell/projects/fisher-bd-results/live/trimmed/*/*.trimmed.R2.fq.gz)
# serialise array for passing to qsub script
args2=$(printf "%s " ${reads2[@]})

bamout=(/rds/general/user/tsewell/projects/fisher-bd-results/live/bams)

jmax=$(( ${#reads1[@]}-1 ))

#  map trimmed reads

#   MARKDUPLICATES  ---------------

# reference isolates
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"

#  Array of all input BAMs for processing
bams=(/rds/general/user/tsewell/projects/fisher-bd-results/live/bams/*/*.raw.bam)
#  Create single
bamlist=$(printf "%s " ${bams[@]})
qsub -J 0-${#bams[@]} -v bamlist="${bamlist}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/mark_duplicates.sh

#   CALL VARIANTS WITH FREEBAYES  ---------------

# reference isolates
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"

#  Array of all input BAMs for processing
newbams=(/rds/general/user/tsewell/projects/fisher-bd-results/live/bams/*/*.mkdup.bam)

oldbams=(/rds/general/user/tsewell/projects/fisher-chytrid-results/live/bams/*.mkdup.bam)

# combine t new and old :) 
bams=( "${newbams[@]}" "${oldbams[@]}" )

#  Create single string variable
bamlist=$(printf "%s " ${bams[@]})
#  Optional parameters (if not specified default is same as input BAM directory):
callout=(/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs)
normout=(/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/normalised)

qsub -J 0-${#bams[@]} -v "bamlist=${bamlist},ref=${ref},callout=${callout},normout=${normout}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/freebayes_calling_01-individual_samples.sh

#  MERGE VCF FILES  ---------------

# reference isolates
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"

#  Previsouly called VCFs
vcfOld=(/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/*.vcf.gz)
#vcfNew=(/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/*.vcf.gz)

#  All VCFs
vcfs=( "${vcfOld[@]}" "${vcfNew[@]}" )

#  Make single string to pass to qsub
vcflist=$(printf "%s " ${vcfs[@]})
#  Combined vcf file to output
outfile="/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/merged/april.2019.bd.all.known.variant.positions.vcf.gz"

#  Send to job submitter
qsub -v "ref=${ref},vcflist=${vcflist},outfile=${outfile}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/freebayes_calling_02-merging_samples_to_positionlist.sh

### RECALL SAMPLES AT ALL PUTATIVE SITES
#  Combined vcf file to output

# reference file 
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"

varIndex="/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/merged/april.2019.bd.all.known.variant.positions.vcf.gz"

#  BAMs to recall the variants at (including all old BAMs)
oldbams=(/rds/general/user/tsewell/projects/fisher-chytrid-results/live/bams/*.mkdup.bam)

newbams=(/rds/general/user/tsewell/projects/fisher-bd-results/live/bams/*/*.mkdup.bam)

bams=( "${newbams[@]}" "${oldbams[@]}" )

#  Make single string to pass to qsub
bamlist=$(printf "%s " ${bams[@]})

#   Optional parameters (if not specified default is same as input BAM directory):
#    $outfile (path to output file)
#    $outdir (if you want to move all output (which could come from multiple call sessions) into a single directory)
outdir="/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs"

qsub -J 1-${#bams[@]} -v "bamlist=${bamlist},ref=${ref},varIndex=${varIndex},outdir=${outdir}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/freebayes_calling_03-recall_samples_at_known_positions_cx1_version.sh

# merge vcfs chromosome by chromosome
vcf_dir=/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs
out=/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/chunked
ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/jel423_broad/batrachochytrium_dendrobatidis_1_supercontigs.fasta"
name_out="bd.april.2019.complete.panel"
qsub -J 1-292 -v "vcf_dir=${vcf_dir},out=${out},ref=${ref},name_out=${name_out}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/VCFS-merge_squared_recalled_vcfs_by_chunk.sh

#  COMBINE CHROMOSOME VCFS TO SINGLE FILE  ---------------

input_dir=/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/chunked/chunks
outfile=/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/merged/000_bd.global.2019.global.panel
qsub -v "input_dir=${input_dir},outfile=${outfile}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/VCFS-merge_chunks_to_vcf.sh


#  SUBSET TO REQUIRED SAMPLES, FIND SEGREGATING SITES, RUN VCF2FASTA AND RAXML  ---------------

invcf=/rds/general/user/tsewell/projects/fisher-bd-results/live/vcfs/merged/*.snps.only.vcf.gz
outdir=/rds/general/user/tsewell/projects/fisher-bd-results/live/raxml
samples=(Ab09NSW CR09Tas JEL253 Me00LB MM05LB Pa10CMCC RTP5 To05LB Tu06LB Tu98LB)
prefix=bd.april.2019.panel.seg


#cp -r ${WORK}/raxml ${SCRATCH}
qsub -v "samples=${samples},invcf=${invcf},outdir=${outdir},prefix=${prefix}" /rds/general/user/tsewell/projects/fisher-bd-analysis/live/VCFS-vcfs2raxml.sh

