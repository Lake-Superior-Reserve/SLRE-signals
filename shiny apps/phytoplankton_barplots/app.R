# app.R

library(shiny)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

#—— 1) SOURCE YOUR EDI PULL (raw GitHub URL) ————————————————————————
#    This must define: edi_site_info, edi_phyto_shape, edi_phyto
source(
  "https://raw.githubusercontent.com/Lake-Superior-Reserve/SLRE-signals/main/data_wrangling/edi_pull.R",
  local = TRUE
)

#—— 2) ENSURE SAMPLE_DATE IS Date ——————————————————————————————————
if (!inherits(edi_phyto$SAMPLE_DATE, "Date")) {
  edi_phyto <- edi_phyto %>%
    mutate(SAMPLE_DATE = as.Date(SAMPLE_DATE, format = "%m/%d/%Y"))
}

#—— 3) DEFINE CORE 8 SITES ————————————————————————————————————————
core_sites <- c(
  "Allouez Bay", "Miller Creek", "Barker's Island", "North Bay",
  "Pokegama Bay", "Mud Lake", "Billings Park", "Kingsbury Bay"
)

#—— 4) PLOTTING FUNCTION WITH CORE‐SITE LOGIC ————————————————————————
plot_division_stacked <- function(phyto_df, shape_df, site_info_df,
                                  site_names, division_names) {
  # map full site → codes (Mud Lake → MU & MU2)
  site_map   <- setNames(site_info_df$site, site_info_df$Full.Site.Name)
  codes_site <- unlist(lapply(site_names, function(x) {
    if (x == "Mud Lake") {
      c(site_map["Mud Lake West"], site_map["Mud Lake East"])
    } else {
      site_map[x]
    }
  }), use.names = FALSE)
  
  # filter & drop East when West present same date
  df_phyto <- phyto_df %>% filter(site %in% codes_site)
  west_dates <- df_phyto %>%
    filter(site == site_map["Mud Lake West"]) %>%
    pull(SAMPLE_DATE) %>% unique()
  df_phyto <- df_phyto %>%
    filter(!(site == site_map["Mud Lake East"] & SAMPLE_DATE %in% west_dates))
  
  # map division names → DIV codes
  div_map   <- shape_df %>% distinct(DIV, Division)
  name2code <- setNames(div_map$DIV, div_map$Division)
  codes_div <- unname(name2code[division_names])
  
  # reshape + summarize
  df <- df_phyto %>%
    select(SAMPLE_DATE, site, ends_with("_BV")) %>%
    pivot_longer(
      ends_with("_BV"),
      names_to      = "SPPcode",
      names_pattern = "(.*)_BV",
      values_to     = "biovolume"
    ) %>%
    left_join(shape_df %>% select(SPPcode, DIV, Division), by = "SPPcode") %>%
    filter(DIV %in% codes_div) %>%
    group_by(SAMPLE_DATE, site, Division) %>%
    summarise(total_biovolume = sum(biovolume, na.rm = TRUE) / 1e3,
              .groups = "drop") %>%
    left_join(site_info_df %>% select(site, Full.Site.Name), by = "site") %>%
    mutate(Display.Site = ifelse(
      Full.Site.Name %in% c("Mud Lake West","Mud Lake East"),
      "Mud Lake",
      Full.Site.Name
    ))
  
  # custom colors
  base_colors <- c(
    "BAC" = "brown",  "BAP" = "tan",   "CHL" = "green",
    "CHR" = "yellow", "CRY" = "orange","CYA" = "cyan",
    "PRO" = "grey",   "PYR" = "red"
  )
  fill_cols <- setNames(base_colors[codes_div], division_names)
  
  # plot
  ggplot(df, aes(SAMPLE_DATE, total_biovolume, fill = Division)) +
    geom_col(width = 10) +
    scale_fill_manual(name = "Division", values = fill_cols) +
    scale_x_date(
      date_breaks = "2 months",
      date_labels = function(x,...) tolower(format(x, "%b-%y"))
    ) +
    scale_y_continuous(labels = label_comma()) +
    facet_wrap(~ Display.Site, ncol = 1) +
    labs(
      title = paste("Biovolume of", paste(division_names, collapse = ", ")),
      x     = NULL,
      y     = "Total Biovolume (10³ µm³/mL)"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#—— 5) SHINY UI —————————————————————————————————————————————————————
ui <- fluidPage(
  titlePanel("Phytoplankton Biovolume Explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput("sites", "Select site(s):",
                  choices  = core_sites,
                  multiple = TRUE,
                  selected = core_sites[3]),
      selectInput("divisions", "Select division(s):",
                  choices  = unique(edi_phyto_shape$Division),
                  multiple = TRUE,
                  selected = unique(edi_phyto_shape$Division)[1:9])
    ),
    mainPanel(
      plotOutput("bv_plot", height = "600px")
    )
  )
)

#—— 6) SHINY SERVER ——————————————————————————————————————————————————
server <- function(input, output, session) {
  output$bv_plot <- renderPlot({
    req(input$sites, input$divisions)
    plot_division_stacked(
      phyto_df       = edi_phyto,
      shape_df       = edi_phyto_shape,
      site_info_df   = edi_site_info,
      site_names     = input$sites,
      division_names = input$divisions
    )
  })
}

#—— 7) RUN APP —————————————————————————————————————————————————————
shinyApp(ui, server)
