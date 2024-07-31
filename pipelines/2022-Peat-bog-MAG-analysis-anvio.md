
# MAG taxonomic and functional analysis with anvi'o 
###### Rhys Allen 2022

This is an analysis of bins assembled from peat bog metagenome sequence. 
File status: complete through Module 1 of 5. 

To use this file, you will need the contigs.db and profile.db folders of files, and the reformatted contigs2bins.tsv files as described in MAG-anvio-pipeline-10-2022.md file. You will need to run the anvi'o server from Docker (instructions below). 

# Contents:
    MODULE 0: Merge profiles, import bins, analyze SCG taxonomy, summarize bin statistics 
    MODULE 1: QC bin completeness/coverage/redundancy. Manual curation of bins with anvi-refine
    MODULE 2: Analyze function and metabolic capabilities of bins with anvi-estimate-metabolism
    MODULE 3: Bio-prospecting for MAGs with novel markers: anvi'o and structural biology
    MODULE 4: Analyzing phylogony http://merenlab.org/2017/06/07/phylogenomics/
    MODULE 5: Creating Pangenomes http://merenlab.org/2016/11/08/pangenomics-v2/

# References:

#### General links for anvio help:
-Anvio-specific terms:  
  https://anvio.org/vocabulary/#all-things-anvio  
-Ways to find Anvio info:  
  https://merenlab.org/2019/10/07/getting-help/

#### Anvio can be used at various points in the pipeline:
-analyzing unassembled reads using read recruitment  
-binning co-assembled contigs using anvi-cluster-contigs  
-analyzing bins imported from other software using anvi-import-collections  

#### Manuals / Tutorials/ Analysis pipelines:

Intro to Anvi-interactive, and visualization of MAG bins:  
https://astrobiomike.github.io/metagenomics/metagen_anvio 

Detailed manual of anvi-interactive:  
https://merenlab.org/2016/02/27/the-anvio-interactive-interface/

Anvi-summarize and anvi-refine:  
http://merenlab.org/2016/06/22/anvio-tutorial-v2/ 

Taxonomic analysis of MAGs in anvi'o:  
https://merenlab.org/tutorials/infant-gut/#chapter-i-genome-resolved-metagenomics
<br>
<br>
<br>

# Module 0: Merge profiles, import bins, summarize and visualize

1) Run the anvi'o server from Docker.
2) Import bins.
3) Estimate taxonomy.
4) Bin completeness and recovery.
5) Anvi-summarize of bin collection statistics.
   
###### 1) Run anvi'o server from Docker. 
Make sure Docker is downloaded and installed correctly on your machine.  
Launch the Docker application.  
Follow instructions here for accessing Anvi'o Docker instance:  
https://merenlab.org/2015/08/22/docker-image-for-anvio/

To run the anvi'o server in Docker:  

https://merenlab.org/2015/08/22/docker-image-for-anvio/  

``` {bash eval =FALSE}
docker run --rm -it -v `pwd`:`pwd` -w `pwd` -p 8080:8080 meren/anvio:7.1_main_0522

# your display should then look like this:
# :: anvi'o v7.1_main_0522 :: /WORK/DIR/PATH >>>

MERGE PROFILES. This step performs heirarchical clustering of contigs across samples.

#use case:
#anvi-merge SAMPLE-01/PROFILE.db SAMPLE-02/PROFILE.db SAMPLE-03/PROFILE.db -o SAMPLES-MERGED -c contigs.db

anvi-merge 490profile/490profile.db 524profile/524profile.db 527profile/527profile.db -o peat-merged-profiles -c peat-contigs.db

```

###### 2) Import bins

Importing bins is done by adding them to an anvi'o collection. A collection in anvi'o comprises one or more bins. They can be imported from an external binner, or bins can be created within anvi'o.

