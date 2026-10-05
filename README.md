Wheat Mutation Mapping Using Skim-seq
This repository contains scripts, workflows, and supporting data for mutation mapping in wheat using ultra-low-coverage skim-sequencing (skim-seq). The mutant populations were generated in Jagger and Chinese Spring (CS) wheat backgrounds by Prof. Vijay Tiwari's group at the University of Maryland. The sequencing was performed in the Poland Lab at Kansas State University.
Population and Sequencing
The dataset includes:
•	794 mutant lines in the Jagger background, together with 3 non-mutant Jagger control lines.
•	The Jagger population was sequenced at an average coverage of approximately 0.031×. Of the 794 mutant lines, 747 had ≥0.01× sequencing coverage.
•	An additional 60 mutant lines were generated in the Chinese Spring (CS) background and included in the mutation-mapping dataset.
Objective
The primary objective of this project is to use ultra-low-coverage skim-seq data to genotype the mutant lines and identify genomic regions associated with the mutant phenotypes. The mutant lines are expected to carry genomic changes such as deletions, duplications, and other structural or copy-number changes.
The two genetic backgrounds were analyzed separately using their corresponding reference genomes:
•	Jagger mutant population: reads were mapped to the newer Jagger reference genome developed at the University of Maryland.
•	Chinese Spring mutant population: reads were mapped to the Chinese Spring (CS) reference genome v2.0.
Separating the populations and using their corresponding reference genomes allows the analysis to account for differences in genetic background and reference-genome structure.
Data and Analysis
The repository provides the computational scripts, workflows, and supporting files used to process the skim-seq data and perform downstream mutation-mapping analyses. The workflow includes raw read processing for QC, trimming, alignment to the appropriate wheat reference genome, and identification of mutant regions potentially associated with
<img width="468" height="647" alt="image" src="https://github.com/user-attachments/assets/77452c97-6b6b-4e35-aa59-256af8423881" />
