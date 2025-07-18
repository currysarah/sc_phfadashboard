#### SETUP ####
library(shiny)
library(rsconnect)
library(conflicted)
library(tidyr)
library(shiny)
library(shinythemes)
library(bslib)
library(leaflet)
library(plotly)
conflicts_prefer(shiny::p)

sidebarPanel2 <-
  function (..., out = NULL, width = 4)
    #for putting logo outside of sidebarpanel
  {
    div(class = paste0("col-sm-", width),
        tags$form(class = "well", ...),
        out)
  }

#### UI ####
ui <- navbarPage(
  theme = shinytheme("flatly"),
  collapsible = TRUE,
  title = strong("Pennsylvania Housing Explorer"),
  windowTitle = "PA Housing Data Explorer",
  ##### Leaflet #####
  tabPanel(
    "PA Mapper",
    tags$head(includeCSS("styles.css")),
    leafletOutput("leaflet", height = "90vh", width = "100%"),
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      top = 110,
      left = 55,
      width = 250,
      fixed = TRUE,
      draggable = TRUE,
      height = "auto",
      h3("Housing Data Mapper"),
      p(
        "Use this web map to explore housing conditions across Pennsylvania counties. For best experience, please view on computer browser."
      ),
      selectInput(
        "variable",
        strong("Select an indicator"),
        choices = list(
          "Homeowners" = list(
            "Homeownership rate (2023)" = "owner_occ_hh_pct2023",
            "White homeownership rate (2023)" = "white_own_occ_hh_pct2023",
            "Black homeownership rate (2023)" = "black_own_occ_hh_pct2023",
            "Hispanic or Latinx homeownership rate (2023)" = "hisp_lat_own_occ_hh_pct2023",
            "Median home value (2023)" = "med_home_value2023",
            "Mortgage burdened households (2023)" = "mortgage_burdened_pct2023"
          ),
          "Renter households" = list(
            "Rentership rate (2023)" = "renter_occ_hh_pct2023",
            "Rent burdened households (2023)" = "rent_burdened_pct2023",
            "Median gross rent (2023)" = "med_gross_rent2023"
          ),
          "Housing stock" = list(
            "Vacant rental units (2023)" = "renter_vacant_pct2023",
            "Median age of home (2023)" = "med_age_home2023",
            # "Affordable rent units available" = "afford_avail_units",
            "Affordable housing shortage (2021)" = "housing_balance",
            "Permits Approved for Residential Untis (2024)" = "totalresunitpermits24"
          ),
          "Other topics" = list("Households with internet access (2023)" = "internet_hh_pct2023")
        ),
        selected = "owner_occ_hh_pct2023"
      ),
      strong("About this indicator"),
      p(textOutput("indicator_desc_text")),
      out =
        img(src = 'logos.png', height = 120)
    )
  ),
  ##### Barplot #####
  tabPanel(
    "County comparisons",
    tags$head(includeCSS("styles.css")),
    sidebarLayout(
      sidebarPanel2(
        width = 3,
        h3("Cross-County Comparisons"),
        selectInput(
          "variable_bar",
          "Select a variable",
          choices = list(
            "Homeowners" = list(
              "Homeownership rate (2023)" = "owner_occ_hh_pct2023",
              "White homeownership rate (2023)" = "white_own_occ_hh_pct2023",
              "Black homeownership rate (2023)" = "black_own_occ_hh_pct2023",
              "Hispanic or Latinx homeownership rate (2023)" = "hisp_lat_own_occ_hh_pct2023",
              "Median home value (2023)" = "med_home_value2023",
              "Mortgage burdened households (2023)" = "mortgage_burdened_pct2023"
            ),
            "Renter households" = list(
              "Rentership rate (2023)" = "renter_occ_hh_pct2023",
              "Rent burdened households (2023)" = "rent_burdened_pct2023",
              "Median gross rent (2023)" = "med_gross_rent2023"
            ),
            "Housing stock" = list(
              "Vacant rental units (2023)" = "renter_vacant_pct2023",
              "Median age of home (2023)" = "med_age_home2023",
              # "Affordable rent units available" = "afford_avail_units",
              "Affordable housing shortage (2021)" = "housing_balance",
              "Permits Approved for Residential Untis (2024)" = "totalresunitpermits24"
            ),
            "Other topics" = list("Households with internet access (2023)" = "internet_hh_pct2023")
          ),
          selected = "owner_occ_hh_pct2023"
        ),
        selectInput(
          "barp_counties",
          "Select counties to show",
          choices = list(
            "Adams",
            "Allegheny",
            "Armstrong",
            "Beaver",
            "Bedford",
            "Berks",
            "Blair",
            "Bradford",
            "Bucks",
            "Butler",
            "Cambria",
            "Cameron",
            "Carbon",
            "Centre",
            "Chester",
            "Clarion",
            "Clearfield",
            "Clinton",
            "Columbia",
            "Crawford",
            "Cumberland",
            "Dauphin",
            "Delaware",
            "Elk",
            "Erie",
            "Fayette",
            "Forest",
            "Franklin",
            "Fulton",
            "Greene",
            "Huntingdon",
            "Indiana",
            "Jefferson",
            "Juniata",
            "Lackawanna",
            "Lancaster",
            "Lawrence",
            "Lebanon",
            "Lehigh",
            "Luzerne",
            "Lycoming",
            "McKean",
            "Mercer",
            "Mifflin",
            "Monroe",
            "Montgomery",
            "Montour",
            "Northampton",
            "Northumberland",
            "Perry",
            "Philadelphia",
            "Pike",
            "Potter",
            "Schuylkill",
            "Snyder",
            "Somerset",
            "Sullivan",
            "Susquehanna",
            "Tioga",
            "Union",
            "Venango",
            "Warren",
            "Washington",
            "Wayne",
            "Westmoreland",
            "Wyoming",
            "York"
          ),
          selected = list("Allegheny", "Cameron", "Dauphin", "Fayette", "Philadelphia", "Potter"),
          multiple = TRUE
        ),
        br(),
        shiny::p(
          "Select an indicator to compare across counties and rural status."
        ),
        out =
          img(src = 'logos.png', height = 120)
      ),
      mainPanel(width = 9, 
              plotlyOutput(
        "plot", height = "700px", width = "100%"
      ))
    )
  ),
  
  ##### Scatterplot #####
  tabPanel("Data plotter",
           sidebarLayout(
             sidebarPanel2(
               width = 3,
               h3("Affordable Housing Explorer"),
               selectInput(
                 "variable_scatter_x",
                 "X variable",
                 choices = list(
                   "Homeowners" = list(
                     "Homeownership rate (2023)" = "owner_occ_hh_pct2023",
                     "White homeownership rate (2023)" = "white_own_occ_hh_pct2023",
                     "Black homeownership rate (2023)" = "black_own_occ_hh_pct2023",
                     "Hispanic or Latinx homeownership rate (2023)" = "hisp_lat_own_occ_hh_pct2023",
                     "Median home value (2023)" = "med_home_value2023",
                     "Mortgage burdened households (2023)" = "mortgage_burdened_pct2023"
                   ),
                   "Renter households" = list(
                     "Rentership rate (2023)" = "renter_occ_hh_pct2023",
                     "Rent burdened households (2023)" = "rent_burdened_pct2023",
                     "Median gross rent (2023)" = "med_gross_rent2023"
                   ),
                   "Housing stock" = list(
                     "Vacant rental units (2023)" = "renter_vacant_pct2023",
                     "Median age of home (2023)" = "med_age_home2023",
                     # "Affordable rent units available" = "afford_avail_units",
                     "Affordable housing shortage (2021)" = "housing_balance",
                     "Permits Approved for Residential Untis (2024)" = "totalresunitpermits24"
                   ),
                   "Other topics" = list("Households with internet access (2023)" = "internet_hh_pct2023")
                 ),
                 selected = "owner_occ_hh_pct2023"
               ),
               selectInput(
                 "variable_scatter_y",
                 "Y variable",
                 choices = list(
                   "Homeowners" = list(
                     "Homeownership rate (2023)" = "owner_occ_hh_pct2023",
                     "White homeownership rate (2023)" = "white_own_occ_hh_pct2023",
                     "Black homeownership rate (2023)" = "black_own_occ_hh_pct2023",
                     "Hispanic or Latinx homeownership rate (2023)" = "hisp_lat_own_occ_hh_pct2023",
                     "Median home value (2023)" = "med_home_value2023",
                     "Mortgage burdened households (2023)" = "mortgage_burdened_pct2023"
                   ),
                   "Renter households" = list(
                     "Rentership rate (2023)" = "renter_occ_hh_pct2023",
                     "Rent burdened households (2023)" = "rent_burdened_pct2023",
                     "Median gross rent (2023)" = "med_gross_rent2023"
                   ),
                   "Housing stock" = list(
                     "Vacant rental units (2023)" = "renter_vacant_pct2023",
                     "Median age of home (2023)" = "med_age_home2023",
                     # "Affordable rent units available" = "afford_avail_units",
                     "Affordable housing shortage (2021)" = "housing_balance",
                     "Permits Approved for Residential Untis (2024)" = "totalresunitpermits24"
                   ),
                   "Other topics" = list("Households with internet access (2023)" = "internet_hh_pct2023")
                 ),
                 selected = "owner_occ_hh_pct2023"
               ),
               shiny::p(
                 "Use this scatter plot to visualize the relationship between any two housing indicators. Click on the home icon to reset zoom/axes."
               ),
               out =
                 img(src = 'logos.png', height = 120)
             ),
             mainPanel(
               width = 9,
               br(),
               plotlyOutput("scatter", height = "600px", width = "100%")
             )
           )),
  ##### Data download #####
  tabPanel("Data",
           sidebarLayout(
             sidebarPanel2(
               width = 3,
               h3("Data Viewer and Download"),
               selectInput(
                 "variable_tab",
                 "Select a variable",
                 choices = list(
                   "Homeowners" = list(
                     "Homeownership rate (2023)" = "owner_occ_hh_pct2023",
                     "White homeownership rate (2023)" = "white_own_occ_hh_pct2023",
                     "Black homeownership rate (2023)" = "black_own_occ_hh_pct2023",
                     "Hispanic or Latinx homeownership rate (2023)" = "hisp_lat_own_occ_hh_pct2023",
                     "Median home value (2023)" = "med_home_value2023",
                     "Mortgage burdened households (2023)" = "mortgage_burdened_pct2023"
                   ),
                   "Renter households" = list(
                     "Rentership rate (2023)" = "renter_occ_hh_pct2023",
                     "Rent burdened households (2023)" = "rent_burdened_pct2023",
                     "Median gross rent (2023)" = "med_gross_rent2023"
                   ),
                   "Housing stock" = list(
                     "Vacant rental units (2023)" = "renter_vacant_pct2023",
                     "Median age of home (2023)" = "med_age_home2023",
                     # "Affordable rent units available" = "afford_avail_units",
                     "Affordable housing shortage (2021)" = "housing_balance",
                     "Permits Approved for Residential Untis (2024)" = "totalresunitpermits24"
                   ),
                   "Other topics" = list("Households with internet access (2023)" = "internet_hh_pct2023")
                 ),
                 selected = "owner_occ_hh_pct2023"
               ),
               shiny::p(
                 "Use this table to view data for any indicator by county. Data used in this dashboard can be downloaded as a CSV file."
               ),
               out =
                 img(src = 'logos.png', height = 120)
             ),
             mainPanel(
               width = 9,
               h4(textOutput("tableheader")),
               DT::dataTableOutput("table"),
               br(),
               tableOutput("sum"),
               br(),
               downloadButton("downloadDataAll", "All indicators")
             )
           )),
  ##### About #####
  tabPanel("About this site",
           sidebarLayout(
             sidebarPanel(
               img(src = 'PA.png', width = "100%"),
               p("Source: The Brookings Institute.")
             ),
             mainPanel(
               h2("Pennsylvania Housing Explorer"),
               p("Last update: July 1, 2025"),
               p(
                 "This dashboard is a collaboration between the Pennsylvania Housing Finance Agency and the Housing Initiative at Penn. The dashboard shows current housing trends across Pennsylvania counties based on data from the U.S. Census Bureau 5-year American Community Survey and U.S. Department of Housing and Urban Development’s Comprehensive Housing Affordability Strategy."
               ),
               h4("About Pennsylvania Housing Finance Agency"),
               p(
                 "The",
                 a(href = "https://www.phfa.org/", "Pennsylvania Housing Finance Agency"),
                 " works to provide affordable homeownership and rental apartment options for older adults, low- and moderate-income families, and people with special housing needs. Through its carefully managed mortgage programs and investments in multifamily housing developments, as well as funding provided for community development projects, PHFA also promotes economic development across the Commonwealth."
               ),
               h4("About Housing Initiative at Penn"),
               p(
                 "The",
                 a(href = 'https://www.housinginitiative.org/', 'Housing Initiative at Penn'),
                 " is a housing policy research initiative based in the University of Pennsylvania's Weitzman School of Design. We conduct rigorous academic and empirical research that advances evidence-based policymaking and analyze current conditions and future trends with the potential to affect housing. Our mission is to achieve more effective, equitable housing policy at the local, state, and national levels."
               ),
               h4("Methods"),
               p(
                 "All data in this dashboard comes from the",
                 a(href = "https://www.census.gov/programs-surveys/acs/news/data-releases.2023.html#list-tab-1133175109", "American Community Survey's"),
                 " 2023 5-year-estimates, with the exception of the Affordable Housing Shortage variable, which is from HUD’s Comprehensive Housing Affordability Strategy dataset (2021). All census data was accessed through the US Census Bureau API using the tidycensus package in R. All data processing and preparation was completed using the following R packages: dplyr, tigris, sf, stringr, tidyr. This dashboard was made entirely using the R-language in Posit's Shiny app interface, and visualizations were made using the R packages leaflet, plotly, ggplot2, and pander. Full documentation for this project can be found here:",
                 a(href = 'https://github.com/housinginitiative/PHFA-Housing-Dash', 'github repository')
               ),
               h4("Get in touch"),
               p(
                 HTML(
                   "For questions about this dashboard, please contact
        Rebecca Yae, Director, at
        <a href='mailto:ryae@design.upenn.edu'>ryae@design.upenn.edu</a>
        and/or Amy Sechrist, Senior Policy Officer, at
        <a href='mailto:asechrist@phfa.org'>asechrist@phfa.org</a>"
                 )
               ),
        img(src = 'hip_logo.png', height = 140),
        img(src = 'phfa_logo.png', height = 140)
             )
           ))
)

