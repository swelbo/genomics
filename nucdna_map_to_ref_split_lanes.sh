#!/bin/bash


#PBS -lselect=1:ncpus=8:mem=8gb
#PBS -lwalltime=18:00:00

######PBS -l mem=8gb,walltime=24:00:00,ncpus=8

#  Reset BASH timer
SECONDS=0

module load bwa/0.7.8
module load samtools/1.3.1
threads=8

i=$PBS_ARRAY_INDEX

#  Expand a space-sperated parameter of file names into addressable array
reads1=(${args1})
reads2=(${args2})

#  Reference to map to
ref=${ref}

#  Output folder
bamout=${bamout}

#  Location of reference fasta and desired output directory (all files will go in subdirectories named by sample)
#ref="/rds/general/user/tsewell/projects/fisher-bd-reference/live/batrachochytrium_dendrobatidis_1_supercontigs.fasta"
#bamout="/med-bio/fisherlab/results/bd/bams/raw_ax3_run/"

#  Various meta-data for the BAM files
fcid=$(echo ${reads1[$i]##*/} | cut -d_ -f4 )
lane=$(echo ${reads1[$i]##*/} | cut -d_ -f5 )
sample=$( basename $(dirname ${reads1[$i]}) )
lib="kihansi_2019${sample}"
RG="@RG\tID:${fcid}.${lane}\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

#  make output directory if it doesn't exist
if [ ! -d "${bamout}/${sample}" ]; then mkdir -p "${bamout}/${sample}"; fi

#  Map the reads, then run fixmate, sort the file, output a BAM and then extract mapped reads only
bwa mem -t $threads -R "$RG" "$ref" "${reads1[$i]}" "${reads2[$i]}" >"${bamout}/${sample}/${sample}.${lane}.sam"

samtools fixmate -O bam "${bamout}/${sample}/${sample}.${lane}.sam" "${bamout}/${sample}/${sample}.${lane}.fm.bam"
samtools sort -@ ${threads} -O bam -T "${EPHEMERAL}/tmp_${sample}.${lane}" "${bamout}/${sample}/${sample}.${lane}.fm.bam" > "${bamout}/${sample}/${sample}.${lane}.tmp.bam"
rm "${bamout}/${sample}/${sample}.${lane}.fm.bam" "${bamout}/${sample}/${sample}.${lane}.sam"*
mv "${bamout}/${sample}/${sample}.${lane}.tmp.bam" "${bamout}/${sample}/${sample}.${lane}.sorted.bam"


#  Check if all files are ready for merge
#fls=(${bamout}/${sample}/${sample}.[5\|7].raw.bam)

#  For samples that have been split over 4 lanes there will be 4 bams which need to be put together
#  I do it that way so that I can annotate the reads from the different bmas with different read
#  groups.
#if [[ "${#fls[@]}" -eq 4 ]]; then
#	samtools merge -@ ${threads} "${bamout}/${sample}.raw.bam" ${bamout}/${sample}/${sample}.[1-8].raw.bam
#	rm ${bamout}/${sample}/${sample}\.[5\|7]\.raw.bam
#fi

#  Some samples were run across 1 lane, which in this case was lane 6, so for these files
#  just rename them to $sample.raw.bam
#if [[ "${fls[0]}" == *.6.raw.bam ]]; then
#	mv "${bamout}/${sample}/${sample}.6.raw.bam" "${bamout}/${sample}.raw.bam"
#	rm ${bamout}/${sample}/${sample}.6.raw.bam
#fi

#if [[ -s "${bamout}/${sample}.raw.bam" ]]; then
#	samtools index "${bamout}/${sample}.raw.bam"
#	samtools flagstat "${bamout}/${sample}.raw.bam" | tr -s ' + ' $'\t' | cut -f-2 | awk '{if (NR == 1) {print $1"\n"$2} else if (NR != 1) print $1}' | paste -sd$'\t' <( echo $sample ) - | tr $'\n' $'\t' >> ${EPHEMERAL}/raw_bam_flagstats.txt
#	rm -rf ${bamout}/${sample}/
#fi

#  Run time of the script (not CPU time etc)
echo -e "\nElapsed: $(($SECONDS / 3600)) hrs $((($SECONDS / 60) % 60)) min $(($SECONDS % 60)) sec"