``` {bash eval=FALSE}
#Use case:
anvi-import-collection binning_results.txt -p SAMPLES-MERGED/PROFILE.db -c contigs.db --source "SOURCE_NAME"
#source name is sample ecotype, for example Peat Bog Pelsa, Medium Depth.

#binning_results.txt is an output of dastool: DASTool_contig2bin.tsv
#File contains two columns: a contig name, and the bin name it belongs to.

anvi-import-collection formatted_dastool_contigs2bins.tsv -p peat-merged-profiles/PROFILE.db -c peat-contigs.db  --contigs-mode --collection-name PeatTechReps

#Additionally, to show all bins and collections in your contigs database, use anvi-show-collections-and-bins -p peat-merged-profiles/PROFILE.db

#If you want to use pretty bin names:
anvi-rename-bins -c peat-contigs.db -p peat-merged-profiles/PROFILE_DB --collection-to-read PeatTechReps --collection-to-write NewCollectionName --prefix PelsaMed --report-file renamed-bins.txt --call-MAGs --dry-run

#--collection-to-read is current (old) name of your collection
#--collection-to-write is new name of collection
#--prefix will be Prefix_XXX_00001, where XXX is MAG if the --call-MAGs switch is used; otherwise it's BINS
#report-file gives you the old-to-new name info in a file
# the --dry-run switch will show output without actually changing anything.
```

###### 3) Estimate Taxonomy.

Using Single Copy Genes to estimate taxonomy, completeness, and redundancy of bins / MAGs.  
https://merenlab.org/2019/10/08/anvio-scg-taxonomy/  

Anvi'o assigns taxonomy to bins / MAGs using the GTDB, the Genome Taxonomy DataBase (Australia), based on the previously-characterized taxonomy of single-copy genes. This database does not include eukaryotes as of 2022. 

Note that Candidate Phyla Radiation bacteria are harder to detect with traditional SCG ribosomal sequence  
Of course, Meren made some machine learning classifiers in anvi'o to help us out:  
https://merenlab.org/2016/04/17/predicting-CPR-Genomes/  

``` {bash eval=FALSE}
#set up databases:
anvi-setup-scg-taxonomy

#analyze your contigs db:
anvi-run-scg-taxonomy -c peat-contigs.db --num-threads 4

#estimate relative abundance of taxa through coverages (coverage = read count*read length / genome size)
	# For the code below, you must CHOOSE ONE:
	#--metagenome-mode for manual binning
	#-C PeatTechReps for a pre-binned metagenome imported as collection

anvi-estimate-scg-taxonomy -c CONTIGS.db -p merged-or-single-profiles/PROFILE.db -C PeatTechReps --metagenome-mode --compute-scg-coverages 

anvi-estimate-scg-taxonomy -c peat-contigs.db -p peat-merged-profiles/PROFILE.db --metagenome-mode --compute-scg-coverages --num-threads 16 --update-profile-db-with-taxonomy > tax-scg-est-per-sample.tsv

#I kept getting error msgs when trying to use the --output-file flags, so I just ported the StOut to a file instead. 

anvi-estimate-scg-taxonomy -c peat-contigs.db -p peat-merged-profiles/PROFILE.db -C PeatTechReps  > tax-scg-est-per-bin.tsv

#Note that unlike the previous command, this command is not done in metagenome mode, because we cannot simultaneously treat contigs.db as metagenome, and also provide it with a collection.

#Important note:
Anvi'o has just finished recovering SCG coverages from the profile database to
estimate the average coverage of your bins across your samples. Please note that
anvi'o SCG taxonomy framework is using only 22 SCGs to estimate taxonomy. Which
means, even a highly complete bin may be missing all of them. In which case, the
coverage of that bin will be `None` across all your samples. The best way to
prevent any misleading insights is take these results with a huge grain of salt,
and use the `anvi-summarize` output for critical applications.
```

###### 4) Completeness and recovery of bins.

See Module 1 for interpreting and acting on bin QC data. 

``` {bash eval=FALSE}
anvi-estimate-genome-completeness -p peat-merged-profiles/PROFILE.db -c peat-contigs.db -C PeatTechReps > qc-bin-est-genome-completeness.tsv

#Redundancy means more than one copy of a SCG appeared in a bin.
#Completeness means what fraction of total SCG for that taxon appear in the bin.

#Reported coverages are raw values for SCG, rather than % coverages. 
#coverage = (read count * read length ) / total genome size
```

###### 5) Anvi-summarize

Aniv-summarize lets you look at a comprehensive overview of your collection and its many statistics that anvi’o has calculated.

https://anvio.org/help/main/programs/anvi-summarize/  
https://merenlab.org/2016/06/22/anvio-tutorial-v2/#anvi-summarize  

You will need one of these files as input in order to visualize taxonomy of bins in the anvi-interactive dendrogram at next step. 

Warning: anvi-summarize will generate fasta files of your original contigs, b/c the summary is intended to give someone everything they need to share a project analysis with others. 32 MB for 4 bins.
You can also use the flag --quick-summary to get a less comprehensive summary with a much shorter processing time and only 1.3 MB, but no convenient bin_summary.txt to use as for viewing taxonomy via --additional-layers. 

