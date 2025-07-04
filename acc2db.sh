#!/bin/env bash

########################################################
###  Script to download different types of records from
###  NCBI database. Utulizes list of accession numbers
###  provided in one column file with LST extension
###  if no file is passed, it searches through current
###  directory for the list files
###  runs on Linux/Unix systems only
###
###  usage: ./acc2db.sh file.lst
###         '-h' or '--help' as argument prints usage
###
###  Date:01.07.2025        Created by T.J.Sanko
###                                    (CERI SA)
###
########################################################
VER='1.0'
if ! [[ `uname -s` == 'Linux' ]]; then echo -e "\n\tYou need to run it on Linux machine\n" && exit 2; fi

USAGE="
 +===================================================================+
 |Syntax:                                                            |
 |        $0 -i file.lst -D -C                              |
 |        $0 --dir                                          |
 +===================================================================+
 |Required:                                                          |
 |                                                                   |
 | -i  | --infile     input file with accession number as a list.    |
 |                    Has to have '.lst' extension                   |
 |                                                                   |
 | -d  | --dir        Alternative to '-i' option. Searches through   |
 |                    current directory                              |
 |                                                                   |
 |Optional:                                                          |
 |                                                                   |
 | -D  | --download   Automatically downloads the files, else it     |
 |                    creates script that can be use to download     |
 |                    manually (default: OFF)                        |
 |                                                                   |
 | -C  | --clean      Automatically remove all intermediate file,    |
 |                    else it preserves them (default: OFF)          |
 |                                                                   |
 |                                                                   |
 | -v  | --version    prints current version                         |
 |                                                                   |
 | -h  | --help       prints this message                            |
 |                                                                   |
 +-------------------------------------------------------------------+
"

##############
### DEFAULTS
##############
### working directory
WDIR=`realpath $(pwd) 2>/dev/null`
### Automatic download after scripts created: 1 => ON; 0 => OFF (will require manual run of the download scripts)
DOWNLOAD=0
### Clean up after I am done - delete files it created?: 1 => Yes; 0 => No
CLEAN=0
### Divide every N-lines per file (max 500)
PER_FILE=50
### No. of accession numbers downloaded at once (max. 300)
PER_LINE=300
### NCBI database to download from: nuccore, protein, pubmed
DB='nuccore'
### database format: gb, gff, asn1, json
TYPE='gb'
### database mode: text, summary
MODE='text'
### url fragments
URL_PT1='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db='${DB}'&id=';
URL_PT2='&rettype='${TYPE}'&retmode='${MODE};

### Checking provided parameters
unset INFILES; declare -a INFILES;
while [[ $# -gt 0 ]]; do
 case "$1" in
  -D|--download) echo -e "-> Set to auto-download files"; DOWNLOAD=1;           shift 1;;
  -C|--clean)    echo -e "-> Set to clean-up intermediate files"; CLEAN=1;      shift 1;;
  -i|--infile)   INFILES=(`echo $2 |sed -r 's/.*\s//' | grep -i ".lst"`);       shift 2;;
  -d|--dir)      INFILES=(`find ${WDIR}/ -maxdepth 1 -type f -iname "*.lst"`);  shift 1;;
  -h|--help)     echo -e "${USAGE}"                                           && exit 1;;
  -v|--version)  echo -e "-> Current version: ${VER}"                         && exit 1;;
  *)             echo -e "${USAGE}[ERROR] Unknown parameter [$1]\n"           && exit 2;;
 esac
done

#if [[ $2 =~ ^$ ]]; then i=1; INDIR=${WDIR}; else i=2; INDIR=`realpath $2`; fi;
#  -i=* | --infile=*) INFILES=(`echo $1 | sed -r 's/.*=//' | grep -i ".lst"`); shift 1;;
### output directory
OUT=${WDIR}'/ncbi_dl'
mkdir -p -m a=rwx ${OUT}

