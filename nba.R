library(shiny)
library(rvest)
library(DT)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(stringr)
library(tibble)
library(ggplot2)
library(plotly)

source("nba_func.R")
source("nba_layout.R")

ui <-
  dashboardPage(
    header <-
      dashboardHeader(title = "NBA Fantasy DB", titleWidth = 200),
    sidebar <- sidebar,
    body <- body
  )

server <- function(input, output) {
  output$title <- renderText({
    input$compare
    isolate({
      paste0(input$player, "'s Career Stats")
    })
  })
  br_stats <- reactive({
    br_getstats(input$player)
  })
  output$stats_tb <-
    renderDataTable({
      input$compare
      isolate({
        datatable(br_stats(), options = list(pageLength = 5, dom = 'tp'))
      })
    })
  br_stats2 <- reactive({
    br_getstats(input$player2)
  })
  
  br_line <- reactive({
    if (input$player2 == "") {
      br_stats() %>%
        ggplot(aes(x = c(1:nrow(.)),
                   y = get(input$attribute))) +
        geom_point(color = '#3C8DBC') +
        geom_line(color = '#3C8DBC') +
        labs(title = input$attribute,
             x = "Season",
             y = input$attribute) +
        scale_x_continuous(breaks = seq(1, 30, 1)) +
        theme_classic() +
        theme(plot.title = element_text(face = "bold"))
    } else {
      ggplot() +
        geom_point(aes(
          x = c(1:nrow(br_stats())),
          y = get(input$attribute),
          color = input$player
        ), data = br_stats()) +
        geom_line(aes(
          x = c(1:nrow(br_stats())),
          y = get(input$attribute),
          color = input$player
        ), data = br_stats()) +
        geom_point(aes(
          x = c(1:nrow(br_stats2())),
          y = get(input$attribute),
          color = input$player2
        ), data = br_stats2()) +
        geom_line(aes(
          x = c(1:nrow(br_stats2())),
          y = get(input$attribute),
          color = input$player2
        ), data = br_stats2()) +
        labs(
          title = input$attribute,
          x = "Season",
          y = input$attribute,
          color = NULL
        ) +
        scale_x_continuous(breaks = seq(1, 30, 1)) +
        theme_classic() +
        scale_color_manual(values = c("#222D32", "#3C8DBC")) +
        theme(plot.title = element_text(face = "bold"))
    }
  })
  output$attr_line <-
    renderPlotly({
      input$compare
      isolate({
        ggplotly(br_line(), tooltip = NULL) %>% layout(legend = list(
          orientation = "v",
          x = 0.8,
          y = 1.1,
          font = list(size = 10)
        ))
      })
    })
  
  output$fantasy <- renderValueBox({
    input$compare
    isolate({
      valueBox(
        value = f_formula(br_stats()),
        subtitle = paste0(input$player, "'s Fantasy Score"),
        icon = icon("basketball-ball"),
        color = 'light-blue'
      )
    })
  })
  output$fantasy2 <- renderValueBox({
    input$compare
    isolate({
      if (input$player2 != "") {
        valueBox(
          value = f_formula(br_stats2()),
          subtitle = paste0(input$player2, "'s Fantasy Score"),
          icon = icon("basketball-ball"),
          color = 'light-blue'
        )
      } else {
        valueBox(value = "",
                 subtitle = "",
                 color = 'light-blue')
      }
    })
  })
  
  output$pg_img <- renderText({
    input$build
    isolate({
      c('<img src="', br_getimage(input$pg), '">')
    })
  })
  output$sg_img <- renderText({
    input$build
    isolate({
      c('<img src="', br_getimage(input$sg), '">')
    })
  })
  output$sf_img <- renderText({
    input$build
    isolate({
      c('<img src="', br_getimage(input$sf), '">')
    })
  })
  output$pf_img <- renderText({
    input$build
    isolate({
      c('<img src="', br_getimage(input$pf), '">')
    })
  })
  output$c_img <- renderText({
    input$build
    isolate({
      c('<img src="', br_getimage(input$c), '">')
    })
  })
  
  output$pg_f <- renderTable({
    input$build
    isolate({
      br_getcareer(input$pg)
    })
  }, rownames = T)
  output$sg_f <- renderTable({
    input$build
    isolate({
      br_getcareer(input$sg)
    })
  }, rownames = T)
  output$sf_f <- renderTable({
    input$build
    isolate({
      br_getcareer(input$sf)
    })
  }, rownames = T)
  output$pf_f <- renderTable({
    input$build
    isolate({
      br_getcareer(input$pf)
    })
  }, rownames = T)
  output$c_f <- renderTable({
    input$build
    isolate({
      br_getcareer(input$c)
    })
  }, rownames = T)
  output$team_fantasy <- renderValueBox({
    input$build
    isolate({
      valueBox(
        value = f_formula(br_getstats(input$pg)) +
          f_formula(br_getstats(input$sg)) +
          f_formula(br_getstats(input$sf)) +
          f_formula(br_getstats(input$pf)) +
          f_formula(br_getstats(input$c)),
        subtitle = "Total Fantasy Score",
        icon = icon("basketball-ball"),
        color = 'light-blue'
      )
    })
  })
}

shinyApp(ui = ui, server = server)