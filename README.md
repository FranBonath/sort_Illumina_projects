# sort_Illumina_projects
A simple R script to identify Illumina finished library projects that could be a candidate for pre-sequencing ONT QC.

## Running the script
After the function `sort_project` has been loaded it is used as follows:
[output variable] <- sort_project([input…data] [sequencing setups] [options])

## Input
### data
It assumes a data input file with the following headers:

Project
Project Name
Type
Application
Samples
Library Construction Method
library_type_(ready-made_libraries)
Dual index (Y/N)
UDI (Y/N)
Contain EDTA (Y/N)
Pool conc (nM)
Pool volume (uL)
Custom library (Y/N)
Single stranded lib (Y/N)
Sequencing Platform
Flowcell
Sequencing Setup
Lanes

### sequencing setups
Furter, it requires a description of all sequencing setups in the data dataframe as a dataframe with these headers:
Sequencing.Platform
Flowcell
seq_reads

whereas Sequencing.Platform and Flowcell are to be the same as in the data input and seq_reads is the amount of reads expected as output in Millions. For example a Nextseq 2000 P1 flowcell would return 100 Million reads.

## Parameters
These are parameters and their defaults. The values can be changed in the script by adding them to the function call:
name_outfile="result_sort_projects"   # this is the basename of all output files
max_samples=1000                      # maximum number of samples allowed in the Illumina pool
min_vol=10                            # Minimum volume an Illumina pool has to have
used_fmol_ONT=100                     # fmole used as input in the ONT QC library prep
min_tot_cycles=175                    # required amount cycles ordered by the user
min_Ill_runs_possible=2               # requird amount of Illumina 25B runs that would still be possible after ONT QC has been performed. 
Ill_req_ul=40                         # Required ul for an Illumina 25B lane, single run (used as basis for standard Illumina input)
Ill_req_nM=10                         # Required nM for an Illumina 25 lane, single run (used as basis for standard Illumina input)
output_25B_lane=3000                  # expected output of a 25B lane (used to calculate min_Ill_runs_possible)
min_25_perc=12.5                      # Minimum %age of a 25B lane the user run has to have ordered 

## Output
### report
The report will tell 
(1) how many projects fulfilled the criteria
(2) lists all criteria used

### table
The table will contain the un-trimmed list of all projects that fulfilled the criteria

### command line output
The report and a trimmed project list will be printed to the screen.


