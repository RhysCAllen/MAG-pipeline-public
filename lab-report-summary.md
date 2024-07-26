# Lab report summary

words words words

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

 see MAG-pipeline-public/output-files/20120700-P#M_multiqc_report.html file. 
![fastqc_overrepresented_sequencesi_plot](https://github.com/user-attachments/assets/2314036b-6734-4c5a-a3ef-2d2686b01093)


 
MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk
MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts
MODULE 5: Genome (SPAdes) and Metagenome (Megahit) Assembly
MODULE 6: Read Mapping and Alignments using BBWrap
MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool
MODULE 8: Bin Evaluation with CheckM
MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o 
