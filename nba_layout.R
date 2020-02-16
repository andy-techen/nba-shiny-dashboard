sidebar <-
  dashboardSidebar(
    width = 200,
    textInput("player", "Enter Full Name", value = "Kobe Bryant"),
    textInput("player2", "Head-to-Head", value = "LeBron James"),
    selectInput(
      "attribute",
      "Select Attribute",
      choices = c(
        "G", "MP", "FGA", "FG%", "3PA", "3P%", "FT%",
        "TRB", "AST", "STL", "BLK", "TOV", "PTS"
      ),
      selected = "PTS"
    ),
    actionButton(inputId = "compare", label = "Compare!")
  )

body <-
  dashboardBody(tabBox(
    width = 12,
    tabPanel(
      "Stat Searcher",
      fluidRow(column(
        width = 12,
        strong(textOutput("title"), style = "font-size: 18px;"),
        dataTableOutput("stats_tb")
      )),
      fluidRow(
        column(width = 8, plotlyOutput("attr_line", height = "280px")),
        br(),
        column(
          width = 4,
          valueBoxOutput("fantasy",
                         width = 12),
          valueBoxOutput("fantasy2",
                         width = 12)
        )
      )
    ),
    tabPanel(
      "Team Builder",
      fluidRow(
        column(width = 1),
        column(width = 2, textInput("pg", "PG", value = "LeBron James")),
        column(width = 2, textInput("sg", "SG", value = "Danny Green")),
        column(width = 2, textInput("sf", "SF", value = "Kyle Kuzma")),
        column(width = 2, textInput("pf", "PF", value = "Anthony Davis")),
        column(width = 2, textInput("c", "C", value = "JaVale McGee"))
      ),
      br(),
      fluidRow(
        column(width = 1),
        column(width = 2, htmlOutput("pg_img")),
        column(width = 2, htmlOutput("sg_img")),
        column(width = 2, htmlOutput("sf_img")),
        column(width = 2, htmlOutput("pf_img")),
        column(width = 2, htmlOutput("c_img"))
      ),
      fluidRow(
        column(width = 1),
        column(width = 2, tableOutput("pg_f")),
        column(width = 2, tableOutput("sg_f")),
        column(width = 2, tableOutput("sf_f")),
        column(width = 2, tableOutput("pf_f")),
        column(width = 2, tableOutput("c_f"))
      ),
      br(),
      fluidRow(
        column(width = 3),
        column(
          width = 2,
          br(),
          br(),
          actionButton(inputId = "build", label = "Build Team!")
        ),
        column(width = 4, valueBoxOutput("team_fantasy", width = 12))
      )
    )
  ))