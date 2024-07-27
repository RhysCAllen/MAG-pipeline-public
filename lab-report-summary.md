# Lab report summary

Three libraries representing technical replicates of a peat bog were co-assembled and binned. 

MODULE 1: Read Trimming and Quality Filtering of K-mers using BBtools  
MODULE 2: Visualizing Read Quality with FastQC  
MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk  
MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts  
MODULE 5: Genome (SPAdes) and Metagenome (Megahit) Assembly  
MODULE 6: Read Mapping and Alignments using BBWrap  
MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool  
MODULE 8: Bin Evaluation with CheckM  
MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o  

# Summary:


# Details per module: 

MODULE 1: Read Trimming and Quality Filtering of K-mers using BBtools  
Illumina adapters trimmed, as well as sequence with low entropy=0.95 (a proxy for low quality) and minimum ave quality=8.  
Spike-ins, and cleaning by optical cell tile (Illumina) was not done.  
Removed sequences were diverted to a separate file rather than deleted.  

MODULE 2: Visualizing Read Quality with FastQC  
 I compared sequence that was qualtrimmed, vs seq that was removed by qualtrimming step above.  
 As expected, sequence quality of qualtrimmed was of good quality across all metrics, 
 whereas quality of removed sequence was lower and sometimes poor.  

 see MAG-pipeline-public/output-files/20120700-P#M_multiqc_report.html file for more details.
 <br>
 <img src = "https://github.com/user-attachments/assets/2314036b-6734-4c5a-a3ef-2d2686b01093" width=400 align=center alt="" title="fastqc overrepresented sequences plot"/>
 <br>
Some of the sequences show higher-than-average GC content, which is typical of certain bacterial genera. 
 
MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk
Table of classifications provided by sourmash by kmer comparison to GBDB database.
see file MAG-pipeline-public/output-files/peat_taxonomy_summary.csv

MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts

Unassembled reads are 91% unclassified at this point (smaller plot, right). 
The remaining 9% include Acidobacteria and Actinobacteria (large plot, left). Sourmash detected strains that were characterized in the 2018 study ("Palsa" strains), which is nice confirmation that the sourmash database used is up-to-date, and the pipeline is correctly identifying some of the reads in these samples. 

 <img src = "https://github.com/user-attachments/assets/1f57d127-9333-4723-8b3c-c9f978ade635" width=800 align=center alt="" title="krona plot of 9% of sequences that were classified"/>

 <img src = "https://github.com/user-attachments/assets/e5d700e2-f4c5-4118-a8a4-d28c129cd3fd" width=100 align=center alt="" title="krona plot showing 91% of unassembled reads are unclassified"/>


MODULE 5: Genome (SPAdes) and Metagenome (Megahit) Assembly
Error correction using metaSPAdes; read depth normalization using BBNorm (tadpole), co-assembly of the three libraries with MEGAHIT, and calculation of assembly statistics. 
Megahit assebly with kmer of length 33 was chosen in absence of better suggestions as a compromise between more reads assembled (shorter kmer) and larger contigs (
longer kmer). 
Co-assembly of three error-corrected and normalized libraries took about 40 minutes.

I visually examined the maximum contig sizes and number of contigs for a K21, K33, and K55 from the stats summaries, and there didn't seem to be too much difference between K33 and K55, which K21 having much smaller contig sizes. I selected K33 for moving forward with the pipeline.
Unfortunately looks like I did not save the assembly stats file. 
It is recommended to view the deBruijn graphs of the assemblies; however, the recommended software for this has been deprecated since 2022 with no obvious alternatives. 

MODULE 6: Read Mapping and Alignments using BBWrap
Used BBMap (via BBwrap) to index contigs, align reads, and index sorted aligned contigs. 
It looks like I deleted these files too, but StOut reported acceptable error rate ( <10%) for ave library read lengths (~ 100bp).
If I recall correctly, average read depth was one read, which makes sense considering the high genetic diversity and low sequencing depth of these libraries. 

MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool

Binning was performed using MaxBin2, MetaBAT2, BinSanity. Bins were optimized with DAS tool. Concoct, a fourth binner, was unavailable on the OS used for this analysis. 
MaxBin2: Total of 6 bins; themost complete were bin 2 (58%) and bin 5 (59%).  
MetaBat produced 5 bins. 
BinSanity: 5 refined bins, in addition to and handful of low-completion bins. 

DASTool performs bin optimization and dereplication, aided by functional annotiation using Prodigal, followed with diamond to look for marker (SGC) genes.

DAS Tool provided 6 bins, four of which were low-completion. 

MODULE 8: Bin Evaluation with CheckM


MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o 















