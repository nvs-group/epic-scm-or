library(shiny)
library(bslib)
library(DT)
library(dplyr)

# Runs the full validated data pipeline (filter, join, assertions) on
# every app start. If a future data_raw/ refresh breaks the join, the
# stopifnot() checks in data_prep.R will fail here with a clear message
# instead of the app silently launching with bad data.
source("data_prep.R")

ui <- page_sidebar(
  title = "EPIC: SCM & OR Career Explorer",
  sidebar = sidebar(
    p("Explore schools and careers in Supply Chain Management and",
      "Operations Research."),
    p(em("Scenario comparison coming in a later step."))
  ),
  navset_tab(
    nav_panel(
      "Explore Programs",
      DTOutput("programs_table")
    ),
    nav_panel(
      "Explore Careers",
      DTOutput("careers_table")
    )
  )
)

server <- function(input, output, session) {
  
  output$programs_table <- renderDT({
    explore_programs %>%
      select(-UNITID, -CIPCODE, -AWLEVEL) %>%
      datatable(
        rownames = FALSE,
        options = list(pageLength = 15, scrollX = TRUE),
        colnames = c(
          "School", "City", "State", "Program", "Degree Level",
          "Out-of-State Cost (Low)", "Out-of-State Cost (High)",
          "In-State Cost (Low)", "In-State Cost (High)",
          "% Receiving Grant Aid", "% Grad. within 150% Time"
        )
      )
  })
  
  output$careers_table <- renderDT({
    explore_careers %>%
      select(-OCCCODE) %>%
      datatable(
        rownames = FALSE,
        options = list(pageLength = 10, scrollX = TRUE),
        colnames = c(
          "Occupation", "Entry Salary (17th pctl)", "Median Salary",
          "High Salary (82nd pctl)", "Projected Growth %",
          "Typical Entry Degree", "Experience Typically Required"
        )
      )
  })
  
}

shinyApp(ui, server)