# Lab report

Three libraries representing technical replicates of a peat bog sample were co-assembled and binned. 

# Summary

Three technical replicates (2010, 2011, 2012) of a peat bog fen sample were chosen from a previously published study (BJ Woodcroft et al, 2018). Illumina HiSeq 2500 libraries (100 bp paired reads, ave insert size ~350 bp, comprising 11.5 GBp of sequence.  After qualtrimming, 86% or 24.2 million reads were retained, including singletons. including singletons).  Classification of unassembled reads by sourmash showed 91% unclassified, 9% included Acidobacteria and Actinobacteria, as well as study-specific strains (e.g. "Palsa"). Assembly using this tool showed best results with K55, showing N50 of 75kb and L50 of 3. Total assembled x million reads, or y% of qualtrimmed reads. Read alignments to contigs showed average depth of 1 read, 10% error and some other read alignment stat; including x% of of normalized reads aligned. Indexed and sorted alignment files were binned and dereplicated, for a consensus dereplicated binning of 6 bins, including 4 low-quality bins. CheckM says this. Manually refining bins in anvi'o led to xyz. Classification of bins in anvi'o indicate xyz, as bins had duplication of single copy markers A and B. Additional refinement steps include single-library assembly for comparison and curation. Bins most likely include Genus species and Genus species, which is consistent with published analysis of these libraries. 



# Pipeline modules

    MODULE 1: Read Trimming and Quality Filtering of K-mers using BBtools  
    MODULE 2: Visualizing Read Quality with FastQC  
    MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk  
    MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts  
    MODULE 5: Contig assembly with MetaHit
    MODULE 6: Read Mapping and Alignments using BBWrap  
    MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool  
    MODULE 8: Bin Evaluation with CheckM  
    MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o  


# Results per module: 

###### MODULE 1: Read Trimming and Quality Filtering of K-mers using BBtools  
Illumina adapters trimmed, as well as sequence with low entropy=0.95 (a proxy for low quality) and minimum ave quality=8.  Spikeins (phiX) were removed.
Cleaning by optical cell tile (Illumina) was not performed.  
Removed sequences were diverted to a separate file rather than deleted.  

###### MODULE 2: Visualizing Read Quality with FastQC  
 I compared sequence that was qualtrimmed, vs seq that was removed by qualtrimming step above.  
 As expected, sequence quality of qualtrimmed was of good quality across all metrics, 
 whereas quality of removed sequence was lower and sometimes poor.  

 see MAG-pipeline-public/output-files/20120700-P#M_multiqc_report.html file for more details.
 <br>
 <img src = "https://github.com/user-attachments/assets/2314036b-6734-4c5a-a3ef-2d2686b01093" width=400 align=center alt="" title="fastqc overrepresented sequences plot"/>
 <br>
Some of the sequences show higher-than-average GC content, which is typical of certain bacterial genera, such as Actinobacteria.

(28.2 million reads before qc trimming; 24.2 million reads @ 100 bp after qc trimming). 
 
###### MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk
Table of classifications provided by sourmash by kmer comparison to GBDB database.
see file MAG-pipeline-public/output-files/peat_taxonomy_summary.csv

###### MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts

Unassembled reads are 91% unclassified at this point (smaller plot, right). 
The remaining 9% include Acidobacteria and Actinobacteria (large plot, left). Sourmash detected strains that were characterized in the 2018 study ("Palsa" strains), which is nice confirmation that the sourmash database used is up-to-date, and the pipeline is correctly identifying some of the reads in these samples. 

 <img src = "https://github.com/user-attachments/assets/1f57d127-9333-4723-8b3c-c9f978ade635" width=800 align=center alt="" title="krona plot of 9% of sequences that were classified"/>

 <img src = "https://github.com/user-attachments/assets/e5d700e2-f4c5-4118-a8a4-d28c129cd3fd" width=100 align=center alt="" title="krona plot showing 91% of unassembled reads are unclassified"/>