--initiate-gene-coverages is computationally intensive, but will provide very accurate coverage info down to per-gene level

--reformat-contig-names will include bin name in contigs, and provide an old-to-new name conversion file


``` {bash eval=FALSE}
anvi-summarize -c peat-contigs.db -p peat-merged-profiles/PROFILE.db -C PeatTechReps -o PeatSummarized --quick-summary --init-gene-coverages --reformat-contig-names
```


###### 6) Visualizing bins on anvi-interactive

``` {bash eval=FALSE}
#Launch anvi-interactive from your Docker image:
anvi-interactive -p peat-merged-profiles/PROFILE.db -c peat-contigs.db -C PeatTechReps --additional-layer Summarize/bins_summary.txt

#Or try this lol if you want to see the fun real-time taxonomy of manual binning, with nucleotide-level inspection enabled (not available in collection mode):
anvi-interactive -p peat-merged-profiles/PROFILE.db -c peat-contigs.db
```

Crash-course for anvi-interactive, and visualization of MAG bins:  
https://astrobiomike.github.io/metagenomics/metagen_anvio  

Detailed manual of anvi-interactive:  
https://merenlab.org/2016/02/27/the-anvio-interactive-interface/  

https://merenlab.org/tutorials/interactive-interface/  
https://anvio.org/help/main/programs/anvi-interactive/  

<br>
<br>
<br>

# Module 1: QC and refinement of bins.

###### 1) Quality control

look at bin coverage, completeness, and redundancy:  
https://merenlab.org/2016/06/09/assessing-completion-and-contamination-of-MAGs/  
See also BVCN tutorial on Bin completeness and redundancy.  
https://genome.cshlp.org/content/25/7/1043  
CheckM paper has good discussion of bin quality.  

See Jill Banfield lab for publications on techniques for uber-refined bins:  
https://geomicrobiology.berkeley.edu/

https://merenlab.org/2016/06/09/assessing-completion-and-contamination-of-MAGs/  
 "Identifying contamination with advanced visualization and analysis practices."  
https://peerj.com/articles/1839/



``` bash {eval=FALSE}
anvi-estimate-genome-completeness -p peat-merged-profiles/PROFILE.db -c peat-contigs.db -C PeatTechReps > qc-bin-est-genome-completeness.tsv

#Bins with more than 10% redundancy are almost certainly containing more than one genome.
#Bins with >90% completion and <10% redundancy are considered good.
```

###### 2) Bin refinement

Comprehensive info on refinement capacity in anvi'o:  
https://merenlab.org/2015/05/11/anvi-refine/  
You should definitely look at bins using anvi-refine even if the Completion/Redundancy numbers are excellent:  
https://merenlab.org/2017/05/11/anvi-refine-by-veronika/  
What SNVs tell us about contamination:  
https://merenlab.org/2017/01/03/loki-the-link-archaea-eukaryota/  
How to refine bins of cultivars:  
https://merenlab.org/2015/06/25/screening-cultivars/  
" Illumina points out that insufficient flushing of HiSeq instruments between runs can lead to a sample carryover rate of 0.05%–0.1%. Additional contamination at this very low detection threshold is also highly likely due to sample handling, including pipetting, gel excision, and airborne droplets produced during opening and closing of PCR strips.
"  
--warning signs of contamination:  
Unusually high number of variants (view by sequence variation), with a narrow distribution of minor allele frequencies (small std deviation compared to what would be expected in the wild).  
--in a re-sequencing experiment, alternate between spike-ins (phiX and pUC18) in alternate wells / lanes / flowcells as a positive control for contamination. Also a nice phylogenetic method for detecting direction of contamination. 

Refining bins when you don't have reads:  
https://merenlab.org/2016/06/06/working-with-contigs-only/
Binning giant viruses:  
https://merenlab.org/2022/01/03/giant-viruses/  
Targeted binning of a novel nitrogen-fixing population from the Arctic Ocean: this one is wow for bioprospecting with anvi'o.  
https://merenlab.org/2021/10/20/targeted-binning-nif-mag  
Evolution of a study on marine microbes:  
https://merenlab.org/2021/09/13/boats-to-bits/  


