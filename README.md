### ABOUT snoDanio project
This repository from the [danio-elte](https://github.com/danio-elte) lab contains all the code and documentation for the The zebrafish (Danio rerio) snoRNAome paper, which provides a comprehensive database and interactive tools for exploring the zebrafish snoRNAome.

### OVERWIEV
Our database includes RNA sequencing data of different types and from various laboratories, allowing us to study the expression of each snoRNA. For consistency, we align each dataset starting from the raw data and map it to the most recent zv11 genome. We continually expand the transcriptome table with newly annotated snoRNAs and use this updated version for all analyses. We created our own Galaxy pipeline for each type of RNA-seq experiment, ensuring robust and accurate data processing.

### CONTENTS
    -    **data/**: This folder contains the sample .rds file needed for the app.
    -    **projects.csv**: A CSV file listing all the bioprojects included in the database, with metadata such as range, type, and project ID.
    -    **sno_genes.csv**: A CSV file containing information about each snoRNA gene, including its ID, symbol, Rfam family, and related parent gene details.
    -    **scripts/**: Custom scripts used for data processing, alignment, and generating the .rds objects.
    -    **app.R**: The main Shiny app script.
