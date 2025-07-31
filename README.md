<p><h3>DESCRIPTION:</h3>
&emsp;Scripts for automatic download genbank records based on file with list of accessionn numbers (or directory with those files).</br>
&emsp;The files have to have '.lst' extension. Furthermore it allows to dived the genbank files into genes and genome sequences</br>
&emsp;and taxonomy table adapted for blast or qiime2 classifier analysis.</p>
</body>
<p>
&emsp; DATE:   &emsp; &emsp; &nbsp;01.07.2025<br />
&emsp; VERSION:&emsp; 1.0<br />
&emsp; CREATOR:&emsp; T.J.SANKO<br />
&emsp; ADDRESS:&emsp; Stellenbosch University, Tygerberg Campus,<br />
        &emsp; &emsp; &emsp; &emsp; &emsp; &nbsp; Francie van Zijl Drive, Cape Town, South Africa<br />
&emsp; CONTACT:&emsp; tjsanko@sun.ac.za<br />

<h3>1. Requirements</h3>
&emsp; Script is design to work on any Linux machine with bash/shell language.</br>
&emsp; It was tested on CentOS7 and Ubuntu SMP 24.04.2.</br>

<h3>2. Installation</h3>
&emsp; Uses basic bash/shell commands. Does not require any additional installation.</br>
&emsp; May require changing permissions after downloading to linux/unix environment</br>
&emsp; <pre>chmod +x *.sh</pre>

<h3>3. Syntax</h3>
<code>./acc2db.sh -i file.lst -D -C</code><br>
&ensp;or alternative:<br />
<pre>&emsp;./acc2db.sh --dir -D -C</pre>

<h3>4. Options</h3><pre>
  <b>Required:</b>
    -i | --infile       input file with accession number as a list. Has to have
                       '.lst' extension. Overrides '--dir' option.</br>
    -d | --dir          Alternative to '-i' option. Does not require any
                        parameters. Searches through current directory.
                        Inferrior to '-i' and cannot be used together with that
                        option.
  <b>Optional:</b>
    -D | --download     Automatically downloads the files, else it creates
                        script that can be use to download manually
                        (default: OFF)</br>
    -C | --clean        Automatically remove all intermediate file, else it
                        preserves them (default: OFF)</br>
    -v | --version      prints current version</br>
    -h | --help         prints this message
</pre>

<h3>5. Description</h3>
&emsp; acc2db script takes as input list of accession numbers. The list has to be in file and has to have '.lst' extension. </br>
&emsp; Alternatively, instead a file, current directory can be provided by passing the '-d' parameter. It does not search </br>
&emsp; recursively (limited depth to one level only). If both, '-d' and '-i' are provided, '-i' takes priority. The '-d'</br>
&emsp; parameter allows for more than one list to be used as long as it is in the current directory. After all lists are read,</br>
&emsp; all duplicated accessions are removed and only unique numbers are divided into download lines and saved in</br>
&emsp; 'download_TTTTNN.sh' files. Each file has max 300 accession numbers per line, max 500 lines per file. TTTT in the name</br>
&emsp; is the file format to download (e.g. gb, gff, asn1, json) and NN is the consecutive number. If '-D' parameter is not</br>
&emsp; provided the files will be created with instructions inside on hot to run them manually. Last line in each file checks</br>
&emsp; if 'check_download' script exists in current location, and pass list of accessions, from all lines in the file. It will</br>
&emsp; be used for redonload of the record if it was not successful in the first round. Each 'download_TTTTNN.sh' file will</br>
&emsp; pull records per all lines and will save them under 'current_dir/ncbi_sl' directory.&nbsp; Successful download and</br>
&emsp; (eventual) download of failed records will be mereged into one file 'ncbi_DDD.TTTT' where DDD is the name of the</br>
&emsp; database and TTTT is format of files downloaded. If '-C' option is provided it will clean up after whole process</br>
&emsp; removing the 'download_TTTTNN.sh' files and 'current_dir/ncbi_dl' folder leaving only the final file.</br>

<h3>6. Personalization</h3>
&emsp;Some of the defaults can be edited to suit better the needs of the user.<br />
&emsp;The defaults that can be adapted are:</br>

<table style="width:100%"> 
<tr><td>PER_FILE</td><td>Divides files in N-download lines per file (default 500)</td></tr>
<tr><td>PER_LINE</td><td>No. of accession numbers downloaded at once per line (default 300). Do not exceed over 300 else it will block the connection to NCBI and you will end with many failed downloads</td></tr>
<tr><td>DB </td><td>NCBI database to download from: nuccore, protein, pubmed (default 'nuccore')</td></tr>
<tr><td>TYPE</td><td>database format: gb, gff, asn1, json (default 'gb')</td></tr>
<tr><td>MODE</td><td>database mode: text, summary (default 'text')</td></tr>
<tr><td>OUT</td><td>output directory name (default 'current_dir/ncbi_dl')</td></tr>
</table></p></br>
