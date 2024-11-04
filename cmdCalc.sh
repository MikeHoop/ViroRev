#CHANGED FROM vORFFNDER! By Michael Hooper

##-- 1. receive user input file and parameters
name=$1

taskID=${name}
file=./data/${name}/${name}_split.zip
orf_len=300
start_codon=0
genetic_code=1
ignore_nest=FALSE

rm -r ./data/$taskID/blastp ./data/$taskID/database ./data/$taskID/ORF ./data/$taskID/log
mkdir -p  ./data/$taskID/blastp ./data/$taskID/database ./data/$taskID/ORF ./data/$taskID/log
chmod 777 ./data/$taskID/blastp ./data/$taskID/database ./data/$taskID/ORF ./data/$taskID/log


printf "your taskID is : "$taskID"\n"
printf "ORFfinder parameters are setting to:\n"
printf "ORF length : "$orf_len"\n"
printf "start codon : "$start_codon"\n"
printf "genetic code : "$genetic_code"\n"
printf "ignore_nest : "$ignore_nest"\n"
printf "your file including:\n"

unzip $file -d ./data/$taskID/database/virus_seq
mv ./data/$taskID/database/virus_seq/*/* ./data/$taskID/database/virus_seq

echo "SOME PREPARE WORK"
##--  2. some prepare work

#format fasta files included in zip file
for id in $(ls ./data/$taskID/database/virus_seq/*fasta); do ID=`echo $id|sed 's/.*\\///g'|sed 's/.fasta//g'`;sed -i "s/>.*/>$ID/g" $id; done

cat ./data/$taskID/database/virus_seq/*fasta > ./data/$taskID/database/virus_db.fasta
Rscript script/virus_length.R ./data/$taskID/database/virus_db.fasta ./data/$taskID/database/virus_length.txt

mafft ./data/$taskID/database/virus_db.fasta > ./data/$taskID/database/virus_msa.fasta

##-- 3. construct phylogenetic tree : DECIPHER (Not needed for current pipeline)
###Rscript script/phyloTree_DECIPHER.R ./data/$taskID/database/virus_msa.fasta ./data/$taskID/database/constree> ./data/$taskID/log/step3_phyloTree_DECIPHER.log 
###sed -i 's/\"//g' ./data/$taskID/database/constree

##-- 4. make ORF database
echo "MAKING ORF DATABASE"
for id in $(ls ./data/$taskID/database/virus_seq/*fasta); do { sample=`echo ${id}|sed 's/.*\///g'|sed 's/.fasta//g'`; software/ORFfinder -in $id -ml $orf_len -s $start_codon -g $genetic_code -n $ignore_nest -out ./data/$taskID/ORF/${sample}.orfs >> ./data/$taskID/log/step4_make_orf_db.log; }& done ;wait
for id in $(ls ./data/$taskID/database/virus_seq/*fasta); do { sample=`echo ${id}|sed 's/.*\///g'|sed 's/.fasta//g'`; software/ORFfinder -in $id -ml $orf_len -s $start_codon -g $genetic_code -n $ignore_nest -out ./data/$taskID/ORF/${sample}.seq >> ./data/$taskID/log/step4_make_orf_db.log -outfmt 1; }& done ;wait
sed -i 's/lcl|//g' ./data/$taskID/ORF/*.orfs
sed -i 's/ unnamed protein product.*//g' ./data/$taskID/ORF/*.orfs

cat ./data/$taskID/ORF/*.orfs > ./data/$taskID/database/orf_db.fasta

echo "MAKEBLASTDB"
makeblastdb -in ./data/$taskID/database/orf_db.fasta -parse_seqids -dbtype prot >> ./data/$taskID/log/step4_make_orf_db.log
##-- 5. blastp
echo "BLASTP"

for id in $(ls ./data/$taskID/ORF/*orfs); do { sample=`echo ${id}|sed 's/.*\///g'|sed 's/.orfs//g'`; blastp -query $id -db ./data/$taskID/database/orf_db.fasta -outfmt 15 -evalue 0.05 > ./data/$taskID/blastp/${sample}.blast ; }& done ; wait
for id in $(ls ./data/$taskID/ORF/*orfs); do { sample=`echo ${id}|sed 's/.*\///g'|sed 's/.orfs//g'`; blastp -query $id -db ./data/$taskID/database/orf_db.fasta -outfmt 10 -evalue 0.05 > ./data/$taskID/blastp/${sample}.blastp ; }& done ; wait
for id in $(ls ./data/$taskID/blastp/*blast)
do
  Rscript ./script/blast_process2.R $id ./data/$taskID >> ./data/$taskID/log/step5_blastp.log
done

for id in $(ls ./data/$taskID/blastp/*blastp)
do
  Rscript ./script/blast_process.R  $id ./data/$taskID >> ./data/$taskID/log/step5_blastp.log
done

#for id in $(ls $taskID/blastp/*fa); do { /opt/conda/bin/clustalw -INFILE=$id -OUTPUT=FASTA >> $taskID/log/step5_clustalw.log; }& done; wait
#for id in $(ls blastp/*msa.fa); do Rscript script/msa_html.R $id>> log/step5_blastp.log ; done

## files for orf viewer
echo "FILE FOR ORF VIEWER"
#for id in $(ls ./data/$taskID/ORF/*orfs); do { Rscript script/orf_process.R $id ./data/$taskID>> ./data/$taskID/log/step6_orfviewer.log; }& done
for id in $(ls ./data/$taskID/ORF/*orfs)
do 
	echo ${id}
	Rscript script/orf_process.R $id ./data/$taskID
done

