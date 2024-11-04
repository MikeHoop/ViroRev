Grapevine virus rORF finder (Michael Hooper, 2024):

This program utilises vORFfinder scripts as designed by Gong et al (2021).

HOW TO USE:

1) Installation:

Please make sure that the following command line tools are installed:
(NB! Run the below commands in the same working directory as pipeline.pbs)

NCBI datasets: (https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/)
Recommended installation is to simply type "curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets'" into the command line (WITHOUT the double quotes)

DIAMOND BLAST tools:
wget http://github.com/bbuchfink/diamond/releases/download/v2.1.10/diamond-linux64.tar.gz
tar xzf diamond-linux64.tar.gz

Once these are installed please run:

chmod 777 ./datasets
cmhod 777 ./diamond
chmod 777 ./software/ORFfinder

(The above commands give execution permissions to the executables.)

2) Running the script:

First, open "pipeline.pbs" and change the variable name to the virus family you want to study. Then:

Running on an HPC, simply type (WITHOUT double quotes): "qsub pipeline.pbs"

	If you do not have bioinformatics queue permissions, remove "#PBS -q bix"

Note: If you do not have access to an HPC, rename "pipeline.pbs" to "pipeline.sh" and you should be able to run the script on Linux by removing all "module load" lines and installing the necessary libraries.
