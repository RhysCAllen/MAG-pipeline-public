# Peat Metagenome assembly pipeline 2022
###### Rhys Allen 2022

The purpose of this file is to develop a pipeline for assembling prokaryote genomes from shotgun metagenomic sequence (MAGs). This pipeline uses from a Swedish arctic peat bog, <a href="https://www.nature.com/articles/s41586-018-0338-1">previously characterized</a> in BJ Woodcroft et al in 2018: "Genome-centric view of carbon processing in thawing permafrost.", Nature, 2018 Aug;560(7716):49-54.   

The pipeline was developed primarily from two resources: <a href="https://biovcnet.github.io/">BVCN</a> and <a href="https://anvio.org/">anvi'o</a>, with additional pipeline info from <a href="https://maveric-informatics.readthedocs.io/en/latest/Processing-a-Microbial-Metagenome.html">MAVERIC</a> (the Sullivan lab; OSU). This is a work-in-progress that will undergo continuous updating with version control. 

**What is BVCN?**  
>"The Bioinformatics Virtual Coordination Network was started in March 2020 in response to the COVID-19 pandemic. As research laboratories were shutting, we, a group of bioinformaticians and computational biologists, sought to formalize training to helping wet-lab biologists pick up some computational skills/begin computational projects during the global crisis."

**Anvi'o in a Nutshell:**
>"Anvi’o is a comprehensive platform that brings together many aspects of today’s cutting-edge computational strategies of data-enabled microbiology, including genomics, metagenomics, metatranscriptomics, pangenomics, metapangenomics, phylogenomics, and microbial population genetics in an integrated and easy-to-use fashion through extensive interactive visualization capabilities."


This pipeline was prepared using  
Linux-5.4.0-1065-gcp-x86_64-with-glibc2.27 or  
Linux-5.4.0-1087-gcp-x86_64-with-glibc2.27,  
running Ubuntu 18.04 LTS
on a Google cloud virtual machine.

The following additional files can be used to aid installation of software environments used in this pipeline. Note you will need to update the path at the bottom of each .yml file to reflect your local settings.  
&emsp;-anvio-env.yml   
&emsp;-anvio7.1_x-platform_env.yml  
&emsp;-base-env.yml  
&emsp;-binning_x-platform_env.yml  
&emsp;-sourmash_x-platform_env.yml   
&emsp;-vm-instance-GCE-protocol.txt  

Previous versions of this pipeline (MAG-bvcn-pipeline-bbtools.md; MAG-bvcn-pipeline-kraken2.md) include detailed information on the following.  
&emsp;-Fastq-dump  
&emsp;-Trimmomatic  
&emsp;-Bowtie2  
&emsp;-SPAdes  
&emsp;-Kraken2  
&emsp;-Binning tools (DAS-tool, MaxBin, etc)  
&emsp;-CheckM for bin QC  

### References:

###### Peat metagenome:
https://maveric-informatics.readthedocs.io/en/latest/Processing-a-Microbial-Metagenome.html  
Journal article link: https://www.ncbi.nlm.nih.gov/pubmed/30013118  
Bioproject number link: https://www.ncbi.nlm.nih.gov/bioproject/PRJNA386568  

###### Conda/HPC:
https://protocols.hostmicrobe.org/metagenomics-in-the-cloud  
https://towardsdatascience.com/introduction-to-conda-virtual-environments-eaea4ac84e28  
https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-from-an-environment-yml-file  
https://stackoverflow.com/questions/42352841/how-to-update-an-existing-conda-environment-with-a-yml-file  
https://conda.io/projects/conda/en/latest/user-guide/install/linux.html  

###### Additional Metagenome Tutorials:  
SunBeam, a SnakeMake for automating MAGs (Bittinger Lab, U Penn)  
https://sunbeam.readthedocs.io/en/stable/  
Happy Belly Bioinformatics, a bioinformatics tutorial resource (Mike Lee, NASA)
https://astrobiomike.github.io/genomics/metagen_anvio  
Computational Genomics Manual (R. Edwards Lab, Flinders U, Australia)
https://github.com/linsalrob/ComputationalGenomicsManual
Metagenomics course instruction (J Banfield Lab, UC Berkeley)  
https://jwestrob.github.io/ESPM_112L/  

# Contents:
    MODULE 0: Setting up VM, Github repo, Conda Environments, and Data Download with FasterQ-dump
    MODULE 1: Read Trimming and Quality Filtering using BBtools
    MODULE 2: Visualizing Read Quality with FastQC  
    MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk
    MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts
    MODULE 5: Library assembly and co-assembly with MegaHIT and metaSPAdes
    MODULE 6: Read Mapping and Alignments using BBWrap
    MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool
    MODULE 8: Bin Evaluation with CheckM
    MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o and PathwayTools
    APPENDIX: X11-forwarding to use Pathway Tools

##### Tool Links:
bbtools: https://jgi.doe.gov/data-and-tools/bbtools/  
FastQC: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/  
MultiQC: https://multiqc.info/   
sourmash: https://sourmash.readthedocs.io/en/latest/)  
krona: https://github.com/marbl/Krona/wiki  
metabat: https://bitbucket.org/berkeleylab/metabat/src/master/  
binsanity: https://github.com/edgraham/BinSanity/   
DAS Tool: https://github.com/cmks/DAS_Tool  
CHeckM: https://github.com/Ecogenomics/CheckM   

Each Module is organized as follows:  
&emsp;-A brief intro statement to set the stage for connecting from previous module, and tool selection for current module.  
&emsp;-Tool documentation and help menu commands  
&emsp;-bash code examples for peat pipeline use case  
&emsp;-Explanation of code parameters   
&emsp;-Interpreting tool outputs  
&emsp;-Supplementary tool info   

Pipeline File structure (flat rather than nested directory structure recommended):  

~/MAG-pipeline/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Github repo  
~/miniconda3/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# conda install and envs  
~/project-data/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Original SRR downloads, and qualtrimmed files  
~/sourmash/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Taxonomic Classification and Krona charts  
~/megahit/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Co-assembly contigs  
~/SPAdes&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Error-corrected and normalized reads  
~/bbwrap&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Read alignments, mapping files  
~/binning/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# bin results from BinSanity etc  
~/binning/DAS_Tool&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# binning optimization  
~/binning/checkm&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# binning QC  
~/anvi'o&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# visualization and metabolic analysis of MAGs  

The conda environments and repos for these files take about 45GB of disk space, before any data is downloaded. 
<br>
<br>
<br>

# Module 0: Set up VM, Github Repo, Conda Environment, and Data Download

###### 1. Set up VM.
 
See file vm-instance-GCE-protocol.txt  
Create project with public metadata.  
Create VM instance.  

For assembling a single library:  
  Recommend 8 cores, 50 GB RAM, 100 GB SSD hard drive boot disk.  
For co-assembly of 3 libraries totalling 5 GB data (12 GBp seq):  
  Recommend 128 GB RAM, 500 GB disk, and 16 cores (actually only needed 75 GB RAM, 69 GB disk usage without anvio installed).  
For co-assembly of soil metagenome (3.5 billion reads, 252 billion bp):  
  Recommend 24 cores, 260-384 GB RAM, 10-15 TB disk space.  

See this meta-analysis for benchmarking computation performance needed for co-assembly:  https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-017-3918-9  

In order to view interactive web pages from your VM, such as with anvi'o interactive, you will need to add firewall rules to the VM.   

For making a firewall rule, start by opening your VM in a Google Chrome browser.  

If you've previously created a firewall for a given project, check to make sure it's being applied to your current VM by filtering for 'Enforcement: enabled' 

https://www.trendmicro.com/cloudoneconformity/knowledge-base/gcp/CloudVPC/check-for-port-ranges.html  

To set up a new firewall rule, for anvi'o web interactive from a cloud VM:  

https://cloud.google.com/vpc/docs/using-firewalls  
https://edwards.flinders.edu.au/install-anvio-on-an-aws-instance/  
https://merenlab.org/2015/11/28/visualizing-from-a-server/  
https://merenlab.org/2018/03/07/working-with-remote-interative/  

From the first link, start with this step:  
"Edit your security groups. You need to add HTTP and HTTPS that are chosen from the pull down menu, but you also need to add a single special rule for port 8080 traffic that anvi’o uses."  

The http and https are selected when creating or editing VM instance. Adding the new firewall rule requires additional steps.  

For Google cloud, the way to edit security groups is as follows:  
1) Pause your VM instance.  
2) In Google cloud account's hamburger menu in the upper left:  
VPC network --> Firewall --> Create Firewall Rule  

3) Choose the following settings:
   -default network (nic0),
   -priority 1000 (default; high),
   -Ingress action allowed,
   -targets: all instances on network;
   -source filter: IPv4 ranges;
   -Source IPv4 ranges: 0.0.0.0/0  
   -second source filter: service account;
   -service account scope: in this project;
   -source service account: Compute Engine default (75153623014-compute@developer.gserviceaccount.com),
   -Specified protocols and port: TCP; 8080.  
It's hard to tell, but I think this is as close to the AWS guide above on setting the source range and port range for this custom TCP firewall rule.  

4) Once the self-test runs (anvi-self-test --suite mini), you can head to your browser and enter your VM external IP address followed by :8080, something like this:  

http://18.188.65.122:8080  

Don't use the URL provided in the terminal output bc it won't work. :D  

###### 2. Connect to your github profile 

For using anvi'o with Google Cloud, generate a .pem SSH keypair in your VM, so that there aren't any issues with the VM user name conflicting with SSH key username for SSH port tunneling or user access levels.  

``` {bash eval=FALSE}
#Generate key pairs

 ssh-keygen -t rsa -m pem
 $ specify filepath: ~/.ssh/id_rsa.pem  #need to specify the .pem extension when prompted

eval 'ssh-agent -s' 
ssh-add ~/.ssh/id_rsa.pem

#sometimes you will need to run this line:
sudo ssh-add ~/.ssh/id_rsa.pem
#even if you get an error, you should be able to eval and then ssh-add after that:
eval 'ssh-agent -s' ssh
ssh-add ~/.ssh/id_rsa.pem

#confirm the new private key was added:
ssh-add -l

#You might need create and modify the .ssh/ config file if ssh-add isn't working, or to run X11 forwarding such as for Pathway Tools:
#https://stackoverflow.com/questions/3466626/how-to-permanently-add-a-private-key-with-ssh-add-on-ubuntu

cd ~/.ssh
cat > config <<EOF
Host github.com
    User git
    IdentityFile ~/.ssh/id_rsa.pem
EOF

ssh -T git@github.com

 If all else fails, just make a new ssh key pair:

  profile:
 http://zeeelog.blogspot.com/2017/08/the-authenticity-of-host-githubcom.html

 # copy the public key text, and add to your github profile
 # also go to your VM instance, and add to SSH keys
 ```


``` {bash eval=FALSE}

#Set some git defaults for proper init downstream

cd ~
 git --version #confirm git installed by default with Ubuntu
 git status 
 git config --global user.name rhys
 git config --global user.email 31254709+RhysCAllen@users.noreply.github.com

 git config --global init.defaultBranch main
 git config --list


#Initialize git, connect to github, and clone repo with conda envs.

git init
git status  #confirm git initialized
git remote add origin https://github.com/RhysCAllen/MAG-pipeline

cd ~

git clone git@github.com:RhysCAllen/MAG-pipeline ~/MAG-pipeline
```



###### 3. Create and activate conda environment.

Info for installing conda:

https://conda.io/projects/conda/en/latest/user-guide/install/linux.html

```{bash eval=FALSE}
sudo apt-get update

curl https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh > conda-install.sh

bash conda-install.sh

#For changes to take effect, close and re-open your current shell.
```



``` {bash eval=FALSE}
#If sourmash-env.yml file exists already:
conda env create --file ~/MAG-pipeline/sourmash-environment.yml

# Otherwise, to create sourmash conda env from scratch (no .yml file):

conda config --add channels bioconda, conda-forge, agbiome

sudo apt-get update
conda config --add channels bioconda, conda-forge, agbiome

conda install fastqc 
conda install multiqc 
conda install -c bioconda sra-tools
conda install -c agbiome bbtools  #will have a build-integer of 0; is ok
conda install krona
conda install -c bioconda sourmash 


to export yml file after everything's installed:

conda env export > sourmash-environment.yml
conda env export --no-builds > sourmash-env-x-platform.yml 
#add a --no-builds flag to exclude platform-specific build constrains, possibly #making your .yml file transferrable between Mac and Linux, for example. 
```

``` {bash eval=FALSE}
#Create separate environment for using fasterq-dump, which is incompatible with sourmash env. Fasterq-dump is much faster than fastq-dump

conda create -n fasterq-dump sra-tools=2.10.0 -c bioconda 
```


###### 4. Collect data to analyze:

use an awk script to iterate through a text file of SRR numbers, if needed.
Or sed, maybe?

Sample naming: I inferred this by looking at the supplementary data, and cross-referencing with BioSample info online.

In the paper, they indicate the following:  

Three different environments:&nbsp;palsa (P), bog (S), and fen (E)  
Three consecutive years:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2010, 2011, 2012  
Three depths:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Surface, Medium, Deep (extra deep sometimes)  
Three technical replicates:&nbsp;&nbsp;&nbsp;1, 2, 3  

