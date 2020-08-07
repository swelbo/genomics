#!/bin/bash
#PBS -lselect=1:ncpus=8:mem=16gb
#PBS -lwalltime=12:00:00

# Script to create new FASTA file including SNPs called - an alternate reference

# load modules
module load gatk/3.6
module load java/jdk-8u66
module load bbmap/36.92

# index array
i=$PBS_ARRAY_INDEX

# path to reference genome
ref=${ref}

#  Expand a space-sperated parameter of file names into addressable array
vcflist=(${args})

# sample name
sample=$( basename ${vcflist[$i]} )

# output location
fastaout=${fastaout}

# create fasta "reference genomes" for each individual isolates

java -jar -Djava.io.tmpdir=$EPHEMERAL $GATK_HOME/GenomeAnalysisTK.jar \
-T FastaAlternateReferenceMaker \
-R "${ref}" \
-V "${vcflist[$i]}" \
-o "${fastaout}/${sample%%.*}.fasta"

perl -pi -e "s/^>/>${sample%%.*}/g" "${fastaout}/${sample%%.*}.fasta"

grep -v ">" "${fastaout}/${sample%%.*}.fasta" > "${fastaout}/${sample%%.*}.nameless.fasta"

perl -p -e "s/^>/>${sample%%.*}/g" "${fastaout}/${sample%%.*}.nameless.fasta" > "${fastaout}/${sample%%.*}.merged.fasta"

#perl -pi -e "s/^>/>${sample%%.*}-merged/g" "${fastaout}/${sample%%.*}.nameless.fasta" 

#bbrename.sh in="${fastaout}/${sample%%.*}.nameless.fasta" out="${fastaout}/${sample%%.*}.merged.fasta" prefix="${sample%%.*}"

#sed "s/>.*/&_${sample%%.*}/" "${fastaout}/${sample%%.*}.edit.fasta" > "${fastaout}/${sample%%.*}.fasta"

#rm -f "${fastaout}/${sample%%.*}.edit.fasta"

#perl -pi -e "s/^>/>${sample%%.*}-/g" foo.fasta

#bbrename.sh in=file.fasta out=renamed.fasta prefix=phosphate addprefix=t