
The purpose of this report is to benchmark a MAG pipeline (2022-MAG-assembly-anvio-pipeline.md). The pipeline is a hybrid of a variety of sources, including BVCN, anvi'o, and MAVERIC (Sullivan lab, OSU). Two criteria were used for benchmarking: 1) comparison with results from a published tutorial called MAVERIC for one of these three samples; and 2) statistics at each checkpoint, to help me develop a feel for MAG QC and troubleshooting.

# Summary

Three technical replicates (years 2010, 2011, 2012) of a peat bog sample were chosen from a previously published study (BJ Woodcroft et al, 2018). Illumina HiSeq 2500 libraries (100 bp paired reads, ave insert size ~350 bp) comprising 11.5 GBp of sequence were downloaded.  After qualtrimming with bbtools, 86% or 24.2 million paired-end reads were retained, including singletons.  Classification of unassembled reads by sourmash showed 91% unclassified, with 9% including Acidobacteria and Actinobacteria, as well as study-specific strains (e.g. "Palsa"). Co-assembly of the three libraries with metaSPAdes appeared to work well, with K33 co-assembly comprising 1 million contigs with an N50 of 250k bp and an L50 of 322. Read alignments to these contigs using BBWrap showed average depth of 1 read, with 10% error. Indexed and sorted alignment files were binned and dereplicated, for a consensus dereplicated binning of 4 bins from DAS Tool. CheckM showed the highest quality MetaBat2 bin was classified as Actinobacteria, with 58% completeness and 0% contamination. Manually refining bins in anvi'o led to minor reduction of contamination for two of four bins, with the highest-quality bin having 97.18% completeness and 1.41% contamination. Future work includes using single-library assembly with metaSPAdes, instead of co-assembly of these three replicates. Additional pipeline development includes troubleshooting the poor quality of MegaHIT co-assembly, and finding up-to-date software to view deBruijn graphs. 


<img src="https://github.com/user-attachments/assets/0fa9ba4b-cd85-4cb1-8a48-df6497206902" align=center width=600 title="Tracking DNA retention">


# Pipeline modules

    MODULE 1: Read Trimming and Quality Filtering using BBtools  
    MODULE 2: Visualizing Read Quality with FastQC  
    MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBduk  
    MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona
    MODULE 5: Contig co-assembly with MetaHit and metaSPAdes
    MODULE 6: Read Mapping and Alignments using BBWrap and Bowtie2
    MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool  
    MODULE 8: Bin Evaluation with CheckM  
    MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o  


# Results per module: 

###### MODULE 1: Read Trimming and Quality Filtering using BBtools  
Illumina adapters were trimmed, and reads with low entropy=0.95 (a proxy for low quality) and minimum ave quality=8 were removed.  Spike-ins (phiX) were removed.
Cleaning by optical cell tile (Illumina) was not performed.  
Removed sequences were diverted to a separate file rather than deleted.  
86% of reads (24.2 million) remained after qualtrimming.

###### MODULE 2: Visualizing Read Quality with FastQC  
 Qualtrimmed data were compared with removed sequences using FastQC. 
 As expected, sequence quality of qualtrimmed reads was of good quality across all metrics, 
 whereas quality of removed sequence was lower and sometimes poor.  Some of the sequences show higher-than-average GC content, which is typical of certain bacterial genera, such as Actinobacteria.


 <img src = "https://github.com/user-attachments/assets/2314036b-6734-4c5a-a3ef-2d2686b01093" width=400 align=center alt="" title="fastqc overrepresented sequences plot"/>
 
     /MAG-pipeline-public/output-files/20120700-P#M_multiqc_report.html
 <br>


 
###### MODULE 3: Classification of Unassembled Reads by K-mer Sketch using Sourmash and BBDuk
Table of classifications provided by sourmash by kmer comparison to GenBank's representative genomes, k31, LCA database.

     /MAG-pipeline-public/output-files/peat_taxonomy_summary.csv

###### MODULE 4: Visualizing Taxonomy of Unassembled Reads With Krona charts

Reads were placed into taxonomy in Krona using GTDB taxonomy file.
Unassembled reads are 91% unclassified at this point (small plot). 
The remaining 9% include Acidobacteria and Actinobacteria (large plot). Sourmash detected strains that were characterized in the 2018 study ("Palsa" strains). 

 <img src = "https://github.com/user-attachments/assets/e5d700e2-f4c5-4118-a8a4-d28c129cd3fd" width=200 align=center alt="" title="krona plot showing 91% of unassembled reads are unclassified"/>
<br>
<br>
 <img src = "https://github.com/user-attachments/assets/1f57d127-9333-4723-8b3c-c9f978ade635" width=800 align=center alt="" title="krona plot of 9% of sequences that were classified"/>
 
     /MAG-pipeline-public/output-files/peatPM2012-krona-all.html

###### MODULE 5: Co-assembly with MegaHIT and metaSPAdes

Read error-correction with SPAdes resulted in 17.8 million corrected reads, retaining 74% of the qualtrimmed reads, or 63% of the downloaded data. 

For read depth normalization to aid co-assembly, BBnorm output indicated an average kmer depth of 4.5, with standard dev = 35, and a median read depth of 3.  

Co-assembly was first performed on the three libraries with metaSPAdes. 
   
I visually examined the maximum contig sizes and number of contigs for a K21, K33, and K55 from the metaSPAdes stats summaries, and there didn't seem to be too much difference between K33 and K55, which K21 having much smaller contig sizes. I selected K33 for moving forward with the pipeline.


