<br>########################################################################</br>
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
   Script is design to work on any Linux machine with bash/shell language.
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
     -i  | --infile     input file with accession number as a list. Has to have
                        '.lst' extension. Overrides '--dir' option.

     -d  | --dir        Alternative to '-i' option. Does not require any
                        parameters. Searches through current directory.
                        Inferrior to '-i' and cannot be used together with that
                        option.

   Optional:
     -D  | --download   Automatically downloads the files, else it creates
                        script that can be use to download manually
                        (default: OFF)

     -C  | --clean      Automatically remove all intermediate file, else it
                        preserves them (default: OFF)

     -v  | --version    prints current version

     -h  | --help       prints this message

5. Description
    acc2db script takes as input list of accession numbers. The list has to be
    in file and has to have '.lst' extension. Alternatively, instead a file,
    current directory can be provided by passing the '-d' parameter. It does 
    not search recursively (limited depth to one level only). If both, '-d' and
    '-i' are provided, '-i' takes priority. The '-d' parameter allows for more
    than one list to be used as long as it is in the current directory. After
    all lists are read, all duplicated accessions are removed and only unique
    numbers are divided into download lines and saved in 'download_TTTTNN.sh'
    files. Each file has max 300 accession numbers per line, max 500 lines per
    file. TTTT in the name is the file format to download (e.g. gb, gff, asn1,
    json) and NN is the consecutive number. If '-D' parameter is not provided
    the files will be created with instructions inside on hot to run them
    manually. Last line in each file checks if 'check_download' script exists
    in current location, and pass list of accessions, from all lines in the
    file. It will be used for redonload of the record if it was not successful
    in the first round. Each 'download_TTTTNN.sh' file will pull records per 
    all lines and will save them under 'current_dir/ncbi_sl' directory. 
    Successful download and (eventual) download of failed records will be
    mereged into one file 'ncbi_DDD.TTTT' where DDD is the name of the database
    and TTTT is format of files downloaded. If '-C' option is provided it will
    clean up after whole process removing the 'download_TTTTNN.sh' files and
    'current_dir/ncbi_dl' folder leaving only the final file.

6. Personalization
    Some of the defaults can be edited to suit better the needs of the user.
    The defaults that can be adapted are:
    PER_FILE        Divides every N-download lines per file (default 500)
    PER_LINE        No. of accession numbers downloaded at once per line
                    (default 300). Do not exceed over 300 else it will block
                    the connection to NCBI and you will end with many failed
                    downloads
    DB                NCBI database to download from: nuccore, protein, pubmed
                    (default 'nuccore')
    TYPE            database format: gb, gff, asn1, json (default 'gb')
    MODE            database mode: text, summary (default 'text')
    OUT				output directory name (default 'current_dir/ncbi_dl')

