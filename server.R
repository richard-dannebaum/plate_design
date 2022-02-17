library(shiny)
library(DT)
library(data.table)

rows <- c("A", "B", "C", "D", "E", "F", "G", "H")
cols <- ifelse(nchar(cols) == 1, paste0("0", cols), as.character(cols))
allWells <- apply(expand.grid(rows, cols), 1, function(x) paste(x, collapse=""))

mat <- matrix(nrow=8, ncol=12, 0)
rownames(mat) <- c("A", "B", "C", "D", "E", "F", "G", "H")
cols <- ifelse(nchar(cols) == 1, paste0("0", cols), as.character(cols))
colnames(mat) <- cols


server <- function(input, output, session){

    plate <- reactiveValues()
    plate$dt <- data.table(experiment_name = "",
                           user = "",
                           WellName = allWells,
                           sample_name = "none",
                           sample_type = "none",
                           DNA_source = "none",
                           input_ng = 0,
                           provider = "none",
                           process = "none",
                           preamp = "none",
                           fetal_fraction = 0,
                           spikein_sample = "none",
                           spikein_ratio = 0,
                           primer_set = "none",
                           assay_type = "none",
                           FAM_target = "none",
                           HEX_target = "none",
                           Cy5_target = "none",
                           Cy5.5_target = "none",
                           notes = "")[order(WellName)]

    plate$select <- mat

    output$plateWell <- DT::renderDataTable(plate$select,
                                            server=FALSE,
                                            selection = list(mode="multiple",target="cell"),
                                            width="100%"
                                            )

    output$plateRow <- DT::renderDataTable(plate$select,
                                        server=FALSE,
                                        selection = list(mode="multiple",target="row"),
                                        width="100%"
                                        )

    output$plateCol <- DT::renderDataTable(plate$select,
                                           server=FALSE,
                                           selection = list(mode="multiple",target="column"),
                                           width="100%"
                                           )


    plateRow_proxy <- DT::dataTableProxy("plateRow")
    observeEvent(input$selectAllRows, {
        if(isTRUE(input$selectAllRows)){
            DT::selectRows(plateRow_proxy, input$plateRow_rows_all)
        } else {
            DT::selectRows(plateRow_proxy, NULL)
        }
    })

    plateCol_proxy <- DT::dataTableProxy("plateCol")
    observeEvent(input$selectAllCols, {
        if(isTRUE(input$selectAllCols)){
            DT::selectRows(plateCol_proxy, input$plateCol_columns_all)
        } else {
            DT::selectRows(plateCol_proxy, NULL)
        }
    })


    getSelected <- reactive({
        rows <- c("A", "B", "C", "D", "E", "F", "G", "H")
        cols <- ifelse(nchar(cols) == 1, paste0("0", cols), as.character(cols))

        if(input$selection == "wells"){
            req(input$plateWell_cells_selected)
            tab  <- input$plateWell_cells_selected
            selected  <-  apply(tab, 1, function(x) paste(rows[x[1]], cols[x[2]]))
            selected <- sub(" ", "", selected)
            return(selected)
        }
        if(input$selection == "rows"){
            rowSelect <- rows[input$plateRow_rows_selected]
            selected <- apply(expand.grid(rowSelect, cols), 1, function(x) paste(x, collapse=""))
            return(selected)
        }
        if(input$selection == "columns"){
            colSelect <- cols[input$plateCol_columns_selected]
            selected <- apply(expand.grid(rows, colSelect), 1, function(x) paste(x, collapse=""))
            return(selected)
        }
    })


    output$updatedPlate <- DT::renderDataTable(plate$dt,
                                               server=TRUE,
                                               width="100%"
                                               )



    observeEvent(input$update_metadata, {
        selectedWells <- getSelected()
        shiny::validate(need(length(selectedWells) > 0, "No Wells selected"))
        update  <-  data.table(experiment_name = input$experiment_name,
                               user = input$user,
                               WellName = selectedWells,
                               sample_name = input$sample_name,
                               sample_type = input$sample_type,
                               DNA_source =  input$DNA_source,
                               input_ng = input$input_ng,
                               provider = input$provider,
                               process = input$process,
                               preamp = input$preamp,
                               fetal_fraction = input$fetal_fraction,
                               spikein_sample = input$spikein_sample,
                               spikein_ratio = input$spikein_ratio,
                               primer_set = "none",
                               assay_type = input$assay_type,
                               FAM_target = input$FAM_target,
                               HEX_target = input$HEX_target,
                               Cy5_target = input$Cy5_target,
                               Cy5.5_target = input$Cy5.5_target,
                               notes = input$sample_notes)
        updated <- rbind(plate$dt[!WellName %in% selectedWells], update)
        plate$dt <- updated[order(WellName)]
        byRow <- substring(selectedWells, 1, 1)
        byCol <- substring(selectedWells, 2, 3)
        plate$select[match(byRow, rownames(plate$select)), match(byCol, colnames(plate$select))] <- input$sample_type

    })




}