###### MODULE 5: Genome (SPAdes) and Metagenome (Megahit) Assembly
14.1 million readds * paired = 28.2 million reads *100 bp = 2820 million base pairs or 2.8 Billion base pairs.

Then for the K33 assembly, we had sum_length about 308 million. Sooooooooo that's a pretty small percentage, About 11%. Cool!

f there's a sum_length assembly of 308 million bp, and 100 bp per read, then there should be about3 million reads aligned.
But it said only 420, 000 reads aligned. 


Num seqs is the number of contigs
K21:
num_seqs 2.4 million, sum_length = 335 million, max_length = 8kb
min_length = 22. N50; L50 = 500,000 bp; contig #215
K33:
num_seq = 1 million, sum_length = 306 million, min_length 34,
ave_length 300, max_length 50 kb. N50, L50 = 250,000bp; contig #322.
num_seq = 500,000; sum_length = 250 million, min_length 56, ave_length = 430, max_length = 500 kb. 
N50, L50 = 120,000bp; contig #460

The BBnorm output also indicated an average kmer depth of 4.5, with st dev = 35. Median read depth of 3
Error correction using metaSPAdes; read depth normalization using BBNorm (tadpole), co-assembly of the three libraries with MEGAHIT, and calculation of assembly statistics. 
Megahit assebly with kmer of length 33 was chosen in absence of better suggestions as a compromise between more reads assembled (shorter kmer) and larger contigs (
longer kmer). 
Co-assembly of three error-corrected and normalized libraries took about 40 minutes.

I visually examined the maximum contig sizes and number of contigs for a K21, K33, and K55 from the stats summaries, and there didn't seem to be too much difference between K33 and K55, which K21 having much smaller contig sizes. I selected K33 for moving forward with the pipeline.
Unfortunately looks like I did not save the assembly stats file. 
It is recommended to view the deBruijn graphs of the assemblies; however, the recommended software for this has been deprecated since 2022 with no obvious alternatives. 

megahit assembly: 8605 contigs, total 25065139 bp, min 1000 bp, max 365382 bp, avg 2912 bp, N50 3604 bp
I'll pick k57 since I read somewhere that the best assemblies are between 50 and 60 for metagenomes. 
#contigs   #bp          #N50  L50   
8605    25065139    1139    3604

###### MODULE 6: Read Mapping and Alignments using BBWrap

But this time, it attempted to align 28.2 million reads, most of which were detected as paired reads (14.2 million pairs). 
But, only 13% of read pairs aligned concordantly (with expected FR orientation and distance between reads that would occur from Illumina paired-end sequence library protocol). 

Used BBMap (via BBwrap) to index contigs, align reads, and index sorted aligned contigs. 
It looks like I deleted these files too, but StOut reported acceptable error rate ( <10%) for ave library read lengths (~ 100bp).
If I recall correctly, average read depth was one read, which makes sense considering the high genetic diversity and low sequencing depth of these libraries. 

As expected the coverage % per contig is very high (98-100%). 
Percent reads mapped between 3% and 20%. I think that's pretty normal since the ref seq is de-novo metagenomic assembly from low seq depth and high diversity. 

###### MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool

Binning was performed using MaxBin2, MetaBAT2, BinSanity. Bins were optimized with DAS tool. Concoct, a fourth binner, was unavailable on the OS used for this analysis. 
MaxBin2: Total of 6 bins; themost complete were bin 2 (58%) and bin 5 (59%).  
MetaBat produced 5 bins. 
BinSanity: 5 refined bins, in addition to and handful of low-completion bins. 

DASTool performs bin optimization and dereplication, aided by functional annotiation using Prodigal, followed with diamond to look for marker (SGC) genes.

DAS Tool provided 6 bins, four of which were low-completion. 

###### MODULE 8: Bin Evaluation with CheckM


###### MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o 

6201 item(s) that were in the database, but were not in the input file, will not be described by any bin in the collection peatTechReps.
think that just means that only some of  the contigs in the co-assembly ended up in bins, which is to be expected. But I wasn't sure about the "splits" name, so I'm putting this info here in case I need to refer to it laterrr.













