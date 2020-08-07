perl /usr/local/Cellar/deconseq-standalone-0.4.3/deconseq.pl -f fu_1.fq -dbs ./refChr/hs_ref_GRCh38_p2 -i 90 -c 90 -out_dir DECONSEQ

perl /usr/local/Cellar/deconseq-standalone-0.4.3/deconseq.pl -f ~/Documents/bioinfomatics/MADA_210/160219_D00248_0151_AC8GC2ANXX_8_TP-D7-008_TP-D5-007_1.fastq.gz -dbs ~/Documents/bioinfomatics/db_dir/hs_ref_GRCh38 -i 90 -c 90 -out_dir ./


#PBS -lselect=N:ncpus=X:mem=Ygb
#PBS -lwalltime=HH:00:00



# build the index
bowtie2-build amphiblib.fasta amphiblib 

# run the mapping using 16 processes
bowtie2 -x ../db_dir/xenotrop -1 160219_D00248_0151_AC8GC2ANXX_8_TP-D7-008_TP-D5-007_1.trimmed.R1.fq.gz -2 160219_D00248_0151_AC8GC2ANXX_8_TP-D7-008_TP-D5-007_2.trimmed.R2.fq.gz | samtools sort > seqs.amp.bam

# extract the left reads that match the reference genome
samtools fastq -G 12 -f 65 seqs.sharks.bam > left.shark.fastq

# extract the right reads that match the reference genome
samtools fastq -G 12 -f 129 seqs.sharks.bam > right.shark.fastq



bowtie2 -x ../db_dir/xenotrop -p 8 -1 160219_D00248_0151_AC8GC2ANXX_8_TP-D7-008_TP-D5-007_1.trimmed.R1.fq.gz -2 160219_D00248_0151_AC8GC2ANXX_8_TP-D7-008_TP-D5-007_2.trimmed.R2.fq.gz > carpoutput.sam

bowtie2 -x ../db_dir/xenotrop -p 8 -1 160303_D00248_0155_AC6K7AANXX_1_TP-D7-008_TP-D5-007_1.trimmed.R1.fq.gz -2 160303_D00248_0155_AC6K7AANXX_1_TP-D7-008_TP-D5-007_2.trimmed.R2.fq.gz > output1.sam

bowtie2 -x ../db_dir/xenotrop -p 8 -1 160303_D00248_0155_AC6K7AANXX_2_TP-D7-008_TP-D5-007_1.trimmed.R1.fq.gz -2 160303_D00248_0155_AC6K7AANXX_2_TP-D7-008_TP-D5-007_2.trimmed.R2.fq.gz > output2.sam

bowtie2 -x ../db_dir/xenotrop -p 8 -1 160303_D00248_0155_AC6K7AANXX_3_TP-D7-008_TP-D5-007_1.trimmed.R1.fq.gz -2 160303_D00248_0155_AC6K7AANXX_3_TP-D7-008_TP-D5-007_2.trimmed.R2.fq.gz > output3.sam

samtools sort .*bam

samtools merge .*bam 

blastn -query contigs.fasta -subject GCA_000951615.2_common_carp_genome_genomic.fna 