##############
### CHECKUPS
##############
### checking up on LST files
unset ACCLST; declare -a ACCLST
for INFILE in ${INFILES[@]}; do
  NLINE=`cat ${INFILE} | wc -l`
  if [[ ${NLINE} -eq 0  && ${#INFILES[@]} -eq 1 ]]; then echo -e "=> File ${INFILE} is empty" && exit 2; fi;
  echo -e "-> File ${INFILE}\thas ${NLINE} accession numbers";
  ACCLST=(${ACCLST[@]} `cat ${INFILE}`)
done
if [[ ${#ACCLST} -eq 0 ]]; then echo -e "[ERROR] The list files are empty" && exit 2; fi;

### checking for parallel avilability
MULTI_THREADING=0
NTHR=1
PARALLEL_VER=`parallel --version | grep -Ei 'GNU parallel' | head -n1 | cut -d ' ' -f3`
if [[ ! -z ${PARALLEL_VER} ]]; then
 NPROC=`/bin/nproc`;
 if [[ ${NPROC} -gt 4 ]]; then NTHR=$((${NPROC}/2)); MULTI_THREADING=1; echo -e "-> Using parallel v${PARALLEL_VER}"; fi
fi

### checking amout of accession numbers per line (max 300)
if [[ ${PER_LINE} -gt 300 ]]; then echo -e "-> setting accessions amount to max 300 per line"; PER_LINE=300; fi

### estimating no. of files
NFILES=$(($((${#ACCLST[@]} / $((${PER_FILE} * ${PER_LINE})))) +1))

##############
### PROGRAM
##############
### zeroes
Z=$(for i in $(seq 0 $((`echo -n ${NFILES} | wc -c` -1)) ); do echo -n '0'; done);

### lines initial count
L=1
### accession number initial count
S=0
### files initial count
I=1
### line initial number
LN=1

### reformatting accession list to dictionary
if [[ -e "/tmp/lines.tmp" ]]; then rm -f /tmp/lines.tmp; fi
unset LINE ACCDIC TMP; declare -A ACCDIC; declare -A TMP;
for ACC in ${ACCLST[@]}; do
 if [[ -n ${TMP[$ACC]} ]]; then continue; fi
 if [[ ${S} -eq ${PER_LINE} ]]; then
  ACCDIC[$L]=`echo ${LINE} | sed -r 's/\,$//'`;
  echo ${L} >>/tmp/lines.tmp;
  unset LINE;
  S=0;
  ((L++));
 fi
 LINE+="${ACC},";
 TMP[$ACC]=1;
 ((S++))
done
ACCDIC[$L]=`echo ${LINE} | sed -r 's/\,$//'`;

### initialize first files
SHFILE=${WDIR}"/download_${TYPE}${Z}${I}.sh";
DBFILE=${OUT}"/download_${TYPE}${Z}${I}.${TYPE}";
unset TMP;
for N in $(sort -n /tmp/lines.tmp); do
  if [[ ${LN} -gt ${PER_FILE} ]]; then
     ### appending to the bottom of the file download checking function
     echo -en "if [[ -e \"${WDIR}/check_download.sh\" ]]; then\n eval ${WDIR}/check_download.sh ${DBFILE} ${PER_LINE} ${OUT} ${DB} ${TYPE} ${MODE} '" >>${SHFILES}
     echo -en `echo ${TMP} | sed -r 's/,$//'`"';\nfi" >>${SHFILE}
     chmod a=rwx ${SHFILE}
    
     ### naming new download files
    ((NFILES--)); ((I++)); unset TMP;
    Z=$(for i in $(seq 0 $((`echo -n ${NFILES} | wc -c` -1)) ); do echo -n '0'; done);
    SHFILE=${WDIR}"/download_${TYPE}${Z}${I}.sh"
    DBFILE=${OUT}"/download_${TYPE}${Z}${I}.${TYPE}";

    ### restarting line count
    LN=1
  fi

  if [[ ${LN} -eq 1 ]]; then
   ### screen print outs
   echo -e "-> Creating download file:"
   echo -e "   ${Z}${I}] download_${TYPE}${Z}${I}"
  fi

  if [[ ${DONWLOAD} -eq 0 && ${LN} -eq 1 ]]; then
    echo -e "# to run manual download: eval ${SHFILE} &" >${SHFILE};
  fi

  ### screen print outs
  echo -e "echo \"   - file: download_${TYPE}${Z}${I}\tline number: $N\"" >>${SHFILE}
  echo -e "sleep 1s" >>${SHFILE}

  ### download line
  echo -e " curl -N -# '${URL_PT1}${ACCDIC[$N]}${URL_PT2}' >> ${DBFILE}" >>${SHFILE};
  TMP+="${ACCDIC[$N]},"
  echo -e "\t...line number ${LN}";
  ((LN++))
done
rm -f /tmp/lines.tmp

### appending to the bottom of the file download checking function
echo -en "if [[ -e \"${WDIR}/check_download.sh\" ]]; then\n eval ${WDIR}/check_download.sh ${DBFILE} ${PER_LINE} ${OUT} ${DB} ${TYPE} ${MODE} '" >>${SHFILE}
echo -en `echo ${TMP} | sed -r 's/\,$//'`"';\nfi" >>${SHFILE}
chmod a=rwx ${SHFILE}

################
### Downloading
################
if [[ ${DOWNLOAD} -eq 1 ]]; then
 echo -e "-> Downloading..."
 if [[ ${MULTI_THREADING} -eq 1 ]]; then ls ${WDIR}/download_*.sh | parallel -j ${NTHR} -n 1 -I % "eval %"; fi
 if [[ ${MULTI_THREADING} -eq 0 ]]; then for SH in $(ls ${WDIR}/download_*.sh); do echo eval ${SH}; done; fi

 ### splitting each character with a space in DB name
 D=(`echo ${DB} | sed -r 's,(\w),\1 ,g'`)
 ONAME='ncbi_'${D[0]}${D[1]}${D[2]}'.'${TYPE}
 cat ${OUT}/*.${TYPE} >>${ONAME}

 ### Checking for missing accessions
 if [[ -e "${WDIR}/check_download.sh" ]]; then
   echo -e "-> Checking for failed downloads..."
   for N in ${!ACCDIC[@]}; do
     eval ${WDIR}/check_download.sh  ${ONAME} ${PER_LINE} ${OUT} ${DB} ${TYPE} ${MODE} "${ACCDIC[$N]}"
   done
 fi

 if [[ ${CLEAN} -eq 1 ]]; then rm ${WDIR}/download_*.sh; rm -fr ${OUT}; fi
fi

echo -e "-> DONE!";

exit 0;
