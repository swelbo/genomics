## Nanoplot ##

#activate environment
conda activate nanoplot

#NanoPlot loop over barcodes in each Push
for file in *; do
	cat $file/*.fastq.gz > $file/reads.fastq.gz; 
	NanoPlot --fastq $file/reads.fastq.gz -o $file; 
done
