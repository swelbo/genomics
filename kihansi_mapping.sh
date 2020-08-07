#  Kihansi shotgun sequence data

# reference sequence
ref=/rds/general/user/tsewell/projects/fisher-bd-reference/live/Bd_JEL423_v1/batrachochytrium_dendrobatidis_jel423_mitochondrial_assembly_1_1_contigs.fasta

# reads 
read1=TOG_EHH3_AC040803_A_S1_L006_R1_001.fastq.gz
read2=TOG_EHH3_AC290703_A2_S2_L006_R1_001.fastq.gz

# output folder 
output=/rds/general/user/tsewell/projects/fisher-chytrid-results/live

# header 1
fcid=$(echo ${read1[$i]##*/} | cut -d_ -f4 )
lane=$(echo ${read1[$i]##*/} | cut -d_ -f5 )
lib="kihansishotgun_feb2019"
RG="@RG\tID:${fcid}.${lane}\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

# read mapping 1
bwa mem -t 8 -R $RG $ref /rds/general/user/tsewell/projects/fisher-chytrid-rawdata/live/kinhansi/TOG_EHH3_AC040803_A_S1_L006_R1_001.fastq.gz > $output/output_A_S1.sam

# header 2
fcid=$(echo ${read2[$i]##*/} | cut -d_ -f4 )
lane=$(echo ${read2[$i]##*/} | cut -d_ -f5 )
lib="kihansishotgun_feb2019"
RG="@RG\tID:${fcid}.${lane}\tSM:${sample}\tPL:ILLUMINA\tLB:${lib}"

# read mapping 2
bwa mem -t 8 -R $RG $ref /rds/general/user/tsewell/projects/fisher-chytrid-rawdata/live/kinhansi/TOG_EHH3_AC290703_A2_S2_L006_R1_001.fastq.gz > $output/output_A2_S2.sam

# sam > bam
samtools view -S -b output_A_S1.sam > output_A_S1.bam
samtools view -S -b output_A2_S2.sam > output_A2_S2.bam

# sort sam
samtools sort -O bam -T $TMPDIR output_A_S1.bam > output_A_S1.sorted.bam
samtools sort -O bam -T $TMPDIR output_A2_S2.bam > output_A2_S2.sorted.bam

# index samfile
samtools index output_A_S1.sorted.bam 
samtools index output_A2_S2.sorted.bam
