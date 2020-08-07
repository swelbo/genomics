#!/bin/bash
#PBS -lselect=1:ncpus=16:mem=64gb
#PBS -lwalltime=48:00:00

# MEDUSA!
# move into medusa folder for some reason i can only get it to work if i do this
cd ~/medusa

#modules
module load java/jdk-8u66
module load anaconda3/personal
#module load mummer/3.23

# index array
i=$PBS_ARRAY_INDEX

# assemblies
assembly=(${args1})

# copy assembly into folder
cp -u "${assembly[$i]}" ~/medusa

# sample name
#sample=$( basename $(dirname ${assembly[$i]}) )
sample=$( basename "${assembly[$i]}" )

# command
java -jar /rds/general/user/tsewell/home/medusa/medusa.jar -f /rds/general/user/tsewell/home/medusa/bd -i /rds/general/user/tsewell/home/medusa/${sample%%.*}.fasta -v -o /rds/general/user/tsewell/projects/fisher-bd-results/live/pacbio/medusa/${sample%%.*}/${sample%%.*}.medusa.fasta