So for example, the following sample names can be used to identify technical and biological replicates:  

/* these are the three technical replicates of the deep fen sample in 2010.  
^ these are 3 of 9 biological replicates of surface fen sample from '10-'12  

20100900_E1D *  
20100900_E1S ^  
20100900_E2D *  
20100900_E2S  
20100900_E3D *  
20100900_E3S  
20110600_E1D  
20110600_E1M  
20110600_E1S ^  
20110600_E2D  
20110600_E2S  
20110600_E3D  
20110600_E3M  
20120600_E2S ^  

Let's start with co-assembly of three technical replicates.  

From Fig 1 in the paper, looks like the wettest biome (fen) has the most ecological diversity (most interesting phylogenetic trees) and has a good amount of Chloroflexi, which are fun to look at for different carbon pathways. Fen is mostly saturated peat, which will have an oxygen gradient, adding metabolic functional diversity too. Chloroflexi is also a good choice because there are no new MAGs desribed in this phylum by this study, so the chloroflexi have probably been previously sequenced and published multiple times, meaning good k-mer classificaton confidence compared to newbly identified strains.  

I want to keep the original library from the published MAG pipeline tutorial, since the analysis of that one is well-characterized.  
https://maveric-informatics.readthedocs.io/en/latest/Processing-a-Microbial-Metagenome.html

Here's that info: this is the third technical replicate of the palsa ecotype, from July of 2012, Medium depth.    

20120700_P3M SRR7151490 1.2 GB (2.9 GBp)--> ends up being 8 GB of .fastq   

Here are the other two replicates:  

20120700_P2M SRR7151527 1.4 GB&nbsp;&nbsp;(3.4 GBp)--> 9 GB of .fastq   

20120700_P1M SRR7151524 1.9 GB&nbsp;&nbsp;(5.2 GBp)--> 13 GB of .fastq  

Let's get the SRR numbers for these three technical replicates (deep fen from 2010), in case we ever want to check these out (more data):  

20100900_E1D SAMN07124883 SRS3288991 SRR7151642 8 GB  
20100900_E2D --> &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;-->&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;SRR7151644 7.6 GB  
20100900_E3D --> &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;-->&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;SRR7151720 8.4 GB  



fasterq-dump is a wrapper for two distinct steps: first, downloading .sra files from NCBI using FTP; and second, using SRA-tools to convert the .sra files to fasta format.  
https://blogs.iu.edu/ncgas/2021/02/22/a-beginners-guide-to-the-sra/  

fasterq-dump has a default behavior of downloading cache files, which are then deleted after download is complete. The cache files take up 10x the memory of the fasta files. Apparently the cache files are optional. Recommend to toggle off the cache option, and change the default download path.


```{bash eval=FALSE}
conda activate fasterq-dump
mkdir project-data
vdb-config -i 
#you'll get a strange-looking color screen displayed in the terminal. Navigate with tab to toggle off the cache, and set downloads folder path. 
```

Alternatively, there's a bunch of info about using pre-fetch and checking and adjusting file size capacity. I don't understand the benefit of this.

Check disk storage when launching new connection:
 => / is using 89.2% of 96.73GB  # gotta delete stuff

 You can keep all the files as you move through the whole pipeline if you're analyzing just one SRR sample. For multiple samples on a 100 GB drive, will need to delete files as you go along.

Tool use:  
https://blogs.iu.edu/ncgas/2021/02/22/a-beginners-guide-to-the-sra/  
https://github.com/ncbi/sra-tools/wiki/08.-prefetch-and-fasterq-dump  

Linux file systems affected by SRA downloads:  
https://www.moritzs.de/linux/thank_you_sra/  

More info on the effect of cache files during fasterq-dump download:  
https://standage.github.io/that-darn-cache-configuring-the-sra-toolkit.html  

```{bash eval=FALSE}
fasterq-dump SRR000001 --size-check   #checks size of download. multiply by 10 for cache files.

vdb-dump --info SRR7151524      #tells the size of file being downloaded

# For best results, use pre-fetch to do the FTP of .sra files first. 
# Using 'fasterq-dump SRR######' will automatically do pre-fetch.

fasterq-dump SRR7151524 -p #20120700_P1M 
fasterq-dump SRR7151527 #20120700_P2M
fasterq-dump SRR7151490 #20120700_P3M  
#P3M is the sample analyzed in the Maverick peat pipeline

```
the -p flag is for progress bar  
-t is for threads, with diminishing returns. Default is 6.  
<br>
<br>
<br>


# Module 1: Read Trimming and Quality Filtering Using K-mers

We're going to trim reads first, and then in Module 2, examine the quality of trimmed and untrimmed reads both. If you're concerned about read quality of a sequencing run, you may want to start with Module 2 and screen quality of reads first, before trimming etc.

Two options for read trimming: trimmomatic, or bbduk.
Bbduk supports an option for keeping singletons if only one of a pair of reads has been filtered out:
http://seqanswers.com/forums/showthread.php?t=58296

While capturing singletons for additional binning data doesn't make much of a difference, it's pretty easy to keep track of, and there's no real reason to throw away this data. 

Required Tools and conda channel for install:  
&emsp;-sourmash  
&emsp;-bioconda  
&emsp;-bbtools  
&emsp;-agbiome  

BBtools help and links:
https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbduk-guide/  

For help menu:  
bbduk.sh with no parameters into the terminal.  

-t threads which is auto-detected  


``` {bash eval=FALSE}

# bbtools can be found in the sourmash conda env:
 conda activate sourmash

# Two lines of code for the peat metagenome are as follows:

# 1) Trim read adapters.

#from a single sample:

SRR=SRR7151527

bbduk.sh in1=${SRR}_1.fastq in2=${SRR}_2.fastq out1=${SRR}_1_trimmed.fastq out2=${SRR}_2_trimmed.fastq ref=adapters ktrim=r k=23 mink=11 hdist=1 tpe tbo ordered

#from multiple samples:
cd ~/project-data

for prefix in `ls *.fastq | cut -f1 -d'_' | sort -u`; do 

  echo ${prefix}

  Read1=( ${prefix}_1.fastq )  
  Read2=( ${prefix}_2.fastq )

bbduk.sh in1=$Read1 in2=$Read2 out1=${prefix}_1_trimmed.fastq out2=${prefix}_2_trimmed.fastq ref=adapters ktrim=r k=23 mink=11 hdist=1 tpe tbo ordered;
done 



# 2: Screen read quality and keep singletons   


for prefix in `ls *_trimmed.fastq | cut -f1 -d'_' | sort -u`; do

  echo ${prefix}

  Read1=( ${prefix}_1_trimmed.fastq )
  Read2=( ${prefix}_2_trimmed.fastq )

  bbduk.sh in1=$Read1 in2=$Read2 qtrim=rl trimq=10 maq=8 minlen=70 ordered out1=${prefix}_1_qualtrimmed.fastq out2=${prefix}_2_qualtrimmed.fastq outm1=${prefix}_1_removed.fastq outm2=${prefix}_2_removed.fastq removeifeitherbad=f outs=${prefix}_singletons_qualtrimmed.fastq stats=${prefix}_stats nzo=t statscolumns=5 ow=t;

done

```

Info below is background and alternative quality trimming, etc. 
To proceed with pipeline, skip to next section (Module 2). &nbsp;&emsp;

bbduk creator's recommended settings for adapter trimming:  
ref=adapters&emsp;&emsp;&emsp;&emsp;&emsp;#use the built in adapters.fa file containing all known Illumina adapters  
ktrim=r&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;#trim from the right (3') end of the sequence  
k=23&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;#use a kmer length of 23 bp  
mink=11&nbsp;&nbsp;&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;#allow a minimum kmer length of 11 bp at the end of the sequence  
hdist=1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;#allow a maximum of 1 mismatch  
tbo&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;#trim by overlap    
tpe&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;#trim both reads to be the same length  
ow=t&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;#allow overwriting of existing files  


BBDuk is strictly deterministic on a per-read basis, however it does by default reorder the reads when run multithreaded. You can add the flag "ordered" to keep output reads in the same order as input reads.  

Note that clumpify.sh only works on raw sequence data; it will throw an error if it's run on SRA downloads which are presumably missing the tiling info from the files.


``` {bash eval=FALSE}
for prefix in `ls *_R1_*.fastq.gz | cut -f1 -d'_' | sort -u`; do 

  echo ${prefix}

  R1=( ${prefix}*_R1_*.gz )
  R2=( ${prefix}*_R2_*.gz )
  
  # Remove optical duplicates
  # This means they are Illumina reads within a certain distance on the flowcell.
  clumpify.sh in1=$R1 in2=$R2 out=clumped.fq.gz dedupe optical ow=t

  # Remove low-quality regions by flowcell tile
  # All reads within a small unit of area called a micro-tile are averaged, then the micro-tile is either retained or discarded as a unit.
  filterbytile.sh in=clumped.fq.gz out=filtered_by_tile.fq.gz ow=t
  
  #Trim adapters
  # 'ordered' means to maintain the input order as produced by clumpify.sh
  bbduk.sh in=filtered_by_tile.fq.gz out=trimmed.fq.gz ktrim=r k=23 mink=11 hdist=1 tbo tpe minlen=70 ref=adapters ordered ow=t

  #Remove synthetic artifacts and spike-ins by kmer-matching
  # 'cardinality' will generate an accurate estimation of the number of unique kmers in the dataset using the LogLog algorithm
  bbduk.sh in=trimmed.fq.gz out=filtered.fq.gz k=31 ref=artifacts,phix ordered cardinality ow=t
  
  #Quality-trim and entropy filter the remaining reads.
  # 'entropy' means to filter out reads with low complexity
  # 'maq' is 'mininum average quality' to filter out overall poor reads
  bbduk.sh in=filtered.fq.gz out=qtrimmed_${prefix}.fq.gz qtrim=r trimq=10 minlen=70 ordered maxns=0 maq=8 entropy=.95 ow=t
  #this level of entropy will filter out most of your reads; the range is 0 to 1 with 1 being the most stringent.
  
  # remove extra files
  rm clumped.fq.gz filtered_by_tile.fq.gz trimmed.fq.gz filtered.fq.gz

  # compute the minhash signatures (won't work until code below is activated)
  sourmash compute -k 31 --scaled=1000 qtrimmed_${prefix}.fq.gz
  
done
```

For running these steps one at a time, exluding clumpify and filter-by-tile, but including cleaned and masked and filtered by entropy, a sample loop would look like this:

``` {bash eval=FALSE}
for prefix in `ls *_trimmed.fastq | cut -f 1 -d '_'`; do bbduk.sh in=${prefix}_trimmed.fastq out=${prefix}_qualtrimmed.fastq qtrim=r trimq=10 minlen=70 ordered maxns=0 maq=8 entropy=.95; done
```

tbo=f (trimbyoverlap) Trim adapters based on where paired reads overlap.  

Here's why setting this to true (tbo=t or just tbo) is probably a good selection:   https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-016-1069-7  
Maybe set to true for shotgun sequencing, but set to false for SRA where inserts are likely to be shorter than read length, leading to read-through and adapter comtamination.  

tpe=f (trimpairsevenly) When kmer right-trimming, trim both reads to the minimum length of either.  

In ktrim=r mode, once a reference kmer is matched in a read, that kmer and all the bases to the right will be trimmed, leaving only the bases to the left; this is the normal mode for adapter trimming. (Adapters are only trimmed from the 3' end; i.e. the right end of the read, for Illumina; see this link:  
https://support.illumina.com/bulletins/2016/04/adapter-trimming-why-are-adapter-sequences-trimmed-from-only-the--ends-of-reads.html )  


Summary of some commands from help menu:  
out=<file>&emsp;&emsp;&emsp;&emsp;(outnonmatch) Write reads here that do not contain kmers matching the database. 'out=stdout.fq' will pipe to standard out.  
out2=<file>&emsp;&emsp;&emsp;&emsp;(outnonmatch2) Use this to write 2nd read of pairs to a different file.  
outm=<file>&emsp;&emsp;&emsp;&emsp;(outmatch) Write reads here that fail filters. In default kfilter mode, this means any read with a matching kmer. In any mode, it also includes reads that fail filters such as minlength, mingc, maxgc, entropy, etc.  In other words, it includes all reads that do not go to 'out'.  
outm2=<file>&emsp;&emsp;&emsp;&emsp;(outmatch2) Use this to write 2nd read of pairs to a different file.  
outs=<file>&emsp;&emsp;&emsp;&emsp;(outsingle) Use this to write singleton reads whose mate was trimmed shorter than minlen.  
stats=<file>&emsp;&emsp;&emsp;&emsp;Write statistics about which contamininants were detected.  
nzo=t&emsp;&emsp;&emsp;&emsp; Only write statistics about ref sequences with nonzero hits.  
statscolumns=3&emsp;&emsp;&emsp;&emsp;(cols) Number of columns for stats output, 3 or 5. 5 includes base counts.  

Wow it can make a bunch of histograms:  
Histogram output parameters:  
bhist=<file>&emsp;&emsp;&emsp;&emsp;Base composition histogram by position.  
qhist=<file>&emsp;&emsp;&emsp;&emsp;Quality histogram by position.  
qchist=<file>&emsp;&emsp;&emsp;&emsp;Count of bases with each quality value.  
aqhist=<file>&emsp;&emsp;&emsp;&emsp;Histogram of average read quality.  
bqhist=<file>&emsp;&emsp;&emsp;&emsp;Quality histogram designed for box plots.  
lhist=<file>&emsp;&emsp;&emsp;&emsp;Read length histogram.  
gchist=<file>&emsp;&emsp;&emsp;&emsp;Read GC content histogram.  
gcbins=100&emsp;&emsp;&emsp;&emsp;&emsp;Number gchist bins. Set to 'auto' to use read length.  
maxhistlen=6000 &emsp;&emsp;&emsp;&emsp;Set an upper bound for histogram lengths; higher uses more memory. The default is 6000 for some histograms and 80000 for others.  

Histograms for mapped sam/bam files only:  
histbefore=t&emsp;&emsp;&emsp;&emsp;Calculate histograms from reads before processing.  
ehist=<file>&emsp;&emsp;&emsp;&emsp;Errors-per-read histogram.  
qahist=<file>&emsp;&emsp;&emsp;&emsp;Quality accuracy histogram of error rates versus quality   

Neat you can tell it to ignore known variants: :D  
varfile=<file> &emsp;&emsp;&emsp;&emsp;Ignore substitution errors listed in this file when calculating error rates. Can be generated with CallVariants.  
vcf=<file>&emsp;&emsp;&emsp;&emsp;Ignore substitution errors listed in this VCF file when calculating error rates.  

Here's the switch for determining if one or both members of a paired read are kept:  
removeifeitherbad=t (rieb) Paired reads get sent to 'outmatch' if either is match (or either is trimmed shorter than minlen). Set to false to require both.  

Cool Entropy/Complexity parameters:  
entropy=-1&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;Set between 0 and 1 to filter reads with entropy below that value. Higher is more stringent.  
entropywindow=50&emsp;&emsp;&emsp;&emsp;Calculate entropy using a sliding window of this length.  
entropyk=5&emsp;&emsp;&emsp;&emsp;&emsp;Calculate entropy using kmers of this length.  
minbasefrequency=0&emsp;&emsp;&emsp;&emsp;Discard reads with a minimum base frequency below this.  
entropymask=f&emsp;&emsp;&emsp;&emsp;&emsp;Values:  
&emsp;&emsp;&emsp;&emsp;f:  Discard low-entropy sequences.  
&emsp;&emsp;&emsp;&emsp;t:  Mask low-entropy parts of sequences with N.  
&emsp;&emsp;&emsp;&emsp;lc: Change low-entropy parts of sequences to lowercase.  
<br>
<br>

#hdist=1 is the hamming distance: "If a hamming distance is used, such as hdist=1, then the number of kmers stored will be multiplied by 1+(3*k)^hdist. So, for E.coli with K=31 and hdist=0, there are 4554207 kmers stored, using around 140MB, taking about 0.5 seconds; with hdist=1, there are 427998710 kmers stored (94 times as many), using 15GB, and taking 104 seconds."  

#entropy (low complexity) and maq (min ave quality, for reads that have low overall quality) are added from BVCN pipeline.  

For keeping singletons, the two commands reib and outs must be coordinated. If you use one, you should also use the other.  

"With BBDuk you can use the "rieb" (removeifeitherbad) flag to determine whether pairs are removed. It defaults to "true". If you set "minlen=25 rieb=t" then pairs will be removed if EITHER is shorter than 25bp (default behavior); if you set rieb=f they will be removed only if BOTH are shorter than 25bp.  

Therefore, with the default behavior, you already should not have any singletons, period."  

So, in order to catch singletons whose mate is trimmed shorter than minlength, set reib=f AND designate a file to catch resulting singletons with outs=<filename>.  
If rieb=true, your outs file will always be empty.  


# Module 2: Visualizing Read Quality with FastQC and MultiQC.

Create conda environment for multiQC:
``` {bash eval=FALSE}
conda create -n qc -c bioconda multiqc  
conda activate qc  
conda install -c bioconda fastqc=0.11.9  
```

Running fastQC on the peat metagenome (4GB F and 4GB R) can take up to 30 min.

``` {bash eval=FALSE}
# switch to qc env:
conda activate qc

# make a directory for the output
mkdir 00_FastQC

# run a loop to run fastqc on all fastq files
for file in *.fastq;
do
fastqc ${file} -o 00_FastQC/
done

# run multiqc on all fastqc output files
cd 00_fastqc
multiqc .
```

The multiqc .html report can be viewed in R Studio.
To interpret the report, videos are embedded. 

# Module 3: Classification of Unassembled Reads by K-mer Sketch

Pipeline uses Sourmash. Note that BBtools (bbduk) also does great classification via k-mers with MinHash sketching (see BVCN tutorial).  

Part 1 is for the MAG pipeline, 2 and 3 are not.  

1) Screening of taxonomy, before assembling into MAGs.  
Also useful for quick types of analyses and Krona chart visualization/ summary statistics tables that don't require the complexity of anvi'o.  

2) Use to identify genomes, and many other use cases with tutorials:  
https://sourmash.readthedocs.io/en/latest/  

3) Create heatmap to summarize overall % sequence similarity between dozens of assembled genomes.  


###### Part 1) Metagenome pipeline: classify unassembled reads, and visualize taxonomy with Krona.

This part is needed for the MAG pipeline.
```{bash eval=FALSE}

# For taxonomic classification, you'll want to use a proper database, available here:
# https://sourmash.readthedocs.io/en/latest/databases.html
# can also create your own database if needed for memory reasons; see BVCN tutorial for examples

# I chose the 'representative genomes, k31, LCA' database; about half the size as the equivalent comprehensive database.

# Opt: LCA database download:

cd ~
mkdir sourmash
cd sourmash

curl https://osf.io/ypsjq/download > sourmash.html
nano sourmash.html

# Cut and paste the link in the sourmash.html file, and then curl that link:
curl https://files.osf.io/v1/resources/wxf9z/providers/googledrive/gtdb-rs202/gtdb-rs202.genomic-reps.k31.lca.json.gz > sourmash-k31-lca-db.gz

# For krona visualization, you will also need to the GTDB taxonomy file, gtdb-rs202.taxonomy.v2.csv, located at the website https://osf.io/p6z3w/download 

curl https://files.osf.io/v1/resources/wxf9z/providers/googledrive/gtdb-rs202/gtdb-rs202.taxonomy.v2.csv> gtdb-rs202.taxonomy.v2.csv

# Compute the MinHash signature for your prepped sequence files using k=31 and scaled to 1/1000 of total signatures:
#sourmash sketch -k 31 --scaled=1000 *.fasta.gz

cd ~/project-data
sourmash sketch dna -p k=31 *qualtrimmed.fastq 
# -p is parameter string.

mv *.sig ~/sourmash
cd ~/sourmash

# Optional: Take a look at the signatures
cat file.fa.gz.sig | tr ',' '\n' | head -n20

# Optional: View the database
gunzip sourmash-k31-lca-db.gz
cat sourmash-k31-lca-db | tr ',' '\n' | head -n400

# When analyzing shotgun sequence, or wanting to assess if there's more than one genome present in a bin, you can use the summarize command:
sourmash lca summarize --db genbank-k31.lca.json.gz --query SRR*qualtrimmed.fastq.sig
#It's like a fast-and-dirty QIIME output in table format. 

OR, 

#To see more comprehensively what's in a metagenome, first use the gather command:
#sourmash gather bins.sig sourmash-k31-lca-db -o bins_taxonomy_summary.txt

# A loop version for multiple sequence files:
for prefix in `ls *fastq.sig | cut -f -2 -d'_'`; do
#echo ${prefix}_qualtrimmed.fastq.sig;
sourmash gather ${prefix}_qualtrimmed.fastq.sig sourmash-k31-lca-db.gz -o ${prefix}-sourmash-taxonomy-summary.csv;
done

To be able to visualize sourmash taxonomy integration via Krona, run this additional command:

for prefix in `ls *-taxonomy-summary.csv | cut -f -1 -d '.'`;
do 
#echo ${prefix};
sourmash tax metagenome --gather-csv ${prefix}.csv --taxonomy gtdb-rs202.taxonomy.v2.csv --output-format krona --rank species -o ${prefix}; #krona.tsv automatically appended 
done

#For metagenome pipeline; skip to Module 4: Krona visualization.
#For other useful sourmash functions, see Part 2.

```


###### Part 2) Classifying a genome, or visualizing heatmap of relatedness between two or more genomes.

This part is optional; it's not needed for the MAG pipeline.  

Let's say we're interested in classifying a freshly-assembled MAG. Since we don't have one,
we're going to feign ignorance and classify a previously-identified chlorobi genome.


```{bash eval=FALSE}

# Using the LCA database to classify signatures:

# Download a Chlorobi ref genome from genbank:
# https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/168/715/GCA_000168715.1_ASM16871v1/

curl -L -o chlorobi.fna.gz https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/168/715/GCA_000168715.1_ASM16871v1/GCA_000168715.1_ASM16871v1_genomic.fna.gz

# Make a signature of the Chlorobi genome:
sourmash sketch dna -p scaled=1000,k=31 --name-from-first chlorobi.fna.gz

# Classify your chlorobi genome:
sourmash lca classify --db genbank-k31.lca.json.gz --query chlorobi.fna.gz.sig

# Another way to classify chlorobi genome:
sourmash lca summarize --db genbank-k31.lca.json.gz --query chlorobi.fna.gz.sig
```


###### Part 3) Heat maps to summarize % similarity between multiple assembled genomes.

This part is not needed for the MAG pipeline. 

``` {bash eval = FALSE}

# To do an all-vs-all comparison for all signatures; for example, you want to see how similar the metagenome of two samples is in broad strokes, or
you wanted to summarize heat map similarities of 25 different chlorobi MAGs:
sourmash compare ./ *.sig -k 31 -o meta_comp

# Plot them on a heatmap
sourmash plot --pdf --labels meta_comp

# Ten open topic-metagenomics/data/meta_comp.matrix.pdf in the browser
```


# Module 4: Visualizing Taxonomy of Unassembled Reads With Krona.

Krona is an interactive circos (circular) plot of unassembled read taxonomy (tree) and classification (Genus species).  

https://docs.csc.fi/apps/krona/  
https://github.com/marbl/Krona/wiki  
https://sourmash.readthedocs.io/en/latest/command-line.html  <--- sourmash krona  
https://bluegenes.github.io/sourmash-tax/  <--- blog post on sourmash krona integration  
https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-12-385  

To access Krona help:  
Navigate to the krona directory to be able to use help functions:  

cd ~/miniconda3/envs/sourmash/opt/krona/  

ktImportText  
ktUpdateTaxonomy.sh --help  

If you type ktImportTaxonomy, the last line of the help menu is the filepath for your default krona taxonomy *.dmp files.  

The readme.txt file in this krona taxonomy folder explains what the default taxonomy database is, when krona is installed.  

#type kt at the command line from ^^this file path^^ for list of functions: this works on BVCN Binder, but only sometimes for my VM terminal; see also krona/bin folder for very long list of available krona scripts and tools.  



Visualizing classification using Krona:  
need to add a Linux tool called make, that's a dependency of the krona tools taxonomy:  


Confirm that krona is in the sourmash environment, or:  
```{bash eval=FALSE}

cd ~
sudo apt-get install make 

#install krona using conda
conda install -c bioconda krona=2.8.1

```

Basic steps:  
1) create your krona-compatible seq classification .tsv file from sourmash.  
2) update krona taxonomy database.  
3) make krona chart using ktImportText.  

###### Step 1: Completed in previous Module 3, above. 

###### Step 2: update taxonomy

I guess they require this step so people don't accidentally use the default GenBank taxonomy db that downloads with krona install, in case they're using a different taxonomy database, such as Silva or GreenGenes.  

From BVCN Binder, input files are names.dmp and nodes.dmp; output file taxonomy.tsv  

``` {bash eval=FALSE}

# Go to path-to-krona-taxonomy-folder:

cd ~/miniconda3/envs/sourmash/opt/krona/

ktUpdateTaxonomy.sh --preserve 
#preserve saves the *.dmp files instead of deleting

#This step will create a taxonomy.tab file from the names.dmp and nodes.dmp files in the krona taxonomy folder.

#optional switches: --preserve, --only-fetch, --only-build, PATH-to-alternate-db-output
```

###### Step 3: make krona chart.  

``` {bash eval=FALSE}
cd ~/sourmash

# for a single seq file analysis:
ktImportText sourmash-krona-output.tsv -o filename.html  

# To include multiple sequence files in a single krona chart, use -c flag:
ktImportText *krona.tsv -c -o peat-krona-all.html 

```

To visualize the resulting .html file, export to GitHub and open with R Studio, which has an HTML preview function.  


Add't krona info:  

"Executing transaction: -   
Krona installed.  You still need to manually update the taxonomy  
databases before Krona can generate taxonomic reports.  The update  
script is ktUpdateTaxonomy.sh.  The default location for storing  
taxonomic databases is /home/rcallen1/miniconda3/opt/krona/taxonomy  

If you would like the taxonomic data stored elsewhere, simply replace  
this directory with a symlink.  For example:  

rm -rf /home/rcallen1/miniconda3/opt/krona/taxonomy  
mkdir /path/on/big/disk/taxonomy  
ln -s /path/on/big/disk/taxonomy /home/rcallen1/miniconda3/opt/krona/taxonomy  
ktUpdateTaxonomy.sh"  


Classification: a specific genus, species, etc. Example: a DNA seq is classified as Lactobacillus acidophilus. This information stands on its own.  

Taxonomy: ranking. Where the species falls in relation to other species, according to a taxonomy tree.  

Taxonomy ID looks like it is from the NCBI Taxonomy browser. For example Synechocystis is taxID # 2930568 and the Bacteria domain is TaxID 3.  

Magnitude: I don't think I need this info for sourmash integration; only kraken2. But according to the publication link, krona interprets magnitude from reads per contig (and provides a script for doing so), and represents it as width of krona chart wedge, called a classification. https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-12-385  


Default krona taxonomy database is GenBank.  
Sourmash also uses GenBank but then need to make sure they're the same versions (year released, redundancy, etc). The sourmash k-mer database I'm using is sourmash-k31-lca-db; it's a file containing all the signatures for a low-redundancy (GTDB R06-RS202 genomic representatives) version of GenBank. I guess we're just assuming that the krona GenBank *.dmp taxonomy files are close enough to the March 2022 k-mer sketch databases created from that release of GenBank? Roll those dice, I guess.  
https://github.com/ctb/2017-tara-binning/blob/master/delmont.taxinfo.txt  


# Module 5: Genome and Metagenome Assembly: Isolate genome assembly and MAGs

Assembly (turning a bucket of 100 bp reads into a handful of kb-long contigs) is computationally expensive. Before assembling, we will use several data processing steps of unassembled reads in order to minimize the RAM and disk space needed for assembly:

Co-assembly of three error-corrected and normalized libraries took about 40 minutes.

1) Error correction using metaSPAdes.    
  Sequencing errors dramatically and artifically increase the number of unique k-mers present in the data. Correcting sequencing errors reduces number of k-mers, speeding up computation while improving assembly accuracy, for an unskippable win-win step in our pipeline. 
  We will use metaSPAdes for error correction, but Tadpole and BBnorm also can do a less effective error correction, but is not as demanding for large amounts of RAM.  

2) Normalization using BBNorm.    
  This flattens the uneven frequencies of read distribution, which is recommended for assembling metagenomic data. It will be important to align the non-normalized data during the Module 6 mapping to determine coverage (as for binning MAGs), so Do Not Discard the non-normalized data from Step 1!!!!  
  
3) Co-assembly with MEGAHIT.    
Assembly is performed on a single metagenomic library (single SRR#) using metaSPAdes.  
Co-assembly with MEGAHIT is performed on two or more libraries that are biological replicates or technical replicates, described below.  

4) Calculate assembly statistics.  
<br>
<br>
  
###### Step 1: Error correction of a single library with metaSPAdes.  

While error correction of each library is mandatory, assembling individual libraries may also be helpful for troubleshooting MAGs, such as during de-replication step (Mike Lee's comment).  

This section follows the published peat pipeline from Maverick:  
https://maveric-informatics.readthedocs.io/en/latest/Processing-a-Microbial-Metagenome.html  

SPAdes and metaSPAdes are both used to assemble a single libary only. SPAdes is for a library generated from a pure culture. metaSPAdes is for assembling a library from a metagenomic sample.  
metaSPAdes will let you specify up to 9 paired-end libraries, but they will not be co-assembled (each library will be assembled separately in a loop).  

from http://cab.spbu.ru/files/release3.12.0/manual.html#meta  
--meta   (same as metaspades.py)  
    This flag is recommended when assembling metagenomic data sets (runs metaSPAdes, see paper for more details). Currently metaSPAdes supports only a single short-read library which has to be paired-end (we hope to remove this restriction soon). In addition, you can provide long reads (e.g. using --pacbio or --nanopore options), but hybrid assembly for metagenomes remains an experimental pipeline and optimal performance is not guaranteed. It does not support careful mode (mismatch correction is not available). In addition, you cannot specify coverage cutoff for metaSPAdes. Note that metaSPAdes might be very sensitive to presence of the technical sequences remaining in the data (most notably adapter readthroughs), please run quality control and pre-process your data accordingly.  


SPAdes 3.13 documantion:  
http://cab.spbu.ru/files/release3.13.0/manual.html  

Memory allocation issue with spades:  
https://github.com/ablab/spades/issues/871   

SPAdes is already included in the sourmash conda environment.  
Below is code for error correction and/or assembling a single library.  
For assembly using multiple libraries (co-assembly), MEGAHIT is used instead.   

The code for the peat pipeline (single library) is provided, followed by a few other examples (multiple libraries, interleaved vs separate paired-end reads).  

```{bash eval=FALSE}
spades.py --help     #for help menu  
spades.py [options] -o <output_dir> 
```

Pipeline options:  
--only-error-correction runs only read error correction (without assembling)  
--only-assembler runs only assembling (without read error correction, which can take a long time)  

According to this, there's no way to figure out how much RAM you'll need, or limit the amount of RAM in exchange for a longer run time:
https://github.com/ablab/spades/issues/19  
  
  "SPAdes does not decide anything. The amount of RAM required depends on your input dataset, coverage, error rate, repeat content, etc. In general we cannot determine in advance how much RAM is required in the majority of cases.  

  SPAdes uses 512 Mb per thread for buffers, which results in higher memory consumption. If you set memory limit manually, SPAdes will use smaller buffers and thus less RAM."  

-m <int> (or --memory <int>)  
    Set memory limit in Gb. SPAdes terminates if it reaches this limit. The default value is 250 Gb. Actual amount of consumed RAM will be below this limit. Make sure this value is correct for the given machine. SPAdes uses the limit value to automatically determine the sizes of various buffers, etc.   

This -m flag appears to be fairly useless, as it simply causes SPAdes to quit:  

  "The -m option acts as a last resort precaution since it sets the hard memory limit, SPAdes will simply crash if it would require to allocate more RAM then this limit. In some cases it is possible to provide time / memory tradeoff and we use the value passed to -m option for this. However, in general, you'd simply pass to -m the amount of free RAM available to your SPAdes job. Same for -t option - pass the number of threads that you could use for the assembly."  

For other error-correction options, consider BBnorm or Tadpole.  


```{bash eval=FALSE}

!!!!!SPAdes will overwrite your output folder with no warning!
For each library that is corrected or assembled, you will either need a unique output folder, or will need to transfer files to a new folder.
UGH!!!!!

 # The following code will assemble seq files from a single library that are paired but NOT interleaved.

# The command below took about 2 hours to run Bayes Hammer on one library, and 45 min for each kmer for the peat metagenome sample library: total of ~5 hours.

mkdir spades/
spades.py -1 SRR7151524_1_qualtrimmed.fastq -2 SRR7151524_2_qualtrimmed.fastq -s SRR7151524_singletons_qualtrimmed.fastq --meta --only-error-correction --threads 24 -o ~/spades/
# add the --only-error-correction switch if you want the BayesHammer error correction, but no assembly.

#if you're connecting to HPC via terminal, you may wish to set your laptop sleep clock to never.
#if the assembly gets interrupted, you can continue from last checkpoint with this:
spades.py -o spades/ --continue

# The following code will assemble seq files from three sequence libraries that are paired but NOT interleaved.

pe1-1 is the forward reads from the first library.
pe2-2 is the reverse reads from the second library.
pe3-s is the singletons file from the 3rd library.

Do Not Run This Code:
spades.py --meta --pe1-1 SRR#_1.fq --pe1-2 SRR#_2.fq --pe1-s SRR#_singletons.fq /
                 --pe2-1 SRR#_1.fq --pe2-2 SRR#_2.fq --pe2-s SRR#_singletons.fq /
                 --pe3-1 SRR#_1.fq --pe3-2 SRR#_2.fq --pe3-s SRR#_singletons.fq /
                 -o spades/

Use case: error correct (no assemble) three paired-end libraries including singletons:
spades.py --meta --only-error-correction --threads 16 --pe1-1 SRR*490_1_qualtrimmed.fastq --pe1-2 SRR*490_2_qualtrimmed.fastq --pe1-s SRR*490_singletons_qualtrimmed.fastq --pe2-1 SRR*524_1_qualtrimmed.fastq --pe2-2 SRR*524_2_qualtrimmed.fastq --pe2-s SRR*524_singletons_qualtrimmed.fastq --pe3-1 SRR*527_1_qualtrimmed.fastq --pe3-2 SRR*527_2_qualtrimmed.fastq --pe3-s SRR*527_singletons_qualtrimmed.fastq -o ~/spades/

One library: 
spades.py -1 SRR*490_1_qualtrimmed.fastq -2 SRR*490_2_qualtrimmed.fastq -s SRR*490_singletons_qualtrimmed.fastq  --meta --only-error-correction --threads 32 -o ~/spades-527/
```


Scaffolds consist of contigs and gaps, mapped to a continuous predicted genome ref seq  

N50: median length of contigs (N50 = 75kb). i.e. half of the contigs are longer than 75kb; the other half are shorter. 
L50: the number of the contig halfway through a list of contigs sorted by size (the 75kb contig is the third contig in the list, so L50 = 3).  
U50: Same as N50, but only unique contigs are counted (those that are entirely overlapped by other contigs are not counted; the red contigs in this fig).   
https://pubmed.ncbi.nlm.nih.gov/28418726/#&gid=article-figures&pid=fig-2-uid-1  

Think of N = Number of base pairs in the median contig; L = median rank in the List of contigs.  

How to evalulate which is the "best" assembly?  
According to biostar handbook, small k-mers give you more total assembled sequence (% of reads assembled), but smaller contigs; large k-mers give you smaller % reads assembled, but larger contigs.  

If MAG is the goal, we're using alignments (seq depth) to bin contigs. SO it seems like because our coverage is so low, binning would be more ambiguous with the small contigs. With larger contigs, more easy to resolve bins.  

Sequencing errors will always dramatically increase the amount of coverage needed for k-mer saturation. For example, an e-coli genome is 4 Mb, but need closer to 10 Mb to saturate k-mers. The correct k-mers will always be the most abundant. SPAdes corrects for sequencing errors before doing assembly, using BayesHammer.  

From Biostar Handbook, GAGE tutorial:  
"In general, it is true that the longer a k-mer is, the fewer identical k-mers to it exist. At the same time it is also true the longer a k-mer is, the more likely is that it will contain an error. When it comes to assembly processes the rule of reasoning is that:
• A larger k value allows resolving more repetitions.  
• A smaller k increases the chances of seeing a given k-mer."  
smaller k-mers for sensitivity; larger k-mers for accuracy.  

Note that for assemblies of different length, such as de novo assemblies (see sum_length stat for K21, K33, and K55), you can't directly compare N50/L50 numbers.  

Bottom line: just choose the middle one, I guess? K33   


###### Step 2: Normalization with BBNorm.

https://github.com/BioInfoTools/BBMap/blob/master/sh/bbnorm.sh  
https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbnorm-guide/  
https://astrobiomike.github.io/genomics/where_to_start  

MEGAHIT github recommends normalizing to 70x coverage, which is likely far greater coverage than exists in these peat sample libraries. 
For kmer depth Dk, read depth Dr, read length R, and kmer size K:  Dr=Dk*(R/(R-K+1)). Default kmer size is 31.  

Useage:  
bbnorm.sh in=<input> in2=<paired-input> out=<reads to keep>   
#optional: outt=<reads to toss> hist=<histogram output>  

This will run 2-pass normalization to produce an output file of reads with an average (k-mer?) depth of 100x. Reads with an apparent depth of under 5x will be presumed to be errors and discarded.  

BBNorm needs to read input files multiple times (twice per pass), which means it is unable to accept piped input.  

The memory can be used more efficiently by specifying “prefilter”, which stores low-count kmers in smaller cells (2-bit, by default) and high-count kmers in bigger cells (32-bit, by default). Prefilter is by default false, as it makes things slower, but should always be enabled when maximal accuracy is desired or if the tables become too full (say, over 50% or so for normalization; lower for error-correction).  

Since Tadpole does a better job of error correction than does BBnorm, error correction is turned off by default for BBnorm.  

I don't think I need to keep the tossed reads file from the normalization process, since I have those reads represented in the error-corrected files for alignment.  


``` {bash eval=FALSE}
#The forward and reverse reads of a library can be normalized at once, but only if both files have the same number of reads (not true after error correction)

-->>>> bbnorm.sh doesn't seem to accept file names with wildcard symbols for input? idgi

#default output format is .fastq; specify .fasta for smaller files

mkdir ~/normalized
mv <error-corrected-files> ~/normalized

bbnorm.sh in=SRR7151527_singletons_qualtrimmed.00.0_1.cor.fastq.gz out=SRR7151527_singletons_qualtrim-corr-norm.fasta prefilter=t

#The F, R, singletons, and unpaired error corrected are normalized separately.

```


###### Step 3: Co-assembly with MegaHit.  

From Mike Lee (@astrobiomike, BVCN):    

"if [libraries] are from the same biological sample, i’d say your best best is to do a co-assembly with all of them. That way you get (in theory) the best assembly possible, and you can use differential coverage (mapping the 3 technical replicates to the one co-assembly) to likely substantially improve your binning efforts.
Because microbial diversity be whack, and soil diversity be hyper-whack, it is possible individual assemblies might do better and allow you to recover more/higher quality bins. But i wouldn’t go in with that assumption. So if it were me i’d start with the co-assembly approach, and if you’re testing more things, i’d do individual assemblies, individual mappings, recover the high-quality bins you can, and then run something to “dereplicate” them. And then consider the dereplicated high-quality bins the “combined” output. My thoughts anyway, good luck!"  

From Ella Sieradzki (BVCN): "In my experience soil assemblies improve with more data. I wouldn’t co-assemble soil samples that aren’t replicates, because of low similarity, but I’d definitely co-assemble replicates. In any case you’ll end up running dRep at the end. That would be the dereplication step. Also, if you co-assemble with MEGAHIT (which works much better with large metagenomes), set the disconnect ratio to 0.33 to reduce chimeras."  

At this point, because we are doing co-assembly, we are diverging from the published peat pipeline from Maverick, and shifting to anvi'o published pipelines:  

https://merenlab.org/tutorials/assembly-based-metagenomics/#co-assembly  
https://astrobiomike.github.io/metagenomics/metagen_anvio  

https://github.com/voutcn/megahit/wiki  
https://github.com/voutcn/megahit/wiki/An-example-of-real-assembly  
https://github.com/voutcn/megahit/issues/144 #settings for soil co-assembly  
https://www.biorxiv.org/content/10.1101/2021.07.11.451960v1.full  
https://academic.oup.com/bioinformatics/article/31/10/1674/177884  
the Megahit article above is actually useful for a few things  
https://www.metagenomics.wiki/tools/assembly/megahit  

Comments from Megahit repo about assembling 2T of soil data:  

  "It is super huge. Hopefully, it can be assembled in 1T RAM.  
  If you don't have a server equipped with that much RAM, please try to use BBNorm or khmer to normalize the dataset first. It should be okay to normalize the depth to 70x.  
  If the data comes from "wild" environment like soil or wetland, the option --preset meta-large is recommended."  


megahit -h  

megahit [options] {-1 <pe1> -2 <pe2> | --12 <pe12> | -r <se>} [-o <out_dir>]  

  -1&emsp;&emsp;<pe1>&emsp;comma-separated list of fasta/q paired-end #1 files, paired with files in <pe2>  
  -2&emsp;&emsp;<pe2>&emsp;comma-separated list of fasta/q paired-end #2 files, paired with files in <pe1>  
  --12&emsp;&emsp;<pe12>&emsp;comma-separated list of interleaved fasta/q paired-end files  
  -r/--read&emsp;<se>&emsp;comma-separated list of fasta/q single-end files  

A fun way to use environmental variables for a comma-separated list:  

R1s=`ls 01_QC/*QUALITY_PASSED_R1* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`  

R2s=`ls 01_QC/*QUALITY_PASSED_R2* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`  

R1s=`echo SRR*_1*`  

Sample code for co-assembly:  

use case:

megahit -1 ../data/Sample_A_1.fastq.gz,../data/Sample_B_1.fastq.gz,../data/Sample_C_1.fastq.gz,../data/Sample_D_1.fastq.gz \
 -2 ../data/Sample_A_2.fastq.gz,../data/Sample_B_2.fastq.gz,../data/Sample_C_2.fastq.gz,../data/Sample_D_2.fastq.gz \
 -o megahit_default -t 4
set the disconnect ratio to 0.33 to reduce chimeras.  
if the data comes from "wild" environment like soil or wetland, the option --preset meta-large is recommended.  

megahit -1  

``` {bash eval=FALSE}
#Co-assembly of three error-corrected and normalized libraries took about 40 minutes.

conda activate sourmash

cd ~/normalized

R1s=`ls SRR*_1* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

echo $R1s  #should be a comma-separated list

R2s=`ls SRR*_2* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

Rsingle=`ls SRR*_singletons* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

Unpaired=`ls SRR*_unpaired* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

#Concatenate the singletons and unpaired into one variable:

AllSingles="${Rsingle},${Unpaired}" #not sure if the quotes will change the var type and interfere with Megahit input.
echo $AllSingles

megahit -1 $R1s -2 $R2s -r $AllSingles -o ~/megahit-out -t 16 --presets meta-large --min-contig-len 1000 --disconnect-ratio 0.33

```

###### Step 4: Evaluating contigs: de Bruijn graphs and assembly statistics.  

calculate assembly statistics  

``` {bash eval=FALSE}

seqkit stat genome.contigs.fa
#Biostars handbook 2021 pg 936 for interpreting these data.

# OR

statswrapper.sh final_contigs.fasta > final_contigs_stats.txt
  
cat final_contigs_stats.txt

```

https://github.com/voutcn/megahit/wiki/Visualizing-MEGAHIT's-contig-graph  

"To visualize contig graph in Bandage, the first step is to convert the fasta file(s) intermediate_contigs/k{kmer_size}.contigs.fa into SPAdes-like FASTG format. The following code shows the translation from k99.contigs.fa into k99.fastg." Note that Bandage is deprecated as of 2022, with no obvious replacements for visualizing deBruijn graphs, at least that I could find on science Twitter etc. 

megahit_toolkit contig2fastg 99 k99.contigs.fa > k99.fastg  

Then the FASTG file k99.fastg can be loaded into Bandage.  

Note that final.contigs.fa in the output directory has filtered out some short contigs, thus we recommend using the contigs intermediate_contigs/k.contigs.fa* for visualiztion."  

Here's an explanation of the different intermediate outputs by Megahit: including*.contigs.fa and *.local.fa:  

https://github.com/voutcn/megahit/wiki/contigs-output-by-MEGAHIT  

From anvi'o Discord:  
DSpaath: I've personally had little luck with getting insights into graph connectivity by running the toolkit on the final contigs. For graph visualization spades has been much more useful to me, but metagenomes are sadly often too large for spades assembly :/
Hdore: OK thank you for your advice! One of my motivations was to try to run MetaCoAG for contigs binning. It seems to require you to get a fastg on the final contigs (or at least that's how they run it in their documentation:  https://metacoag.readthedocs.io/en/latest/preprocess/#megahit).  
DSpaath: ah cool, wasn't familiar with metacoag. Thanks for sharing  

-kK.contigs.fa contains the contigs assembled from the de Bruijn graph of order-K, they can be converted to a SPAdes-like FASTG file for visualization  
-kK.addi.fa contains the contigs assembled after iteratively removing local low coverage unitigs in the de Bruijn graph of order-K  
-kK.local.fa contains the locally assembled contigs for k=K  
-kK.final.contigs.fa contains the stand-alone contigs for k=K; if local assembly is turned on, the file will be empty  

BVCN pipeline recommends visualizing De Bruijn graphs, but Bandage is being depricated after 2022.  
https://github.com/rrwick/Bandage/wiki  
Seems like easier to install and run on laptop.  

Note that for assemblies of different length, such as de novo assemblies (see sum_length stat for K21, K33, and K55), you can't directly compare N50/L50 numbers.  

Somewhere I read a reference saying that metagenome assemblies usually optimize between K51 - k61.  

Megahit chooses for us, but also provides the k-mer specific files from k77 to k127 if there's a specific reason to use the non-chosen assembly.  


# Module 6: Read Mapping and Alignments.

Info archived from BVCN on binning is at the end of this section.  

Instead of BVCN, we are pivoting to anvi'o, starting with the simplifying fasta headers of our final contigs file from Megahit.

https://merenlab.org/tutorials/assembly-based-metagenomics/  
https://astrobiomike.github.io/metagenomics/metagen_anvio  

However, anvi'o uses separate steps for making mapping files with bowtie2, and I like using bbduk wrapper instead, BBwrap, in the sourmash environment. So moving forward, we're mixing and matching parts of BVCN pipeline with anvi'o tools.   

If however, you prefer not to use BBWrap:  
to make a mapping file for each individual library, using a co-assembly ref genome without BBWrap:  
https://merenlab.org/tutorials/assembly-based-metagenomics/#co-assembly  

First, create anvi'o environment (see also Module 9 below) to use the simplify headers function.

If you have the binning_x-platform_env.yml or anvio-env.yml file, run this code:
``` {bash eval=FALSE}
conda env create --file ~/MAG-pipeline/anvio-env.yml
conda activate anvio-7.1
```

If you do not have the anvio conda env file as above, then you will need to install from anvio from scratch:
see https://anvio.org/install/  
``` {bash eval=FALSE}
#install anvio:

cd ~
mkdir anvio
curl -L https://github.com/merenlab/anvio/releases/download/v7.1/anvio-7.1.tar.gz --output anvio-7.1.tar.gz

#Then follow directions here, starting with step 3 (pip install):
#https://anvio.org/install/

pip install anvio-7.1.tar.gz

# note there is a known issue with _sysconfigdata_x86_64_conda_linux_gnu
# see install guide to fix

cd ~/miniconda3/envs/anvio-7.1/lib/python3.6
mv _sysconfigdata_x86_64_conda_cos6_linux_gnu.py _sysconfigdata_x86_64_conda_linux_gnu.py

pip install anvio-7.1.tar.gz #again

# test your installation:  add --no-interactive flag to prevent launching new web page displaying interactive image result
 
anvi-self-test --suite mini --no-interactive
```
 Once anvi'o is installed, use it to simplify fasta headers, as described here:  
 https://astrobiomike.github.io/metagenomics/metagen_anvio  

 ``` {bash eval=FALSE}
cd ~/megahit-out

anvi-script-reformat-fasta final.contigs.fa -o simpl_final.contigs.fa -l 1000 --simplify-names  --report-file report-file

# The report-file switch will create a file that shows old and corresponding new fasta file headers (called deflines) of your contigs.

#T The -l 1000 flag filters out contigs less than 1,000 bp. 
```

Now it's time to run BBWrap on our simplified final contigs file, to create the mapping files necessary for binning:  

This link shows how to do these steps manually using bowtie2 and seqkit:  
https://astrobiomike.github.io/metagenomics/metagen_anvio  
See also previous version of pipeline for more details and use with Bowtie2:  MAG-bvcn-pipeline-bbtools.rmd in my MAG-pipeline repo.  

Running manually involves working directly with a proliferation of files, including .bam, .sam, and .bai.  

The hidden steps are performed automatically by BBWrap are:  
-Index your ref contigs --> .bam files. You will see this refered to as "raw BAM" in some references (anvi'o). "raw" BAM files have not been sorted.  
-Align sample reads to contigs ---> .sam files  
-Convert alignment to binary --> .bam file. This is a sorted .bam file, so it is not considered "raw".  
-Index your sorted alignment --> .bai file  
-Sorted and indexed mapping file is end output (the .bai file).  
The simplified final contigs, the .bai mapping file, and (usually) the sorted BAM files, are the inputs to binning software below.  

Create mapping file using BBMap (BBWrap):  

BBMap automatically performs bowtie2 indexing, alignment, and conversion steps listed above.  

https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/  

When it says BBMap is aligning reads to "a genome", that means either a single reference genome, or a single reference file of multiple assembled contigs, whether those contigsal: "No index available; generating from reference genome: /home/hpc_au are from a single organism or a metagenomic sample.  

Actually, cannot process both paired and unpaired reads in the same run, except by using BBWrap. BBWrap is a simple wrapper that allows BBMap to be run multiple times without reloading the index each time.  

Apparently this output is normgust/project-data/sourmash/spades/K33/ref/index/1/chr1-2_index_k13_c2_b1.block"   

From BBushnell:  
"Also, don't worry about the "#Chromosome sizes" in BBMap's index; a long time ago that made sense, but now multiple chromosomes are packed together in blocks but I never changed the terminology."  

https://www.seqanswers.com/forum/bioinformatics/bioinformatics-aa/51541-bbmap-aligner  


Sample code for running BBMap and BBWrap:  

MAKE SURE YOU ARE MAPPING THE ERROR-CORRECTED BUT NOT NORMALIZED SAMPLE READS! Also, DO NOT map the qual-trimmed but not SPAdes-error-corrected reads.  

Mapping two samples to one genome with BBWrap: note it makes two different bam files. Don't run this code.  

bbwrap.sh ref=DvH_reference.fa.zip #in1=SRR5780888_1.fastq.zip,SRR5780889_1.fastq.zip #in2=SRR5780888_2.fastq.zip,SRR5780889_2.fastq.zip mapper=bbmap #outm=DvH_888.bam,DvH_889.bam  




Interpreting outputs of BBWrap:  

StOut includes % and # of reads and bases.  
It also includes average read length of your libraries, wiich is v useful and hard to get otherwise.  

A good alignment can have a bp match rate in the 90+% range,  
so bp error rate of less than 10%. With longer reads, such as a 350 bp reads, this translates to a 25-50+% chance that a read will contain one or more bp errors.  

An error is considered a mis-match to your refseq contigs.  

Covstats.txt shows read depth info and %coverage info per contig!  
There's a also ref folder that includes a genome folder and an index folder. Gives numbers of contigs and scaffolds and their lengths, and other info, though that seems less clearly useful.  


"To map pairs and singletons and output them into THE SAME BAM FILE (i.e. making a mapping file of the whole co-assembly, rather than each library):  

bbwrap.sh in1=read1.fq,singleton.fq in2=read2.fq,null out=mapped.sam append  

"To index and map at the same time, add the ref assignment:  
bbmap.sh in=reads.fq out=mapped.sam ref=ref.fa  

I don't think we need to make a mapping file of the whole co-assembly, actually. Instead, we co-assemble with megahit, and then we make mapping files of each individual library against the co-assembly ref genome. 
So, each library has its own mapping file, but the co-assembly does not have a mapping file. But, here's the code to do that.  


``` {bash eval=FALSE}
mv simp-final.contigs.fa ~/error-corrected-only
cd ~/error-corrected-only

#create env variables (use ERROR-CORRECTED but not normalized reads):

R1s=`ls SRR*_1_qualtrimmed* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

R2s=`ls SRR*_2_qualtrimmed* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

Unpaired=`ls SRR*_unpaired* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

Single=`ls SRR*_singletons* | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

AllSingles="${Unpaired},${Single}"

Names=`ls SRR*_1_qualtrimmed* | cut -d _ -f -1 | python -c 'import sys; print(",".join([x.strip() for x in sys.stdin.readlines()]))'`

bbwrap.sh ref=simpl_final.contigs.fa in1="${R1s},${AllSingles}" in2=$R2s,null mapper=bbmap outm=490.sam,524.sam,527.sam covstats=covstats.txt bincov=bincov.txt bamscript=bamscript.sh
```

About the code above:  

ref= input file of your reference genome or reference contigs with simplified headers  

in1= a comma-separated list of F reads (paired) and all singletons  
mapper = choices for  PacBio sequencing available, for example.  
append = If append is enabled, and there is exactly one output file, all output will be written to that file.  

bamscript = name.sh will create the mapping file after BBwrap is run.  

Some other sample scripts for reference:  

``` {bash eval+FALSE}
#generate an index of A.fa and write it to /ref/.
“bbmap.sh in=reads.fq ref=A.fa” 

#To index and map at the same time, and generate coverage stats and bin stats, and a bam file and an indexed sorted bam file:

bbmap.sh in1=SRR7151490_1_qualtrimmed.fastq in2=SRR7151490_2_qualtrimmed.fastq ref=simplified-multiLine.fasta outm=bbmap-peat-minid.sam threads=16 bamscript=bs-minid.sh

#Then run bash bs.sh to generate mapping files:
sorted_mapped.bam, and 
sorted_mapped.bam.bai  

# in your current folder. 
```
Note that the shell script automatically created to sort and index your .sam file output from BBWrap will only analyze one .sam file. You will need to update this shell script either by running it for each .sam file, 
or making it loop through your sam files.  

Note that a critical assumption is being made: that all of the .sam files should use the same defaults in the shell script. Unsure if this is true; need to read up on BBWrap / bowtie2 to check.  


# Module 7: Binning Metagenome-Assembled Genomes


If binning_x-platform_env.yml or bin-env.yml file exists:
``` {bash eval=FALSE}
conda env create --file ~/MAG-pipeline/bin-env.yml
conda activate bin-env
```

If bin-env.yml file does not exist:

```{bash eval=FALSE}
#Making new env from scratch:

conda config --remove channels CHANNEL.NAME #remove all channels except defaults and bioconda, otherwise it will take foreverrrrrr to add these binning packages; hangs on solving environment.

conda create -n bin-env -c bioconda -c conda-forge -c ursky das_tool=1.1.2 binsanity=0.3.8 concoct=1.1.0 metabat2=2.12.1 maxbin2=2.2.7

#for adding one at a time, which doesn't really work but best results using only two channels, and bioconda listed first, then defaults:

try this:

conda config --remove channels bioconda
conda config --add channels bioconda
conda config --show channels  #should be just bioconda and then defaults

conda create --name new-env --clone base
source activate new-env
conda install -c bioconda binsanity=0.5.4
conda install -c bioconda maxbin2=2.2.7 OR -c ursky metabat2=2.2.5
conda install -c bioconda metabat2=2.15 OR -c ursky metabat2=2.12.1
conda install -c bioconda concoct=1.1.0  #failed

once you succeed, do this and use env.yml file for future sessions:
conda env export > binning-env.yml
```

https://github.com/edgraham/BinSanity/wiki/Usage  

transcribing the first of Spaath's videos:  
https://www.youtube.com/watch?v=q9U0uTFRsl4  


Information is shown for the following:   

1) MaxBin2  
2) MetaBAT2  
3) BinSanity
4) DAS tool, a bin optimizer

(A fourth binner called Concoct is not compatible with my Ubuntu OS and is omitted here, but is described in BVCN tutorial online.)  

BinSanity is slowest, so recommend running that last, or running while doing other stuff for a few hours. A single library of 28 million 100 bp reads (1.2 GB of data) took 1.5 hours to bin using Binsanity-lc (50 GB RAM, 8 cores).  

Next, should probably run CheckM on all the individual binner outputs. CheckM evaluates but does not improve bins.  
Finally, DAS-tool is then run to aggregate the three binning outputs for de-replication and best average bins.  


Looking ahead: at the end of the binning process, we will need the following files in order to analyze our bins in the next step with anvi'o:  

-Mapping files of co-assembled contigs (map.bam.bai)  
-The assembled contigs (simplified-contigs.fasta)  
-A special text file, .tsv with two columns  
  Column 1 is contig name, and column 2 is bin name the contig lives in.  
This file is created using DAS-tool, a binning aggregator.  
<br>
<br>

Read depth, read coverage, and read abundance are all referring to the same thing: how many unique reads align to a given part of the ref genome or contig. This is the same thing as sequencing depth.  
Each binner has its own unique way of formatting / calculating sequencing depth. Ideally, you can provide this info from the sorted bam file from BBMap output in previous section. Once sequencing depth is calculated, the contigs can be binned.  

###### 1) MaxBin2 is first of three binners.  

https://sourceforge.net/projects/maxbin2/files/  #this is the ReadMe HTML page  

MaxBin2 calls sequencing depth the abundance information. This can be generated de novo by MaxBin2 if you provide your original sequencing files, but it's basically repeating the alignment you did with BBMap in the previous step.  

 MaxBin2 has abundance matrix:  
Instead of a column for each sample, it has a separate file for each sample.  
 A001 30.89  
 A002 20.02  


Trying to figure out whether I need to specify the libraries for my reads.  
"Here we describe MaxBin 2.0, the next generation of the MaxBin algorithm that recovers genomes from co-assembly of multiple metagenomic samples. By exploiting contig coverage levels across multiple metagenomic datasets, MaxBin 2.0 achieves better binning results than binning individual metagenomic samples."  

Since MaxBin2 is designed for binning multiple libaries that have been co-assembled, it must be handling multiple samples. But it doesn't ask for the co-assembly mapping file and I can't tell how MaxBin is distinguishing which library a read file is from. We need the library info because differential coverage from one sample to the next is critical info for binning.  

It seems most links online suggest that MaxBin is binning one library at a time. The "co-assembly" part just refers to using a co-assembled ref input, rather than binning multiple libraries at a time.  

Ok I think I get it. The co-assembly is across multiple libraries. When maxbin2 does read alignment from one of those libraries, it uses different read depth from one genome to a next *within* a library. Some species are more abundant in a sample, and some are less abundant, and therefore they can be sorted into different bins. I still don't *totally* get it, because this would also be true if we only assembled one library to do our alignment, whereas metabin2 is very explicit about using multiple libraries for its improved binning results.  

 To generate abundances, provide a reads file, or MaxBin2 will generate this information for you from your original SRR#.fastq sequencing files. Please specify the reads files (in fasta format) using the  -reads flag.  

 Is there a way to provide the sorted bam file instead of the reads, so we can skip the bowtie2 step? There doesn't seem to be. :Z

run_MaxBin.pl -contig simplified-multiLine.fasta  -reads SRR7151490_1_qualtrimmed.fastq -reads2 SRR7151490_2_qualtrimmed.fastq -reads3 SRR7151490_singletons_qualtrimmed.fastq  -out maxbin-SRR#  -thread 16  

If you have a large number of sequencing files, you can compile a .txt file listing them and provide this file instead (see ReadMe link above)  

run_MaxBin.pl -contig simpl_final.contigs.fa -reads_list list-o-files-527 -out maxbin-SRR# -thread 16  
 #don't use the verbose flag bc it prints allllllll the contigs to stout)  

Interpreting MaxBin output:  

MaxBin gives the following outputs:  
.fasta files   These are your bins  
.abundance     Shows %(?) of each read file per bin, or per contig  
.markers       Keeps track of markers used per bin?  
.noclass       Not enough markers detected for classification?  
.tooshort      Not enough seq data to have useful numbers of markers  
.summary       Table analyzing your bins  

The .summary file includes straight-forward info:  
Bin Name, Completeness, Genome Size, and %GC content.  

From the peat pipeline, I got a total of 6 bins.  
The most complete were bin 2 (58%) and bin 5 (59%).  

You should make a folder for each library that is binned via Maxbin.  

You will need to re-name these bins because they re-use file names for each binning.  

Example of for loop for renaming:  
In bash, everything inside the $(statement) is evaluated first, and then the bash command is performed.  

###### 2) MetaBat2 is second of three binners.  

Optimizing parameters for different types of samples:  
https://bitbucket.org/berkeleylab/metabat/wiki/Best%20Binning%20Practices  

Usage:  
https://bitbucket.org/berkeleylab/metabat/src/master/README.md  

MetaBAT2 abundance file is different in that it requires the mean and the variance of the abundance. Can be run with shell script, using your sorted abundance file generated from BBMap (or bowtie2). MetaBat2 uses depth whereas binsanity uses coverage whereas MaxBin uses abundance; these terms all mean the same thing.  

``` {bash eval=FALSE}
#Generate depth file:
jgi_summarize_bam_contig_depths --referenceFasta simpl_contigs.fa --outputDepth metabat-depth.txt PATH/mapping-files/bbmap-peat_sorted.bam

#this doesn't let you specify threads, but displays thread=0 which means 1 thread per core.

#Run MetaBat2:
metabat2 -i simplified-multiLine.fasta -a metabat-depth.txt -o metabat-out

Interpreting MetaBat output:

MetaBat output includes only the contig bins as .fa files.
The peat pipeline produces five MetaBat bins.
```

BVCN tutorial youtube timestamp 17:40  


###### 3) BinSanity is third of three binners.  
https://github.com/edgraham/BinSanity/wiki  
https://github.com/edgraham/BinSanity/wiki/Usage  
https://github.com/edgraham/BinSanity/issues/41  
https://github.com/edgraham/BinSanity/issues/8  Binsanity is memory-intensive and will run more slowly as dataset gets bigger, and consume massive amounts of RAM (1 TB) for large co-assemblies.  


 Binsanity-lc  

    Binsanity-lc is written for large metagenomic assemblies (e.g >100,000 contigs) where Binsanity and Binsanity-refine become too memory intensive. It uses K-means to subset contigs based on coverage before implementing Binsanity **

 Binsanity2-beta  

    Binsanity2-beta is written to ultimately replace the Binsanity-wf and Binsanity-lc by merging the two workflows. Binsanity2-beta has the option for initial kmeans based subsetting of contigs for large assemblies and by default automatically implements kmeans on assemblies larger than 75,000 contigs. This approach is being adapted currently into a new snakemake workflow and new data will be released along with the workflow demonstrating the improved functionality.



BinSanity filters out contigs <1000 bp by default.  

BinSanity is run in two steps:  
-Binsanity-profile, to generate coverage files.  
-Binsanity-lc, which generates and refines (CheckM) the bins based on coverage.  


```{bash eval=FALSE}
Binsanity-profile tries to use all of the *.bam files in the folder provided. So for example, if you used more than one library to create a single reference contigs file, you would then include each of those unique SRR#.bam files in the folder, and bin them with the single contigs.fasta.

Here, we are aligning a single library *.bam file to its corresponding assembled contigs

You need this annoying file structure to run binsanity:

~/binning/bam-files-folder/
~/binning/simplified-multiLine-1.fasta  

cd ~/binning/

Binsanity-profile -i simplified-multiLine.fasta -s ~/binning/bam-files-folder/ -c bbmap-paired-peat 
#the file extension is automatically appended to the end of the coverage file:
```

There's disagreement between the BinSanity wiki, which says to provide the directory name, not the file name, for the -s flag. However, the Binsanity-profile --help menu suggests providing the .bam file name, not just the directory. Using the *.bam file name throws an error message: Not a directory: 'bbmap-peat_sorted.bam' The difference seems to be that the help menu requires the following flag: -id contig_ids.txt Whereas the wiki does not use the -id flag.  

A total of five new files will be created: three .readcounts files, and two .cov files.  
The Sub-reads software should run, as displayed in terminal.  
Sub-reads generates three files for each .bam file:  

filename.readcounts  
filename.readcounts.summary  
filename.readcounts.saf  

Then Binsanity-profile will use the readcounts files to generate coverage files:  

 a raw .cov file, and  
 a .cov.x100.lognorm, a transformed coverage profile, which looks like this:  

 contig-1 1.2 0.4  
 contig-2 1.0 0.4  
 ....

 The transformed coverage file is also called the abundance matrix, and is tab-delimited. Each column is for a specific sample (SRR#). So, the coverage file above has two different samples. Your coverage file will only have one column of numbers because you only aligned one library to the contigs. The output profile file is a necessary input for binning downstream.  


Now that you've generates your coverage file with Binsanity-profile, run Binsanity-lc to create the bins:  


From ~/binning/ which contains:  
-folder of .bam files used in binsanity-profile script from prev step  
-simplified-contigs.fasta  
-your .cov and .cov.lognorm files  


``` {bash eval=FALSE}
# The wiki recommends providing the full filepath for the coverage files:

Binsanity-lc -f [/path/to/fasta] -l [fastafile] -c [coverage file] -o [output directory]

Binsanity-lc -f . -l simplified-multiLine.fasta -c ~/binning/bbmap-paired-peat.cov.x100.lognorm --checkm_threads 16 -o BINSANITY-LC-OUTPUT
```

Interpreting BinSanity results:  

BinSanity output is a list of bins; each bin is an .fna file. The bin outputs include one or more of the following: 
    -High completion: greater than 95% complete with less than 10% redundancy, greater than 80% with less than 5% redundancy, or greater than 50% with less than 2% redundacy  
    -Low completion: less than 50% complete with less than 2% redundancy  
    -Strain redundancy: greater than 90% complete, with greater than 10% redundancy and greater than 90% strain heterogeneity  
    -High Redundancy: Anything Bin not fitting in those categories is considered high redundancy.  

Completion: how many of the expected marker genes for this species' location on a tree are actually present in the bin. Values range from 0-100%, but it is rare to have more than 95% I think (see BVCN powerpoint files). Note that it's possible to have all of the markers but not all the genome sequence.
Contamination: Contamination of bins is determined by duplication of genes that are thought to be single-copy genes.
Redundancy: The same thing as contamination.
Heterogeneity: CheckM distinguishes between contamination (redundancy) from closely related strains (heterogeneity), and bins with genomes that are more distantly related (species or genus). 

The peat pipeline gives 40-odd bins as output for Binsanity-lc.  
All of them are 'low-completion'.  
When three technical replicates are run, we get 5 refined bins, in addition to all the low-completion bins. :D  

More detailed initial and intermediate files are provided in the .gz file.  
You probably won't need to look in this tarball unless troubleshooting.  

Binsanity-records.tar.gz is a tar file that contains all the intermediate results of clustering and the CheckM results following the initial clustering with Affinity Propagation which have been classified as either high completion, high redundancy, and strain heterogeneous. A .tar file is a Unix utility dating back to 1979, and stands for Tape Archive. A "tarball" is basically a directory of files that has been turned into a single file. To un-tar, use the following command:  

tar -xvzf Binsanity-records.tar.gz  

You would still need to run CheckM on the final BinSanity bins as a separate step.  

Concoct: Incompatible with my Ubuntu OS dependencies. Skip.  

Slightly different bc it requires you to split contigs into equal sized chunks.  
Produces a bed file showing where chunks lie on a genome? from eukaryotes  

###### 4) DAStool optimizes bins created from other tools

youtube timestamp 20:00  

https://github.com/cmks/DAS_Tool  

DASTool curates output from individual binners above (MetaBAT2, MaxBin2, BinSanity) to create optimized binning.  

Running DASTool has two steps:  
1) Create .tsv table of contigs per bin for each binner,using Fasta_to_Contigs2Bin.  
2) Run DASTool to create curated list of bins.  

For the first step, from each of your three binning folders, complete the following:  

``` {bash eval=FALSE}
#If you need to find the shell script path:

find /home/username/ -name Fasta_to_Contig2Bin.sh 
#found it :D
#/home/<USER-NAME>/miniconda3/pkgs/das_tool-1.1.4-r41hdfd78af_0/share/das_tool-1.1.4-0/src/Fasta_to_Contig2Bin.sh

#Then execute the following:
cd ~
mkdir DAStool
cd <PATH-TO-BINS-FOLDER>

/PATH/Fasta_to_Contig2Bin.sh -e fna > ~/DAStool/binner-name_contigs2bin.tsv

/home/hpc_oct/miniconda3/pkgs/das_tool-1.1.4-r41hdfd78af_0/share/das_tool-1.1.4-0/src/Fasta_to_Contig2Bin.sh -e fa > ~/error-corr/dastool/metabat_contigs2bin.tsv

#   -e, --extension            Extension of fasta files. (default: fasta)
#   -i, --input_folder         Folder with bins in fasta format. (default: ./)
```

Good to know the 'find' command, because he's explaining in the YouTube video that different environments are using the same package with the same file path which can sometimes cause troublesome crosstalk when using conda environments, apparently.  

The second step is to use the .tsv files to run DAStool.  
Sample code below is from https://maveric-informatics.readthedocs.io/en/latest/Processing-a-Microbial-Metagenome.html)  


``` bash eval=FALSE}
#in the folder with all of the contigs2bins.tsv files:

cd ~/DAStool
mkdir sample_output  #this step required
#annoyingly, this folder will be empty, but each file will start with the folder name you choose.

DAS_Tool -i binsanity.scaffolds2bin.tsv,maxbin.scaffolds2bin.tsv, / 
metabat2.scaffolds2bin.tsv -l binsanity,maxbin,metabat -c / 
<PATH>/simplified-multiLine.fasta -o sample_output --search_engine=diamond --threads=16 --write_bins  


DAS_Tool -i binsanity_contigs2bin.tsv,maxbin_contigs2bin.tsv,metabat_contigs2bin.tsv -l binsanity,maxbin,metabat -c ~/error-corr/simpl_final.contigs.fa -o sample_output --search_engine=diamond --threads=16 --write_bins
```

DASTool function and output description at timestamp 27 minutes.  

The diamond search engine is used to find the unique markers for evaluating bins. Use the --write_bins 1 to get the contig fasta files per bin.  

First it will call your genes (functional annotiation using Prodigal).  
Then use diamond to look for marker genes. Then it will make some bins, along with other outputs.  
Eval: tells you how good each bin from each tool  
.scg are the single copy gene lists! :D  
It has one file per bin, a .fa file, to know which binner was used for each file.  


# Module 8: Bin Evaluation With CheckM

checkm -h  #this works  
checkm --help  #this does not work  
checkm lineage_wf -h  

a text walking through the Dan Speth's video, presumably. Talks about plotting too.  
https://github.com/biovcnet/bvcn-binder-checkm  

https://github.com/Ecogenomics/CheckM/wiki  

CheckM reports on completeness and contamination of existing bins, but does not modify bins for improving them. 
Curating bins is done in anv'o, in the next module. 

Use Case:
checkm lineage_wf <options> ./bins ./output 

``` {bash eval=FALSE}
#sample CheckM script:
checkm lineage_wf <BIN-DIRECTORY> <OUTPUT-DIRECTORY> -t threads -x bin-file-extension -f output-file.txt

checkm lineage_wf ./ ~/error-corr/dastool/sample_output_DASTool_bins/checkM -t 16 -x fa -f checkm-summary.txt
```

The BinSanity and MaxBin outputs both show an Acidobacteria bin with high completeness (83%) but significant contamination (51%).
MetaBat's Acidobacteria bin shows lower completion (58%) with no contamination.  
All binners agree that only one of the bins is much use; the rest are only resolved to the root or bacterial marker lineage. 
This is true even when three libraries are binned.  

"Contamination" of bins is determined by duplication of genes that are thought to be single-copy genes.  

"ls storage/aai_qa/Candidatus_Brocadia_sinica  
cat storage/aai_qa/Candidatus_Brocadia_sinica/*  

The files in these directories are alignments of the duplicated marker genes checkm identified. Using those, you can assess whether the genes represent true contamination, or are duplicated in the real organism's genome."  

See also this link that shows execution of CheckM on individual binner outbut, such as MetaBat:  
https://maveric-informatics.readthedocs.io/en/latest/Processing-a-Microbial-Metagenome.html  


options:  
[-h] [-r] [--ali] [--nt] [-g] [-u UNIQUE] [-m MULTI] [--force_domain] [--no_refinement]  
                         [--individual_markers] [--skip_adj_correction] [--skip_pseudogene_correction]  
                         [--aai_strain AAI_STRAIN] [-a ALIGNMENT_FILE] [--ignore_thresholds] [-e E_VALUE] [-l LENGTH]  
                         [-f FILE] [--tab_table] [-x EXTENSION] [-t THREADS] [--pplacer_threads PPLACER_THREADS] [-q]  
                         [--tmpdir TMPDIR]  
                         bin_dir output_dir  
amino acid identity (AAI) is an index of pairwise genomic relatedness  


CheckM output (from CheckM wiki --> Genome Quality Commands -> qa):  
https://github.com/Ecogenomics/CheckM  

summary of bin completeness, contamination, and strain heterogeneity  

   - Bin Id: bin identifier derived from input FASTA file  
   - Marker lineage: indicates lineage used for inferring marker set (a precise indication of where a bin was placed in CheckM's reference tree can be obtained with the tree_qa command)  
   - No. genomes: number of reference genomes used to infer marker set for this location in the bin tree  
   - No. markers: number of inferred marker genes  
   - No. marker sets: number of inferred co-located marker sets  
   - 0-5+: number of times each marker gene is identified  
   - Completeness: estimated completeness  
   - Contamination: estimated contamination  
   - Strain heterogeneity: estimated strain heterogeneity, that is, contamination that is predicted to occur where closely related strains are co-binned, versus co-binning of more distantly related genomes (different species or genus, for example).  


# Module 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o and PathwayTools

This Module 9 is the end of the MAG assembly pipeline (this file), and is repeated at the start of the next file, using anvi'o to curate and analyze bins. 2022-Peat-bog-MAG-analysis-with-anvio.md

Visualization of MAGs with anvi'o  

anvi'o generates a web-based interactive server, so you can connect to your VM instance using the 'open in browser window' SSH option.  

If you haven't already done so, you will need to set up a .pem ssh keypair in your VM, and also add firewall rules, in order to view anvio-interactive outputs on your web browser (see Module 0, above).  

Or, run Anvio analysis on hpc, and view the .SVG files from laptop. :(
There's an Anvi'o Docker for this purpose! 

Create conda env and then install anvio:  
https://anvio.org/install/

See Module 8 above for getting anvi'o to run.

Advice on setting firewall rules to use anvi'o web interactive from a cloud VM:  

https://edwards.flinders.edu.au/install-anvio-on-an-aws-instance/  
https://merenlab.org/2015/11/28/visualizing-from-a-server/  
https://merenlab.org/2018/03/07/working-with-remote-interative/  

From the first link, start with this step:  
"Edit your security groups. You need to add HTTP and HTTPS that are chosen from the pull down menu, but you also need to add a single special rule for port 8080 traffic that anvi’o uses."  

The http and https are selected when creating or editing VM instance. Adding the new firewall rule requires additional steps.  


For Google cloud, the way to edit security groups is as follows:  
1) Pause your VM instance.  
2) In Google cloud account's hamburger menu in the upper left:  
VPC network --> Firewall --> Create Firewall Rule  

3) Choose the following settings: default network (nic0), priority 1000 (default; high), Ingress action allowed, targets: all instances on network; source filter: IPv4 ranges; Source IPv4 ranges: 0.0.0.0/0  
second source filter: service account; service account scope: in this project; source service account: Compute Engine default (75153623014-compute@developer.gserviceaccount.com), Specified protocols and port: TCP; 8080.  
It's hard to tell, but I think this is as close to the AWS guide above on setting the source range and port range for this custom TCP firewall rule.  

4) Once the self-test runs, you can head to your browser and enter your VM external IP address followed by :8080, something like this:  

http://18.188.65.122:8080  

Now that we've set up anvi'o, let's put it to use analyzing data:  

General links for anvio help:  
-Anvio-specific terms:  
  https://anvio.org/vocabulary/#all-things-anvio  
-Ways to find Anvio info:  
  https://merenlab.org/2019/10/07/getting-help/  

Anvio can be used at various points in the pipeline:  
-analyzing unassembled reads  
-binning co-assembled contigs using anvi-cluster-contigs  
-analyzing bins imported from other software using anvi-import-collections  

anvi'o tutorials:  

Using Anvio for read recruitment of microbiome reads on a single bacterial genome:  
https://merenlab.org/tutorials/read-recruitment/  

Some code to run for making sorted bam files for each sample:  
https://merenlab.org/tutorials/assembly-based-metagenomics/  

Creating and interpreting visualization of MAG bins:  
https://astrobiomike.github.io/metagenomics/metagen_anvio   
  -Co-assemble samples. Make mapping file of co-assembly (.bai).  
  -Also need .bam and .bai files of each sample library.  
  -Go directly to anvi'o for binning. Skip DAStool, checkM, etc.  

Same as above, with option to import bins created separately  
http://merenlab.org/2016/06/22/anvio-tutorial-v2/   
  -Co-assemble samples.  
  -Bam files (sorted or raw) of each sample, generated by mapping short reads from each sample to the co-assembly.fasta file.  
  -If you're going to import bins, you'll need a .tsv file generated by DAStool that gives a list of contig names per bin.  

Taxonomic analysis of MAGs in anvi'o:  
https://merenlab.org/tutorials/infant-gut/#chapter-i-genome-resolved-metagenomics  

Let's begin! :D  
Shown below are the analysis steps in cases where we want to import previously made bins from external tools.  

Needed files are:  
-simplified.co-assembly.contigs.fasta  
-contigs2bins-summary.tsv  
-lib1.bam, lib2.bam, etc  

You will need to re-format your bin names in the .tsv file, since all the binners use '.' as a field separator in bin names (maxbin.001.fasta) whereas anvi'o only accepts '_' as a field separator in bin names.  

sed or awk will work for this.  

Use case:  

sed 's/unix/linux/g' geekfile.txt > formatted_geekfile.txt  
This command will substitute the word Unix with the word Linux globally (all instances) in the file geekfile.txt, and output a new text.  

``` { bash eval=FALSE}
#For safety, make an unedited copy of your bins2contigs file first:
cp dastool_contigs2bins.tsv dastool_contigs2bins_copy.tsv

sed 's/\./_/g' dastool_contigs2bins.tsv > formatted_dastool_contigs2bins.tsv
```

``` {bash eval=FALSE}
There are recommended steps for Making a Contigs DB:

#1: make a contigs database; anvi-gen-contigs-database --help

anvi-gen-contigs-database -f simpl_final.contigs.fa -o peat-contigs.db -n 'peat-tech-reps' -T 16 


#2: Use Hidden Markov Models to analyze your contigs (analyze scg's)

anvi-run-hmms -c peat-contigs.db --num-threads 16


#3: Display contigs stats: things like N50, total contigs, contig lengths

anvi-display-contigs-stats peat-contigs.db --report-as-text -o peat-contigs-stats


#4: Annotate genes:

anvi-setup-ncbi-cogs  #this needs only be run once per VM instance

anvi-run-ncbi-cogs --help # i dunno what inputs this needs

anvi-run-ncbi-cogs -c peat-contigs.db --num-threads 16


#5: Makes use of functional annotations

anvi-import-functions


#6: Import taxonomy: see this link. https://merenlab.org/2019/10/08/anvio-scg-taxonomy/

anvi-setup-scg-taxonomy --num-threads 16  #this is done once per VM instance

anvi-run-scg-taxonomy -c peat-contigs.db -T 16 
#optional: run again with --debug flag to see details of each call, if the table from the initial run shows mismatches.

anvi-estimate-scg-taxonomy -c peat-contigs.db -T 16 --metagenome-mode
-o peat-taxonomy-estimate

#additional taxonomy estimates available after making profiles for each library.
```

Let's proceed to making profile databases from each of our libraries.  
This step will generate converage and SNV info per nucleotide, with optional contig clustering per sample (default turned off)  

``` {bash eval=FALSE}
anvi-profile -i SAMPLE-01.bam -c contigs.db --output-dir PROFILE-01 --sample-name SAMPLE-01

#Not sure where the sample name shows up, as it doesn't appear in the output directory. :/ The overwrite function default is false, so it should be ok to run each sample without changing output dir.

#the bam file that is sorted and indexed; not the raw bam file
# run this command once for each library sample.

# And now, merge the individual profiles. This step performs heirarchical clustering of contigs across samples.

anvi-merge SAMPLE-01/PROFILE.db SAMPLE-02/PROFILE.db SAMPLE-03/PROFILE.db -o SAMPLES-MERGED -c contigs.db

anvi-merge 490profile/PROFILE.db 524profile/PROFILE.db 527profile/PROFILE.db -o peat-merged-profiles -c peat-contigs.db
```

Now it's time to import our binning info into an anvi'o collection. A collection in anvi'o comprises one or more bins. They can be imported or made within anvi'o.  

``` {bash eval=FALSE}
#Use case:
anvi-import-collection binning_results.txt -p SAMPLES-MERGED/PROFILE.db -c contigs.db --source "SOURCE_NAME"

#binning_results.txt is an output of dastool: DASTool_contig2bin.tsv
#Each line of this TAB-delimited file should contain a contig name (or split name), and the bin name it belongs to.

#Use case:
anvi-import-collection binning_results.txt -p SAMPLES-MERGED/PROFILE.db -c contigs.db --contigs-mode --collection-name PeatTechReps

anvi-import-collection formatted_dastool_contigs2bins.tsv -p peat-merged-profiles/PROFILE.db -c peat-contigs.db  --contigs-mode --collection-name peatTechReps

#Additionally, to show all bins and collections in your contigs database, use anvi-show-collections-and-bins.

#To rename bins:
anvi-rename-bins -c peat-contigs.db -p peat-merged-profiles/PROFILE.db --collection-to-read peatTechReps --collection-to-write PeatTechReps --prefix PalsaMedium --report-file renamed-bins.txt --dry-run
```

If all goes well, our collection of bins is now INSIDE anvi'o, and we've done some analysis of the profiles bins: identified genes and their functional annotation, found SNVs, and looked at taxonomic estimates. Now let's apply some analysis to the bins themselves.  

Check out your estimated taxonomy per bin:

``` {eval bash=FALSE}
anvi-estimate-scg-taxonomy -c peat-contigs.db -p peat-merged-profiles/PROFILE.db --metagenome-mode --compute-scg-coverages --num-threads 16 --update-profile-db-with-taxonomy > tax-scg-est-per-sample.tsv

#I kept getting error msgs when trying to use the --output-file flags, so I just ported the StOut to a file instead. 

anvi-show-collections-and-bins -p peat-merged-profiles/PROFILE.db

anvi-estimate-scg-taxonomy -c peat-contigs.db -p peat-merged-profiles/PROFILE.db -C PeatTechReps  > tax-scg-est-per-bin.tsv

#Note that unlike the previous command, this command is not done in metagenome mode, because we cannot simultaneously treat contigs.db as metagenome, and also provide it with a collection.



Quality control: look at bin coverage, completeness, and redundancy:

``` {bash eval=FALSE}

anvi-estimate-genome-completeness -p peat-merged-profiles/PROFILE.db -c peat-contigs.db -C PeatTechReps > qc-bin-est-genome-completeness.tsv

#Redundancy means more than one copy of a SCG appeared in a bin.
#Completeness means what fraction of total SCG for that taxon appear in the bin.

#Reported values are raw coverages for genes, rather than % coverages. 
#coverage = (read count * read length ) / total genome size

```

Anvi-summarize makes a nice table of bin / genome completeness etc  

``` {bash eval=FALSE}
anvi-summarize -c peat-contigs.db -p peat-merged-profiles/PROFILE.db -C PeatTechReps -o PeatSummarized --quick-summary --init-gene-coverages --reformat-contig-names
```

Note that anvi-summarize generates a whole bunch of .fasta files of your contigs, b/c the summary is intended to give someone everything they need to share a project analysis with others.   

--initiate-gene-coverages is computationally intensive, but will provide very accurate coverage info down to per-gene level  

--reformmat-contig-names will include bin name in contigs, and provide an old-to-new name conversion file  

--quick-summary is less complex. Also doesn't provide a snapshot of the circos plot.

Note that manual refinement is able to reduce contamination, but not increase completeness.

Results: I was able to reduce the contamination of two of my four bins slightly, using manual curation. 

<img src="https://github.com/user-attachments/assets/c0131872-7e28-4ccf-adf1-89bfcf572d12" align=center width=800 title="anvi-quick-summary of four DAS Tool bins after manual curation in anvi'o">



# Appendix 1: X11-forwarding to use Pathway Tools 

Pathway Tools  

From:
 https://maveric-informatics.readthedocs.io/en/latest/Metabolic-and-Pathway-Analyses.html  

https://github.com/hallamlab/metapathways2/wiki  

Here's the non-GUI version:  
https://github.com/hallamlab/MetaPathways/wiki/MetaPathways-v1.0-Installation  

MetaPathways2, from the peat pipeline link, handles most of the processing from bins (MAGs) to the pathways part of the pipeline. To identify pathways, it runs Pathway Tools and collects the results from that tool to integrate it into its [MetaPathways2] final results.  

Unfortunately MetaPathways2 seems to have poor documentation and is not updated. I get a python error running any of the scripts that says print commands should be enclosed with parentheses, which means the change to python3 (backwards incompatible with python2) broke MetaPathways2 python scripts. Although, python3 came out in 2008. The MetaPathways2 github has open issues with no reply dating from 2017. 

So, the information below is archived because it includes useful info on how to use X-11 forwarding for Pathway Tools. But, suggest using Pathway Tools directly rather than MetaPathways2 scripts. 

Pathway Tools install step-by-step:  
https://bioinformatics.ai.sri.com/ptools/installation-guide/released/unix.html  

``` {bash eval=FALSE}
conda activate base

cd ~/pathways

curl -u <USERNAME-FROM-PTOOLS-LICENSE-EMAIL> \ https://bioinformatics.ai.sri.com/ecocyc/dist/ptools-tier1-34987569/pathway-tools-26.0-linux-64-tier1-install \
> pt-install
```

To run the binary install file, first may need to add OpenMotif library, libXm, as described here:  

http://bioinformatics.ai.sri.com/ptools/installation-guide/released-bad/openmotif.html  

and also described here:  
https://bioinformatics.ai.sri.com/ptools/installation-guide/released/unix.html  

``` {bash eval=FALSE}
For Ubuntu 18.04 you should be able to install with just

sudo apt-get install libxm4 

# then run the install:
./pt-install
```

We're using X11-forwarding, as described in these links below: use SSH from your laptop terminal to run the VM, and the GUI window of the VM's output will display on your laptop (XQuartz, in the case of Mac).  

https://goteleport.com/blog/x11-forwarding/  #description  
https://ostechnix.com/how-to-configure-x11-forwarding-using-ssh-in-linux/  
https://bioinformatics.ai.sri.com/ptools/installation-guide/released/unix.html  

``` {bash eval=FALSE}
#create a .pem key pair //in your VM//, add to VM SSH keys, and transfer to your laptop.

ssh-keygen -t rsa -m pem
 $ specify filepath: ~/.ssh/id_rsa.pem  #need to specify the .pem extension when prompted

#make sure to update permissions to your new keypair on your laptop, or you won't be able to connect to github:

The public key (.pub file) should be 644 (-rw-r--r--). 
The private key            should be 600 (-rw-------).

use case:
chmod 644 hpc-august.pem.pub
chmod 600 hpc-august.pem

#also add new keypair to agent:

ssh-add -A  #for adding passphrase to Mac keychain util; not recommended?

eval 'ssh-agent -s' 
ssh-add ~/.ssh/id_rsa.pem

#sometimes you will need to run this line:
sudo ssh-add ~/.ssh/id_rsa.pem
#even if you get an error, you should be able to eval and then ssh-add after that:
eval 'ssh-agent -s' 
ssh-add ~/.ssh/id_rsa.pem

check that it's added:
ssh-add -l

#make a SSH config file that points to your new keypair, as described here:
https://serverfault.com/questions/938870/permission-denied-publickey-mac

cd ~/.ssh

cat > config << EOF
Host instance-1
     User hpc_august #or whatever user name is in your .pem key pair
     HostName #external IP address from VM instance 35.239.141.109
     IdentityFile ~/.ssh/hpc-august.pem #or whatever private key file
EOF

#make sure the User is as it appears in the VM, not in the key pair, i.e. hpc_august, not hpc-august.

#add your new key-pair to your agent, as described here:
https://stackoverflow.com/questions/44250002/how-to-solve-sign-and-send-pubkey-signing-failed-agent-refused-operation

ssh-add -A  #adds passphrase to Mac keychain utility? Not recommended
https://apple.stackexchange.com/questions/48502/how-can-i-permanently-add-my-ssh-private-key-to-keychain-so-it-is-automatically

ssh-add -l #check to make sure it's added to ssh agent

#log into VM from laptop terminal using ssh -Y, which specifies a trusted X11 forwarding:

cd ~

ssh -Y instance-1 #or whatever Host in config file

#you will get this error message, but that's bc it creates a file the first time it's used:

  "/usr/bin/xauth: file ~/.Xauthority does not exist"

#Close terminal w/ VM connection, and re-start:

ssh -Y instance-1

#If it doesn't work, carefully clean out the key pairs in your laptop .ssh folder (make sure not to delete any ones you might need), and start by making a new keypair.



conda activate anvio-7.1

cd ~/pathway-tools
bash pathway-tools

#you should see XQuartz launch on your laptop, with Pathway Tools GUI.

#Note that you will need to modify the config file to update the #External IP for each launch of your VM. 
```

Now we're ready to actually run pathway tools from our laptop with X11 forwarding to view the GUI output.