<img src="https://github.com/user-attachments/assets/a1d3f37a-23f2-4652-94f3-197209a00833" width=600 align=center title="metaSPAdes assembly of single paired-end library with singletons, K33"/>  
<br>
<br>

MegaHIT automatically created assemblies with a range of kmer lengths from K27 to K107. An article benchmarking co-assembly of marine seq libraries suggested K55 or so. Co-assembly of three error-corrected and normalized libraries took about 40 minutes with MegaHIT.

BVCN, my primary tutorial for MAG pipeline, recommended MegaHIT; however, it seems to have performed poorly compared to metaSPAdes for co-assembly of these three libraries, with fewer assebmled contigs and smaller contig sizes (see table). It is likely that a better co-assembly with MegaHIT is possible with these samples, but for now, proceed with metaSPAdes. 

<img src="https://github.com/user-attachments/assets/221f237c-dc5b-4804-8325-e189bd4e8899" width=400 align=center title="metaSPAdes vs MegaHIT co-assembly of three libraries">  
<br>

It is recommended to view the deBruijn graphs of the assemblies; however, the recommended software for this has been deprecated since 2022 with no obvious alternatives. 


###### MODULE 6: Read Mapping and Alignments using BBWrap

Using Bowtie2, there is a 34% alignment rate of metaSPAdes K33 co-assembly. 14.6 million reads were aligned.  
<br>
<img src="https://github.com/user-attachments/assets/67ba1d91-c11c-44a2-ad1a-8245c8f562db" width=600 align=center title="Bowtie2 alignment of metaSPAdes co-assembly, K33" />  
<br>
<br>
Using BBMap, 15 M reads were aligned to metaSPAdes K33 co-assembly.  
<br>
<img src="https://github.com/user-attachments/assets/cd508e3f-282b-4068-aeae-6a2b581069cb" width=600 align=center title="BBWrap alignment of metaSPAdes co-assembly, K33" />  

As expected the coverage % per contig is very high (98-100%). 
Percent reads mapped between 3% and 20%. I think that's pretty normal since the ref seq is de-novo metagenomic assembly from low seq depth and high diversity. 

###### MODULE 7: Binning Metagenome-assembled Genomes using MetaBat, BinSanity, MaxBin, and DAS Tool

Binning was performed using MaxBin2, MetaBAT2, and BinSanity. Bins were optimized with DAS tool. Concoct, a fourth binner, was unavailable on the OS used for this analysis.  
MaxBin2: Total of 6 bins; the most complete were bin 2 (58%) and bin 5 (59%).  
BinSanity: 5 refined bins, in addition to a handful of low-completion bins. 
MetaBat2 produced 5 bins. 

The BinSanity and MaxBin outputs both show an Actinobacteria bin with high completeness (83%) but significant contamination (51%). MetaBat's Actinobacteria bin shows lower completion (58%) with no contamination.

DASTool performs bin optimization and dereplication, aided by functional annotiation using Prodigal, followed with diamond to look for marker (SGC) genes.

DAS Tool provided 4 bins, which is a similar outcome to the MAVERIC pipeline, which provided three DAS tool bins that met with minimum criteria (not shown). 

<img src="https://github.com/user-attachments/assets/729c53fd-ed48-4a4f-ba41-122c104de120" width=800 align=center title="DAStool output for this pipeline">

###### MODULE 8: Bin Evaluation with CheckM

Advice from bioinformaticians via the BVCN Slack channel recommended co-assembly of technical replicates for complex samples like peat, in order to potentially provide more data for higher % completion of predicted genomes. However, they also indicated that single-library co-assemblies can be useful for the bin refinement step to reduce bin contamination. 

The tables below show the checkM results from the MetaBat2 binning results for metaSPAdes co-assembly of three libraries (top; this study) with one library (bottom; MAVERIC tutorial).  
<br>
<img src="https://github.com/user-attachments/assets/490ef2dd-d4e6-4772-bbdf-31411ce88c8a" width=800 align=center title="My MetaBat bins from metaSPAdes K33 co-assembly" >

<img src="https://github.com/user-attachments/assets/9508f9a8-8083-4de9-86f7-04a3d80a32d6" align=center width=800 title="MAVERIC MetaBAT bins from metaSPAdes co-assembly of single library">

<br>
TOP: CheckM of MetaBat2 binning from co-assembly of three libraries; this study.   

BOTTOM: CheckM of MetaBat2 from co-assembly of one library; MAVERIC tutorial.    

In both pipelines, the Actinobacteria bin had the highest completion % and lowest contamination. Interestingly, the MAVERIC co-assembly of a single library showed better checkM results than my co-assembly with three libraries. It could be that the three libraries are functioning less like technical replicates than as separate samples. Although they were collected at the same location and conditions in the peat bog study, they were collected at three consecutive years (2010, 2011, and 2012). 


###### MODULE 9: Refinement, Visualization, and Analysis of MAG bins using anvi'o 

I was able to import into anvi'o the four bins I curated from DAS Tool. Manual curation of bins can help fix contamination issues, but not assembly issues.

I was able to slightly improve the contamination of 2 of the 4 bins with manual curation.

<img src="https://github.com/user-attachments/assets/7f96d69d-be4e-4a1a-a28f-4b867a9e6b08" width=800 align=center title="My anvio summary of peat co-assembly bins">







