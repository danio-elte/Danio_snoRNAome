
### ANNOTATION OF NEW SNORNAS

after download seqs from galaxy (results of the snorna annotation workflow) run snoRNA finders
- snoscan - use online version
- snoGPS - use local linux
- snoreport - run local
- cmsearch - run in galaxy

run the merge-\*scripts to collect ids that predicted as snoRNA by all predictor

\$ *python3 merge-sno-res-HACA.py ./our-plus-time-set-bowtie2/new-HACA-snoreport2.out ./our-plus-time-set-bowtie2/new-HACA-snoGPS-both.out ./our-plus-time-set-bowtie2/new-sno-sca-minusSNORD-cmsearch.csv*

\$ *python3 merge-sno-res-CD.py ./our-plus-time-set-bowtie2/new-CDsnorna-snoreport2.out ./our-plus-time-set-bowtie2/new-both-CDsnorna-snoscan.out ./our-plus-time-set-bowtie2/new-sno-sca-minusSNORA-cmsearch.csv*
 you get a fasta and a bed file with info about new non-ensemble snoRNAs sequences and locations

\$ *python3 collect-best-sequences.py*

 download rnacentral-v17 danio_rerio.GRCz11.bed and find the non-overlap candidates
 
\$ *bedtools window -w 10 -v -a new.bed -b danio_rerio.GRCz11.bed > not-in-rnacentral.bed*

 find the not-snoRNA-overlap candidates step 1: collect all sequences that overlaps (-u)
 
\$ *bedtools window -w 10 -a new.bed -b danio_rerio.GRCz11.bed > in-rnacentral-new.bed*

 select candidates that not annotated as snoRNA 
 
\$ *awk '$20 == "snoRNA" {print $4}' in-rnacentral-new.bed > known_as_snoRNA.bed*

 find all new snorNA transcript/genes
 
\$ *bedtools subtract -A -a in-rnacentral-new.bed -b known_as_snoRNA.bed > known_but_not_as_snoRNA.bed*

\$ *cat not-in-rnacentral-new.bed known_but_not_as_snoRNA > all_new_snoRNA.bed*

\$ *awk '{ print $1, $2, $3, $4, $5,  $6 }' all_new_snoRNA.bed > all_new_snoRNA_first6col.bed*

\$ *sort  all_new_snoRNA_first6col.bed | uniq > dedup_all_new_snoRNA_first6col.bed*

 append known as snoRNA to new uniq snoRNAs by hand > new-67-snorna.csv
  
  download gtf file from ens
 
 find parent genes if existed
 
\$ *bedtools intersect -loj -a dedup_all_new_snoRNA_first6col.bed -b Danio_rerio.GRCz11.104.chr.gtf > find_host_genes.bed*

\$ *bedtools intersect -wo -a dedup_all_new_snoRNA_first6col.bed -b Danio_rerio.GRCz11.104.chr.gtf > only_found_host_genes.bed*

 host gene biotype
\$ *awk '($9 == "gene"){print $24}' only_found_host_genes.bed | sort -n | uniq -c*

\$ * bedtools subtract -A -r -f 0.90 -a danio_rerio.GRCz11.bed -b Danio_rerio.GRCz11.104.chr.gtf > rnacentral-minus-ens104.bed12*

 add columns to dedup_all_new_snoRNA_first6col.bed rnacentral-minus-ens104.bed12 and to get gtf file (in excel) and expand the annotation
 
\$ *cat Danio_rerio_GRCz11.104.chr.gtf > expanded_GRCz11-104-annotation.gtf*

\$ *cat new.gtf >> expanded_GRCz11-104-annotation.gtf*

 create a table for database to show parent genes
 
 get all snoRNA gene
 
\$ *awk '$3 == "gene" {print $1,"\t",$2,"\tgene\t",$4,"\t",$5,"\t.\t",$7,"\t.\t"$9,$10}' zfish-snornaome.gtf > sno-gene-data.gtf*

\$ *change space-tab-space to only tab*

 append parent and sdRNA genes
 
\$ *bedtools intersect -wao -b sno-gene-data.gtf -a Danio_rerio.GRCz11.104.chr.gtf -F 0.9 > sno-genes-data-parent.gtf*

\$ *bedtools intersect -wao -a sno-gene-data.gtf -b Danio_rerio.GRCz11.104.chr.gtf -F 0.9 > sno-genes-data-sd.gtf*

\$ *awk '{if ($3 == "gene" && $21 == "gene" && $18 !~ /snoRNA/ && $10 != $28) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$13,$14,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28}' sno-genes-data-parent.gtf > parent.gtf*

\$ *awk '{if ($3 == "gene" && $13 == "gene" && $28 != "\"snoRNA\";" && $26 != "\"snoRNA\";" && $10 != $20 ) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$23,$24,$25,$26,$27,$28}'*

\$ *sno-genes-data-sd.gtf > sdRNA.gtf*

 create one table with parent info
 
\$ *awk {'print $6'} parent-final-genes.csv | sort | uniq > parented.csv*

\$ *awk {'print $10'} sno-gene-data.gtf | sort | uniq > all.csv*

\$ *comm -23 all.csv parented.csv > non-parented.csv*

\$ *grep -f non-parented.csv sno-gene-data.gtf | awk {'print $1,$2,$4,$5,$7,$10,"- - -"'} >> parent-final-genes.csv*



### VALIDATE PREDICTORS 

 run all predictor for extracted ens104 snoRNA sequences (from galaxy pipeline)
 
\$ *python3 merge_verify.py snoscan_CD_old.out snoGPS_HACA_old.out cmsearch.tabular*



### ADDITIONAL SCRIPTS

 you can find scripts for generating figures
