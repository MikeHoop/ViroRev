import os
import subprocess
import zipfile
import shutil
import math
import sys

#Set working directory
absPath = os.path.abspath(__file__)
dName = os.path.dirname(absPath)
os.chdir(dName)

# Assign family name
family_name = sys.argv[1]

# Create directory
print("Creating directory...")
os.makedirs("./data", exist_ok=True)
folder_path = "./data/" + family_name
os.makedirs(folder_path, exist_ok=True)

query = './datasets download virus genome taxon '+ family_name + ' --complete-only --refseq --filename ./data/'+ family_name + '_dataset.zip'
os.system(query)

# Extract sequences from NCBI folder
file_name = './data/' + family_name + '_dataset.zip'
with zipfile.ZipFile(file_name) as z:
    with z.open('ncbi_dataset/data/genomic.fna') as zf, open('data/' + family_name +'/' + family_name + '_multiFasta.fasta', 'wb') as f:
        shutil.copyfileobj(zf,f)

# Get a count of how many sequences
f = open('data/' + family_name + '/' + family_name + '_multiFasta.fasta', "r")
count = 0
for x in f:
    if x[0] == ">":
        count += 1
print("count =", count)
f.close()

# Split multi fasta file into individual fasta files
folder_path = 'data/' + family_name + '/' + family_name + '_split'
f = open('data/' + family_name + '/' + family_name + '_multiFasta.fasta', "r")
cont = f.read()
l = cont.split(">")
split_path = folder_path +"/" + family_name + "_split"
os.makedirs(split_path, exist_ok=True)
for line in l:
    if line == "":
        continue
    else:
        acc = line.split(" ")[0]
        fasta_num = str(acc)
        fasta_name = split_path + "/" + fasta_num + ".fasta"
        f = open(fasta_name ,"w")
        f.write(">" + line.strip() + "\n")
f.close()

print("Zipping split fasta files...")
zip_name = family_name +"_split"
shutil.make_archive("./data/" + family_name + "/" + zip_name, "zip", folder_path)

print("Done! Zip files ready for vORFfinder.")
