########################################################################
SYNOPIS:
    Scripts for automatic download genbank records based on file with
    list of accessionn numbers (or directory with those files).
    The files have to have '.lst' extension. Furthermore it allows to 
    dived the genbank files into genes and genome sequences and taxonomy
    table adapted for blast or qiime2 classifier analysis.
########################################################################

DATE:    01.07.2025
VERSION: 1.0
CREATOR: T.J.SANKO
ADDRESS: Stellenbosch University, Tygerberg Campus,
         Francie van Zijl Drive, Cape Town, South Africa
CONTACT: tjsanko@sun.ac.za

1. Requirements
   Script is design to work on any linux machine with bash/shell language. 
   It was tested on CentOS7 and Ubuntu SMP 24.04.2.

2. Installation
   Uses basic bash/shell commands. Does not require any additional installation.
   May require changing permissions after downloading to linux/unix environment
   chmod +x *.sh

3. Syntax
   ./acc2db.sh -i file.lst -D -C

   or alternative:
   ./acc2db.sh --dir -D -C

4. Options:
   Required:
   -i  | --infile     input file with accession number as a list. Has to have '.lst' extension.
                      Overrrides '--dir' option.
   -d  | --dir        Alternative to '-i' option. Searches through current directory. Inferrior
                      to '-i'  and cannot be used together with '-i' option.

   Optional:
   -D  | --download   Automatically downloads the files, else it creates script that can be use to download
                      manually (default: OFF)
   -C  | --clean      Automatically remove all intermediate file, else it preserves them (default: OFF)
   -v  | --version    prints current version
   -h  | --help       prints this message

5. Synopis
   

