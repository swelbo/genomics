# importz 
import pandas as pd
import argparse
from isolates import list_of_isolates

# argparse block
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="Input .csv file (incl path/to/file)", required=True)
parser.add_argument("-o", "--output", help="Output csv (i.e 'output.csv' and incl path/to/file)", required=True)
args = parser.parse_args()

# read csv file
df = pd.read_csv(args.input, sep=",")

# change name is Names column 
list_of_new_names = []
for i in df["Names"]:
    list_of_new_names.append(i.split("/")[7])

# Replace the values in the "Names" column with the new values
df["Names"] = df["Names"].replace(df["Names"].values, list_of_new_names)

# convert list of isolates to df2
df2 = pd.DataFrame(list_of_isolates, columns=["Names"])

# merge the two dfs
df = pd.merge(df, df2 , on="Names", how = "outer", sort=True)

# convert missing values to 0
df = df.fillna(0)

#generate csv
df.to_csv(args.output)
