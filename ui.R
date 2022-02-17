library(shiny)
library(shinydashboard)
library(reactable)
library(DT)

source("metadata_fields.R")

dashboardPage(
    dashboardHeader(title = "DDPCR app"),
    dashboardSidebar(
        width=200,
        sidebarMenu(
            tags$style(HTML(".sidebar-menu li a { font-size: 18px; }")),
            menuItem("Select Datasets",
                     tabName="select",
                     icon = icon("list-alt", style="color:#42A5F5"))
            )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "select",
                    fluidRow(
                        column(3,
                               textInput("experiment_name",
                                         h4("Experiment Name"))
                               ),
                        column(3,
                               selectInput("user",
                                           h4("User"),
                                           choices = users,
                                           selected=NULL)
                               )
                    ),
                    hr(),
                    fluidRow(
                        column(6,
                               radioButtons("selection",
                                            h4("choose well selection type"),
                                            choices = c("wells",
                                                        "rows",
                                                        "columns"),
                                            selected = 'wells'),
                               conditionalPanel("input.selection == 'wells'",
                                                DTOutput("plateWell")
                                                ),
                               conditionalPanel("input.selection == 'rows'",
                                                checkboxInput("selectAllRows",
                                                              h4("select all rows"),
                                                              FALSE),
                                                DTOutput("plateRow")
                                                ),
                               conditionalPanel("input.selection == 'columns'",
                                                checkboxInput("selectAllCols",
                                                              h4("select all columns"),
                                                              FALSE),
                                                DTOutput("plateCol")
                                                ),
                               verbatimTextOutput("text")
                               ),
                        column(2,
                               textInput("sample_name",
                                         h4("Sample Name"),
                                         "none"),
                               selectInput("sample_type",
                                           h4("Sample Type"),
                                           choices = sample_types,
                                           selected=1),
                               selectInput("DNA_source",
                                           h4("DNA source"),
                                           choices = DNA_sources,
                                           selected=1),
                               numericInput("input_ng",
                                           h4("DNA input (ng)"),
                                           value = 0,
                                           min=0,
                                           step = 0.1,
                                           max = 100),
                               selectInput("assay_type",
                                           h4("Assay Type"),
                                           choices = assay_types,
                                           selected=1),
                               textInput("sample_notes",
                                         h4("Sample Notes (optional)")
                                         )
                               ),
                        column(2,
                               selectInput("process",
                                           h4("Process"),
                                           choices = process,
                                           selected=1),
                               selectInput("provider",
                                           h4("Provider"),
                                           choices = providers,
                                           selected=1),
                               selectInput("preamp",
                                           h4("Pre-Amplification"),
                                           choices = preamp,
                                           selected=1),
                               checkboxInput("add_FF",
                                             h4("Add Fetal Fraction"),
                                             FALSE),
                               conditionalPanel("input.add_FF == true",
                                                numericInput("fetal_fraction",
                                                             h4("Fetal Fraction"),
                                                             value = 0,
                                                             min=0,
                                                             max = 100)
                                                ),
                               checkboxInput("add_spikein",
                                             h4("Add Spikein Sample"),
                                             FALSE),
                               conditionalPanel("input.add_spikein == true",
                                                selectInput("spikein_sample",
                                                            h4("Spikein Sample"),
                                                            choices = spikein_samples,
                                                            selected=1),
                                                numericInput("spikein_ratio",
                                                             h4("Spikein Ratio"),
                                                             value=0,
                                                             step=0.01,
                                                             min=0,
                                                             max=1)
                                                )

                               ),
                        column(2,
                               selectInput("FAM_target",
                                           h4("FAM target"),
                                           choices = accepted_targets,
                                           selected=NULL),
                               selectInput("HEX_target",
                                           h4("HEX target"),
                                           choices = accepted_targets,
                                           selected=NULL),
                               selectInput("Cy5_target",
                                           h4("Cy5 target"),
                                           choices = accepted_targets,
                                           selected=NULL),
                               selectInput("Cy5.5_target",
                                           h4("Cy5.5 target"),
                                           choices = accepted_targets,
                                           selected=NULL)
                               )
                    ),
                    fluidRow(
                        column(6,
                               h3("plate status"),
                               DTOutput("updatedPlate")
                               ),
                        column(3,
                               actionButton("update_metadata",
                                            h4("Update Wells"))
                               ),
                        column(3,
                               actionButton("export",
                                            h4("Export Template"))
                               )

                    )
                    )
        )
    )
)




