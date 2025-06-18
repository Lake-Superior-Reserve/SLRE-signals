#phyto_bar_plot.R
# Copyright (c) 2025 University of Wisconsin–Madison
# Licensed under the MIT License. See LICENSE file for details.

#!!FIRST make sure you run edi_pull and have edi_phyto, edi_phyto_shape, and edi_site_info tibbles loaded in your environment

plot_division_stacked <- function(phyto_df, shape_df, site_info_df,
                                  site_names, division_names) {
  # — map full site names → codes —
  name_to_code_site <- setNames(site_info_df$site,
                                site_info_df$Full.Site.Name)
  if (!all(site_names %in% names(name_to_code_site))) {
    stop("One or more `site_names` not found in site_info_df$Full.Site.Name")
  }
  site_codes <- unname(name_to_code_site[site_names])
  
  # — map full division names → codes —
  div_map <- shape_df %>% distinct(DIV, Division)
  name_to_code_div <- setNames(div_map$DIV, div_map$Division)
  if (!all(division_names %in% names(name_to_code_div))) {
    stop("One or more `division_names` not found in shape_df$Division")
  }
  div_codes <- unname(name_to_code_div[division_names])
  
  # — prepare color map for the selected divisions —
  div_colors <- c(
    "BAC" = "brown",  "BAP" = "tan",   "CHL" = "green",
    "CHR" = "yellow", "CRY" = "orange","CYA" = "cyan",
    "PRO" = "grey",   "PYR" = "red"
  )
  full_div_colors <- setNames(div_colors[div_codes], division_names)
  
  # — reshape, join, filter, aggregate by site & division —
  df <- phyto_df %>%
    filter(site %in% site_codes) %>%
    select(SAMPLE_DATE, site, ends_with("_BV")) %>%
    pivot_longer(
      cols          = ends_with("_BV"),
      names_to      = "SPPcode",
      names_pattern = "(.*)_BV",
      values_to     = "biovolume"
    ) %>%
    left_join(
      shape_df %>% select(SPPcode, DIV, Division),
      by = "SPPcode"
    ) %>%
    filter(DIV %in% div_codes) %>%
    group_by(SAMPLE_DATE, site, Division) %>%
    summarise(
      total_biovolume = sum(biovolume, na.rm = TRUE) / 1e3,
      .groups         = "drop"
    ) %>%
    left_join(
      site_info_df %>% select(site, Full.Site.Name),
      by = "site"
    )
  
  # — plotting —
  ggplot(df, aes(x = SAMPLE_DATE, 
                 y = total_biovolume, 
                 fill = Division)) +
    geom_col() +
    scale_fill_manual(name = "Division", values = full_div_colors) +
    scale_x_date(
      date_breaks = "2 months",
      date_labels = function(x, ...) tolower(format(x, "%b-%y"))
    ) +
    scale_y_continuous(labels = scales::label_comma()) +
    facet_wrap(~ Full.Site.Name, ncol = 1) +
    labs(
      title = paste("Biovolume of",
                    paste(division_names, collapse = ", "),
                    "by Site"),
      x     = NULL,
      y     = "Total Biovolume (×10³ µm³/mL)"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
}

plot_division_stacked(
  phyto_df       = edi_phyto,
  shape_df       = edi_phyto_shape,
  site_info_df   = edi_site_info,
  site_names     = c("Allouez Bay", "Billings Park"),
  division_names = c("centric diatoms",
                     "pennate diatoms",
                     "cyanobacteria")
)
