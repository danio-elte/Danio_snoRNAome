library(shiny)
library(plotly)
library(shinythemes)
library(ggplot2)
library(DESeq2)
library(BiocManager)
library(DT)  # Required for capturing click events on DataTables
options(repos = BiocManager::repositories())

projects <- read.csv("projects.csv", sep=';', header=T)
genes <- read.csv("sno_genes.csv", sep=';', header=T)
filelist <- list.files("data", pattern = ".*.rds", full.names = T)
project_ids <- substr(gsub('.rds', "", filelist), 6, 20)
#for (i in 1:length(filelist)) assign(project_ids[i], readRDS(filelist[i]))
size_ranges <- as.factor(projects$range)
types <- as.factor(projects$type)

ui <- fluidPage(theme = shinytheme("cosmo"),
                tags$head(
                  tags$style(HTML("
      .centered-image {
        display: block;
        margin-left: auto;
        margin-right: auto;
      }
    "))
                ),
                navbarPage(title= tags$div(
                  tags$span(
                    tags$img(src = "danio.png", height = "35px", style = "margin-right: 10px; vertical-align: middle;"),
                    "snoDanio: the zebrafish snoRNAome database",
                    style = "display: inline-flex; align-items: center;")),
                  tabPanel(title="About",
                           tags$div(
                             tags$span(
                               tags$img(src = "snoDanio_Figure_1.png", height = "350px", class = "centered-image"),
                               uiOutput(style = "font-size: 20px; color: black; text-align: center;",
                                        "snorna_desc_1"),
                               style = "display: auto; align-items: center;")),
                           tags$div(
                             tags$span(
                               tags$img(src = "snoDanio_Figure_2.png", height = "350px", class = "centered-image"),
                               uiOutput(style = "font-size: 20px; color: black; text-align: center;",
                                        "snorna_desc_2"),
                               style = "display: auto; align-items: center;")),
                           tags$div(
                             tags$span(
                               tags$img(src = "snoDanio_Figure_3.png", height = "400px",  class = "centered-image"),
                               uiOutput(style = "font-size: 20px; color: black; text-align: center;",
                                        "about_alt"),
                               style = "display: auto; align-items: center;")),
                           uiOutput(style = "font-size: 20px; color: black; text-align: left;",
                                    "details"),
                           ),
                           #tabPanel(title="Zebrafish snoRNA similarity tree"),
                           tabPanel(title="Description of snoRNAs",
                                    sidebarPanel(
                                      h4("Details Panel"),
                                      h5("Please select a gene from the table!"),
                                      uiOutput("selected_info"),
                                      # Download button
                                      uiOutput("button")
                                    ),
                                    mainPanel(
                                      dataTableOutput("dynamic"),
                                    )),
                           tabPanel(title="Explorer",
                                    sidebarPanel(
                                      selectInput("range", "Select a sequenced size-range:", unique(size_ranges), selected = "total"),
                                      selectInput("type", "Select an experiment-type:", unique(types), selected = "time"),
                                      uiOutput("project"),
                                      
                                      textInput("gene", "Give me a gene ID:", placeholder = "ENSDARG00000083434", value = "ENSDARG00000083434"),
                                      uiOutput("grouping"),
                                      tableOutput("top5")
                                    ),
                                    mainPanel(
                                      textOutput("sample_info", container = h2),
                                      #textOutput("condition_value"),
                                      #plotlyOutput("plot"),
                                      #plotlyOutput("parent_plot"),
                                      uiOutput("plot_or_message"),
                                      uiOutput("parent_plot_or_message")
                                      #tags$div("Please enter a value other than '-' to display the plot.")
                                      
                                    )),
                           #tabPanel(title="Digital in situ")
                           tags$style(type="text/css",
                                      ".shiny-output-error { visibility: hidden; }",
                                      ".shiny-output-error:before { visibility: hidden; }"
                           )
                ))

server <- function(input, output, session) {
  output$snorna_desc_1 <- renderText("<br><br>Small nucleolar RNAs (snoRNAs) are essential RNA molecules\ 
                                   located in the nucleolus, primarily responsible for guiding \
                                   the chemical modifications of rRNA, tRNA, and snRNA. They are \
                                   categorized into two main families: H/ACA and C/D snoRNAs. \
                                   H/ACA snoRNAs, featuring H (ANANNA) and \
                                   ACA motifs, guide the pseudouridylation activity of dyskerin, \
                                   while C/D snoRNAs,  characterized \
                                   by C (RUGAUGA) and D (CUGA) motifs, \
                                     direct the 2'-O-methylation activity of fibrillarin.<br><br>")
  
  output$snorna_desc_2 <- renderText("<br><br>snoRNAs are further classified\
                                   based on their genomic context into intronic snoRNAs, found within\
                                   introns of host genes, and intergenic snoRNAs, located in independent\
                                   genetic loci. The dysregulation of snoRNAs is implicated in various\
                                   human diseases, including cancer, genetic disorders like Prader-Willi\
                                   Syndrome, and neurodegenerative diseases such as Alzheimer disease. \
                                   This highlights their critical role beyond ribosome biogenesis, emphasizing\
                                   their importance in human health and disease.<br><br>")
  
  output$about_image <- renderImage({
    img <- list(src = "about.png",
                style = "width: 500px; height: auto; display: block; margin-left: auto; margin-right: auto;")
    img})
  
  output$danio_image <- renderImage({
    img <- list(src = "danio.png",
                style = "display: inline-flex; align-items: center;")
    img})
  
  output$about_alt <- renderText( 
  "<br><br>The snoDanio database pools previously available datasets, with newly acquired sequencing data\
   to create a comprehensive list of zebrafish snoRNAs, complemented with both snoRNA and host genes\
    expression profiles in the examined datasets.<br><br>")
  
  output$details <- renderText("
<br><b>Key Features:</b>
<br>1. <b>Comprehensive Annotation:</b> snoDanio provides detailed annotations of snoRNAs in the zebrafish genome, including genomic coordinates, sequences, secondary structures, and potential target RNAs.
<br>2. <b>Integration of Known and Newly Annotated snoRNAs:</b> The database integrates known snoRNAs from public repositories with newly annotated snoRNAs identified through computational approach, facilitating the discovery of novel snoRNAs in zebrafish.
<br>3. <b>Functional Annotations:</b> Where available, functional annotations and potential biological roles of snoRNAs are provided, including their targets for guiding RNA modifications such as methylation and pseudouridylation.
<br>4. <b>Search and Retrieval:</b> Users can search and retrieve snoRNAs based on various criteria, such as genomic coordinates, sequence similarity, and associated gene identifiers.
<br>5. <b>Data Visualization:</b> snoDanio offers interactive visualization tools for exploring snoRNA distributions across the zebrafish genome, identifying genomic clusters, and visualizing RNA secondary structures.
<br>6. <b>Downloadable Data:</b> All data in snoDanio are freely accessible and available for download in standard formats, enabling further analysis and integration with other genomic and transcriptomic datasets.
<br>
<br><b>Reference:</b>
<br>Hamar and Varga, The zebrafish (<i>Danio rerio</i>) snoRNAome [Link]")
  
  output$grouping <- renderUI({
    choices <- strsplit(as.character(projects[projects$project==input$project, "type"]), " or ")
    clist <- c()
    for (i in choices){ 
      clist[i] <- i }
    radioButtons("grouping", "Select a grouping factor:", choices = clist)
  })
  
  output$project <-  renderUI({
    project_ids <- projects[ which(projects$type ==input$type
                                   & projects$range == input$range),]
    project_ids <- as.vector(project_ids$project)
    selectInput("project", "Select a dataset:", unique(project_ids), selected = "PRJNA330616")})
  
  output$sample_info <- renderText({paste0(as.character(subset(projects, project==input$project, select=title)))})
  
  
  
  df <- reactive({
    dds <- readRDS(paste('./data/', input$project, '.rds' , sep=""))
    choices <- strsplit(as.character(projects[projects$project==input$project, "type"]), " or ")
    if (input$gene %in% rownames(dds)) {
      df <- plotCounts(dds, gene=input$gene, intgroup=unlist(choices), returnData = T)
    } else {df <- NULL}
    return(df)
  })
  
  parent <- reactive({if (nrow(subset(genes, genes[, 1] == input$gene)) == 0) {
    parent <- "-"
  } else {
    parent <- subset(genes, genes[, 1] == input$gene)$parent_id
  }
    return(parent)})
  
  parent_df <- reactive({
    dds <- readRDS(paste('./data/', input$project, '.rds' , sep=""))
    choices <- strsplit(as.character(projects[projects$project==input$project, "type"]), " or ")
    parent_id <- parent()
    if (parent_id %in% rownames(dds)) {
      parent_df <- plotCounts(dds, gene=parent_id, intgroup=unlist(choices), returnData = T)
    } else {parent_df <- NULL}
    return(parent_df)})
  
  # Check if the dataset is empty
  dataset_empty <- reactive({
    is.null(df()) || nrow(df()) == 0
  })
  
  # Render plot or custom message based on dataset availability
  output$plot_or_message <- renderUI({
    if (!dataset_empty()) {
      tagList(plotlyOutput("plot"))
    } else {
      tags$div("The ", input$gene, " is not significantly expressed in the bioproject", input$project, style = "color: red;")
    }
  })
  
  # Render the plot
  output$plot <- renderPlotly({
    ggplotly(ggplot(df(), aes(get(input$grouping), count, fill=get(input$grouping)), xlab="statistics",ylab="random numbers") + 
               stat_boxplot(geom = "errorbar", width=0.5, position = position_dodge(1)) +
               geom_boxplot(position = position_dodge(1), outlier.shape = NA) + 
               ggtitle(paste("Expression plot of", input$gene, "from the bioproject", input$project, sep= " ")) +
               xlab("Groups") + ylab("Normalised counts") + 
               theme(
                 plot.title = element_text(size = rel(1.5), face="italic", lineheight = 1.9),
                 axis.title.x = element_text(size = rel(1.2), face="italic"),
                 axis.title.y = element_text(size = rel(1.2), face="italic"),
                 axis.text = element_text(size = rel(1.2)),
                 legend.position = "none"
               ))
  })
  
  # Reactive expression to track whether the plot is available
  plot_available <- reactive({
    if (nrow(subset(genes, genes[, 1] == input$gene)) == 0) {
      return(FALSE)
    } else {
      return(TRUE)
    }
  })
  
  # Render the condition value in the UI
  output$condition_value <- renderText({
    parent
  })
  
  parent_dataset_empty <- reactive({
    is.null(parent_df()) || nrow(parent_df()) == 0
  })
  
  output$parent_plot_or_message <- renderUI({
    if (!parent_dataset_empty()) {
      tagList(plotlyOutput("parent_plot"))
    } else {
      tags$div("Custom message when dataset is empty", style = "color: red;")
    }
  })
  
  output$parent_plot <- renderPlotly({
    ggplotly(ggplot(parent_df(), aes(get(input$grouping), count, fill=get(input$grouping)), xlab="statistics",ylab="random numbers") + 
               stat_boxplot(geom = "errorbar", width=0.5, position = position_dodge(1)) +
               geom_boxplot(position = position_dodge(1), outlier.shape = NA) + 
               ggtitle(paste("Expression plot of the parent gene (", parent(), ")", sep= " ")) +
               xlab("Groups") + ylab("Normalised counts") + 
               theme(
                 plot.title = element_text(size = rel(1.5), face="italic", lineheight = 1.9),
                 axis.title.x = element_text(size = rel(1.2), face="italic"),
                 axis.title.y = element_text(size = rel(1.2), face="italic"),
                 axis.text = element_text(size = rel(1.2)),
                 legend.position = "none"
               ))
  })
  
  
  # g <- eventReactive(input$project, {
  #  dds <- readRDS(paste('./data/', input$project, '.rds' , sep=""))
  # genes_in_dds <- rownames(dds)
  #subset(genes, id %in% genes_in_dds)
  #})
  
  #output$dynamic <- renderDataTable({g()}, options = list(pageLength = 3))
  output$dynamic <- renderDataTable({genes[,1:6]}, options = list(pageLength = 10), selection = 'single')
  
  
  res <- eventReactive(input$project, {
    dds <- readRDS(paste('./data/', input$project, '.rds' , sep=""))
    res <- results(dds)
    resOrdered <- res[order(res$pvalue),]
    resSig <- subset(resOrdered, padj < 0.1)
    results <- data.frame(rownames(resSig))
    results <- subset(results, rownames.resSig. %in% genes$id)
    colnames(results) <- c("Top 5 differently expressed snoRNA genes")
    results <- head(results, 5)
    
  })
  output$top5 <- renderTable({res()}, color="lightblue")
  
  output$projectNumber <- renderText(paste("Number of analysed samples:", projects$NOTE[1]))
  
  selected_gene_info <- reactiveVal("")  # Initialize as empty string
  
  # Detect click event on the table "dynamic" row and show details in the sidebar
  observeEvent(input$dynamic_rows_selected, {
    selected_row <- input$dynamic_rows_selected
    if (length(selected_row) > 0) {
      selected_gene_id <- genes[selected_row, "id"]
      selected_gene_parent_id <- genes[selected_row, "parent_id"]
      selected_gene_parent_name <- genes[selected_row, "parent_name"]
      selected_gene_parent_biotype <- genes[selected_row, "parent_biotype"]
      selected_gene_symbol <- genes[selected_row, "symbol"]
      selected_gene_family <- genes[selected_row, "rfam_family"]
      new_info <- paste("<br>Gene ID:&nbsp;&nbsp;&nbsp;", selected_gene_id, '<br>', 
                        "<br>Gene Symbol:&nbsp;&nbsp;&nbsp;", selected_gene_symbol, '<br>', 
                        "<br>Gene Rfam Family:&nbsp;&nbsp;&nbsp;", selected_gene_family, '<br>', 
                        "<br>Parent Gene ID:&nbsp;&nbsp;&nbsp;", selected_gene_parent_id,'<br>', 
                        "<br>Parent Gene Name:&nbsp;&nbsp;&nbsp;", selected_gene_parent_name,'<br>', 
                        "<br>Parent Gene Biotype:&nbsp;&nbsp;&nbsp;", selected_gene_parent_biotype, "<br><br>")
      selected_gene_info(new_info)  # Update selected_gene_info
    } else {
      selected_gene_info("")  # Clear selected_gene_info if no row is selected
    }
  })
  
  # Handle the download
  output$download_data <- downloadHandler(
    filename = function() {
      selected_row <- input$dynamic_rows_selected
    if (length(selected_row) == 0) {
      return("default.fasta")
    }
    # Generate a dynamic filename based on the selected row's ID or other data
    paste0("Sequence_", genes$id[selected_row], ".fasta")
    },
    content = function(file) {
      selected_row <- input$dynamic_rows_selected
      if (length(selected_row) == 0) {
        return(NULL)
      }
      fasta_header <- paste(">", genes$id[selected_row], sep = "")
      selected_value <- genes$sequence[selected_row]
      fasta_content <- paste(fasta_header, selected_value, sep="\n")
      write(fasta_content, file)
    }
  )
  
  output$button <- renderUI({
    if (!is.null(input$dynamic_rows_selected) && length(input$dynamic_rows_selected) > 0) {
      downloadButton("download_data", "Download FASTA")
    }
  })
  
  output$selected_info <- renderText({
    HTML(selected_gene_info())  # Render selected_gene_info
  })
}

# Create Shiny app ----
shinyApp(ui, server)

