import os
from pathlib import Path
import csv
import pandas as pd
import re
import sys

# Change working directory
absPath = os.path.abspath(__file__)
dName = os.path.dirname(absPath)
os.chdir(dName)

#Input family name and creating neccessary directories
family_name = sys.argv[1]
Path("./data/" + family_name).mkdir(parents=True, exist_ok=True)
Path("./data/" + family_name + "/rSeq").mkdir(parents=True, exist_ok=True)

# Take reverse sequences from vORFfinder output folders and format them into 1) individual rORFs for each member 2) multiFasta file of all rORFs in one
directory_path = "./data/" + family_name + "/ORF"
extension = ".orfviewer.txt"

for item in os.listdir(directory_path):
    if item.endswith(extension):
        df = pd.read_csv("./data/" + family_name + "/ORF/" + item, sep="\\t", engine = "python")
        rORFs = df[df["strand"] == "-"]
        seq = rORFs.loc[:, ["seq.name", "seq.text", "hits"]]
        col = ['seq.name', 'seq.text', "hits"]
        file_name = "./data/" + family_name + "/rSeq/" + family_name + "_" + item
        rORFs.to_csv(r"./data/" + family_name + "/rSeq/" + family_name + "_" + item, header=None, index=None, columns= col, sep=str("\t"), mode ="w")
        f = open(file_name, "r")
        cont = f.read()
        l = cont.split("\n")
        name = "./data/" + family_name + "/" + family_name + "_rORFs_multiFasta.fasta"
        f = open(name ,"a")
        for line in l:
            if line == "":
                continue
            else:
                result = re.split(' |\t', line)
                f.write(">" + result[0] + "\n" + result[1] + "\n")

print("Done! MultiFasta file ready for DIAMOND BLAST")