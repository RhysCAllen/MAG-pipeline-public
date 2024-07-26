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
The remaining 9% include Acidobacteria and Actinobacteria. Sourmash detected strains that were characterized in the 2018 study ("Palsa" strains), which is nice confirmation that the sourmash database used is up-to-date, and the pipeline is correctly identifying some of the reads in these samples. 

 <img src = "https://github.com/user-attachments/assets/1f57d127-9333-4723-8b3c-c9f978ade635" width=800 align=center alt="" title="fastqc overrepresented sequences plot"/>

 <img src = "https://github.com/user-attachments/assets/e5d700e2-f4c5-4118-a8a4-d28c129cd3fd" width=100 align=center alt="" title="fastqc overrepresented sequences plot"/>


MODULE 5: Genome (SPAdes) and Metagenome (Megahit) Assembly


MODULE 6: Read Mapping and Alignments using BBWrap
MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool
MODULE 8: Bin Evaluation with CheckM
MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o 