``` {bash eval=FALSE}
#First make a copy of your existing profile database, because when you refine, and then click 'store refined bins in the database, the profile db is automatically updated.

cp peat-merged-profiles/ peat-merged-profiles-autobin-copy/

anvi-refine -p peat-merged-profiles/PROFILE.db -c peat-contigs.db -C PeatTechReps -b PelsaMed_MAG_00003

# I chose the bins with the highest redundancy and lowest coverage, which coincidentally is also the only bin that is identified at genus rather than species level.
```

Notes on how to manually refine bins:  
--Sample coverage should be pretty steady from one contig to the next within a sample. So the sample layers that show coverage as bar height should look smooth, not jagged.  
--Coverage should not change differently from one sample to the next with a given branch (i.e. for one branch, sample A goes up and sample B goes down). Contig coverage should be consistent PER SAMPLE for a given genome.  
--Deeply basal tips (i.e. far-branching, deeply split) at the edge of the dendogram that are small should be trimmed to see if redundancy score goes down.  
--Inspecting areas to spot check with BLAST search for consistent taxonomy is another way to manually check a branch of the dendrogram to see if it should be pruned.  
--Try re-drawing this with only sequence composition (drop-down option on interactive display).  


How to interpret "imperfect" bins (from Delmont's Lokiarchaea article,https://merenlab.org/2017/01/03/loki-the-link-archaea-eukaryota/):

--High std dev of coverage and high relative number of SNVs ('variability' layer?) compared to genome context suggest additional species diversity in the sample that has not yet been characterized / resolved.  
--Abnormally high variation with normal coverage indicates detection of polymorphism (lots of alleles) WITHIN a genome popultion, which can give insight into subtle ecological roles in a population genome for a given homolog function. (see https://merenlab.org/2015/06/25/screening-cultivars/)  
--Anvi'o cannot fix genome assembly issues, only contamination issues.  

When you're done checking bins, re-run anvi-summarize on the curated profile:

``` {bash eval=FALSE}
anvi-summarize -c peat-contigs.db -p peat-merged-profiles/PROFILE.db -C PeatTechReps -o CuratedSummary
```

Conclusion: I was able to reduce the redundancy of 2 out of 4 bins.

<img src="https://github.com/user-attachments/assets/20cd14d1-bedb-4094-bae1-f5147e7b5fad" align=center width=800 title="Avi-summarize of DAS Tool bins after manual curation">


<br>

# Module 2: Analyze function and metabolic capabilities of bins with anvi-estimate-metabolism

To start with functional analysis, you will want the dev branch of anvi'o:
According to this link, the anvi'o main Docker image is the stable dev branch.
https://merenlab.org/2015/08/22/docker-image-for-anvio/
https://github.com/merenlab/anvio/tree/master/Dockerfiles/anvio-main


https://merenlab.org/tutorials/infant-gut/#functional-enrichment-analyses  
https://anvio.org/help/7/programs/anvi-estimate-metabolism/  
Using anvi-estimate-metabolism to determine whether a nitrogen-fixing bin was heterotroph or cyanobacterium:  
Might need to use dev verson of anvi'o for this, as there is a known issue using this script due to HMMER.  
https://anvio.org/blog/targeted-binning/anvi-run-kegg-kofams  
https://discord.com/channels/1002537821212512296/1044161572685238335  
anvi-compute-functional-enrichment-across-genomes  
anvi-script-pfam-accessions-to-hmms-directory  
anvi-display-functions also needs dev version of anvi'o:  
https://merenlab.org/2016/11/08/pangenomics-v2/#quantifying-functional-enrichment-in-a-pangenome  

Anvi'o uses presence-absence of the function/metabolic module within each genome to calculate the proportion of genomes in each group that has that function/module. The enrichment is then calculated from the group proportions.

If your purpose is to compare the gene clusters (not genomes) that you have already binned, it is recommended to use the program anvi-summarize instead.

Can recover mapping statistics of short reads per geneanvi-profile-blitz.

you could do this by using the search tab in the interactive interface to identify your gene clusters of interest (ie, by searching for a particular COG or KO), adding those gene clusters to one or more bins and saving those bins as a collection, and then (after exiting the interface and going back to your terminal) running the program anvi-split (https://anvio.org/help/7.1/programs/anvi-split/)  to extract that collection of bins into smaller, self-contained databases.

If all you are looking for is information about the genes in those gene clusters, you could also just run anvi-summarize and search for the gene cluster IDs in the resulting output.


////////





