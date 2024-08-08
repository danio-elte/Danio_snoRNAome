### HOW to preprocess data to snoDanio shiny app
- download sra table (filter: total rna zebrafish)
- curate bioproject that contains the snoRNA size-range:
	- filter HiSeq 20000 platform (as ours)
	- exclude polyA mRNA workflows
- make expression file via usegalaxy protocol and a coldata file
- generate .rds object for the db
- add this experiment to the project info table 
 	
