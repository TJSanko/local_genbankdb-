#!/bin/env bash

########################################################
###  Script to download missing records from NCBI
###  database. Utulizes list of accession numbers
###  provided as coma separated values. Requires:
###  - input file with potentially missing downloads
###  - amount sequences per line (max 300)
###  - output folder to write to
###  - NCBI database name: nuccore, protein, pubmed
###  - database format: gb, gff, asn1, json
###  - database mode: text, summary
###  - coma separated list of accessions
###
###  runs on Linux/Unix systems only
###
###  usage:
###  ./check_download.sh file.gb 300 ./ncbi_dl 'nuccore' 'gb' 'text'
###
###  Date:01.07.2025        Created by T.J.Sanko
###                                    (CERI SA)
###
########################################################
if ! [[ `uname -s` == 'Linux' ]]; then echo -e "\n\tYou need to run it on Linux machine\n" && exit 2; fi


### File with downloaded NCBI records
INNCBI=$1

### No. of accession numbers downloaded at once (max. 300)
PER_LINE=$2

### output directory
OUT=$3

### NCBI database to download from: nuccore, protein, pubmed
DB=$4

### database format: gb, gff, asn1
TYPE=$5

### database mode: text, summary
MODE=$6

### Coma separated list of accession numbers
INACC=$7

##############
### DEFAULTS
##############
### working directory
WDIR=`realpath $(pwd) 2>/dev/null`

##############
### CHECKUPS
##############
if ! [[ ${INNCBI} =~ [a-zA-Z]+ || -e ${INNCBI} ]]; then echo -e "\nFile ${INNCBI} is empty or does not exist" && exit 2; fi
if ! [[ -e ${OUT} ]]; then echo -e "\nOutput doe not exist. Using temporary one"; OUT=${WDIR}'/tmp_dl'; mkdir -p -m ${OUT}; fi 
if ! [[ `echo ${DB}   | grep -Ei "nuccore|protein|pubmed"` ]]; then DB='nuccore'; fi
if ! [[ `echo ${TYPE} | grep -Ei "gb|gff|asn1|json"`       ]]; then TYPE='gb'; fi
if ! [[ `echo ${MODE} | grep -Ei "text|summary"`           ]]; then TYPE='text'; fi

if [[ ${PER_LINE} -gt 300 || ${PER_LINE} =~ ^$ || ! ${PER_LINE} =~ [0-9]+ ]]; then PER_LINE=300; fi
if [[ ${PER_LINE} -eq 0 ]]; then PER_LINE=1; fi
if [[ ! ${INACC} =~ [a-zA-Z]+ || ${INACC} =~ ^$ ]]; then echo "No accession numbers were provided" && exit 2; fi

URL_PT1='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db='${DB}'&id=';
URL_PT2='&rettype='${TYPE}'&retmode='${MODE};

##############
### PROGRAM
##############
unset ACCLST MISSING;
declare -a ACCLST=(`echo $INACC | tr ',' " "`)

for ACC in ${ACCLST[@]}; do
  if [[ `cat ${INNCBI} | grep ${ACC}` ]]; then continue; fi
  MISSING+="${ACC} "
done

### donwloading missing accessions
if [[ ${MISSING} =~ [a-zA-Z]+ ]]; then
  S=0; TMP="";

  SHFILE=${WDIR}"/download_missing.sh"
  DBFILE=${OUT}"/download_missing.${TYPE}";
  for M in ${MISSING}; do
    if [[ ${S} -eq ${PER_LINE} ]]; then
      ### screen print outs
      echo -e "echo \"   - file: download_${TYPE}${Z}${I}\tline number: $N\"" >>${SHFILE}
      echo -e "sleep 1s" >>${SHFILE}
      echo -e "curl -N -# '${URL_PT1}`echo ${TMP} | sed -r 's/\,$//'`${URL_PT2}' >> ${DBFILE}" >>${SHFILE};
      S=0;
     fi
   done

   if [[ -e "${SHFILE}" ]]; then eval ${SHFILE}; fi
   if [[ -s "${DBFILE}" ]]; then cat ${DBFILE} >>${INNCBI}; fi
 fi

 exit 0;
