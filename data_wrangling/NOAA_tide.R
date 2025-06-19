# NOAA_tide.R
# Copyright (c) 2025 University of Wisconsin–Madison
# Licensed under the MIT License. See LICENSE file for details.
# script uses httr and jsonlite to pull water level data from the NOAA/NOS/CO-OPs tidal station in Duluth - station id 9099064
# https://tidesandcurrents.noaa.gov/stationhome.html?id=9099064 

# custom function to pull data 
get_water_level <- function(start_date, end_date, station_id = "9099064") {
  url <- paste0(
    "https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?",
    "begin_date=", format(start_date, "%Y%m%d"),
    "&end_date=", format(end_date, "%Y%m%d"),
    "&station=", station_id,
    "&product=water_level", # mean water level at 6 minute intervals
    "&datum=STND",
    "&units=english", #feet, metric is other option
    "&time_zone=lst",
    "&format=json"
  )
  response <- GET(url)
  if (status_code(response) != 200) return(NULL)
  data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  if (!"data" %in% names(data)) return(NULL)
  return(as.data.frame(data$data))
}

# set parameters for function
start <- as.Date("2023-01-01") #change date to what is needed
end <- as.Date("2024-12-31") #change date to what is needed
months_seq <- seq.Date(start, end, by = "month")

#loop function that pulls each month in the data range and binds them together - 6 minute interval data
tide_data <- bind_rows(lapply(seq_along(months_seq[-length(months_seq)]), function(i) {
  message("Getting: ", months_seq[i], " to ", months_seq[i + 1] - 1)
  get_water_level(months_seq[i], months_seq[i + 1] - 1)
}))

#calculates mean daily value
tide_daily <- tide_data %>%
  mutate(t = ymd_hm(t), date = as.Date(t)) %>%
  group_by(date) %>%
  summarize(water_level_m = mean(as.numeric(v), na.rm = TRUE), .groups = "drop")
