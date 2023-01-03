# importz 
import pandas as pd
import argparse
from isolates import list_of_isolates

# # argparse block
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

# merge df and list of isolates 
df = pd.concat([df, pd.DataFrame(list_of_isolates, columns=["Test"])], axis=1)

# copy new column to Names  
df['Names'] = df['Test']

# remove added column
df.pop("Test")

# convert missing values to 0
df = df.fillna(0)

#generate csv
df.to_csv(args.output)