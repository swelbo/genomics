#### Amelie gene/snp handling

# libraries 
import pandas as pd
import argparse

# # argparse block
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="Input .txt file (incl path/to/file)", required=True)
parser.add_argument("-g", "--gene", help="Gene name (i.e. 'GeneA')",required=True)
parser.add_argument("-o", "--output", help="Output csv (i.e 'output.csv' and incl path/to/file)", required=True)
args = parser.parse_args()

# # read in data file
# x = pd.read_csv(args.input, sep="\t", header=0)

x = pd.read_csv(args.input, sep="\t", names=["CHROM", "POS", "DOT", "REF", "ALT", "QUAL", "FILTER", "DATA", "GUIDE", "GUIDE_DATA", "ANNO", "NAME"], index_col=False)

# split at . pull at NAME
names = []
for i in x.NAME:
    names.append(i.split(".")[0])

snps = []
for i in x.ANNO:
    y = i.split(",")[9]
    snps.append(i.split(",")[9])

df = pd.DataFrame()
df['Names']  = names
df['SNPS']  = snps

# add a column for gene name
df['Gene'] = args.gene

# combine SNP and gene columns
df['SNP_Gene'] = df['Gene'] + "_" + df['SNPS']

# add a bool column all True
df['Bool'] = True

# drop sNp and gene column
df = df.drop(['SNPS', 'Gene'], axis=1)

# pivot table into a matrix
df = df.pivot(index='Names', columns='SNP_Gene', values='Bool')

# convert True to 1 and False to 0
df = df.fillna(0)
df = df.astype(int)

#generate csv
df.to_csv(args.output)