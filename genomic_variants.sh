## Genomic variants with GATK4 and GVCFs
## guide
https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels-

##
qsub -I -l select=1:ncpus=8:mem=32gb -lwalltime=8:00:00

##
module load  anaconda3/personal

## activate conda environment
conda activate gatk_env

cd /rds/general/project/fisher-aspergillus-results/live/swel

gatk --java-options "-Xmx32g" HaplotypeCaller \
-R /rds/general/project/fisher-aspergillus-reference/live/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa \
-I test2.bam \
-O output2.g.vcf.gz \
--tmp-dir $EPHEMERAL \
-ERC GVCF

gatk CombineGVCFs \
   -R /rds/general/project/fisher-aspergillus-reference/live/Aspergillus_fumigatus.CADRE.12.dna.toplevel.fa \
   --variant output.g.vcf.gz \
   --variant output2.g.vcf.gz \
   --variant output2.g.vcf.gz \
   --tmp-dir $EPHEMERAL \
   -O cohort.g.vcf.gz

   java -jar $PICARD_HOME/picard.jar RenameSampleInVcf \
     INPUT=output.g.vcf.gz \
     OUTPUT=ooutput1.g.vcf.gz \
     NEW_SAMPLE_NAME=WGS1
